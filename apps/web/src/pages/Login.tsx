import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuthContext } from '../context/AuthContext';
import api from '../services/api';
import './Login.css';

export const Login: React.FC = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const [success, setSuccess] = useState(false);
  const { login } = useAuthContext();
  const navigate = useNavigate();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    try {
      const response = await api.post('/auth/login', { email, password });
      const user = response.data.user ?? response.data.data;

      if (response.data.success && response.data.token && user) {
        setSuccess(true);
        setTimeout(() => {
          login(response.data.token, user);
          navigate('/');
        }, 1000);
      } else {
        setError(response.data.message || 'Error de autenticación');
      }
    } catch (err: any) {
      console.error(err);
      setError(err.response?.data?.message || 'Error al conectar con el servidor');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="login-container">
      {/* Atmospheric Background Blobs */}
      <div className="login-blob login-blob--top-right" />
      <div className="login-blob login-blob--bottom-left" />

      <main className="login-main">
        <div className="login-card">

          {/* Brand Identity */}
          <div className="login-brand">
            <div className="login-brand__logo">
              <span className="material-symbols-outlined login-brand__icon">school</span>
              <span className="login-brand__name">Colecheck</span>
            </div>
            <h1 className="login-brand__title">Acceso Administrativo</h1>
            <p className="login-brand__subtitle">
              Ingrese sus credenciales para gestionar el plantel
            </p>
          </div>

          {/* Error Message */}
          {error && (
            <div className="login-error" role="alert">
              <span className="material-symbols-outlined login-error__icon">error</span>
              <span>{error}</span>
            </div>
          )}

          {/* Login Form */}
          <form onSubmit={handleSubmit} className="login-form" id="loginForm">
            <div className="form-group">
              <label htmlFor="email" className="form-label">Correo Electrónico</label>
              <div className="input-wrapper">
                <span className="material-symbols-outlined input-icon">mail</span>
                <input
                  type="email"
                  id="email"
                  className="form-input"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="admin@colegio.edu"
                  required
                />
              </div>
            </div>

            <div className="form-group">
              <label htmlFor="password" className="form-label">Contraseña</label>
              <div className="input-wrapper">
                <span className="material-symbols-outlined input-icon">lock</span>
                <input
                  type={showPassword ? 'text' : 'password'}
                  id="password"
                  className="form-input form-input--password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="••••••••"
                  required
                />
                <button
                  type="button"
                  className="input-toggle-password"
                  onClick={() => setShowPassword(!showPassword)}
                  aria-label={showPassword ? 'Ocultar contraseña' : 'Mostrar contraseña'}
                >
                  <span className="material-symbols-outlined">
                    {showPassword ? 'visibility_off' : 'visibility'}
                  </span>
                </button>
              </div>
              <div className="form-forgot">
                <a href="#" className="form-forgot__link">¿Olvidó su contraseña?</a>
              </div>
            </div>

            <div className="form-submit">
              <button
                type="submit"
                id="submitBtn"
                className={`login-button${success ? ' login-button--success' : ''}`}
                disabled={loading || success}
              >
                {success ? (
                  <>
                    <span className="material-symbols-outlined">check_circle</span>
                    <span>Bienvenido</span>
                  </>
                ) : loading ? (
                  <>
                    <span className="material-symbols-outlined login-spin">refresh</span>
                    <span>Autenticando...</span>
                  </>
                ) : (
                  <>
                    <span>Iniciar Sesión</span>
                    <span className="material-symbols-outlined">login</span>
                  </>
                )}
              </button>
            </div>
          </form>

          {/* Security Badge */}
          <div className="login-security">
            <span className="material-symbols-outlined login-security__icon">verified_user</span>
            <span className="login-security__text">Conexión Segura SSL</span>
          </div>
        </div>
      </main>

      {/* Footer */}
      <footer className="login-footer">
        <span className="material-symbols-outlined login-footer__icon">security</span>
        <p className="login-footer__label">Confianza y Seguridad Escolar</p>
        <span className="login-footer__dot" />
        <p className="login-footer__copy">© 2024 Colecheck. All rights reserved.</p>
      </footer>
    </div>
  );
};
