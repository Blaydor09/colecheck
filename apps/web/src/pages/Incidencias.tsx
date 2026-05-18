import React, { useState } from 'react';
import { Card } from '../components/Card';
import { Button } from '../components/Button';
import { useAppContext, type Incident } from '../context/AppContext';
import { AlertCircle, CheckCircle, Clock, Phone, Mail, User, MapPin, AlignLeft, X } from 'lucide-react';
import './Incidencias.css';

export const Incidencias: React.FC = () => {
  const { incidents, students, resolveIncident } = useAppContext();
  const [selectedIncident, setSelectedIncident] = useState<Incident | null>(null);
  const [resolutionNote, setResolutionNote] = useState('');

  const activeIncidents = incidents.filter(i => i.status === 'active');
  const resolvedIncidents = incidents.filter(i => i.status === 'resolved');

  const handleResolve = (incidentId: string) => {
    resolveIncident(incidentId, resolutionNote.trim() !== '' ? resolutionNote : undefined);
    setSelectedIncident(null);
    setResolutionNote('');
  };

  const openModal = (incident: Incident) => {
    setSelectedIncident(incident);
    setResolutionNote('');
  };

  const closeModal = () => {
    setSelectedIncident(null);
    setResolutionNote('');
  };

  const selectedStudent = selectedIncident?.studentId 
    ? students.find(s => s.id === selectedIncident.studentId) 
    : null;

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
                <Button variant="primary" onClick={() => openModal(incident)}>
                  Resolver
                </Button>
              </div>
            </Card>
          );
        })}
      </div>

      {selectedIncident && (
        <div className="incident-modal-overlay" onClick={closeModal}>
          <div className="incident-modal" onClick={e => e.stopPropagation()}>
            <div className="incident-modal-header">
              <h3>Detalles de Incidencia</h3>
              <button className="icon-button" onClick={closeModal}>
                <X size={24} />
              </button>
            </div>
            
            <div className="incident-modal-content">
              <div className="info-section">
                <h4><MapPin size={18} /> Detalles</h4>
                <p><strong>Ubicación:</strong> {selectedIncident.location}</p>
                <p><strong>Hora:</strong> {selectedIncident.timestamp}</p>
                <p><strong>Descripción:</strong> {selectedIncident.description}</p>
              </div>

              {selectedStudent && selectedStudent.parent && (
                <>
                  <div className="info-section">
                    <h4><User size={18} /> Estudiante</h4>
                    <p><strong>Nombre:</strong> {selectedStudent.name}</p>
                    <p><strong>Grado:</strong> {selectedStudent.grade}</p>
                    <p><strong>ID:</strong> {selectedStudent.id}</p>
                  </div>

                  <div className="info-section">
                    <h4><User size={18} /> Apoderado</h4>
                    <p><strong>Nombre:</strong> {selectedStudent.parent.name}</p>
                    <div className="contact-buttons">
                      <a href={`tel:${selectedStudent.parent.phone}`} className="contact-link">
                        <Phone size={16} /> Llamar ({selectedStudent.parent.phone})
                      </a>
                      <a href={`mailto:${selectedStudent.parent.email}`} className="contact-link">
                        <Mail size={16} /> Correo ({selectedStudent.parent.email})
                      </a>
                    </div>
                  </div>
                </>
              )}

              <div className="info-section resolution-section">
                <h4><AlignLeft size={18} /> Resolución</h4>
                <p className="help-text">Añade una nota o justificación (opcional)</p>
                <textarea 
                  value={resolutionNote}
                  onChange={e => setResolutionNote(e.target.value)}
                  placeholder="Ej: El alumno presentó justificativo médico..."
                  rows={3}
                  className="resolution-textarea"
                />
              </div>
            </div>

            <div className="incident-modal-footer">
              <Button variant="ghost" onClick={closeModal}>Cancelar</Button>
              <Button variant="primary" onClick={() => handleResolve(selectedIncident.id)}>
                Resolver Incidencia
              </Button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
