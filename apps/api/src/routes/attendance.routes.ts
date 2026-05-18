import { Router } from 'express';
import { verifyToken } from '../middlewares/auth.middleware';
import prisma from '../config/db';

const router = Router();

router.use(verifyToken);

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

export default router;
