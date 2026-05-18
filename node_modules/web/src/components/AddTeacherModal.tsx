import React, { useState } from 'react';
import { Button } from './Button';
import { Card } from './Card';
import { X } from 'lucide-react';
import { useAppContext } from '../context/AppContext';

interface AddTeacherModalProps {
  onClose: () => void;
}

export const AddTeacherModal: React.FC<AddTeacherModalProps> = ({ onClose }) => {
  const { addTeacher } = useAppContext();
  
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [phone, setPhone] = useState('');
  const [course, setCourse] = useState('');
  const [error, setError] = useState<string | null>(null);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);

    const result = addTeacher({
      name,
      email,
      phone,
      course
    });

    if (!result.success && result.error) {
      setError(result.error);
    } else {
      onClose();
    }
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
      <Card style={{ width: '100%', maxWidth: '500px', maxHeight: '90vh', overflowY: 'auto' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 'var(--space-lg)' }}>
          <h2 style={{ margin: 0 }}>Registrar Maestro</h2>
          <Button variant="ghost" onClick={onClose} style={{ padding: '8px' }}>
            <X size={20} />
          </Button>
        </div>

        {error && (
          <div style={{ 
            backgroundColor: 'rgba(239, 68, 68, 0.1)', 
            color: 'rgb(239, 68, 68)', 
            padding: '12px', 
            borderRadius: '8px', 
            marginBottom: '16px',
            fontSize: '14px'
          }}>
            {error}
          </div>
        )}

        <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: 'var(--space-md)' }}>
          
          <div>
            <label style={{ display: 'block', marginBottom: '4px', fontSize: '14px', color: 'var(--on-surface-variant)' }}>Nombre Completo</label>
            <input 
              type="text" 
              required
              value={name}
              onChange={(e) => setName(e.target.value)}
              style={{ width: '100%', padding: '10px 12px', borderRadius: '8px', border: '1px solid var(--border-light)' }} 
              placeholder="Ej. Prof. Juan Pérez"
            />
          </div>

          <div>
            <label style={{ display: 'block', marginBottom: '4px', fontSize: '14px', color: 'var(--on-surface-variant)' }}>Curso Asignado (Uno por curso)</label>
            <input 
              type="text" 
              required
              value={course}
              onChange={(e) => setCourse(e.target.value)}
              style={{ width: '100%', padding: '10px 12px', borderRadius: '8px', border: '1px solid var(--border-light)' }} 
              placeholder="Ej. 3ro Secundaria"
            />
          </div>

          <div style={{ display: 'flex', gap: 'var(--space-md)' }}>
            <div style={{ flex: 1 }}>
              <label style={{ display: 'block', marginBottom: '4px', fontSize: '14px', color: 'var(--on-surface-variant)' }}>Correo Electrónico</label>
              <input 
                type="email" 
                required
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                style={{ width: '100%', padding: '10px 12px', borderRadius: '8px', border: '1px solid var(--border-light)' }} 
                placeholder="correo@ejemplo.com"
              />
            </div>
            <div style={{ flex: 1 }}>
              <label style={{ display: 'block', marginBottom: '4px', fontSize: '14px', color: 'var(--on-surface-variant)' }}>Teléfono</label>
              <input 
                type="tel" 
                required
                value={phone}
                onChange={(e) => setPhone(e.target.value)}
                style={{ width: '100%', padding: '10px 12px', borderRadius: '8px', border: '1px solid var(--border-light)' }} 
                placeholder="+56 9 1234 5678"
              />
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
