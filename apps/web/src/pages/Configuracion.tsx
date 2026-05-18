import React from 'react';
import { Card } from '../components/Card';
import { Button } from '../components/Button';
import { Settings, Bell, Shield, Database } from 'lucide-react';

export const Configuracion: React.FC = () => {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--space-xl)' }}>
      <header className="page-header">
        <div>
          <h2>Configuración del Sistema</h2>
          <p className="text-secondary">Administra los ajustes globales de Colecheck.</p>
        </div>
      </header>

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))', gap: 'var(--space-lg)' }}>
        <Card>
          <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '16px' }}>
            <Settings color="var(--primary)" />
            <h3 style={{ margin: 0 }}>General</h3>
          </div>
          <p style={{ color: 'var(--on-surface-variant)', fontSize: '14px', marginBottom: '24px' }}>Ajustes del colegio, horarios y políticas de asistencia.</p>
          <Button variant="secondary">Gestionar Ajustes</Button>
        </Card>

        <Card>
          <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '16px' }}>
            <Bell color="var(--primary)" />
            <h3 style={{ margin: 0 }}>Notificaciones</h3>
          </div>
          <p style={{ color: 'var(--on-surface-variant)', fontSize: '14px', marginBottom: '24px' }}>Configura las alertas enviadas a los padres y apoderados.</p>
          <Button variant="secondary">Configurar Alertas</Button>
        </Card>

        <Card>
          <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '16px' }}>
            <Shield color="var(--primary)" />
            <h3 style={{ margin: 0 }}>Roles y Permisos</h3>
          </div>
          <p style={{ color: 'var(--on-surface-variant)', fontSize: '14px', marginBottom: '24px' }}>Administra el acceso del personal docente y administrativo.</p>
          <Button variant="secondary">Gestionar Accesos</Button>
        </Card>

        <Card>
          <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '16px' }}>
            <Database color="var(--primary)" />
            <h3 style={{ margin: 0 }}>Dispositivos</h3>
          </div>
          <p style={{ color: 'var(--on-surface-variant)', fontSize: '14px', marginBottom: '24px' }}>Administra los lectores QR y cámaras de reconocimiento facial.</p>
          <Button variant="secondary">Ver Dispositivos</Button>
        </Card>
      </div>
    </div>
  );
};
