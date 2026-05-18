import { Request, Response } from 'express';
import prisma from '../config/db';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';

export const login = async (req: Request, res: Response) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ success: false, message: 'Please provide email and password' });
    }

    const user = await prisma.users.findFirst({
      where: { email },
      include: {
        user_roles: true,
        schools: true,
      }
    });

    if (!user || !user.password_hash) {
      return res.status(401).json({ success: false, message: 'Invalid credentials' });
    }

    const isMatch = await bcrypt.compare(password, user.password_hash);
    if (!isMatch) {
      return res.status(401).json({ success: false, message: 'Invalid credentials' });
    }

    const secret = process.env.JWT_SECRET || 'fallback_secret';
    const token = jwt.sign(
      { 
        id: user.id, 
        email: user.email, 
        schoolId: user.school_id,
        roles: user.user_roles.map((r: any) => r.role)
      },
      secret,
      { expiresIn: '1d' }
    );

    res.json({
      success: true,
      token,
      user: {
        id: user.id,
        email: user.email,
        full_name: user.full_name,
        school_id: user.school_id,
        roles: user.user_roles.map((r: any) => r.role)
      }
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ success: false, message: 'Server error during login' });
  }
};
