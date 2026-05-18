import React from 'react';
import { LayoutDashboard, Users, Clock, Settings, AlertCircle, BookOpen } from 'lucide-react';
import { NavLink } from 'react-router-dom';
import './Sidebar.css';

export const Sidebar: React.FC = () => {
  return (
    <aside className="sidebar">
      <div className="sidebar-header">
        <h1 className="brand-title">Colecheck</h1>
      </div>
      <nav className="sidebar-nav">
        <NavLink to="/" className={({ isActive }) => `nav-item ${isActive ? 'active' : ''}`}>
          <LayoutDashboard size={20} />
          <span>Dashboard</span>
        </NavLink>
        <NavLink to="/attendance" className={({ isActive }) => `nav-item ${isActive ? 'active' : ''}`}>
          <Clock size={20} />
          <span>Asistencia</span>
        </NavLink>
        <NavLink to="/students" className={({ isActive }) => `nav-item ${isActive ? 'active' : ''}`}>
          <Users size={20} />
          <span>Estudiantes</span>
        </NavLink>
        <NavLink to="/teachers" className={({ isActive }) => `nav-item ${isActive ? 'active' : ''}`}>
          <BookOpen size={20} />
          <span>Maestros</span>
        </NavLink>
        <NavLink to="/incidents" className={({ isActive }) => `nav-item ${isActive ? 'active' : ''}`}>
          <AlertCircle size={20} />
          <span>Incidencias</span>
        </NavLink>
        <div className="spacer"></div>
        <NavLink to="/settings" className={({ isActive }) => `nav-item ${isActive ? 'active' : ''}`}>
          <Settings size={20} />
          <span>Configuración</span>
        </NavLink>
      </nav>
    </aside>
  );
};
