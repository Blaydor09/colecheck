import React, { useMemo } from 'react';
import { Card } from '../components/Card';
import { StatusChip } from '../components/StatusChip';
import { Users, CheckCircle, AlertTriangle, Clock } from 'lucide-react';
import { useAppContext } from '../context/AppContext';
import './Dashboard.css';

export const Dashboard: React.FC = () => {
  const { students, attendanceLogs, incidents } = useAppContext();

  const presentCount = attendanceLogs.filter(log => log.status === 'present').length;
  const lateCount = attendanceLogs.filter(log => log.status === 'late').length;
  const absentCount = attendanceLogs.filter(log => log.status === 'absent').length;
  const activeIncidentsCount = incidents.filter(inc => inc.status === 'active').length;

  const recentLogs = useMemo(() => {
    return [...attendanceLogs].sort((a, b) => {
      // Very basic string sort for time
      return b.timestamp.localeCompare(a.timestamp);
    }).slice(0, 5);
  }, [attendanceLogs]);

  return (
    <div className="dashboard">
      <header className="dashboard-header">
        <div>
          <h2>Panel Administrativo</h2>
          <p className="text-secondary">Resumen de asistencia de hoy - 17 Mayo 2026</p>
        </div>
      </header>

      <div className="stats-grid">
        <Card className="stat-card">
          <div className="stat-icon-wrapper" style={{ backgroundColor: 'rgba(109, 29, 54, 0.1)' }}>
            <Users size={24} color="var(--primary)" />
          </div>
          <div className="stat-info">
            <h3>{students.length}</h3>
            <p>Total Estudiantes</p>
          </div>
        </Card>
        
        <Card className="stat-card">
          <div className="stat-icon-wrapper" style={{ backgroundColor: 'rgba(67, 185, 138, 0.15)' }}>
            <CheckCircle size={24} color="#2b7a5a" />
          </div>
          <div className="stat-info">
            <h3>{presentCount}</h3>
            <p>Ingresos a tiempo</p>
          </div>
        </Card>

        <Card className="stat-card">
          <div className="stat-icon-wrapper" style={{ backgroundColor: 'rgba(255, 200, 87, 0.2)' }}>
            <Clock size={24} color="#a87e00" />
          </div>
          <div className="stat-info">
            <h3>{lateCount}</h3>
            <p>Retrasos</p>
          </div>
        </Card>

        <Card className="stat-card">
          <div className="stat-icon-wrapper" style={{ backgroundColor: 'rgba(226, 93, 122, 0.15)' }}>
            <AlertTriangle size={24} color="var(--secondary)" />
          </div>
          <div className="stat-info">
            <h3>{absentCount}</h3>
            <p>Faltas</p>
          </div>
        </Card>
      </div>

      <div className="recent-activity">
        <h3>Últimos Registros</h3>
        <Card className="table-card">
          <table className="activity-table">
            <thead>
              <tr>
                <th>Estudiante</th>
                <th>Grado</th>
                <th>Hora</th>
                <th>Estado</th>
              </tr>
            </thead>
            <tbody>
              {recentLogs.length > 0 ? (
                recentLogs.map(log => {
                  const student = students.find(s => s.id === log.studentId);
                  return (
                    <tr key={log.id}>
                      <td>{student?.name || 'Desconocido'}</td>
                      <td>{student?.grade || '-'}</td>
                      <td>{log.timestamp}</td>
                      <td><StatusChip status={log.status} /></td>
                    </tr>
                  );
                })
              ) : (
                <tr>
                  <td colSpan={4} style={{ textAlign: 'center', color: 'var(--on-surface-variant)' }}>
                    No hay registros el día de hoy
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </Card>
      </div>

      {activeIncidentsCount > 0 && (
        <div className="alerts-banner" style={{ marginTop: '24px', padding: '16px', backgroundColor: 'var(--warning)', borderRadius: 'var(--radius-card)', color: '#5a4300', display: 'flex', alignItems: 'center', gap: '12px' }}>
          <AlertTriangle size={24} />
          <span style={{ fontWeight: 600 }}>Atención: Tienes {activeIncidentsCount} incidencia(s) activa(s) que requieren revisión. Ve a la pestaña de Incidencias.</span>
        </div>
      )}
    </div>
  );
};
