import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { Sidebar } from './components/Sidebar';
import { Dashboard } from './pages/Dashboard';
import { Incidencias } from './pages/Incidencias';
import { Asistencia } from './pages/Asistencia';
import { Estudiantes } from './pages/Estudiantes';
import { Maestros } from './pages/Maestros';
import { Configuracion } from './pages/Configuracion';
import { AppProvider } from './context/AppContext';
import { AuthProvider, useAuthContext } from './context/AuthContext';
import { Login } from './pages/Login';

const ProtectedRoute = ({ children }: { children: React.ReactNode }) => {
  const { isAuthenticated, loading } = useAuthContext();
  
  if (loading) {
    return <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '100vh' }}>Cargando...</div>;
  }
  
  if (!isAuthenticated) {
    return <Navigate to="/login" replace />;
  }
  
  return (
    <>
      <Sidebar />
      <main className="main-content" style={{ marginLeft: '260px' }}>
        {children}
      </main>
    </>
  );
};

function App() {
  return (
    <AuthProvider>
      <AppProvider>
        <Router>
          <div className="app-container">
            <Routes>
              <Route path="/login" element={<Login />} />
              <Route path="/*" element={
                <ProtectedRoute>
                  <Routes>
                    <Route path="/" element={<Dashboard />} />
                    <Route path="/attendance" element={<Asistencia />} />
                    <Route path="/incidents" element={<Incidencias />} />
                    <Route path="/students" element={<Estudiantes />} />
                    <Route path="/teachers" element={<Maestros />} />
                    <Route path="/settings" element={<Configuracion />} />
                    <Route path="*" element={<div style={{padding: '24px'}}><h2>Página no encontrada</h2></div>} />
                  </Routes>
                </ProtectedRoute>
              } />
            </Routes>
          </div>
        </Router>
      </AppProvider>
    </AuthProvider>
  );
}

export default App;
