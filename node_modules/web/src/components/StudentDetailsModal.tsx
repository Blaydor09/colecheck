import React from 'react';
import { Button } from './Button';
import { Card } from './Card';
import { X, User, Phone, Mail, GraduationCap } from 'lucide-react';
import type { Student } from '../context/AppContext';

interface StudentDetailsModalProps {
  student: Student;
  onClose: () => void;
}

export const StudentDetailsModal: React.FC<StudentDetailsModalProps> = ({ student, onClose }) => {
  return (
    <div style={{
      position: 'fixed',
      top: 0, left: 0, right: 0, bottom: 0,
      backgroundColor: 'rgba(0,0,0,0.5)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      zIndex: 1000
    }}>
      <Card style={{ width: '100%', maxWidth: '500px' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 'var(--space-lg)' }}>
          <h2 style={{ margin: 0, fontSize: '20px' }}>Detalles del Estudiante</h2>
          <Button variant="ghost" onClick={onClose} style={{ padding: '8px' }}>
            <X size={20} />
          </Button>
        </div>

        <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--space-xl)' }}>
          {/* Estudiante Info */}
          <div style={{ display: 'flex', gap: '16px', alignItems: 'center' }}>
            <div style={{ 
              width: '60px', height: '60px', 
              borderRadius: '50%', backgroundColor: 'rgba(109, 29, 54, 0.1)', 
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              color: 'var(--primary)'
            }}>
              <GraduationCap size={32} />
            </div>
            <div>
              <h3 style={{ margin: 0, fontSize: '18px' }}>{student.name}</h3>
              <p style={{ margin: 0, color: 'var(--on-surface-variant)' }}>ID: {student.id} • {student.grade}</p>
            </div>
          </div>

          <hr style={{ border: 'none', borderTop: '1px solid var(--border-light)', margin: 0 }} />

          {/* Padre Info */}
          <div>
            <h4 style={{ margin: '0 0 16px 0', color: 'var(--primary)', fontSize: '16px' }}>Contacto del Apoderado</h4>
            {student.parent ? (
              <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                  <User size={18} color="var(--on-surface-variant)" />
                  <span style={{ fontWeight: 500 }}>{student.parent.name}</span>
                </div>
                <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                  <Mail size={18} color="var(--on-surface-variant)" />
                  <span>{student.parent.email}</span>
                </div>
                <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                  <Phone size={18} color="var(--on-surface-variant)" />
                  <span>{student.parent.phone}</span>
                </div>
              </div>
            ) : (
              <p style={{ color: 'var(--on-surface-variant)', fontStyle: 'italic' }}>No hay información de apoderado registrada.</p>
            )}
          </div>
        </div>

        <div style={{ display: 'flex', justifyContent: 'flex-end', marginTop: 'var(--space-xl)' }}>
          <Button variant="primary" onClick={onClose}>Cerrar</Button>
        </div>
      </Card>
    </div>
  );
};
