import React from 'react';
import './StatusChip.css';

export type StatusType = 'present' | 'absent' | 'late' | 'pending';

interface StatusChipProps {
  status: StatusType;
  label?: string;
}

const statusMap: Record<StatusType, { defaultLabel: string; className: string }> = {
  present: { defaultLabel: 'Ingreso', className: 'chip-success' },
  absent: { defaultLabel: 'Falta', className: 'chip-error' },
  late: { defaultLabel: 'Retraso', className: 'chip-warning' },
  pending: { defaultLabel: 'Pendiente', className: 'chip-pending' },
};

export const StatusChip: React.FC<StatusChipProps> = ({ status, label }) => {
  const config = statusMap[status];
  
  return (
    <span className={`status-chip ${config.className}`}>
      {label || config.defaultLabel}
    </span>
  );
};
