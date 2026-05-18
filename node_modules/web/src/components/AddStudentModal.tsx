import React, { useState, useRef, useEffect } from 'react';
import { Button } from './Button';
import { Card } from './Card';
import { X, Camera, Upload } from 'lucide-react';
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

  // Face image state
  const [faceImage, setFaceImage] = useState<string | null>(null);
  const [imageError, setImageError] = useState<string | null>(null);
  const [submitError, setSubmitError] = useState<string | null>(null);
  const [isSaving, setIsSaving] = useState(false);
  const [isCameraActive, setIsCameraActive] = useState(false);
  const videoRef = useRef<HTMLVideoElement>(null);
  const canvasRef = useRef<HTMLCanvasElement>(null);

  useEffect(() => {
    return () => {
      stopCamera();
    };
  }, []);

  const startCamera = async () => {
    try {
      setImageError(null);
      const stream = await navigator.mediaDevices.getUserMedia({ video: true });
      if (videoRef.current) {
        videoRef.current.srcObject = stream;
        videoRef.current.play();
        setIsCameraActive(true);
      }
    } catch (err) {
      setImageError('No se pudo acceder a la cámara. Verifique los permisos.');
    }
  };

  const stopCamera = () => {
    if (videoRef.current && videoRef.current.srcObject) {
      const stream = videoRef.current.srcObject as MediaStream;
      stream.getTracks().forEach(track => track.stop());
      setIsCameraActive(false);
    }
  };

  const capturePhoto = () => {
    if (videoRef.current && canvasRef.current) {
      const context = canvasRef.current.getContext('2d');
      if (context) {
        canvasRef.current.width = videoRef.current.videoWidth;
        canvasRef.current.height = videoRef.current.videoHeight;
        context.drawImage(videoRef.current, 0, 0);
        const imageDataUrl = canvasRef.current.toDataURL('image/jpeg');
        setFaceImage(imageDataUrl);
        stopCamera();
      }
    }
  };

  const handleFileUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    setImageError(null);
    const file = e.target.files?.[0];
    if (!file) return;

    if (!['image/jpeg', 'image/png'].includes(file.type)) {
      setImageError('Solo se permiten imágenes JPG o PNG.');
      return;
    }

    if (file.size > 5 * 1024 * 1024) {
      setImageError('La imagen no debe superar los 5MB.');
      return;
    }

    const reader = new FileReader();
    reader.onloadend = () => {
      setFaceImage(reader.result as string);
    };
    reader.readAsDataURL(file);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setSubmitError(null);
    setIsSaving(true);

    try {
      await addStudent(
        { name: studentName, grade: studentGrade, faceImage: faceImage || undefined },
        { name: parentName, dni: parentDni, email: parentEmail, phone: parentPhone }
      );
      onClose();
    } catch (err: any) {
      setSubmitError(err.response?.data?.message || err.message || 'No se pudo registrar el estudiante.');
    } finally {
      setIsSaving(false);
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

            {/* Captura de Imagen */}
            <div style={{ marginTop: 'var(--space-md)' }}>
              <label style={{ display: 'block', marginBottom: '8px', fontSize: '14px', color: 'var(--on-surface-variant)' }}>Fotografía (Reconocimiento Facial)</label>
              
              <div style={{ display: 'flex', gap: 'var(--space-md)', alignItems: 'flex-start' }}>
                <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: '8px' }}>
                  {!isCameraActive ? (
                    <Button type="button" variant="secondary" onClick={startCamera} style={{ width: '100%', display: 'flex', justifyContent: 'center', gap: '8px' }}>
                      <Camera size={18} /> Tomar Foto con Cámara
                    </Button>
                  ) : (
                    <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
                      <video ref={videoRef} style={{ width: '100%', borderRadius: '8px', border: '1px solid var(--border-light)', backgroundColor: '#000' }} autoPlay playsInline muted />
                      <canvas ref={canvasRef} style={{ display: 'none' }} />
                      <div style={{ display: 'flex', gap: '8px' }}>
                        <Button type="button" variant="primary" onClick={capturePhoto} style={{ flex: 1 }}>Capturar</Button>
                        <Button type="button" variant="secondary" onClick={stopCamera}>Cancelar</Button>
                      </div>
                    </div>
                  )}

                  <div style={{ textAlign: 'center', color: 'var(--on-surface-variant)', fontSize: '12px', margin: '4px 0' }}>O</div>

                  <label style={{ 
                    display: 'flex', justifyContent: 'center', alignItems: 'center', gap: '8px', 
                    padding: '8px 16px', borderRadius: '6px', border: '1px solid var(--border-light)', 
                    cursor: 'pointer', backgroundColor: 'var(--surface-container)', color: 'var(--on-surface)' 
                  }}>
                    <Upload size={18} /> Subir Imagen (JPG/PNG, Max 5MB)
                    <input type="file" accept="image/jpeg, image/png" style={{ display: 'none' }} onChange={handleFileUpload} />
                  </label>

                  {imageError && <div style={{ color: 'var(--danger)', fontSize: '12px', marginTop: '4px' }}>{imageError}</div>}
                </div>

                {/* Previsualización */}
                <div style={{ 
                  width: '120px', height: '120px', borderRadius: '8px', 
                  border: '1px dashed var(--border-light)', display: 'flex', 
                  alignItems: 'center', justifyContent: 'center', backgroundColor: 'var(--surface-container-high)',
                  overflow: 'hidden'
                }}>
                  {faceImage ? (
                    <img src={faceImage} alt="Vista previa" style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                  ) : (
                    <span style={{ fontSize: '12px', color: 'var(--on-surface-variant)', textAlign: 'center', padding: '8px' }}>Sin foto</span>
                  )}
                </div>
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
            {submitError && (
              <div style={{ marginRight: 'auto', color: 'var(--danger)', fontSize: '14px', alignSelf: 'center' }}>
                {submitError}
              </div>
            )}
            <Button variant="ghost" onClick={onClose} type="button">Cancelar</Button>
            <Button variant="primary" type="submit" disabled={isSaving}>
              {isSaving ? 'Guardando...' : 'Guardar Registro'}
            </Button>
          </div>
        </form>
      </Card>
    </div>
  );
};
