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
        login(response.data.token, user);
        navigate('/');
      } else {
        setError(response.data.message || 'Error de autenticacion');
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
      <div className="login-box">
        <div className="login-header">
          <h1>Colecheck</h1>
          <p>Bienvenido al Panel de Administracion</p>
        </div>

        {error && <div className="login-error">{error}</div>}

        <form onSubmit={handleSubmit} className="login-form">
          <div className="form-group">
            <label htmlFor="email">Correo o Documento</label>
            <input
              type="text"
              id="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="admin@colecheck.com"
              required
            />
          </div>

          <div className="form-group">
            <label htmlFor="password">Contrasena</label>
            <input
              type="password"
              id="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              placeholder="********"
              required
            />
          </div>

          <button type="submit" className="login-button" disabled={loading}>
            {loading ? 'Iniciando...' : 'Iniciar Sesion'}
          </button>
        </form>
      </div>
    </div>
  );
};
