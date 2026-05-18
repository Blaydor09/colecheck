import React, { createContext, useContext, useState, type ReactNode } from 'react';
import type { StatusType } from '../components/StatusChip';

export interface Parent {
  id: string;
  name: string;
  dni: string;
  email: string;
  phone: string;
  hasAppAccess?: boolean;
  appPassword?: string;
}

export interface Student {
  id: string;
  name: string;
  grade: string;
  parent?: Parent;
}

export interface Teacher {
  id: string;
  name: string;
  email: string;
  phone: string;
  course: string;
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
  resolutionNote?: string;
}

interface AppContextType {
  students: Student[];
  teachers: Teacher[];
  attendanceLogs: AttendanceLog[];
  incidents: Incident[];
  markAttendance: (studentId: string, status: StatusType) => void;
  resolveIncident: (incidentId: string, note?: string) => void;
  addIncident: (description: string, location: string, studentId?: string) => void;
  addStudent: (student: Omit<Student, 'id'>, parent: Omit<Parent, 'id'>) => void;
  addTeacher: (teacher: Omit<Teacher, 'id'>) => { success: boolean; error?: string };
  removeTeacher: (teacherId: string) => void;
  generateParentAccess: (studentId: string) => void;
}

const defaultStudents: Student[] = [
  { id: '1', name: 'Juan Pérez', grade: '3ro Secundaria', parent: { id: 'p1', dni: '12345678', name: 'Carlos Pérez', email: 'carlos@ejemplo.com', phone: '+123456789', hasAppAccess: true, appPassword: 'APP123' } },
  { id: '2', name: 'María Pérez', grade: '1ro Secundaria', parent: { id: 'p1', dni: '12345678', name: 'Carlos Pérez', email: 'carlos@ejemplo.com', phone: '+123456789', hasAppAccess: true, appPassword: 'APP123' } },
  { id: '3', name: 'Carlos Díaz', grade: '5to Primaria', parent: { id: 'p3', dni: '87654321', name: 'Roberto Díaz', email: 'roberto@ejemplo.com', phone: '+112233445' } },
  { id: '4', name: 'Ana Silva', grade: '2do Secundaria', parent: { id: 'p4', dni: '11223344', name: 'Elena Silva', email: 'elena@ejemplo.com', phone: '+554433221' } },
  { id: '5', name: 'Emma Thompson', grade: '5to Secundaria', parent: { id: 'p5', dni: '99887766', name: 'William Thompson', email: 'william@ejemplo.com', phone: '+998877665' } },
  { id: '6', name: 'James Wilson', grade: '4to Secundaria', parent: { id: 'p6', dni: '55667788', name: 'Sarah Wilson', email: 'sarah@ejemplo.com', phone: '+556677889' } },
];

const defaultTeachers: Teacher[] = [
  { id: 't1', name: 'Lic. Fernando Salas', email: 'fsalas@colecheck.com', phone: '+56987654321', course: '3ro Secundaria' },
  { id: 't2', name: 'Prof. Carmen Ortiz', email: 'cortiz@colecheck.com', phone: '+56912345678', course: '5to Primaria' },
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
  const [teachers, setTeachers] = useState<Teacher[]>(defaultTeachers);
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

  const resolveIncident = (incidentId: string, note?: string) => {
    setIncidents(prev => prev.map(inc => 
      inc.id === incidentId ? { ...inc, status: 'resolved', resolutionNote: note } : inc
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
    // Buscar si ya existe un padre con el mismo DNI en los estudiantes registrados
    const existingParentStudent = students.find(s => s.parent?.dni === parentData.dni);
    
    let resolvedParent: Parent;
    if (existingParentStudent && existingParentStudent.parent) {
      resolvedParent = existingParentStudent.parent; // Usar el padre existente (incluyendo su ID y credenciales si tiene)
    } else {
      resolvedParent = {
        ...parentData,
        id: 'p' + Math.random().toString(36).substr(2, 6)
      };
    }
    
    const studentId = Math.random().toString(36).substr(2, 6);
    const newStudent: Student = {
      ...studentData,
      id: studentId,
      parent: resolvedParent
    };
    
    setStudents(prev => [newStudent, ...prev]);
  };

  const addTeacher = (teacherData: Omit<Teacher, 'id'>) => {
    // Verificar si ya existe un maestro para el mismo curso
    const courseExists = teachers.some(t => t.course.toLowerCase().trim() === teacherData.course.toLowerCase().trim());
    if (courseExists) {
      return { success: false, error: `Ya existe un maestro asignado al curso: ${teacherData.course}` };
    }

    const newTeacher: Teacher = {
      ...teacherData,
      id: 't' + Math.random().toString(36).substr(2, 6)
    };
    
    setTeachers(prev => [newTeacher, ...prev]);
    return { success: true };
  };

  const removeTeacher = (teacherId: string) => {
    setTeachers(prev => prev.filter(t => t.id !== teacherId));
  };

  const generateParentAccess = (studentId: string) => {
    const password = Math.random().toString(36).substring(2, 8).toUpperCase();
    
    // Encontramos al estudiante para saber quién es su padre
    const targetStudent = students.find(s => s.id === studentId);
    if (!targetStudent || !targetStudent.parent) return;
    
    const parentId = targetStudent.parent.id;
    
    // Actualizamos a todos los estudiantes que tengan este mismo padre
    setStudents(prev => prev.map(student => {
      if (student.parent && student.parent.id === parentId) {
        return {
          ...student,
          parent: {
            ...student.parent,
            hasAppAccess: true,
            appPassword: password
          }
        };
      }
      return student;
    }));
  };

  return (
    <AppContext.Provider value={{ 
      students, teachers, attendanceLogs, incidents, 
      markAttendance, resolveIncident, addIncident, addStudent, 
      addTeacher, removeTeacher, generateParentAccess
    }}>
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
