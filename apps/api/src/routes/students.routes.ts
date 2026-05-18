import { Router, Response } from 'express';
import { verifyToken, AuthRequest } from '../middlewares/auth.middleware';
import prisma from '../config/db';
import bcrypt from 'bcrypt';

const router = Router();

// Apply auth middleware to all student routes
router.use(verifyToken);

const studentDetailsInclude = {
  class_sections: true,
  student_guardians: {
    include: {
      guardians: true
    }
  }
};

const generateTemporaryPassword = () => {
  return Math.random().toString(36).slice(2, 8).toUpperCase();
};

const ensureUserRole = async (tx: any, userId: string, schoolId: string, role: string) => {
  const existingRole = await tx.user_roles.findFirst({
    where: {
      user_id: userId,
      school_id: schoolId,
      role
    }
  });

  if (!existingRole) {
    await tx.user_roles.create({
      data: {
        user_id: userId,
        school_id: schoolId,
        role
      }
    });
  }
};

const ensureGuardianUser = async (
  tx: any,
  schoolId: string,
  guardianData: {
    userId?: string | null;
    name: string;
    dni: string;
    email?: string | null;
    phone?: string | null;
  },
  passwordHash?: string
) => {
  const existingUser = guardianData.userId
    ? await tx.users.findUnique({ where: { id: guardianData.userId } })
    : await tx.users.findFirst({
        where: {
          school_id: schoolId,
          OR: [
            { document_number: guardianData.dni },
            ...(guardianData.email ? [{ email: guardianData.email }] : [])
          ]
        }
      });

  const user = existingUser
    ? await tx.users.update({
        where: { id: existingUser.id },
        data: {
          email: guardianData.email,
          document_number: guardianData.dni,
          full_name: guardianData.name,
          phone: guardianData.phone,
          ...(passwordHash ? { password_hash: passwordHash, status: 'active' } : {})
        }
      })
    : await tx.users.create({
        data: {
          school_id: schoolId,
          email: guardianData.email,
          document_number: guardianData.dni,
          full_name: guardianData.name,
          phone: guardianData.phone,
          password_hash: passwordHash,
          status: passwordHash ? 'active' : 'invited'
        }
      });

  await ensureUserRole(tx, user.id, schoolId, 'guardian');
  return user;
};

// Get all students for a school
router.get('/', async (req: AuthRequest, res: Response) => {
  try {
    const schoolId = req.user?.schoolId;
    if (!schoolId) {
      return res.status(401).json({ success: false, message: 'Invalid session' });
    }

    const students = await prisma.students.findMany({
      where: { school_id: schoolId },
      include: studentDetailsInclude,
      orderBy: { full_name: 'asc' }
    });
    res.json({ success: true, data: students });
  } catch (error) {
    console.error('Failed to fetch students:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch students' });
  }
});

router.post('/', async (req: AuthRequest, res: Response) => {
  try {
    const schoolId = req.user?.schoolId;
    if (!schoolId) {
      return res.status(401).json({ success: false, message: 'Invalid session' });
    }

    const { student, parent } = req.body ?? {};
    const fullName = String(student?.name ?? '').trim();
    const grade = String(student?.grade ?? '').trim();
    const faceImage = student?.faceImage ? String(student.faceImage) : null;

    const parentName = String(parent?.name ?? '').trim();
    const parentDni = String(parent?.dni ?? '').trim();
    const parentEmail = parent?.email ? String(parent.email).trim() : null;
    const parentPhone = parent?.phone ? String(parent.phone).trim() : null;

    if (!fullName) {
      return res.status(400).json({ success: false, message: 'Student name is required' });
    }

    if (!parentName || !parentDni) {
      return res.status(400).json({ success: false, message: 'Parent name and DNI are required' });
    }

    const createdStudent = await prisma.$transaction(async (tx) => {
      const classSection = grade
        ? await tx.class_sections.findFirst({
            where: {
              school_id: schoolId,
              OR: [
                { display_name: { equals: grade, mode: 'insensitive' } },
                { name: { equals: grade, mode: 'insensitive' } }
              ]
            }
          })
        : null;

      const newStudent = await tx.students.create({
        data: {
          school_id: schoolId,
          current_section_id: classSection?.id,
          student_code: `WEB-${Date.now().toString(36).toUpperCase()}`,
          full_name: fullName,
          photo_url: faceImage,
          metadata: {
            registered_grade_label: grade || null
          }
        }
      });

      const existingGuardian = await tx.guardians.findFirst({
        where: {
          school_id: schoolId,
          document_number: parentDni
        }
      });

      const guardian = existingGuardian
        ? await tx.guardians.update({
            where: { id: existingGuardian.id },
            data: {
              full_name: parentName,
              email: parentEmail,
              phone: parentPhone
            }
          })
        : await tx.guardians.create({
            data: {
              school_id: schoolId,
              full_name: parentName,
              document_number: parentDni,
              email: parentEmail,
              phone: parentPhone
            }
          });

      const guardianUser = await ensureGuardianUser(tx, schoolId, {
        userId: guardian.user_id,
        name: parentName,
        dni: parentDni,
        email: parentEmail,
        phone: parentPhone
      });

      await tx.guardians.update({
        where: { id: guardian.id },
        data: { user_id: guardianUser.id }
      });

      await tx.student_guardians.create({
        data: {
          student_id: newStudent.id,
          guardian_id: guardian.id,
          relationship: 'tutor',
          is_primary: true,
          receives_notifications: true
        }
      });

      return tx.students.findUniqueOrThrow({
        where: { id: newStudent.id },
        include: studentDetailsInclude
      });
    });

    res.status(201).json({ success: true, data: createdStudent });
  } catch (error) {
    console.error('Failed to create student:', error);
    res.status(500).json({ success: false, message: 'Failed to create student' });
  }
});

router.post('/:studentId/parent-access', async (req: AuthRequest, res: Response) => {
  try {
    const schoolId = req.user?.schoolId;
    if (!schoolId) {
      return res.status(401).json({ success: false, message: 'Invalid session' });
    }

    const student = await prisma.students.findFirst({
      where: {
        id: req.params.studentId,
        school_id: schoolId
      },
      include: studentDetailsInclude
    });

    if (!student) {
      return res.status(404).json({ success: false, message: 'Student not found' });
    }

    const guardianLink = student.student_guardians.find((link) => link.is_primary)
      ?? student.student_guardians[0];

    if (!guardianLink?.guardians) {
      return res.status(400).json({ success: false, message: 'Student has no guardian registered' });
    }

    const guardian = guardianLink.guardians;
    const password = generateTemporaryPassword();
    const passwordHash = await bcrypt.hash(password, 10);

    const updatedStudent = await prisma.$transaction(async (tx) => {
      const user = await ensureGuardianUser(tx, schoolId, {
        userId: guardian.user_id,
        name: guardian.full_name,
        dni: guardian.document_number,
        email: guardian.email,
        phone: guardian.phone
      }, passwordHash);

      await tx.guardians.update({
        where: { id: guardian.id },
        data: {
          user_id: user.id,
          app_access_enabled: true
        }
      });

      return tx.students.findUniqueOrThrow({
        where: { id: student.id },
        include: studentDetailsInclude
      });
    });

    res.json({
      success: true,
      data: updatedStudent,
      credentials: {
        username: guardian.email || guardian.document_number,
        password
      }
    });
  } catch (error) {
    console.error('Failed to generate guardian access:', error);
    res.status(500).json({ success: false, message: 'Failed to generate guardian access' });
  }
});

export default router;
