import { Router } from 'express';
import { verifyToken } from '../middlewares/auth.middleware';
import prisma from '../config/db';
import { compareFaces } from '../services/face_comparison.service';

const router = Router();

router.use(verifyToken);

// Get attendance events for the current guardian/parent's students only
router.get('/my-students', async (req: any, res) => {
  try {
    const userId = req.user?.id;
    if (!userId) {
      return res.status(401).json({ success: false, message: 'Invalid session' });
    }

    // Find guardian records linked to this user
    const guardians = await prisma.guardians.findMany({
      where: { user_id: userId },
      include: {
        student_guardians: true
      }
    });

    const studentIds = guardians.flatMap(g =>
      g.student_guardians.map(sg => sg.student_id)
    );

    if (studentIds.length === 0) {
      return res.json({ success: true, data: [] });
    }

    const events = await prisma.attendance_events.findMany({
      where: {
        student_id: { in: studentIds }
      },
      include: {
        students: true
      },
      orderBy: { event_time: 'desc' },
      take: 100
    });

    res.json({ success: true, data: events });
  } catch (error) {
    console.error('Failed to fetch guardian attendance:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch guardian attendance' });
  }
});

router.get('/', async (req: any, res) => {
  try {
    const schoolId = req.user?.schoolId;
    if (!schoolId) {
      return res.status(401).json({ success: false, message: 'Invalid session' });
    }

    const events = await prisma.attendance_events.findMany({
      where: { school_id: schoolId },
      include: {
        students: true
      },
      orderBy: { event_time: 'desc' },
      take: 100
    });

    res.json({ success: true, data: events });
  } catch (error) {
    console.error('Failed to fetch attendance:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch attendance' });
  }
});

router.post('/record', async (req: any, res) => {
  try {
    const { studentId, method, direction, notes } = req.body;
    const schoolId = req.user.schoolId;

    if (!studentId || !method || !direction) {
      return res.status(400).json({ success: false, message: 'Missing required fields' });
    }

    // Get student to find section
    const student = await prisma.students.findUnique({
      where: { id: studentId }
    });

    if (!student || student.school_id !== schoolId) {
      return res.status(404).json({ success: false, message: 'Student not found' });
    }

    // Get policy
    let policy = null;
    if (student.current_section_id) {
      policy = await prisma.attendance_policies.findFirst({
        where: { school_id: schoolId, section_id: student.current_section_id }
      });
    }
    if (!policy) {
      policy = await prisma.attendance_policies.findFirst({
        where: { school_id: schoolId, section_id: null }
      });
    }

    if (!policy) {
      return res.status(400).json({ success: false, message: 'No attendance policy found for this student/school' });
    }

    const now = new Date();
    const currentHour = now.getHours();
    const currentMinute = now.getMinutes();
    const currentTime = currentHour * 60 + currentMinute;
    
    // Prisma returns Time columns as Date objects on 1970-01-01 UTC
    const lateHour = policy.late_after.getUTCHours();
    const lateMinute = policy.late_after.getUTCMinutes();
    const lateTime = lateHour * 60 + lateMinute;

    const absenceHour = policy.absence_after.getUTCHours();
    const absenceMinute = policy.absence_after.getUTCMinutes();
    const absenceTime = absenceHour * 60 + absenceMinute;

    let status_after = 'present';
    if (direction === 'entry') {
      if (currentTime >= absenceTime) {
        status_after = 'late'; // As user specified: after absence time still record as late
      } else if (currentTime >= lateTime) {
        status_after = 'late';
      } else {
        status_after = 'present';
      }
    }

    // Insert attendance event
    const event = await prisma.attendance_events.create({
      data: {
        school_id: schoolId,
        student_id: studentId,
        method: method,
        direction: direction,
        status_after: direction === 'entry' ? status_after as any : undefined,
        recorded_by: req.user.id,
        notes: notes
      }
    });

    res.json({ success: true, message: 'Attendance recorded successfully', data: event });
  } catch (error) {
    console.error('Attendance error:', error);
    res.status(500).json({ success: false, message: 'Failed to record attendance' });
  }
});

