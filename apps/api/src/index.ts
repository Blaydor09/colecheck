import express, { Request, Response } from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import authRoutes from './routes/auth.routes';
import studentsRoutes from './routes/students.routes';
import attendanceRoutes from './routes/attendance.routes';
import { errorHandler } from './middlewares/error.middleware';

dotenv.config();

const app = express();
const port = process.env.PORT || 3001;

// Middlewares
app.use(cors());
app.use(express.json());

// Basic health route
app.get('/api/v1/health', (req: Request, res: Response) => {
  res.json({ status: 'ok', message: 'Colecheck API is running' });
});

// Routes
app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/students', studentsRoutes);
app.use('/api/v1/attendance', attendanceRoutes);

// Global Error Handler
app.use(errorHandler as any);

app.listen(port, () => {

  console.log(`Server is running on port ${port}`);
});
