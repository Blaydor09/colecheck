import React, { useState } from 'react';
import { Card } from '../components/Card';
import { Button } from '../components/Button';
import { useAppContext } from '../context/AppContext';
import { UserPlus, Search, Trash2 } from 'lucide-react';
import { AddTeacherModal } from '../components/AddTeacherModal';

export const Maestros: React.FC = () => {
  const { teachers, removeTeacher } = useAppContext();
  const [isAddModalOpen, setIsAddModalOpen] = useState(false);

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--space-xl)' }}>
      <header className="page-header" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div>
          <h2>Directorio de Maestros</h2>
          <p className="text-secondary">Gestiona la asignación de profesores por curso.</p>
        </div>
        <Button variant="primary" onClick={() => setIsAddModalOpen(true)}>
          <UserPlus size={18} />
          Añadir Maestro
        </Button>
      </header>

      <Card style={{ padding: 0, overflow: 'hidden' }}>
        <div style={{ padding: 'var(--space-md) var(--space-lg)', borderBottom: '1px solid var(--border-light)', display: 'flex', gap: '12px', alignItems: 'center' }}>
          <Search size={20} color="var(--on-surface-variant)" />
          <input 
            type="text" 
            placeholder="Buscar en el directorio..." 
            style={{ flex: 1, border: 'none', outline: 'none', fontSize: '16px', background: 'transparent' }}
          />
        </div>
        
        <table style={{ width: '100%', borderCollapse: 'collapse' }}>
          <thead>
            <tr>
              <th style={{ textAlign: 'left', padding: '16px 24px', backgroundColor: 'rgba(109, 29, 54, 0.02)', color: 'var(--on-surface-variant)', fontSize: '14px', textTransform: 'uppercase' }}>Nombre</th>
              <th style={{ textAlign: 'left', padding: '16px 24px', backgroundColor: 'rgba(109, 29, 54, 0.02)', color: 'var(--on-surface-variant)', fontSize: '14px', textTransform: 'uppercase' }}>Curso Asignado</th>
              <th style={{ textAlign: 'left', padding: '16px 24px', backgroundColor: 'rgba(109, 29, 54, 0.02)', color: 'var(--on-surface-variant)', fontSize: '14px', textTransform: 'uppercase' }}>Contacto</th>
              <th style={{ textAlign: 'center', padding: '16px 24px', backgroundColor: 'rgba(109, 29, 54, 0.02)', color: 'var(--on-surface-variant)', fontSize: '14px', textTransform: 'uppercase' }}>Acciones</th>
            </tr>
          </thead>
          <tbody>
            {teachers.length === 0 ? (
              <tr>
                <td colSpan={4} style={{ textAlign: 'center', padding: '32px', color: 'var(--on-surface-variant)' }}>
                  No hay maestros registrados aún.
                </td>
              </tr>
            ) : (
              teachers.map(teacher => (
                <tr key={teacher.id} style={{ borderBottom: '1px solid var(--border-light)' }}>
                  <td style={{ padding: '16px 24px', fontWeight: 600 }}>{teacher.name}</td>
                  <td style={{ padding: '16px 24px' }}>
                    <span style={{ 
                      backgroundColor: 'rgba(109, 29, 54, 0.1)', 
                      color: 'var(--primary)', 
                      padding: '4px 10px', 
                      borderRadius: '16px', 
                      fontSize: '13px', 
                      fontWeight: 500 
                    }}>
                      {teacher.course}
                    </span>
                  </td>
                  <td style={{ padding: '16px 24px', color: 'var(--on-surface-variant)' }}>
                    {teacher.email}<br />
                    <span style={{ fontSize: '13px' }}>{teacher.phone}</span>
                  </td>
                  <td style={{ padding: '16px 24px', textAlign: 'center' }}>
                    <Button 
                      variant="ghost" 
                      style={{ padding: '6px', color: 'rgb(239, 68, 68)' }}
                      onClick={() => {
                        if (window.confirm(`¿Estás seguro de que deseas eliminar a ${teacher.name}?`)) {
                          removeTeacher(teacher.id);
                        }
                      }}
                      title="Eliminar Maestro"
                    >
                      <Trash2 size={18} />
                    </Button>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </Card>

      {isAddModalOpen && (
        <AddTeacherModal onClose={() => setIsAddModalOpen(false)} />
      )}
    </div>
  );
};