router.post('/record-biometric', async (req: any, res) => {
  try {
    const { capturedImage, direction = 'entry', notes } = req.body;
    const schoolId = req.user.schoolId;

    if (!capturedImage) {
      return res.status(400).json({ success: false, message: 'No se recibió ninguna imagen para el escaneo' });
    }

    // 1. Fetch all active students in the school with registered photo
    const studentsWithPhoto = await prisma.students.findMany({
      where: {
        school_id: schoolId,
        status: 'active',
        photo_url: {
          not: null,
          notIn: ['']
        }
      },
      include: {
        class_sections: true
      }
    });

    if (studentsWithPhoto.length === 0) {
      return res.status(400).json({ success: false, message: 'No hay estudiantes con fotos registradas en este colegio' });
    }

    // 2. Perform 1-to-many comparison
    let bestMatch: typeof studentsWithPhoto[0] | null = null;
    let maxConfidence = 0;

    for (const student of studentsWithPhoto) {
      if (!student.photo_url) continue;
      
      const similarity = await compareFaces(capturedImage, student.photo_url);
      if (similarity > maxConfidence) {
        maxConfidence = similarity;
        bestMatch = student;
      }
    }

    // 3. Check threshold (75%)
    const confidenceThreshold = 75.0;
    if (!bestMatch || maxConfidence < confidenceThreshold) {
      return res.status(404).json({ 
        success: false, 
        message: 'Rostro no reconocido',
        maxConfidence
      });
    }

    // 4. Get attendance policy for the matched student
    let policy = null;
    if (bestMatch.current_section_id) {
      policy = await prisma.attendance_policies.findFirst({
        where: { school_id: schoolId, section_id: bestMatch.current_section_id }
      });
    }
    if (!policy) {
      policy = await prisma.attendance_policies.findFirst({
        where: { school_id: schoolId, section_id: null }
      });
    }

    if (!policy) {
      return res.status(400).json({ success: false, message: 'No se encontró una política de asistencia para el estudiante' });
    }

    const now = new Date();
    const currentHour = now.getHours();
    const currentMinute = now.getMinutes();
    const currentTime = currentHour * 60 + currentMinute;
    
    const lateHour = policy.late_after.getUTCHours();
    const lateMinute = policy.late_after.getUTCMinutes();
    const lateTime = lateHour * 60 + lateMinute;

    const absenceHour = policy.absence_after.getUTCHours();
    const absenceMinute = policy.absence_after.getUTCMinutes();
    const absenceTime = absenceHour * 60 + absenceMinute;

    let status_after = 'present';
    if (direction === 'entry') {
      if (currentTime >= absenceTime) {
        status_after = 'late';
      } else if (currentTime >= lateTime) {
        status_after = 'late';
      } else {
        status_after = 'present';
      }
    }

    // 5. Create attendance event
    const event = await prisma.attendance_events.create({
      data: {
        school_id: schoolId,
        student_id: bestMatch.id,
        method: 'facial',
        direction: direction,
        status_after: direction === 'entry' ? status_after as any : undefined,
        recorded_by: req.user.id,
        biometric_match_score: maxConfidence,
        notes: notes
      }
    });

    res.json({
      success: true,
      message: 'Estudiante identificado y asistencia registrada',
      student: {
        id: bestMatch.id,
        full_name: bestMatch.full_name,
        student_code: bestMatch.student_code,
        current_section: bestMatch.class_sections?.display_name || 'Sin sección',
        photo_url: bestMatch.photo_url
      },
      confidence: maxConfidence,
      event
    });
  } catch (error) {
    console.error('Biometric attendance error:', error);
    res.status(500).json({ success: false, message: 'Error interno al procesar el escaneo biométrico' });
  }
});

export default router;
