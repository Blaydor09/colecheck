import React, { useState } from 'react';
import { Button } from './Button';
import { Card } from './Card';
import { X, User, Phone, Mail, BookOpen, Key, Smartphone, Send, RefreshCw } from 'lucide-react';
import { useAppContext, type Teacher } from '../context/AppContext';

interface TeacherDetailsModalProps {
  teacher: Teacher;
  onClose: () => void;
}

export const TeacherDetailsModal: React.FC<TeacherDetailsModalProps> = ({ teacher, onClose }) => {
  const { teachers, generateTeacherAccess } = useAppContext();
  const [accessError, setAccessError] = useState<string | null>(null);
  const [isGeneratingAccess, setIsGeneratingAccess] = useState(false);

  const currentTeacher = teachers.find(t => t.id === teacher.id) || teacher;

  const handleGenerateAccess = async () => {
    setAccessError(null);
    setIsGeneratingAccess(true);

    try {
      await generateTeacherAccess(currentTeacher.id);
    } catch (err: any) {
      setAccessError(err.response?.data?.message || err.message || 'No se pudo generar el acceso.');
    } finally {
      setIsGeneratingAccess(false);
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
      <Card style={{ width: '100%', maxWidth: '500px' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 'var(--space-lg)' }}>
          <h2 style={{ margin: 0, fontSize: '20px' }}>Detalles del Maestro</h2>
          <Button variant="ghost" onClick={onClose} style={{ padding: '8px' }}>
            <X size={20} />
          </Button>
        </div>

        <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--space-xl)' }}>
          <div style={{ display: 'flex', gap: '16px', alignItems: 'center' }}>
            <div style={{
              width: '60px', height: '60px',
              borderRadius: '50%', backgroundColor: 'rgba(109, 29, 54, 0.1)',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              color: 'var(--primary)'
            }}>
              <User size={32} />
            </div>
            <div>
              <h3 style={{ margin: 0, fontSize: '18px' }}>{currentTeacher.name}</h3>
              <p style={{ margin: '4px 0 0 0', color: 'var(--on-surface-variant)', display: 'flex', alignItems: 'center', gap: '6px' }}>
                <BookOpen size={14} /> Curso: {currentTeacher.course}
              </p>
            </div>
          </div>

          <hr style={{ border: 'none', borderTop: '1px solid var(--border-light)', margin: 0 }} />

          <div>
            <h4 style={{ margin: '0 0 16px 0', color: 'var(--primary)', fontSize: '16px' }}>Informacion de Contacto</h4>
            <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                <Mail size={18} color="var(--on-surface-variant)" />
                <span>{currentTeacher.email}</span>
              </div>
              <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                <Phone size={18} color="var(--on-surface-variant)" />
                <span>{currentTeacher.phone}</span>
              </div>
            </div>
          </div>

          <hr style={{ border: 'none', borderTop: '1px solid var(--border-light)', margin: 0 }} />

          <div>
            <h4 style={{ margin: '0 0 16px 0', color: 'var(--primary)', fontSize: '16px', display: 'flex', alignItems: 'center', gap: '8px' }}>
              <Smartphone size={18} />
              Acceso App Personal/Escaner
            </h4>

            {!currentTeacher.hasAppAccess ? (
              <div style={{ backgroundColor: 'rgba(255, 200, 87, 0.1)', padding: '16px', borderRadius: '8px', border: '1px solid rgba(255, 200, 87, 0.3)' }}>
                <p style={{ margin: '0 0 12px 0', fontSize: '14px', color: 'var(--on-surface-variant)' }}>
                  El maestro aun no tiene credenciales para utilizar el escaner movil.
                </p>
                <Button
                  variant="primary"
                  onClick={handleGenerateAccess}
                  disabled={isGeneratingAccess}
                  style={{ width: '100%', justifyContent: 'center' }}
                >
                  <Key size={16} /> {isGeneratingAccess ? 'Generando...' : 'Generar Acceso'}
                </Button>
                {accessError && (
                  <p style={{ margin: '12px 0 0 0', color: 'var(--danger)', fontSize: '13px' }}>{accessError}</p>
                )}
              </div>
            ) : (
              <div style={{ backgroundColor: 'rgba(67, 185, 138, 0.05)', padding: '16px', borderRadius: '8px', border: '1px solid rgba(67, 185, 138, 0.2)' }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '12px' }}>
                  <div>
                    <p style={{ margin: 0, fontSize: '13px', color: 'var(--on-surface-variant)' }}>Usuario</p>
                    <p style={{ margin: '2px 0 0 0', fontWeight: 600 }}>{currentTeacher.email}</p>
                  </div>
                  <div style={{ padding: '4px 8px', backgroundColor: 'rgba(67, 185, 138, 0.1)', color: '#2B7A5A', borderRadius: '4px', fontSize: '12px', fontWeight: 600 }}>
                    Activo
                  </div>
                </div>
                <div style={{ marginBottom: '16px' }}>
                  <p style={{ margin: 0, fontSize: '13px', color: 'var(--on-surface-variant)' }}>Contrasena generada</p>
                  <p style={{ margin: '2px 0 0 0', fontWeight: 600, fontFamily: 'monospace', fontSize: '18px', letterSpacing: '3px' }}>
                    {currentTeacher.appPassword || 'No visible'}
                  </p>
                  {!currentTeacher.appPassword && (
                    <p style={{ margin: '4px 0 0 0', fontSize: '12px', color: 'var(--on-surface-variant)' }}>
                      Por seguridad, la contrasena guardada no se puede leer. Puedes regenerarla.
                    </p>
                  )}
                </div>
                <div style={{ display: 'flex', gap: '8px' }}>
                  <Button
                    variant="primary"
                    style={{ flex: 1, justifyContent: 'center', padding: '8px' }}
                    disabled={!currentTeacher.appPassword}
                    onClick={() => {
                      alert(`Envia estas credenciales a ${currentTeacher.email}:\n\nUsuario: ${currentTeacher.email}\nContrasena: ${currentTeacher.appPassword}`);
                    }}
                  >
                    <Send size={16} /> Enviar por Correo
                  </Button>
                  <Button
                    variant="ghost"
                    style={{ padding: '8px' }}
                    onClick={() => {
                      if (window.confirm('Seguro que deseas regenerar la contrasena del maestro?')) {
                        handleGenerateAccess();
                      }
                    }}
                    disabled={isGeneratingAccess}
                    title="Regenerar contrasena"
                  >
                    <RefreshCw size={16} />
                  </Button>
                </div>
                {accessError && (
                  <p style={{ margin: '12px 0 0 0', color: 'var(--danger)', fontSize: '13px' }}>{accessError}</p>
                )}
              </div>
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
