import React, { createContext, useContext, useEffect, useState, type ReactNode } from 'react';
import type { StatusType } from '../components/StatusChip';
import api from '../services/api';
import { useAuthContext } from './AuthContext';

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
  faceImage?: string;
}

export interface Teacher {
  id: string;
  name: string;
  email: string;
  phone: string;
  course: string;
  hasAppAccess?: boolean;
  appPassword?: string;
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
  markAttendance: (studentId: string, status: StatusType) => Promise<void>;
  resolveIncident: (incidentId: string, note?: string) => Promise<void>;
  addIncident: (description: string, location: string, studentId?: string) => Promise<void>;
  addStudent: (student: Omit<Student, 'id'>, parent: Omit<Parent, 'id'>) => Promise<void>;
  addTeacher: (teacher: Omit<Teacher, 'id'>) => Promise<{ success: boolean; error?: string }>;
  removeTeacher: (teacherId: string) => Promise<void>;
  generateParentAccess: (studentId: string) => Promise<void>;
  generateTeacherAccess: (teacherId: string) => Promise<void>;
}

const AppContext = createContext<AppContextType | undefined>(undefined);

const formatTime = (dateValue?: string) => {
  if (!dateValue) return '';

  return new Date(dateValue).toLocaleTimeString([], {
    hour: '2-digit',
    minute: '2-digit',
    hour12: true
  });
};

const toStatusType = (status?: string | null): StatusType => {
  if (status === 'present' || status === 'late' || status === 'absent') {
    return status;
  }

  return 'pending';
};

const getMetadataValue = (metadata: unknown, key: string) => {
  if (metadata && typeof metadata === 'object' && key in metadata) {
    const value = (metadata as Record<string, unknown>)[key];
    return typeof value === 'string' ? value : undefined;
  }

  return undefined;
};

const mapApiStudent = (s: any): Student => {
  const primaryGuardian = s.student_guardians?.find((link: any) => link.is_primary)?.guardians
    ?? s.student_guardians?.[0]?.guardians;
  const metadataGrade = getMetadataValue(s.metadata, 'registered_grade_label');

  return {
    id: s.id,
    name: s.full_name || [s.first_name, s.last_name].filter(Boolean).join(' ') || 'Sin nombre',
    grade: s.class_sections?.display_name || s.class_sections?.name || metadataGrade || 'No asignado',
    faceImage: s.photo_url || undefined,
    parent: primaryGuardian
      ? {
          id: primaryGuardian.id,
          name: primaryGuardian.full_name,
          dni: primaryGuardian.document_number,
          email: primaryGuardian.email || '',
          phone: primaryGuardian.phone || '',
          hasAppAccess: primaryGuardian.app_access_enabled
        }
      : undefined
  };
};

const mapApiTeacher = (staff: any): Teacher => {
  const metadataCourse = getMetadataValue(staff.metadata, 'assigned_course_label');
  const assignedSection = staff.class_sections?.[0];

  return {
    id: staff.id,
    name: staff.full_name,
    email: staff.email || '',
    phone: staff.phone || '',
    course: assignedSection?.display_name || assignedSection?.name || metadataCourse || 'No asignado',
    hasAppAccess: staff.app_access_enabled
  };
};

const mapApiAttendance = (event: any): AttendanceLog => ({
  id: event.id,
  studentId: event.student_id || '',
  status: toStatusType(event.status_after),
  timestamp: formatTime(event.event_time)
});

const mapApiIncident = (incident: any): Incident => ({
  id: incident.id,
  studentId: incident.student_id || null,
  description: incident.description || incident.title || 'Incidencia sin descripcion',
  location: incident.access_locations?.name || getMetadataValue(incident.metadata, 'location_label') || 'Sin ubicacion',
  status: incident.status === 'resolved' ? 'resolved' : 'active',
  timestamp: formatTime(incident.occurred_at),
  resolutionNote: incident.resolution_note || undefined
});

