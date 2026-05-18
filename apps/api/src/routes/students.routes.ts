import { Router } from 'express';
import { verifyToken } from '../middlewares/auth.middleware';
import prisma from '../config/db';

const router = Router();

// Apply auth middleware to all student routes
router.use(verifyToken);

// Get all students for a school
router.get('/', async (req: any, res) => {
  try {
    const schoolId = req.user.schoolId;
    const students = await prisma.students.findMany({
      where: { school_id: schoolId },
      include: {
        class_sections: true
      }
    });
    res.json({ success: true, data: students });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to fetch students' });
  }
});

export default router;
