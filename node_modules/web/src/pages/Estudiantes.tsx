import React, { useState } from 'react';
import { Card } from '../components/Card';
import { Button } from '../components/Button';
import { useAppContext } from '../context/AppContext';
import type { Student } from '../context/AppContext';
import { UserPlus, Search } from 'lucide-react';
import { AddStudentModal } from '../components/AddStudentModal';
import { StudentDetailsModal } from '../components/StudentDetailsModal';

export const Estudiantes: React.FC = () => {
  const { students } = useAppContext();
  const [isAddModalOpen, setIsAddModalOpen] = useState(false);
  const [selectedStudent, setSelectedStudent] = useState<Student | null>(null);

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--space-xl)' }}>
      <header className="page-header" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div>
          <h2>Directorio de Estudiantes</h2>
          <p className="text-secondary">Gestiona la base de datos de estudiantes y sus perfiles.</p>
        </div>
        <Button variant="primary" onClick={() => setIsAddModalOpen(true)}>
          <UserPlus size={18} />
          Añadir Estudiante
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
              <th style={{ textAlign: 'left', padding: '16px 24px', backgroundColor: 'rgba(109, 29, 54, 0.02)', color: 'var(--on-surface-variant)', fontSize: '14px', textTransform: 'uppercase' }}>ID</th>
              <th style={{ textAlign: 'left', padding: '16px 24px', backgroundColor: 'rgba(109, 29, 54, 0.02)', color: 'var(--on-surface-variant)', fontSize: '14px', textTransform: 'uppercase' }}>Grado</th>
              <th style={{ textAlign: 'left', padding: '16px 24px', backgroundColor: 'rgba(109, 29, 54, 0.02)', color: 'var(--on-surface-variant)', fontSize: '14px', textTransform: 'uppercase' }}>Acciones</th>
            </tr>
          </thead>
          <tbody>
            {students.map(student => (
              <tr key={student.id} style={{ borderBottom: '1px solid var(--border-light)' }}>
                <td style={{ padding: '16px 24px', fontWeight: 600, display: 'flex', alignItems: 'center', gap: '12px' }}>
                  {student.faceImage ? (
                    <img src={student.faceImage} alt={student.name} style={{ width: '32px', height: '32px', borderRadius: '50%', objectFit: 'cover' }} />
                  ) : (
                    <div style={{ width: '32px', height: '32px', borderRadius: '50%', backgroundColor: 'var(--surface-container-high)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'var(--on-surface-variant)', fontSize: '14px' }}>
                      {student.name.charAt(0)}
                    </div>
                  )}
                  {student.name}
                </td>
                <td style={{ padding: '16px 24px', color: 'var(--on-surface-variant)' }}>{student.id}</td>
                <td style={{ padding: '16px 24px' }}>{student.grade}</td>
                <td style={{ padding: '16px 24px' }}>
                  <Button 
                    variant="ghost" 
                    style={{ padding: '4px 12px', fontSize: '13px' }}
                    onClick={() => setSelectedStudent(student)}
                  >
                    Ver Detalles
                  </Button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </Card>

      {isAddModalOpen && (
        <AddStudentModal onClose={() => setIsAddModalOpen(false)} />
      )}

      {selectedStudent && (
        <StudentDetailsModal 
          student={selectedStudent} 
          onClose={() => setSelectedStudent(null)} 
        />
      )}
    </div>
  );
};