export const AppProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const { isAuthenticated, loading: authLoading } = useAuthContext();
  const [students, setStudents] = useState<Student[]>([]);
  const [teachers, setTeachers] = useState<Teacher[]>([]);
  const [attendanceLogs, setAttendanceLogs] = useState<AttendanceLog[]>([]);
  const [incidents, setIncidents] = useState<Incident[]>([]);

  const fetchRealData = async () => {
    const token = localStorage.getItem('token');
    if (!token || !isAuthenticated) {
      setStudents([]);
      setTeachers([]);
      setAttendanceLogs([]);
      setIncidents([]);
      return;
    }

    try {
      const [studentsRes, teachersRes, attendanceRes, incidentsRes] = await Promise.all([
        api.get('/students'),
        api.get('/staff'),
        api.get('/attendance'),
        api.get('/incidents')
      ]);

      if (studentsRes.data.success) {
        setStudents(studentsRes.data.data.map(mapApiStudent));
      }

      if (teachersRes.data.success) {
        setTeachers(teachersRes.data.data.map(mapApiTeacher));
      }

      if (attendanceRes.data.success) {
        setAttendanceLogs(attendanceRes.data.data.map(mapApiAttendance));
      }

      if (incidentsRes.data.success) {
        setIncidents(incidentsRes.data.data.map(mapApiIncident));
      }
    } catch (error) {
      console.error('Error fetching data from backend:', error);
    }
  };

  useEffect(() => {
    if (!authLoading) {
      fetchRealData();
    }
  }, [authLoading, isAuthenticated]);

  const markAttendance = async (studentId: string, status: StatusType) => {
    try {
      const response = await api.post('/attendance/record', {
        studentId,
        method: 'manual',
        direction: 'entry'
      });

      if (response.data.success) {
        const event = response.data.data;
        const newLog = mapApiAttendance({
          ...event,
          status_after: event.status_after || status
        });

        setAttendanceLogs(prev => [newLog, ...prev.filter(log => log.studentId !== studentId)]);
      }
    } catch (error) {
      console.error('Failed to send attendance to API:', error);
    }
  };

  const resolveIncident = async (incidentId: string, note?: string) => {
    const response = await api.patch(`/incidents/${incidentId}/resolve`, { note });

    if (response.data.success) {
      const updatedIncident = mapApiIncident(response.data.data);
      setIncidents(prev => prev.map(inc => inc.id === incidentId ? updatedIncident : inc));
    }
  };

  const addIncident = async (description: string, location: string, studentId?: string) => {
    const response = await api.post('/incidents', {
      description,
      location,
      studentId
    });

    if (!response.data.success) {
      throw new Error(response.data.message || 'No se pudo registrar la incidencia');
    }

    setIncidents(prev => [mapApiIncident(response.data.data), ...prev]);
  };

  const addStudent = async (studentData: Omit<Student, 'id'>, parentData: Omit<Parent, 'id'>) => {
    const response = await api.post('/students', {
      student: studentData,
      parent: parentData
    });

    if (!response.data.success) {
      throw new Error(response.data.message || 'No se pudo registrar el estudiante');
    }

    setStudents(prev => [mapApiStudent(response.data.data), ...prev]);
  };

  const addTeacher = async (teacherData: Omit<Teacher, 'id'>) => {
    try {
      const response = await api.post('/staff', teacherData);

      if (!response.data.success) {
        return { success: false, error: response.data.message || 'No se pudo registrar el maestro' };
      }

      setTeachers(prev => [mapApiTeacher(response.data.data), ...prev]);
      return { success: true };
    } catch (err: any) {
      return {
        success: false,
        error: err.response?.data?.message || 'No se pudo registrar el maestro'
      };
    }
  };

  const removeTeacher = async (teacherId: string) => {
    const response = await api.delete(`/staff/${teacherId}`);

    if (response.data.success) {
      setTeachers(prev => prev.filter(t => t.id !== teacherId));
    }
  };

  const generateParentAccess = async (studentId: string) => {
    const response = await api.post(`/students/${studentId}/parent-access`);

    if (!response.data.success) {
      throw new Error(response.data.message || 'No se pudo generar el acceso del apoderado');
    }

    const updatedStudent = mapApiStudent(response.data.data);
    const password = response.data.credentials?.password;

    setStudents(prev => prev.map(student => {
      if (student.id !== updatedStudent.id) {
        if (student.parent && updatedStudent.parent && student.parent.id === updatedStudent.parent.id && password) {
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
      }

      return {
        ...updatedStudent,
        parent: updatedStudent.parent
          ? {
              ...updatedStudent.parent,
              appPassword: password
            }
          : undefined
      };
    }));
  };

  const generateTeacherAccess = async (teacherId: string) => {
    const response = await api.post(`/staff/${teacherId}/access`);

    if (!response.data.success) {
      throw new Error(response.data.message || 'No se pudo generar el acceso del maestro');
    }

    const updatedTeacher = mapApiTeacher(response.data.data);
    const password = response.data.credentials?.password;

    setTeachers(prev => prev.map(teacher => teacher.id === updatedTeacher.id
      ? { ...updatedTeacher, appPassword: password }
      : teacher
    ));
  };

  return (
    <AppContext.Provider value={{
      students, teachers, attendanceLogs, incidents,
      markAttendance, resolveIncident, addIncident, addStudent,
      addTeacher, removeTeacher, generateParentAccess, generateTeacherAccess
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
