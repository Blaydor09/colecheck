import React, { createContext, useContext, useState, useEffect, type ReactNode } from 'react';
import api from '../services/api';

interface User {
  id: string;
  email?: string | null;
  full_name?: string;
  school_id?: string;
  schoolId?: string;
  roles?: string[];
}

interface AuthContextType {
  isAuthenticated: boolean;
  user: User | null;
  login: (token: string, userData: User) => void;
  logout: () => void;
  loading: boolean;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [isAuthenticated, setIsAuthenticated] = useState<boolean>(false);
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState<boolean>(true);

  useEffect(() => {
    // Check if token exists on load
    const verifySession = async () => {
      const token = localStorage.getItem('token');
      if (token) {
        try {
          const res = await api.get('/auth/me'); // We have this route in auth.controller
          const sessionUser = res.data.user ?? res.data.data;
          if (res.data.success && sessionUser) {
            setUser(sessionUser);
            setIsAuthenticated(true);
          } else {
            localStorage.removeItem('token');
          }
        } catch (error) {
          console.error("Session verification failed", error);
          localStorage.removeItem('token');
        }
      }
      setLoading(false);
    };

    verifySession();
  }, []);

  const login = (token: string, userData: User) => {
    localStorage.setItem('token', token);
    setUser(userData);
    setIsAuthenticated(true);
  };

  const logout = () => {
    localStorage.removeItem('token');
    setUser(null);
    setIsAuthenticated(false);
    window.location.href = '/login';
  };

  return (
    <AuthContext.Provider value={{ isAuthenticated, user, login, logout, loading }}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuthContext = () => {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuthContext must be used within an AuthProvider');
  }
  return context;
};
