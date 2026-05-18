import React, { useState } from 'react';
import { Card } from '../components/Card';
import { StatusChip } from '../components/StatusChip';
import { useAppContext } from '../context/AppContext';
import { Search } from 'lucide-react';
import './Asistencia.css';

export const Asistencia: React.FC = () => {
  const { students, attendanceLogs, markAttendance } = useAppContext();
  const [searchTerm, setSearchTerm] = useState('');

  const filteredStudents = students.filter(student => 
    student.name.toLowerCase().includes(searchTerm.toLowerCase()) || 
    student.grade.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <div className="asistencia-page">
      <header className="page-header">
        <div>
          <h2>Control de Asistencia</h2>
          <p className="text-secondary">Registro manual y verificación de estados diarios.</p>
        </div>
      </header>

      <Card className="checklist-container">
        <div className="search-bar">
          <Search size={20} color="var(--on-surface-variant)" />
          <input 
            type="text" 
            placeholder="Buscar por nombre o grado..." 
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
        </div>

        <table className="checklist-table">
          <thead>
            <tr>
              <th>Estudiante</th>
              <th>Grado</th>
              <th>Estado Actual</th>
              <th>Acciones Rápidas</th>
            </tr>
          </thead>
          <tbody>
            {filteredStudents.map(student => {
              const log = attendanceLogs.find(l => l.studentId === student.id);
              
              return (
                <tr key={student.id}>
                  <td>
                    <div className="student-name">{student.name}</div>
                    <div className="student-id">ID: {student.id}</div>
                  </td>
                  <td>{student.grade}</td>
                  <td>
                    {log ? <StatusChip status={log.status} /> : <StatusChip status="pending" />}
                    {log && <div className="log-time">{log.timestamp}</div>}
                  </td>
                  <td>
                    <div className="action-buttons">
                      <button 
                        className={`action-btn success ${log?.status === 'present' ? 'active' : ''}`}
                        onClick={() => markAttendance(student.id, 'present')}
                      >
                        Ingreso
                      </button>
                      <button 
                        className={`action-btn warning ${log?.status === 'late' ? 'active' : ''}`}
                        onClick={() => markAttendance(student.id, 'late')}
                      >
                        Retraso
                      </button>
                      <button 
                        className={`action-btn error ${log?.status === 'absent' ? 'active' : ''}`}
                        onClick={() => markAttendance(student.id, 'absent')}
                      >
                        Falta
                      </button>
                    </div>
                  </td>
                </tr>
              );
            })}
            
            {filteredStudents.length === 0 && (
              <tr>
                <td colSpan={4} className="no-results">No se encontraron estudiantes.</td>
              </tr>
            )}
          </tbody>
        </table>
      </Card>
    </div>
  );
};
