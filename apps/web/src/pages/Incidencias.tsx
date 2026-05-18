import React from 'react';
import { Card } from '../components/Card';
import { Button } from '../components/Button';
import { useAppContext } from '../context/AppContext';
import { AlertCircle, CheckCircle, Clock } from 'lucide-react';
import './Incidencias.css';

export const Incidencias: React.FC = () => {
  const { incidents, students, resolveIncident } = useAppContext();

  const activeIncidents = incidents.filter(i => i.status === 'active');
  const resolvedIncidents = incidents.filter(i => i.status === 'resolved');

  return (
    <div className="incidencias-page">
      <header className="page-header">
        <div>
          <h2>Incidencias Activas</h2>
          <p className="text-secondary">Revisa y gestiona alertas de seguridad y anomalías del sistema.</p>
        </div>
      </header>

      <div className="stats-grid">
        <Card className="stat-card">
          <div className="stat-info">
            <h3>{incidents.length}</h3>
            <p>Total Incidencias</p>
          </div>
        </Card>
        <Card className="stat-card" style={{ borderColor: 'var(--warning)' }}>
          <div className="stat-info">
            <h3 style={{ color: '#a87e00' }}>{activeIncidents.length}</h3>
            <p>Pendientes de Revisión</p>
          </div>
        </Card>
        <Card className="stat-card" style={{ borderColor: 'var(--success)' }}>
          <div className="stat-info">
            <h3 style={{ color: '#2b7a5a' }}>{resolvedIncidents.length}</h3>
            <p>Resueltas Hoy</p>
          </div>
        </Card>
      </div>

      <div className="incidents-list">
        <h3>Pendientes ({activeIncidents.length})</h3>
        {activeIncidents.length === 0 && (
          <div className="empty-state">
            <CheckCircle size={48} color="var(--success)" opacity={0.5} />
            <p>¡Todo en orden! No hay incidencias pendientes.</p>
          </div>
        )}
        
        {activeIncidents.map(incident => {
          const student = incident.studentId ? students.find(s => s.id === incident.studentId) : null;
          return (
            <Card key={incident.id} className="incident-card">
              <div className="incident-icon">
                <AlertCircle size={32} color="var(--warning)" />
              </div>
              <div className="incident-details">
                <h4>{student ? student.name : 'Desconocido'}</h4>
                <p className="incident-meta">
                  {student ? `ID: ${student.id} • ${student.grade}` : incident.location}
                </p>
                <p className="incident-desc">{incident.description}</p>
                <div className="incident-footer">
                  <Clock size={14} />
                  <span>{incident.timestamp}</span>
                </div>
              </div>
              <div className="incident-actions">
                <Button variant="primary" onClick={() => resolveIncident(incident.id)}>
                  Resolver
                </Button>
                <Button variant="ghost">Ver detalles</Button>
              </div>
            </Card>
          );
        })}
      </div>
    </div>
  );
};
