-- Colecheck database schema.
-- Target: PostgreSQL 16+.

BEGIN;

CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS citext;

DO $$ BEGIN CREATE TYPE school_status AS ENUM ('active', 'inactive'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE user_status AS ENUM ('invited', 'active', 'suspended', 'disabled'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE app_role AS ENUM ('system_admin', 'school_admin', 'director', 'teacher', 'attendance_staff', 'guardian'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE staff_kind AS ENUM ('director', 'admin', 'teacher', 'attendance_staff', 'security'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE staff_status AS ENUM ('active', 'inactive'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE student_status AS ENUM ('active', 'inactive', 'transferred', 'graduated'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE enrollment_status AS ENUM ('active', 'withdrawn', 'completed'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE guardian_relationship AS ENUM ('father', 'mother', 'tutor', 'relative', 'other'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE access_location_kind AS ENUM ('main_gate', 'gate', 'classroom', 'office', 'other'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE device_type AS ENUM ('mobile_app', 'qr_scanner', 'facial_camera', 'tablet', 'web_panel'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE device_status AS ENUM ('active', 'inactive', 'maintenance', 'lost'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE attendance_status AS ENUM ('pending', 'present', 'late', 'absent', 'justified', 'excused'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE attendance_method AS ENUM ('qr', 'facial', 'manual', 'system'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE attendance_direction AS ENUM ('entry', 'exit', 'status_update'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE attendance_event_result AS ENUM ('accepted', 'rejected', 'needs_review', 'duplicate'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE incident_type AS ENUM ('facial_not_recognized', 'invalid_qr', 'unidentified_visitor', 'manual_review', 'absence_without_notice', 'device_error', 'other'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE incident_status AS ENUM ('active', 'in_review', 'resolved', 'dismissed'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE incident_severity AS ENUM ('low', 'medium', 'high', 'critical'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE justification_status AS ENUM ('pending', 'approved', 'rejected', 'cancelled'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE biometric_status AS ENUM ('active', 'revoked', 'expired'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE notification_channel AS ENUM ('app', 'sms', 'email', 'whatsapp'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE notification_status AS ENUM ('queued', 'sent', 'delivered', 'read', 'failed', 'cancelled'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE notification_type AS ENUM ('attendance_entry', 'attendance_exit', 'late', 'absence', 'incident', 'justification', 'system'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE OR REPLACE FUNCTION touch_updated_at()
RETURNS trigger AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TABLE IF NOT EXISTS schools (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  slug citext NOT NULL UNIQUE,
  legal_name text,
  document_number text,
  timezone text NOT NULL DEFAULT 'America/La_Paz',
  country_code char(2) NOT NULL DEFAULT 'BO',
  email citext,
  phone text,
  address text,
  logo_url text,
  status school_status NOT NULL DEFAULT 'active',
  settings jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT schools_slug_format CHECK (slug::text ~ '^[a-z0-9][a-z0-9-]*$')
);

CREATE TABLE IF NOT EXISTS users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id uuid REFERENCES schools(id) ON DELETE CASCADE,
  email citext,
  document_number text,
  full_name text NOT NULL,
  phone text,
  avatar_url text,
  password_hash text,
  status user_status NOT NULL DEFAULT 'invited',
  last_login_at timestamptz,
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT users_login_identifier_required CHECK (email IS NOT NULL OR document_number IS NOT NULL)
);

CREATE UNIQUE INDEX IF NOT EXISTS users_email_unique
  ON users (email)
  WHERE email IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS users_school_document_unique
  ON users (school_id, document_number)
  WHERE school_id IS NOT NULL AND document_number IS NOT NULL;

CREATE INDEX IF NOT EXISTS users_school_status_idx ON users (school_id, status);

CREATE TABLE IF NOT EXISTS user_roles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  school_id uuid REFERENCES schools(id) ON DELETE CASCADE,
  role app_role NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS user_roles_unique_scope
  ON user_roles (user_id, (COALESCE(school_id, '00000000-0000-0000-0000-000000000000'::uuid)), role);

CREATE INDEX IF NOT EXISTS user_roles_school_role_idx ON user_roles (school_id, role);

CREATE TABLE IF NOT EXISTS guardians (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id uuid NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
  user_id uuid UNIQUE REFERENCES users(id) ON DELETE SET NULL,
  full_name text NOT NULL,
  document_number text NOT NULL,
  email citext,
  phone text,
  app_access_enabled boolean NOT NULL DEFAULT false,
  notification_enabled boolean NOT NULL DEFAULT true,
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (school_id, document_number)
);

CREATE UNIQUE INDEX IF NOT EXISTS guardians_school_email_unique
  ON guardians (school_id, email)
  WHERE email IS NOT NULL;

CREATE INDEX IF NOT EXISTS guardians_school_name_idx ON guardians (school_id, full_name);

CREATE TABLE IF NOT EXISTS staff_members (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id uuid NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
  user_id uuid UNIQUE REFERENCES users(id) ON DELETE SET NULL,
  employee_code text,
  full_name text NOT NULL,
  email citext,
  phone text,
  kind staff_kind NOT NULL DEFAULT 'teacher',
  status staff_status NOT NULL DEFAULT 'active',
  app_access_enabled boolean NOT NULL DEFAULT false,
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS staff_school_email_unique
  ON staff_members (school_id, email)
  WHERE email IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS staff_school_employee_unique
  ON staff_members (school_id, employee_code)
  WHERE employee_code IS NOT NULL;

CREATE INDEX IF NOT EXISTS staff_school_kind_idx ON staff_members (school_id, kind, status);

CREATE TABLE IF NOT EXISTS academic_years (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id uuid NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
  name text NOT NULL,
  starts_on date NOT NULL,
  ends_on date NOT NULL,
  is_active boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (school_id, name),
  CONSTRAINT academic_years_dates_check CHECK (ends_on >= starts_on)
);

CREATE UNIQUE INDEX IF NOT EXISTS academic_years_one_active_per_school
  ON academic_years (school_id)
  WHERE is_active;

CREATE TABLE IF NOT EXISTS grade_levels (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id uuid NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
  code text NOT NULL,
  name text NOT NULL,
  stage text NOT NULL,
  sort_order integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (school_id, code)
);

CREATE TABLE IF NOT EXISTS class_sections (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id uuid NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
  academic_year_id uuid NOT NULL REFERENCES academic_years(id) ON DELETE CASCADE,
  grade_level_id uuid NOT NULL REFERENCES grade_levels(id) ON DELETE RESTRICT,
  name text NOT NULL DEFAULT 'A',
  display_name text NOT NULL,
  homeroom_teacher_id uuid REFERENCES staff_members(id) ON DELETE SET NULL,
  room text,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (school_id, academic_year_id, grade_level_id, name)
);

CREATE INDEX IF NOT EXISTS class_sections_school_year_idx ON class_sections (school_id, academic_year_id, is_active);

CREATE TABLE IF NOT EXISTS students (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id uuid NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
  current_section_id uuid REFERENCES class_sections(id) ON DELETE SET NULL,
  student_code text NOT NULL,
  document_number text,
  full_name text NOT NULL,
  preferred_name text,
  birth_date date,
  gender text,
  status student_status NOT NULL DEFAULT 'active',
  photo_url text,
  enrollment_date date NOT NULL DEFAULT CURRENT_DATE,
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (school_id, student_code)
);

CREATE UNIQUE INDEX IF NOT EXISTS students_school_document_unique
  ON students (school_id, document_number)
  WHERE document_number IS NOT NULL;

CREATE INDEX IF NOT EXISTS students_school_status_idx ON students (school_id, status);
CREATE INDEX IF NOT EXISTS students_section_idx ON students (current_section_id);
CREATE INDEX IF NOT EXISTS students_school_name_idx ON students (school_id, full_name);

CREATE TABLE IF NOT EXISTS student_enrollments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id uuid NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  academic_year_id uuid NOT NULL REFERENCES academic_years(id) ON DELETE RESTRICT,
  class_section_id uuid NOT NULL REFERENCES class_sections(id) ON DELETE RESTRICT,
  status enrollment_status NOT NULL DEFAULT 'active',
  enrolled_on date NOT NULL DEFAULT CURRENT_DATE,
  withdrawn_on date,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (student_id, academic_year_id),
  CONSTRAINT student_enrollments_dates_check CHECK (withdrawn_on IS NULL OR withdrawn_on >= enrolled_on)
);

CREATE INDEX IF NOT EXISTS student_enrollments_section_idx ON student_enrollments (class_section_id, status);

CREATE TABLE IF NOT EXISTS student_guardians (
  student_id uuid NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  guardian_id uuid NOT NULL REFERENCES guardians(id) ON DELETE CASCADE,
  relationship guardian_relationship NOT NULL DEFAULT 'tutor',
  is_primary boolean NOT NULL DEFAULT false,
  can_pick_up boolean NOT NULL DEFAULT true,
  receives_notifications boolean NOT NULL DEFAULT true,
  emergency_contact_order integer,
  created_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (student_id, guardian_id)
);

CREATE UNIQUE INDEX IF NOT EXISTS student_guardians_one_primary
  ON student_guardians (student_id)
  WHERE is_primary;

CREATE INDEX IF NOT EXISTS student_guardians_guardian_idx ON student_guardians (guardian_id);

CREATE TABLE IF NOT EXISTS access_locations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id uuid NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
  name text NOT NULL,
  kind access_location_kind NOT NULL DEFAULT 'gate',
  description text,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (school_id, name)
);

CREATE TABLE IF NOT EXISTS devices (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id uuid NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
  location_id uuid REFERENCES access_locations(id) ON DELETE SET NULL,
  assigned_staff_id uuid REFERENCES staff_members(id) ON DELETE SET NULL,
  name text NOT NULL,
  type device_type NOT NULL,
  identifier text NOT NULL,
  status device_status NOT NULL DEFAULT 'active',
  last_seen_at timestamptz,
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (school_id, identifier)
);

CREATE INDEX IF NOT EXISTS devices_school_status_idx ON devices (school_id, status);
CREATE INDEX IF NOT EXISTS devices_location_idx ON devices (location_id);

CREATE TABLE IF NOT EXISTS school_settings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id uuid NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
  key text NOT NULL,
  value jsonb NOT NULL DEFAULT '{}'::jsonb,
  updated_by uuid REFERENCES users(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (school_id, key),
  CONSTRAINT school_settings_key_format CHECK (key ~ '^[a-z0-9_.-]+$')
);

CREATE TABLE IF NOT EXISTS attendance_policies (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id uuid NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
  section_id uuid REFERENCES class_sections(id) ON DELETE CASCADE,
  name text NOT NULL DEFAULT 'Default policy',
  days_of_week smallint[] NOT NULL DEFAULT ARRAY[1,2,3,4,5],
  entry_starts_at time NOT NULL DEFAULT '06:30',
  late_after time NOT NULL DEFAULT '08:00',
  absence_after time NOT NULL DEFAULT '09:00',
  exit_starts_at time,
  exit_ends_at time,
  notify_guardians boolean NOT NULL DEFAULT true,
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT attendance_policies_day_values CHECK (days_of_week <@ ARRAY[1,2,3,4,5,6,7]::smallint[])
);

CREATE UNIQUE INDEX IF NOT EXISTS attendance_policies_default_unique
  ON attendance_policies (school_id)
  WHERE section_id IS NULL;

CREATE UNIQUE INDEX IF NOT EXISTS attendance_policies_section_unique
  ON attendance_policies (section_id)
  WHERE section_id IS NOT NULL;

CREATE TABLE IF NOT EXISTS student_qr_credentials (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id uuid NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
  student_id uuid NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  token_hash text NOT NULL UNIQUE,
  label text,
  valid_from timestamptz NOT NULL DEFAULT now(),
  valid_until timestamptz,
  revoked_at timestamptz,
  created_by uuid REFERENCES users(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT student_qr_validity_check CHECK (valid_until IS NULL OR valid_until > valid_from)
);

CREATE INDEX IF NOT EXISTS student_qr_credentials_student_idx ON student_qr_credentials (student_id, revoked_at);

CREATE TABLE IF NOT EXISTS biometric_profiles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id uuid NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
  student_id uuid NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  provider text NOT NULL,
  template_ref text NOT NULL,
  template_hash text,
  quality_score numeric(5,2),
  status biometric_status NOT NULL DEFAULT 'active',
  enrolled_by uuid REFERENCES users(id) ON DELETE SET NULL,
  enrolled_at timestamptz NOT NULL DEFAULT now(),
  revoked_at timestamptz,
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (student_id, provider, template_ref),
  CONSTRAINT biometric_quality_check CHECK (quality_score IS NULL OR (quality_score >= 0 AND quality_score <= 100))
);

CREATE INDEX IF NOT EXISTS biometric_profiles_student_status_idx ON biometric_profiles (student_id, status);

CREATE TABLE IF NOT EXISTS attendance_records (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id uuid NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
  student_id uuid NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  class_section_id uuid REFERENCES class_sections(id) ON DELETE SET NULL,
  attendance_date date NOT NULL,
  status attendance_status NOT NULL DEFAULT 'pending',
  first_entry_at timestamptz,
  last_exit_at timestamptz,
  source attendance_method NOT NULL DEFAULT 'system',
  marked_by uuid REFERENCES users(id) ON DELETE SET NULL,
  notes text,
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (student_id, attendance_date)
);

CREATE INDEX IF NOT EXISTS attendance_records_school_date_idx ON attendance_records (school_id, attendance_date);
CREATE INDEX IF NOT EXISTS attendance_records_school_status_idx ON attendance_records (school_id, attendance_date, status);
CREATE INDEX IF NOT EXISTS attendance_records_student_date_idx ON attendance_records (student_id, attendance_date DESC);
CREATE INDEX IF NOT EXISTS attendance_records_section_date_idx ON attendance_records (class_section_id, attendance_date);

CREATE TABLE IF NOT EXISTS attendance_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id uuid NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
  attendance_record_id uuid REFERENCES attendance_records(id) ON DELETE SET NULL,
  student_id uuid REFERENCES students(id) ON DELETE SET NULL,
  event_time timestamptz NOT NULL DEFAULT now(),
  direction attendance_direction NOT NULL DEFAULT 'entry',
  method attendance_method NOT NULL,
  result attendance_event_result NOT NULL DEFAULT 'accepted',
  status_after attendance_status,
  location_id uuid REFERENCES access_locations(id) ON DELETE SET NULL,
  device_id uuid REFERENCES devices(id) ON DELETE SET NULL,
  recorded_by uuid REFERENCES users(id) ON DELETE SET NULL,
  scanned_token_hash text,
  biometric_match_score numeric(5,2),
  failure_reason text,
  notes text,
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT attendance_events_score_check CHECK (biometric_match_score IS NULL OR (biometric_match_score >= 0 AND biometric_match_score <= 100))
);

CREATE INDEX IF NOT EXISTS attendance_events_school_time_idx ON attendance_events (school_id, event_time DESC);
CREATE INDEX IF NOT EXISTS attendance_events_student_time_idx ON attendance_events (student_id, event_time DESC);
CREATE INDEX IF NOT EXISTS attendance_events_record_idx ON attendance_events (attendance_record_id);
CREATE INDEX IF NOT EXISTS attendance_events_device_time_idx ON attendance_events (device_id, event_time DESC);

CREATE OR REPLACE FUNCTION apply_attendance_event_to_daily_record()
RETURNS trigger AS $$
DECLARE
  school_timezone text;
  local_attendance_date date;
  current_class_section_id uuid;
  daily_record_id uuid;
BEGIN
  IF NEW.result <> 'accepted'::attendance_event_result
     OR NEW.student_id IS NULL
     OR NEW.status_after IS NULL THEN
    RETURN NEW;
  END IF;

  SELECT COALESCE(s.timezone, 'America/La_Paz')
    INTO school_timezone
  FROM schools s
  WHERE s.id = NEW.school_id;

  school_timezone := COALESCE(school_timezone, 'America/La_Paz');
  local_attendance_date := (NEW.event_time AT TIME ZONE school_timezone)::date;

  SELECT s.current_section_id
    INTO current_class_section_id
  FROM students s
  WHERE s.id = NEW.student_id;

  INSERT INTO attendance_records (
    school_id,
    student_id,
    class_section_id,
    attendance_date,
    status,
    first_entry_at,
    last_exit_at,
    source,
    marked_by,
    notes
  )
  VALUES (
    NEW.school_id,
    NEW.student_id,
    current_class_section_id,
    local_attendance_date,
    NEW.status_after,
    CASE WHEN NEW.direction = 'entry'::attendance_direction THEN NEW.event_time ELSE NULL END,
    CASE WHEN NEW.direction = 'exit'::attendance_direction THEN NEW.event_time ELSE NULL END,
    NEW.method,
    NEW.recorded_by,
    NEW.notes
  )
  ON CONFLICT (student_id, attendance_date) DO UPDATE SET
    class_section_id = COALESCE(attendance_records.class_section_id, EXCLUDED.class_section_id),
    status = CASE
      WHEN NEW.direction = 'exit'::attendance_direction THEN attendance_records.status
      ELSE EXCLUDED.status
    END,
    first_entry_at = CASE
      WHEN NEW.direction = 'entry'::attendance_direction THEN
        CASE
          WHEN attendance_records.first_entry_at IS NULL THEN NEW.event_time
          ELSE LEAST(attendance_records.first_entry_at, NEW.event_time)
        END
      ELSE attendance_records.first_entry_at
    END,
    last_exit_at = CASE
      WHEN NEW.direction = 'exit'::attendance_direction THEN
        GREATEST(COALESCE(attendance_records.last_exit_at, NEW.event_time), NEW.event_time)
      ELSE attendance_records.last_exit_at
    END,
    source = NEW.method,
    marked_by = COALESCE(NEW.recorded_by, attendance_records.marked_by),
    notes = COALESCE(NEW.notes, attendance_records.notes),
    updated_at = now()
  RETURNING id INTO daily_record_id;

  NEW.attendance_record_id := daily_record_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS attendance_events_apply_daily_record ON attendance_events;
CREATE TRIGGER attendance_events_apply_daily_record
  BEFORE INSERT ON attendance_events
  FOR EACH ROW
  EXECUTE FUNCTION apply_attendance_event_to_daily_record();

CREATE TABLE IF NOT EXISTS incidents (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id uuid NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
  student_id uuid REFERENCES students(id) ON DELETE SET NULL,
  attendance_event_id uuid REFERENCES attendance_events(id) ON DELETE SET NULL,
  device_id uuid REFERENCES devices(id) ON DELETE SET NULL,
  location_id uuid REFERENCES access_locations(id) ON DELETE SET NULL,
  type incident_type NOT NULL DEFAULT 'other',
  severity incident_severity NOT NULL DEFAULT 'medium',
  status incident_status NOT NULL DEFAULT 'active',
  title text NOT NULL,
  description text NOT NULL,
  occurred_at timestamptz NOT NULL DEFAULT now(),
  resolved_at timestamptz,
  resolved_by uuid REFERENCES users(id) ON DELETE SET NULL,
  resolution_note text,
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS incidents_school_status_idx ON incidents (school_id, status, occurred_at DESC);
CREATE INDEX IF NOT EXISTS incidents_student_idx ON incidents (student_id, occurred_at DESC);
CREATE INDEX IF NOT EXISTS incidents_active_idx ON incidents (school_id, occurred_at DESC) WHERE status IN ('active', 'in_review');

CREATE TABLE IF NOT EXISTS absence_justifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id uuid NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
  student_id uuid NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  attendance_record_id uuid REFERENCES attendance_records(id) ON DELETE SET NULL,
  submitted_by_guardian_id uuid REFERENCES guardians(id) ON DELETE SET NULL,
  reason text NOT NULL,
  evidence_url text,
  status justification_status NOT NULL DEFAULT 'pending',
  reviewed_by uuid REFERENCES users(id) ON DELETE SET NULL,
  reviewed_at timestamptz,
  review_note text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS absence_justifications_school_status_idx ON absence_justifications (school_id, status, created_at DESC);
CREATE INDEX IF NOT EXISTS absence_justifications_student_idx ON absence_justifications (student_id, created_at DESC);

CREATE UNIQUE INDEX IF NOT EXISTS absence_justifications_one_open_per_record
  ON absence_justifications (attendance_record_id)
  WHERE attendance_record_id IS NOT NULL AND status IN ('pending', 'approved');

CREATE TABLE IF NOT EXISTS notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id uuid NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
  recipient_user_id uuid REFERENCES users(id) ON DELETE SET NULL,
  student_id uuid REFERENCES students(id) ON DELETE SET NULL,
  attendance_record_id uuid REFERENCES attendance_records(id) ON DELETE SET NULL,
  incident_id uuid REFERENCES incidents(id) ON DELETE SET NULL,
  type notification_type NOT NULL,
  channel notification_channel NOT NULL,
  status notification_status NOT NULL DEFAULT 'queued',
  title text NOT NULL,
  body text NOT NULL,
  scheduled_for timestamptz NOT NULL DEFAULT now(),
  sent_at timestamptz,
  delivered_at timestamptz,
  read_at timestamptz,
  delivery_attempts integer NOT NULL DEFAULT 0,
  failure_reason text,
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS notifications_recipient_status_idx ON notifications (recipient_user_id, status, created_at DESC);
CREATE INDEX IF NOT EXISTS notifications_school_status_idx ON notifications (school_id, status, scheduled_for);
CREATE INDEX IF NOT EXISTS notifications_student_idx ON notifications (student_id, created_at DESC);

CREATE TABLE IF NOT EXISTS notification_preferences (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id uuid NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type notification_type NOT NULL,
  channel notification_channel NOT NULL,
  enabled boolean NOT NULL DEFAULT true,
  quiet_hours_from time,
  quiet_hours_to time,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, type, channel)
);

CREATE INDEX IF NOT EXISTS notification_preferences_school_user_idx ON notification_preferences (school_id, user_id);

CREATE TABLE IF NOT EXISTS push_device_tokens (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  platform text NOT NULL,
  token_hash text NOT NULL,
  device_name text,
  last_seen_at timestamptz,
  revoked_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, token_hash)
);

CREATE INDEX IF NOT EXISTS push_device_tokens_user_active_idx ON push_device_tokens (user_id, revoked_at);

CREATE TABLE IF NOT EXISTS audit_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id uuid REFERENCES schools(id) ON DELETE CASCADE,
  actor_user_id uuid REFERENCES users(id) ON DELETE SET NULL,
  action text NOT NULL,
  entity_type text NOT NULL,
  entity_id uuid,
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS audit_logs_school_time_idx ON audit_logs (school_id, created_at DESC);
CREATE INDEX IF NOT EXISTS audit_logs_actor_time_idx ON audit_logs (actor_user_id, created_at DESC);

CREATE OR REPLACE VIEW v_daily_attendance_summary AS
SELECT
  school_id,
  class_section_id,
  attendance_date,
  count(*)::integer AS total_records,
  count(*) FILTER (WHERE status = 'present')::integer AS present_count,
  count(*) FILTER (WHERE status = 'late')::integer AS late_count,
  count(*) FILTER (WHERE status = 'absent')::integer AS absent_count,
  count(*) FILTER (WHERE status = 'justified')::integer AS justified_count,
  count(*) FILTER (WHERE status = 'pending')::integer AS pending_count
FROM attendance_records
GROUP BY school_id, class_section_id, attendance_date;

CREATE OR REPLACE VIEW v_school_daily_attendance_summary AS
SELECT
  school_id,
  attendance_date,
  count(*)::integer AS total_records,
  count(*) FILTER (WHERE status = 'present')::integer AS present_count,
  count(*) FILTER (WHERE status = 'late')::integer AS late_count,
  count(*) FILTER (WHERE status = 'absent')::integer AS absent_count,
  count(*) FILTER (WHERE status = 'justified')::integer AS justified_count,
  count(*) FILTER (WHERE status = 'pending')::integer AS pending_count
FROM attendance_records
GROUP BY school_id, attendance_date;

CREATE OR REPLACE VIEW v_guardian_students AS
SELECT
  g.id AS guardian_id,
  g.user_id AS guardian_user_id,
  s.id AS student_id,
  s.school_id,
  s.student_code,
  s.full_name AS student_name,
  cs.display_name AS class_section,
  sg.relationship,
  sg.is_primary,
  sg.receives_notifications
FROM student_guardians sg
JOIN guardians g ON g.id = sg.guardian_id
JOIN students s ON s.id = sg.student_id
LEFT JOIN class_sections cs ON cs.id = s.current_section_id;

DO $$
DECLARE
  trigger_target record;
BEGIN
  FOR trigger_target IN
    SELECT *
    FROM (VALUES
      ('schools'),
      ('users'),
      ('guardians'),
      ('staff_members'),
      ('academic_years'),
      ('grade_levels'),
      ('class_sections'),
      ('students'),
      ('student_enrollments'),
      ('access_locations'),
      ('devices'),
      ('school_settings'),
      ('attendance_policies'),
      ('student_qr_credentials'),
      ('biometric_profiles'),
      ('attendance_records'),
      ('incidents'),
      ('absence_justifications'),
      ('notifications'),
      ('notification_preferences'),
      ('push_device_tokens')
    ) AS targets(table_name)
  LOOP
    EXECUTE format('DROP TRIGGER IF EXISTS %I ON %I', 'touch_' || trigger_target.table_name || '_updated_at', trigger_target.table_name);
    EXECUTE format(
      'CREATE TRIGGER %I BEFORE UPDATE ON %I FOR EACH ROW EXECUTE FUNCTION touch_updated_at()',
      'touch_' || trigger_target.table_name || '_updated_at',
      trigger_target.table_name
    );
  END LOOP;
END $$;

COMMIT;
