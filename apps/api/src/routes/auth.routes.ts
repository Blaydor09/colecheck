import { Router } from 'express';
import { login } from '../controllers/auth.controller';
import { verifyToken, AuthRequest } from '../middlewares/auth.middleware';

const router = Router();

router.post('/login', login);

// Example protected route
router.get('/me', verifyToken, (req: AuthRequest, res) => {
  res.json({ success: true, user: req.user, data: req.user });
});

export default router;
