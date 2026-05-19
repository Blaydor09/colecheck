-- Demo data aligned with the current React and Flutter mocks.
-- Remove this file from docker-entrypoint-initdb.d for a clean production database.

BEGIN;

INSERT INTO schools (id, name, slug, legal_name, timezone, country_code, email, phone, address, status)
VALUES (
  '11111111-1111-4111-8111-111111111111',
  'Colecheck Demo School',
  'colecheck-demo',
  'Colecheck Demo School',
  'America/La_Paz',
  'BO',
  'admin@colecheck.com',
  '+59100000000',
  'Av. Principal 123',
  'active'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  slug = EXCLUDED.slug,
  timezone = EXCLUDED.timezone,
  updated_at = now();

-- Password hashes are pre-computed with Node.js bcrypt (cost 10) for compatibility.
-- ADMIN123, APP123, PROF123, CORTIZ1
INSERT INTO users (id, school_id, email, document_number, full_name, phone, password_hash, status)
VALUES
  ('11111111-1111-4111-8111-000000000001', '11111111-1111-4111-8111-111111111111', 'admin@colecheck.com', '90000001', 'Admin Colecheck', '+59170000001', '$2b$10$owawtKXTxByMvLVIyWF/cOdLk7skpNuvMOGSHo7soFN4zyE0CnHam', 'active'),
  ('11111111-1111-4111-8111-000000000002', '11111111-1111-4111-8111-111111111111', 'carlos@ejemplo.com', '12345678', 'Carlos Perez', '+123456789', '$2b$10$xdrjxQXykaj4ZlnNtPYxr.qnuXaJk/yd.ANL6Pxl5gJrfeFBwlhZa', 'active'),
  ('11111111-1111-4111-8111-000000000003', '11111111-1111-4111-8111-111111111111', 'fsalas@colecheck.com', '90000003', 'Lic. Fernando Salas', '+56987654321', '$2b$10$oc18UpWyYgutAPpGYyadmeiaZwjZaLNeodJGHmHvzHBe3rKafdVsu', 'active'),
  ('11111111-1111-4111-8111-000000000004', '11111111-1111-4111-8111-111111111111', 'cortiz@colecheck.com', '90000004', 'Prof. Carmen Ortiz', '+56912345678', '$2b$10$r0v1qugcWPCnH4GDtC7pEeIlrTCyYcyi7O.cDpNLDQtPbnRH.9WV.', 'invited'),
  ('11111111-1111-4111-8111-000000000005', '11111111-1111-4111-8111-111111111111', 'roberto@ejemplo.com', '87654321', 'Roberto Diaz', '+112233445', NULL, 'invited'),
  ('11111111-1111-4111-8111-000000000006', '11111111-1111-4111-8111-111111111111', 'elena@ejemplo.com', '11223344', 'Elena Silva', '+554433221', NULL, 'invited'),
  ('11111111-1111-4111-8111-000000000007', '11111111-1111-4111-8111-111111111111', 'william@ejemplo.com', '99887766', 'William Thompson', '+998877665', NULL, 'invited'),
  ('11111111-1111-4111-8111-000000000008', '11111111-1111-4111-8111-111111111111', 'sarah@ejemplo.com', '55667788', 'Sarah Wilson', '+556677889', NULL, 'invited')
ON CONFLICT (id) DO UPDATE SET
  email = EXCLUDED.email,
  document_number = EXCLUDED.document_number,
  full_name = EXCLUDED.full_name,
  phone = EXCLUDED.phone,
  password_hash = COALESCE(EXCLUDED.password_hash, users.password_hash),
  status = EXCLUDED.status,
  updated_at = now();

INSERT INTO user_roles (id, user_id, school_id, role)
VALUES
  ('12111111-1111-4111-8111-000000000001', '11111111-1111-4111-8111-000000000001', '11111111-1111-4111-8111-111111111111', 'school_admin'),
  ('12111111-1111-4111-8111-000000000002', '11111111-1111-4111-8111-000000000002', '11111111-1111-4111-8111-111111111111', 'guardian'),
  ('12111111-1111-4111-8111-000000000003', '11111111-1111-4111-8111-000000000003', '11111111-1111-4111-8111-111111111111', 'teacher'),
  ('12111111-1111-4111-8111-000000000004', '11111111-1111-4111-8111-000000000003', '11111111-1111-4111-8111-111111111111', 'attendance_staff'),
  ('12111111-1111-4111-8111-000000000005', '11111111-1111-4111-8111-000000000004', '11111111-1111-4111-8111-111111111111', 'teacher'),
  ('12111111-1111-4111-8111-000000000006', '11111111-1111-4111-8111-000000000005', '11111111-1111-4111-8111-111111111111', 'guardian'),
  ('12111111-1111-4111-8111-000000000007', '11111111-1111-4111-8111-000000000006', '11111111-1111-4111-8111-111111111111', 'guardian'),
  ('12111111-1111-4111-8111-000000000008', '11111111-1111-4111-8111-000000000007', '11111111-1111-4111-8111-111111111111', 'guardian'),
  ('12111111-1111-4111-8111-000000000009', '11111111-1111-4111-8111-000000000008', '11111111-1111-4111-8111-111111111111', 'guardian')
ON CONFLICT (id) DO NOTHING;

INSERT INTO guardians (id, school_id, user_id, full_name, document_number, email, phone, app_access_enabled)
VALUES
  ('22222222-2222-4222-8222-000000000001', '11111111-1111-4111-8111-111111111111', '11111111-1111-4111-8111-000000000002', 'Carlos Perez', '12345678', 'carlos@ejemplo.com', '+123456789', true),
  ('22222222-2222-4222-8222-000000000002', '11111111-1111-4111-8111-111111111111', '11111111-1111-4111-8111-000000000005', 'Roberto Diaz', '87654321', 'roberto@ejemplo.com', '+112233445', false),
  ('22222222-2222-4222-8222-000000000003', '11111111-1111-4111-8111-111111111111', '11111111-1111-4111-8111-000000000006', 'Elena Silva', '11223344', 'elena@ejemplo.com', '+554433221', false),
  ('22222222-2222-4222-8222-000000000004', '11111111-1111-4111-8111-111111111111', '11111111-1111-4111-8111-000000000007', 'William Thompson', '99887766', 'william@ejemplo.com', '+998877665', false),
  ('22222222-2222-4222-8222-000000000005', '11111111-1111-4111-8111-111111111111', '11111111-1111-4111-8111-000000000008', 'Sarah Wilson', '55667788', 'sarah@ejemplo.com', '+556677889', false)
ON CONFLICT (id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  document_number = EXCLUDED.document_number,
  email = EXCLUDED.email,
  phone = EXCLUDED.phone,
  app_access_enabled = EXCLUDED.app_access_enabled,
  updated_at = now();

INSERT INTO staff_members (id, school_id, user_id, employee_code, full_name, email, phone, kind, status, app_access_enabled)
VALUES
  ('33333333-3333-4333-8333-000000000001', '11111111-1111-4111-8111-111111111111', '11111111-1111-4111-8111-000000000003', 'T-001', 'Lic. Fernando Salas', 'fsalas@colecheck.com', '+56987654321', 'teacher', 'active', true),
  ('33333333-3333-4333-8333-000000000002', '11111111-1111-4111-8111-111111111111', '11111111-1111-4111-8111-000000000004', 'T-002', 'Prof. Carmen Ortiz', 'cortiz@colecheck.com', '+56912345678', 'teacher', 'active', false)
ON CONFLICT (id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  email = EXCLUDED.email,
  phone = EXCLUDED.phone,
  kind = EXCLUDED.kind,
  status = EXCLUDED.status,
  app_access_enabled = EXCLUDED.app_access_enabled,
  updated_at = now();

INSERT INTO academic_years (id, school_id, name, starts_on, ends_on, is_active)
VALUES ('44444444-4444-4444-8444-000000000001', '11111111-1111-4111-8111-111111111111', '2026', '2026-02-01', '2026-12-15', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  starts_on = EXCLUDED.starts_on,
  ends_on = EXCLUDED.ends_on,
  is_active = EXCLUDED.is_active,
  updated_at = now();

INSERT INTO grade_levels (id, school_id, code, name, stage, sort_order)
VALUES
  ('55555555-5555-4555-8555-000000000001', '11111111-1111-4111-8111-111111111111', '5P', '5to Primaria', 'Primaria', 5),
  ('55555555-5555-4555-8555-000000000002', '11111111-1111-4111-8111-111111111111', '1S', '1ro Secundaria', 'Secundaria', 7),
  ('55555555-5555-4555-8555-000000000003', '11111111-1111-4111-8111-111111111111', '2S', '2do Secundaria', 'Secundaria', 8),
  ('55555555-5555-4555-8555-000000000004', '11111111-1111-4111-8111-111111111111', '3S', '3ro Secundaria', 'Secundaria', 9),
  ('55555555-5555-4555-8555-000000000005', '11111111-1111-4111-8111-111111111111', '4S', '4to Secundaria', 'Secundaria', 10),
  ('55555555-5555-4555-8555-000000000006', '11111111-1111-4111-8111-111111111111', '5S', '5to Secundaria', 'Secundaria', 11)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  stage = EXCLUDED.stage,
  sort_order = EXCLUDED.sort_order,
  updated_at = now();

INSERT INTO class_sections (id, school_id, academic_year_id, grade_level_id, name, display_name, homeroom_teacher_id, room)
VALUES
  ('66666666-6666-4666-8666-000000000001', '11111111-1111-4111-8111-111111111111', '44444444-4444-4444-8444-000000000001', '55555555-5555-4555-8555-000000000004', 'A', '3ro Secundaria', '33333333-3333-4333-8333-000000000001', 'Aula S3-A'),
  ('66666666-6666-4666-8666-000000000002', '11111111-1111-4111-8111-111111111111', '44444444-4444-4444-8444-000000000001', '55555555-5555-4555-8555-000000000002', 'A', '1ro Secundaria', NULL, 'Aula S1-A'),
  ('66666666-6666-4666-8666-000000000003', '11111111-1111-4111-8111-111111111111', '44444444-4444-4444-8444-000000000001', '55555555-5555-4555-8555-000000000001', 'A', '5to Primaria', '33333333-3333-4333-8333-000000000002', 'Aula P5-A'),
  ('66666666-6666-4666-8666-000000000004', '11111111-1111-4111-8111-111111111111', '44444444-4444-4444-8444-000000000001', '55555555-5555-4555-8555-000000000003', 'A', '2do Secundaria', NULL, 'Aula S2-A'),
  ('66666666-6666-4666-8666-000000000005', '11111111-1111-4111-8111-111111111111', '44444444-4444-4444-8444-000000000001', '55555555-5555-4555-8555-000000000006', 'A', '5to Secundaria', NULL, 'Aula S5-A'),
  ('66666666-6666-4666-8666-000000000006', '11111111-1111-4111-8111-111111111111', '44444444-4444-4444-8444-000000000001', '55555555-5555-4555-8555-000000000005', 'A', '4to Secundaria', NULL, 'Aula S4-A')
ON CONFLICT (id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  homeroom_teacher_id = EXCLUDED.homeroom_teacher_id,
  room = EXCLUDED.room,
  updated_at = now();

INSERT INTO students (id, school_id, current_section_id, student_code, full_name, status, enrollment_date)
VALUES
  ('77777777-7777-4777-8777-000000000001', '11111111-1111-4111-8111-111111111111', '66666666-6666-4666-8666-000000000001', 'STU-0001', 'Juan Perez', 'active', '2026-02-01'),
  ('77777777-7777-4777-8777-000000000002', '11111111-1111-4111-8111-111111111111', '66666666-6666-4666-8666-000000000002', 'STU-0002', 'Maria Perez', 'active', '2026-02-01'),
  ('77777777-7777-4777-8777-000000000003', '11111111-1111-4111-8111-111111111111', '66666666-6666-4666-8666-000000000003', 'STU-0003', 'Carlos Diaz', 'active', '2026-02-01'),
  ('77777777-7777-4777-8777-000000000004', '11111111-1111-4111-8111-111111111111', '66666666-6666-4666-8666-000000000004', 'STU-0004', 'Ana Silva', 'active', '2026-02-01'),
  ('77777777-7777-4777-8777-000000000005', '11111111-1111-4111-8111-111111111111', '66666666-6666-4666-8666-000000000005', 'STU-0005', 'Emma Thompson', 'active', '2026-02-01'),
  ('77777777-7777-4777-8777-000000000006', '11111111-1111-4111-8111-111111111111', '66666666-6666-4666-8666-000000000006', 'STU-0006', 'James Wilson', 'active', '2026-02-01')
ON CONFLICT (id) DO UPDATE SET
  current_section_id = EXCLUDED.current_section_id,
  student_code = EXCLUDED.student_code,
  full_name = EXCLUDED.full_name,
  status = EXCLUDED.status,
  updated_at = now();

INSERT INTO student_enrollments (student_id, academic_year_id, class_section_id, status, enrolled_on)
VALUES
  ('77777777-7777-4777-8777-000000000001', '44444444-4444-4444-8444-000000000001', '66666666-6666-4666-8666-000000000001', 'active', '2026-02-01'),
  ('77777777-7777-4777-8777-000000000002', '44444444-4444-4444-8444-000000000001', '66666666-6666-4666-8666-000000000002', 'active', '2026-02-01'),
  ('77777777-7777-4777-8777-000000000003', '44444444-4444-4444-8444-000000000001', '66666666-6666-4666-8666-000000000003', 'active', '2026-02-01'),
  ('77777777-7777-4777-8777-000000000004', '44444444-4444-4444-8444-000000000001', '66666666-6666-4666-8666-000000000004', 'active', '2026-02-01'),
  ('77777777-7777-4777-8777-000000000005', '44444444-4444-4444-8444-000000000001', '66666666-6666-4666-8666-000000000005', 'active', '2026-02-01'),
  ('77777777-7777-4777-8777-000000000006', '44444444-4444-4444-8444-000000000001', '66666666-6666-4666-8666-000000000006', 'active', '2026-02-01')
ON CONFLICT (student_id, academic_year_id) DO UPDATE SET
  class_section_id = EXCLUDED.class_section_id,
  status = EXCLUDED.status,
  updated_at = now();

INSERT INTO student_guardians (student_id, guardian_id, relationship, is_primary, receives_notifications)
VALUES
  ('77777777-7777-4777-8777-000000000001', '22222222-2222-4222-8222-000000000001', 'father', true, true),
  ('77777777-7777-4777-8777-000000000002', '22222222-2222-4222-8222-000000000001', 'father', true, true),
  ('77777777-7777-4777-8777-000000000003', '22222222-2222-4222-8222-000000000002', 'father', true, true),
  ('77777777-7777-4777-8777-000000000004', '22222222-2222-4222-8222-000000000003', 'mother', true, true),
  ('77777777-7777-4777-8777-000000000005', '22222222-2222-4222-8222-000000000004', 'father', true, true),
  ('77777777-7777-4777-8777-000000000006', '22222222-2222-4222-8222-000000000005', 'mother', true, true)
ON CONFLICT (student_id, guardian_id) DO UPDATE SET
  relationship = EXCLUDED.relationship,
  is_primary = EXCLUDED.is_primary,
  receives_notifications = EXCLUDED.receives_notifications;

INSERT INTO access_locations (id, school_id, name, kind, description)
VALUES
  ('88888888-8888-4888-8888-000000000001', '11111111-1111-4111-8111-111111111111', 'Entrada Principal', 'main_gate', 'Punto principal de ingreso y salida'),
  ('88888888-8888-4888-8888-000000000002', '11111111-1111-4111-8111-111111111111', 'Puerta Norte', 'gate', 'Ingreso secundario'),
  ('88888888-8888-4888-8888-000000000003', '11111111-1111-4111-8111-111111111111', 'Puerta B', 'gate', 'Ingreso lateral')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  kind = EXCLUDED.kind,
  description = EXCLUDED.description,
  updated_at = now();

INSERT INTO devices (id, school_id, location_id, assigned_staff_id, name, type, identifier, status, last_seen_at)
VALUES
  ('99999999-9999-4999-8999-000000000001', '11111111-1111-4111-8111-111111111111', '88888888-8888-4888-8888-000000000001', '33333333-3333-4333-8333-000000000001', 'Movil Fernando Salas', 'mobile_app', 'mobile-fsalas-demo', 'active', '2026-05-17 08:15:00-04'),
  ('99999999-9999-4999-8999-000000000002', '11111111-1111-4111-8111-111111111111', '88888888-8888-4888-8888-000000000001', NULL, 'Camara Facial Entrada Principal', 'facial_camera', 'face-main-gate-demo', 'active', '2026-05-17 08:15:00-04'),
  ('99999999-9999-4999-8999-000000000003', '11111111-1111-4111-8111-111111111111', '88888888-8888-4888-8888-000000000002', NULL, 'Lector QR Puerta Norte', 'qr_scanner', 'qr-north-gate-demo', 'active', '2026-05-17 08:15:00-04')
ON CONFLICT (id) DO UPDATE SET
  location_id = EXCLUDED.location_id,
  assigned_staff_id = EXCLUDED.assigned_staff_id,
  name = EXCLUDED.name,
  type = EXCLUDED.type,
  identifier = EXCLUDED.identifier,
  status = EXCLUDED.status,
  last_seen_at = EXCLUDED.last_seen_at,
  updated_at = now();

INSERT INTO attendance_policies (id, school_id, name, entry_starts_at, late_after, absence_after, exit_starts_at, exit_ends_at, notify_guardians)
VALUES (
  'aaaaaaaa-aaaa-4aaa-8aaa-000000000001',
  '11111111-1111-4111-8111-111111111111',
  'Politica general',
  '06:30',
  '08:00',
  '09:00',
  '13:00',
  '16:00',
  true
)
ON CONFLICT (id) DO UPDATE SET
  entry_starts_at = EXCLUDED.entry_starts_at,
  late_after = EXCLUDED.late_after,
  absence_after = EXCLUDED.absence_after,
  notify_guardians = EXCLUDED.notify_guardians,
  updated_at = now();

INSERT INTO student_qr_credentials (id, school_id, student_id, token_hash, label, created_by)
VALUES
  ('bbbbbbbb-bbbb-4bbb-8bbb-000000000001', '11111111-1111-4111-8111-111111111111', '77777777-7777-4777-8777-000000000001', encode(digest('colecheck-demo:STU-0001', 'sha256'), 'hex'), 'QR principal', '11111111-1111-4111-8111-000000000001'),
  ('bbbbbbbb-bbbb-4bbb-8bbb-000000000002', '11111111-1111-4111-8111-111111111111', '77777777-7777-4777-8777-000000000002', encode(digest('colecheck-demo:STU-0002', 'sha256'), 'hex'), 'QR principal', '11111111-1111-4111-8111-000000000001')
ON CONFLICT (id) DO NOTHING;

INSERT INTO attendance_events (id, school_id, student_id, event_time, direction, method, result, status_after, location_id, device_id, recorded_by, scanned_token_hash)
VALUES
  ('cccccccc-cccc-4ccc-8ccc-000000000001', '11111111-1111-4111-8111-111111111111', '77777777-7777-4777-8777-000000000001', '2026-05-17 07:55:00-04', 'entry', 'qr', 'accepted', 'present', '88888888-8888-4888-8888-000000000001', '99999999-9999-4999-8999-000000000001', '11111111-1111-4111-8111-000000000003', encode(digest('colecheck-demo:STU-0001', 'sha256'), 'hex')),
  ('cccccccc-cccc-4ccc-8ccc-000000000002', '11111111-1111-4111-8111-111111111111', '77777777-7777-4777-8777-000000000002', '2026-05-17 08:05:00-04', 'entry', 'qr', 'accepted', 'late', '88888888-8888-4888-8888-000000000001', '99999999-9999-4999-8999-000000000001', '11111111-1111-4111-8111-000000000003', encode(digest('colecheck-demo:STU-0002', 'sha256'), 'hex')),
  ('cccccccc-cccc-4ccc-8ccc-000000000003', '11111111-1111-4111-8111-111111111111', '77777777-7777-4777-8777-000000000004', '2026-05-17 07:45:00-04', 'entry', 'manual', 'accepted', 'present', '88888888-8888-4888-8888-000000000001', '99999999-9999-4999-8999-000000000001', '11111111-1111-4111-8111-000000000003', NULL),
  ('cccccccc-cccc-4ccc-8ccc-000000000004', '11111111-1111-4111-8111-111111111111', '77777777-7777-4777-8777-000000000006', '2026-05-17 09:05:00-04', 'status_update', 'system', 'accepted', 'absent', '88888888-8888-4888-8888-000000000001', NULL, NULL, NULL)
ON CONFLICT (id) DO NOTHING;

INSERT INTO incidents (id, school_id, student_id, device_id, location_id, type, severity, status, title, description, occurred_at)
VALUES
  ('dddddddd-dddd-4ddd-8ddd-000000000001', '11111111-1111-4111-8111-111111111111', '77777777-7777-4777-8777-000000000005', '99999999-9999-4999-8999-000000000002', '88888888-8888-4888-8888-000000000001', 'facial_not_recognized', 'medium', 'active', 'Falla de reconocimiento facial', 'El rostro no pudo ser reconocido en la entrada principal.', '2026-05-17 08:11:00-04'),
  ('dddddddd-dddd-4ddd-8ddd-000000000002', '11111111-1111-4111-8111-111111111111', '77777777-7777-4777-8777-000000000006', '99999999-9999-4999-8999-000000000003', '88888888-8888-4888-8888-000000000002', 'invalid_qr', 'medium', 'active', 'Credencial no valida', 'Se rechazo un codigo QR en Puerta Norte.', '2026-05-17 08:00:00-04'),
  ('dddddddd-dddd-4ddd-8ddd-000000000003', '11111111-1111-4111-8111-111111111111', NULL, NULL, '88888888-8888-4888-8888-000000000003', 'unidentified_visitor', 'high', 'active', 'Visitante no identificado', 'Se detecto una persona sin credencial asociada.', '2026-05-17 07:30:00-04')
ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  title = EXCLUDED.title,
  description = EXCLUDED.description,
  updated_at = now();

INSERT INTO notifications (id, school_id, recipient_user_id, student_id, attendance_record_id, type, channel, status, title, body, sent_at)
SELECT
  'eeeeeeee-eeee-4eee-8eee-000000000001',
  ar.school_id,
  '11111111-1111-4111-8111-000000000002',
  ar.student_id,
  ar.id,
  'attendance_entry',
  'app',
  'sent',
  'Ingreso Registrado',
  'Juan Perez ingreso a las 07:55 AM.',
  '2026-05-17 07:55:10-04'
FROM attendance_records ar
WHERE ar.student_id = '77777777-7777-4777-8777-000000000001'
  AND ar.attendance_date = '2026-05-17'
ON CONFLICT (id) DO NOTHING;

COMMIT;
