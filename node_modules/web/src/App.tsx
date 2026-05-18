import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { Sidebar } from './components/Sidebar';
import { Dashboard } from './pages/Dashboard';
import { Incidencias } from './pages/Incidencias';
import { Asistencia } from './pages/Asistencia';
import { Estudiantes } from './pages/Estudiantes';
import { Maestros } from './pages/Maestros';
import { Configuracion } from './pages/Configuracion';
import { AppProvider } from './context/AppContext';

function App() {
  return (
    <AppProvider>
      <Router>
        <div className="app-container">
          <Sidebar />
          <main className="main-content" style={{ marginLeft: '260px' }}>
            <Routes>
              <Route path="/" element={<Dashboard />} />
              <Route path="/attendance" element={<Asistencia />} />
              <Route path="/incidents" element={<Incidencias />} />
              <Route path="/students" element={<Estudiantes />} />
              <Route path="/teachers" element={<Maestros />} />
              <Route path="/settings" element={<Configuracion />} />
              <Route path="*" element={<div style={{padding: '24px'}}><h2>Página no encontrada</h2></div>} />
            </Routes>
          </main>
        </div>
      </Router>
    </AppProvider>
  );
}

export default App;
