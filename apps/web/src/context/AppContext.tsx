import React, { createContext, useContext, useState, ReactNode } from 'react';
import type { StatusType } from '../components/StatusChip';

export interface Parent {
  id: string;
  name: string;
  email: string;
  phone: string;
}

export interface Student {
  id: string;
  name: string;
  grade: string;
  parent?: Parent;
}

export interface AttendanceLog {
  id: string;
  studentId: string;
  status: StatusType;
  timestamp: string;
}

export interface Incident {
  id: string;
  studentId: string | null;
  description: string;
  location: string;
  status: 'active' | 'resolved';
  timestamp: string;
}

interface AppContextType {
  students: Student[];
  attendanceLogs: AttendanceLog[];
  incidents: Incident[];
  markAttendance: (studentId: string, status: StatusType) => void;
  resolveIncident: (incidentId: string) => void;
  addIncident: (description: string, location: string, studentId?: string) => void;
  addStudent: (student: Omit<Student, 'id'>, parent: Omit<Parent, 'id'>) => void;
}

const defaultStudents: Student[] = [
  { id: '1', name: 'Juan Pérez', grade: '3ro Secundaria', parent: { id: 'p1', name: 'Carlos Pérez', email: 'carlos@ejemplo.com', phone: '+123456789' } },
  { id: '2', name: 'María Gómez', grade: '1ro Secundaria', parent: { id: 'p2', name: 'Laura Gómez', email: 'laura@ejemplo.com', phone: '+987654321' } },
  { id: '3', name: 'Carlos Díaz', grade: '5to Primaria', parent: { id: 'p3', name: 'Roberto Díaz', email: 'roberto@ejemplo.com', phone: '+112233445' } },
  { id: '4', name: 'Ana Silva', grade: '2do Secundaria', parent: { id: 'p4', name: 'Elena Silva', email: 'elena@ejemplo.com', phone: '+554433221' } },
  { id: '5', name: 'Emma Thompson', grade: '5to Secundaria', parent: { id: 'p5', name: 'William Thompson', email: 'william@ejemplo.com', phone: '+998877665' } },
  { id: '6', name: 'James Wilson', grade: '4to Secundaria', parent: { id: 'p6', name: 'Sarah Wilson', email: 'sarah@ejemplo.com', phone: '+556677889' } },
];

const defaultLogs: AttendanceLog[] = [
  { id: '101', studentId: '1', status: 'present', timestamp: '07:55 AM' },
  { id: '102', studentId: '2', status: 'late', timestamp: '08:05 AM' },
  { id: '103', studentId: '4', status: 'present', timestamp: '07:45 AM' },
];

const defaultIncidents: Incident[] = [
  { id: '201', studentId: '5', description: 'Falla de reconocimiento facial', location: 'Entrada Principal', status: 'active', timestamp: '08:11 AM' },
  { id: '202', studentId: '6', description: 'Credencial no válida', location: 'Puerta Norte', status: 'active', timestamp: '08:00 AM' },
  { id: '203', studentId: null, description: 'Visitante no identificado', location: 'Puerta B', status: 'active', timestamp: '07:30 AM' },
];

const AppContext = createContext<AppContextType | undefined>(undefined);

export const AppProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [students, setStudents] = useState<Student[]>(defaultStudents);
  const [attendanceLogs, setAttendanceLogs] = useState<AttendanceLog[]>(defaultLogs);
  const [incidents, setIncidents] = useState<Incident[]>(defaultIncidents);

  const markAttendance = (studentId: string, status: StatusType) => {
    const now = new Date();
    const timeString = now.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', hour12: true });
    
    setAttendanceLogs(prev => {
      // Remove previous log for the same student today to avoid duplicates in this simple mock
      const filtered = prev.filter(log => log.studentId !== studentId);
      return [{
        id: Math.random().toString(36).substr(2, 9),
        studentId,
        status,
        timestamp: timeString
      }, ...filtered];
    });
  };

  const resolveIncident = (incidentId: string) => {
    setIncidents(prev => prev.map(inc => 
      inc.id === incidentId ? { ...inc, status: 'resolved' } : inc
    ));
  };

  const addIncident = (description: string, location: string, studentId?: string) => {
    const now = new Date();
    const timeString = now.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', hour12: true });
    
    setIncidents(prev => [{
      id: Math.random().toString(36).substr(2, 9),
      studentId: studentId || null,
      description,
      location,
      status: 'active',
      timestamp: timeString
    }, ...prev]);
  };

  const addStudent = (studentData: Omit<Student, 'id'>, parentData: Omit<Parent, 'id'>) => {
    const parentId = 'p' + Math.random().toString(36).substr(2, 6);
    const studentId = Math.random().toString(36).substr(2, 6);
    
    const newStudent: Student = {
      ...studentData,
      id: studentId,
      parent: {
        ...parentData,
        id: parentId
      }
    };
    
    setStudents(prev => [newStudent, ...prev]);
  };

  return (
    <AppContext.Provider value={{ students, attendanceLogs, incidents, markAttendance, resolveIncident, addIncident, addStudent }}>
      {children}
    </AppContext.Provider>
  );
};

export const useAppContext = () => {
  const context = useContext(AppContext);
  if (context === undefined) {
    throw new Error('useAppContext must be used within an AppProvider');
  }
  return context;
};
