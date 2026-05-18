import { Router, Response } from 'express';
import { verifyToken, AuthRequest } from '../middlewares/auth.middleware';
import prisma from '../config/db';

const router = Router();

router.use(verifyToken);

const incidentInclude = {
  students: true,
  access_locations: true
};

router.get('/', async (req: AuthRequest, res: Response) => {
  try {
    const schoolId = req.user?.schoolId;
    if (!schoolId) {
      return res.status(401).json({ success: false, message: 'Invalid session' });
    }

    const incidents = await prisma.incidents.findMany({
      where: { school_id: schoolId },
      include: incidentInclude,
      orderBy: { occurred_at: 'desc' },
      take: 100
    });

    res.json({ success: true, data: incidents });
  } catch (error) {
    console.error('Failed to fetch incidents:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch incidents' });
  }
});

router.post('/', async (req: AuthRequest, res: Response) => {
  try {
    const schoolId = req.user?.schoolId;
    if (!schoolId) {
      return res.status(401).json({ success: false, message: 'Invalid session' });
    }

    const description = String(req.body?.description ?? '').trim();
    const location = String(req.body?.location ?? '').trim();
    const studentId = req.body?.studentId ? String(req.body.studentId) : null;

    if (!description || !location) {
      return res.status(400).json({ success: false, message: 'Description and location are required' });
    }

    const student = studentId
      ? await prisma.students.findFirst({
          where: {
            id: studentId,
            school_id: schoolId
          }
        })
      : null;

    if (studentId && !student) {
      return res.status(404).json({ success: false, message: 'Student not found' });
    }

    const accessLocation = await prisma.access_locations.findFirst({
      where: {
        school_id: schoolId,
        name: location
      }
    });

    const incident = await prisma.incidents.create({
      data: {
        school_id: schoolId,
        student_id: studentId,
        location_id: accessLocation?.id,
        type: 'other',
        severity: 'medium',
        status: 'active',
        title: description,
        description,
        metadata: {
          location_label: location
        }
      },
      include: incidentInclude
    });

    res.status(201).json({ success: true, data: incident });
  } catch (error) {
    console.error('Failed to create incident:', error);
    res.status(500).json({ success: false, message: 'Failed to create incident' });
  }
});

router.patch('/:incidentId/resolve', async (req: AuthRequest, res: Response) => {
  try {
    const schoolId = req.user?.schoolId;
    if (!schoolId) {
      return res.status(401).json({ success: false, message: 'Invalid session' });
    }

    const incident = await prisma.incidents.findFirst({
      where: {
        id: req.params.incidentId,
        school_id: schoolId
      }
    });

    if (!incident) {
      return res.status(404).json({ success: false, message: 'Incident not found' });
    }

    const updatedIncident = await prisma.incidents.update({
      where: { id: incident.id },
      data: {
        status: 'resolved',
        resolved_at: new Date(),
        resolved_by: req.user?.id,
        resolution_note: req.body?.note ? String(req.body.note) : null
      },
      include: incidentInclude
    });

    res.json({ success: true, data: updatedIncident });
  } catch (error) {
    console.error('Failed to resolve incident:', error);
    res.status(500).json({ success: false, message: 'Failed to resolve incident' });
  }
});

export default router;
