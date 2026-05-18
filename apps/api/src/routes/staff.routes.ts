import { Router, Response } from 'express';
import { verifyToken, AuthRequest } from '../middlewares/auth.middleware';
import prisma from '../config/db';
import bcrypt from 'bcrypt';

const router = Router();

router.use(verifyToken);

const staffDetailsInclude = {
  class_sections: true
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

const ensureStaffUser = async (
  tx: any,
  schoolId: string,
  staffData: {
    userId?: string | null;
    name: string;
    email: string;
    phone?: string | null;
  },
  passwordHash?: string
) => {
  const existingUser = staffData.userId
    ? await tx.users.findUnique({ where: { id: staffData.userId } })
    : await tx.users.findFirst({
        where: {
          school_id: schoolId,
          email: staffData.email
        }
      });

  const user = existingUser
    ? await tx.users.update({
        where: { id: existingUser.id },
        data: {
          email: staffData.email,
          full_name: staffData.name,
          phone: staffData.phone,
          ...(passwordHash ? { password_hash: passwordHash, status: 'active' } : {})
        }
      })
    : await tx.users.create({
        data: {
          school_id: schoolId,
          email: staffData.email,
          full_name: staffData.name,
          phone: staffData.phone,
          password_hash: passwordHash,
          status: passwordHash ? 'active' : 'invited'
        }
      });

  await ensureUserRole(tx, user.id, schoolId, 'teacher');
  return user;
};

router.get('/', async (req: AuthRequest, res: Response) => {
  try {
    const schoolId = req.user?.schoolId;
    if (!schoolId) {
      return res.status(401).json({ success: false, message: 'Invalid session' });
    }

    const staff = await prisma.staff_members.findMany({
      where: {
        school_id: schoolId,
        status: 'active'
      },
      include: staffDetailsInclude,
      orderBy: { full_name: 'asc' }
    });

    res.json({ success: true, data: staff });
  } catch (error) {
    console.error('Failed to fetch staff:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch staff' });
  }
});

router.post('/', async (req: AuthRequest, res: Response) => {
  try {
    const schoolId = req.user?.schoolId;
    if (!schoolId) {
      return res.status(401).json({ success: false, message: 'Invalid session' });
    }

    const name = String(req.body?.name ?? '').trim();
    const email = String(req.body?.email ?? '').trim();
    const phone = String(req.body?.phone ?? '').trim();
    const course = String(req.body?.course ?? '').trim();

    if (!name || !email || !course) {
      return res.status(400).json({ success: false, message: 'Name, email and course are required' });
    }

    const createdStaff = await prisma.$transaction(async (tx) => {
      const classSection = await tx.class_sections.findFirst({
        where: {
          school_id: schoolId,
          OR: [
            { display_name: { equals: course, mode: 'insensitive' } },
            { name: { equals: course, mode: 'insensitive' } }
          ]
        }
      });

      if (classSection?.homeroom_teacher_id) {
        throw new Error(`Ya existe un maestro asignado al curso: ${course}`);
      }

      const existingByCourseLabel = !classSection
        ? await tx.staff_members.findFirst({
            where: {
              school_id: schoolId,
              status: 'active',
              metadata: {
                path: ['assigned_course_label'],
                equals: course
              }
            }
          })
        : null;

      if (existingByCourseLabel) {
        throw new Error(`Ya existe un maestro asignado al curso: ${course}`);
      }

      const staff = await tx.staff_members.create({
        data: {
          school_id: schoolId,
          employee_code: `WEB-${Date.now().toString(36).toUpperCase()}`,
          full_name: name,
          email,
          phone,
          kind: 'teacher',
          status: 'active',
          metadata: {
            assigned_course_label: course
          }
        }
      });

      const user = await ensureStaffUser(tx, schoolId, {
        name,
        email,
        phone,
        userId: staff.user_id
      });

      await tx.staff_members.update({
        where: { id: staff.id },
        data: { user_id: user.id }
      });

      if (classSection) {
        await tx.class_sections.update({
          where: { id: classSection.id },
          data: { homeroom_teacher_id: staff.id }
        });
      }

      return tx.staff_members.findUniqueOrThrow({
        where: { id: staff.id },
        include: staffDetailsInclude
      });
    });

    res.status(201).json({ success: true, data: createdStaff });
  } catch (error: any) {
    console.error('Failed to create staff:', error);
    res.status(400).json({ success: false, message: error.message || 'Failed to create staff' });
  }
});

router.delete('/:staffId', async (req: AuthRequest, res: Response) => {
  try {
    const schoolId = req.user?.schoolId;
    if (!schoolId) {
      return res.status(401).json({ success: false, message: 'Invalid session' });
    }

    const staff = await prisma.staff_members.findFirst({
      where: {
        id: req.params.staffId,
        school_id: schoolId
      }
    });

    if (!staff) {
      return res.status(404).json({ success: false, message: 'Staff member not found' });
    }

    await prisma.$transaction(async (tx) => {
      await tx.class_sections.updateMany({
        where: {
          school_id: schoolId,
          homeroom_teacher_id: staff.id
        },
        data: { homeroom_teacher_id: null }
      });

      await tx.staff_members.update({
        where: { id: staff.id },
        data: {
          status: 'inactive',
          app_access_enabled: false
        }
      });
    });

    res.json({ success: true });
  } catch (error) {
    console.error('Failed to remove staff:', error);
    res.status(500).json({ success: false, message: 'Failed to remove staff' });
  }
});

router.post('/:staffId/access', async (req: AuthRequest, res: Response) => {
  try {
    const schoolId = req.user?.schoolId;
    if (!schoolId) {
      return res.status(401).json({ success: false, message: 'Invalid session' });
    }

    const staff = await prisma.staff_members.findFirst({
      where: {
        id: req.params.staffId,
        school_id: schoolId,
        status: 'active'
      },
      include: staffDetailsInclude
    });

    if (!staff) {
      return res.status(404).json({ success: false, message: 'Staff member not found' });
    }

    if (!staff.email) {
      return res.status(400).json({ success: false, message: 'Staff member needs an email to access the app' });
    }

    const password = generateTemporaryPassword();
    const passwordHash = await bcrypt.hash(password, 10);

    const updatedStaff = await prisma.$transaction(async (tx) => {
      const user = await ensureStaffUser(tx, schoolId, {
        userId: staff.user_id,
        name: staff.full_name,
        email: staff.email!,
        phone: staff.phone
      }, passwordHash);

      await ensureUserRole(tx, user.id, schoolId, 'attendance_staff');

      await tx.staff_members.update({
        where: { id: staff.id },
        data: {
          user_id: user.id,
          app_access_enabled: true
        }
      });

      return tx.staff_members.findUniqueOrThrow({
        where: { id: staff.id },
        include: staffDetailsInclude
      });
    });

    res.json({
      success: true,
      data: updatedStaff,
      credentials: {
        username: staff.email,
        password
      }
    });
  } catch (error) {
    console.error('Failed to generate staff access:', error);
    res.status(500).json({ success: false, message: 'Failed to generate staff access' });
  }
});

export default router;
