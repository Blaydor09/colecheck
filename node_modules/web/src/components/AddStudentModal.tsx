import React, { useState } from 'react';
import { Button } from './Button';
import { Card } from './Card';
import { X } from 'lucide-react';
import { useAppContext } from '../context/AppContext';

interface AddStudentModalProps {
  onClose: () => void;
}

export const AddStudentModal: React.FC<AddStudentModalProps> = ({ onClose }) => {
  const { addStudent } = useAppContext();
  
  // Student state
  const [studentName, setStudentName] = useState('');
  const [studentGrade, setStudentGrade] = useState('');
  
  // Parent state
  const [parentName, setParentName] = useState('');
  const [parentDni, setParentDni] = useState('');
  const [parentEmail, setParentEmail] = useState('');
  const [parentPhone, setParentPhone] = useState('');

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    addStudent(
      { name: studentName, grade: studentGrade },
      { name: parentName, dni: parentDni, email: parentEmail, phone: parentPhone }
    );
    onClose();
  };

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
      <Card style={{ width: '100%', maxWidth: '600px', maxHeight: '90vh', overflowY: 'auto' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 'var(--space-lg)' }}>
          <h2 style={{ margin: 0 }}>Registrar Estudiante</h2>
          <Button variant="ghost" onClick={onClose} style={{ padding: '8px' }}>
            <X size={20} />
          </Button>
        </div>

        <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: 'var(--space-xl)' }}>
          
          {/* Datos del Estudiante */}
          <div>
            <h3 style={{ fontSize: '16px', color: 'var(--primary)', marginBottom: 'var(--space-md)' }}>Datos del Estudiante</h3>
            <div style={{ display: 'flex', gap: 'var(--space-md)' }}>
              <div style={{ flex: 1 }}>
                <label style={{ display: 'block', marginBottom: '4px', fontSize: '14px', color: 'var(--on-surface-variant)' }}>Nombre Completo</label>
                <input 
                  type="text" 
                  required
                  value={studentName}
                  onChange={(e) => setStudentName(e.target.value)}
                  style={{ width: '100%', padding: '10px 12px', borderRadius: '8px', border: '1px solid var(--border-light)' }} 
                  placeholder="Ej. Juan Pérez"
                />
              </div>
              <div style={{ flex: 1 }}>
                <label style={{ display: 'block', marginBottom: '4px', fontSize: '14px', color: 'var(--on-surface-variant)' }}>Grado/Curso</label>
                <input 
                  type="text" 
                  required
                  value={studentGrade}
                  onChange={(e) => setStudentGrade(e.target.value)}
                  style={{ width: '100%', padding: '10px 12px', borderRadius: '8px', border: '1px solid var(--border-light)' }} 
                  placeholder="Ej. 3ro Secundaria"
                />
              </div>
            </div>
          </div>

          <hr style={{ border: 'none', borderTop: '1px solid var(--border-light)', margin: 0 }} />

          {/* Datos del Apoderado */}
          <div>
            <h3 style={{ fontSize: '16px', color: 'var(--primary)', marginBottom: 'var(--space-md)' }}>Datos del Padre/Apoderado</h3>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--space-md)' }}>
              <div style={{ display: 'flex', gap: 'var(--space-md)' }}>
                <div style={{ flex: 1 }}>
                  <label style={{ display: 'block', marginBottom: '4px', fontSize: '14px', color: 'var(--on-surface-variant)' }}>DNI / Documento</label>
                  <input 
                    type="text" 
                    required
                    value={parentDni}
                    onChange={(e) => setParentDni(e.target.value)}
                    style={{ width: '100%', padding: '10px 12px', borderRadius: '8px', border: '1px solid var(--border-light)' }} 
                    placeholder="Ej. 12345678"
                  />
                </div>
                <div style={{ flex: 2 }}>
                  <label style={{ display: 'block', marginBottom: '4px', fontSize: '14px', color: 'var(--on-surface-variant)' }}>Nombre Completo</label>
                  <input 
                    type="text" 
                    required
                    value={parentName}
                    onChange={(e) => setParentName(e.target.value)}
                    style={{ width: '100%', padding: '10px 12px', borderRadius: '8px', border: '1px solid var(--border-light)' }} 
                    placeholder="Ej. Carlos Pérez"
                  />
                </div>
              </div>
              <div style={{ display: 'flex', gap: 'var(--space-md)' }}>
                <div style={{ flex: 1 }}>
                  <label style={{ display: 'block', marginBottom: '4px', fontSize: '14px', color: 'var(--on-surface-variant)' }}>Correo Electrónico (Para Login)</label>
                  <input 
                    type="email" 
                    required
                    value={parentEmail}
                    onChange={(e) => setParentEmail(e.target.value)}
                    style={{ width: '100%', padding: '10px 12px', borderRadius: '8px', border: '1px solid var(--border-light)' }} 
                    placeholder="correo@ejemplo.com"
                  />
                </div>
                <div style={{ flex: 1 }}>
                  <label style={{ display: 'block', marginBottom: '4px', fontSize: '14px', color: 'var(--on-surface-variant)' }}>Teléfono (Notificaciones)</label>
                  <input 
                    type="tel" 
                    required
                    value={parentPhone}
                    onChange={(e) => setParentPhone(e.target.value)}
                    style={{ width: '100%', padding: '10px 12px', borderRadius: '8px', border: '1px solid var(--border-light)' }} 
                    placeholder="+56 9 1234 5678"
                  />
                </div>
              </div>
            </div>
          </div>

          <div style={{ display: 'flex', justifyContent: 'flex-end', gap: 'var(--space-md)', marginTop: 'var(--space-md)' }}>
            <Button variant="ghost" onClick={onClose} type="button">Cancelar</Button>
            <Button variant="primary" type="submit">Guardar Registro</Button>
          </div>
        </form>
      </Card>
    </div>
  );
};
