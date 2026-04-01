- Tabla companies
CREATE TABLE IF NOT EXISTS companies (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  industry text,
  country text,
  website_url text,
  linkedin_url text,
  size_range text,
  plan text,
  active boolean DEFAULT true,
  scraping_status text,
  created_at timestamp with time zone DEFAULT now(),
  mrr numeric,
  logins_last_7_days integer,
  diagnostic_progress integer
);

-- Tabla users
CREATE TABLE IF NOT EXISTS users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email text NOT NULL UNIQUE,
  password_hash text,
  role text NOT NULL,
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now()
);

-- Tabla profiles
CREATE TABLE IF NOT EXISTS profiles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES users(id) ON DELETE CASCADE,
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  full_name text,
  position text,
  phone text,
  created_at timestamp with time zone DEFAULT now()
);

-- Tabla diagnostic_responses
CREATE TABLE IF NOT EXISTS diagnostic_responses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  section text,
  question text,
  answer text,
  validated boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT now()
);

-- Tabla esg_scores
CREATE TABLE IF NOT EXISTS esg_scores (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  pillar text,
  value numeric,
  calculated_at timestamp with time zone DEFAULT now(),
  formula_version text
);

-- Tabla companies_profile
CREATE TABLE IF NOT EXISTS companies_profile (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  field_name text NOT NULL,
  value text,
  source text,
  collected_at timestamp with time zone DEFAULT now()
);

-- Tabla iros (catálogo de riesgos ESG)
CREATE TABLE IF NOT EXISTS iros (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code text NOT NULL UNIQUE,
  name text NOT NULL,
  sector text,
  pillar text CHECK (pillar IN ('E', 'S', 'G')),
  base_score numeric,
  is_active boolean DEFAULT true
);

-- Tabla documents
CREATE TABLE IF NOT EXISTS documents (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  category text,
  file_name text NOT NULL,
  file_url text NOT NULL,
  uploaded_at timestamp with time zone DEFAULT now()
);

-- Tabla subscriptions
CREATE TABLE IF NOT EXISTS subscriptions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  plan_type text NOT NULL,
  status text NOT NULL,
  start_date date,
  end_date date
);

-- Tabla audit_log
CREATE TABLE IF NOT EXISTS audit_log (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES users(id),
  table_name text NOT NULL,
  action text NOT NULL,
  record_id uuid,
  changed_at timestamp with time zone DEFAULT now(),
  details jsonb
);

-- Tabla onboarding_jobs
CREATE TABLE IF NOT EXISTS onboarding_jobs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  status text NOT NULL,
  started_at timestamp with time zone DEFAULT now(),
  finished_at timestamp with time zone,
  error_message text
);

-- Tabla survey_responses (si la necesitas además de diagnostic_responses)
CREATE TABLE IF NOT EXISTS survey_responses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  section text,
  question text,
  answer text,
  validated boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT now()
);

ALTER TABLE companies ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE diagnostic_responses ENABLE ROW LEVEL SECURITY;
ALTER TABLE esg_scores ENABLE ROW LEVEL SECURITY;
ALTER TABLE companies_profile ENABLE ROW LEVEL SECURITY;
ALTER TABLE documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE onboarding_jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE survey_responses ENABLE ROW LEVEL SECURITY;

UPDATE users SET role = 'super_admin' WHERE email = 'admin@tudominio.com';
UPDATE users SET role = 'admin_empresa' WHERE email = 'admin-empresa@tudominio.com';
UPDATE users SET role = 'editor_empresa' WHERE email = 'editor@tudominio.com';
UPDATE users SET role = 'viewer_empresa' WHERE email = 'viewer@tudominio.com';

UPDATE users SET role = 'admin_empresa' WHERE role = 'admin';
UPDATE users SET role = 'editor_empresa' WHERE role = 'editor';
UPDATE users SET role = 'viewer_empresa' WHERE role = 'viewer';

DROP POLICY IF EXISTS "Companies: Solo mi empresa" ON companies;

CREATE POLICY "Companies: Solo mi empresa"
ON companies
FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM users
    WHERE users.company_id = companies.id
      AND users.id = auth.uid()
  )
);

DROP POLICY IF EXISTS "Companies: Admin puede editar" ON companies;

CREATE POLICY "Companies: Admin puede editar"
ON companies
FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM users
    WHERE users.company_id = companies.id
      AND users.id = auth.uid()
      AND users.role = 'admin_empresa'
  )
);

DROP POLICY IF EXISTS "Companies: Admin puede borrar" ON companies;

CREATE POLICY "Companies: Admin puede borrar"
ON companies
FOR DELETE
USING (
  EXISTS (
    SELECT 1 FROM users
    WHERE users.company_id = companies.id
      AND users.id = auth.uid()
      AND users.role = 'admin_empresa'
  )
);

DROP POLICY IF EXISTS "Companies: Solo super_admin puede crear" ON companies;

CREATE POLICY "Companies: Solo super_admin puede crear"
ON companies
FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM users
    WHERE users.id = auth.uid()
      AND users.role = 'super_admin'
  )
);

DELETE FROM users WHERE id = '11111111-1111-1111-1111-111111111111';

DELETE FROM users WHERE id = '11111111-1111-1111-1111-111111111112';

DELETE FROM users WHERE id = '11111111-1111-1111-1111-111111111113';

INSERT INTO users (id, company_id, full_name, email, role, active, created_at)
VALUES
  ('11111111-1111-1111-1111-111111111111', '00000000-0000-0000-0000-000000000001', 'Ana Admin', 'ana@ecofoods.cl', 'admin_empresa', true, now()),
  ('11111111-1111-1111-1111-111111111112', '00000000-0000-0000-0000-000000000001', 'Juan Editor', 'juan@ecofoods.cl', 'editor_empresa', true, now()),
  ('11111111-1111-1111-1111-111111111113', '00000000-0000-0000-0000-000000000001', 'Laura Viewer', 'laura@ecofoods.cl', 'viewer_empresa', true, now());

-- Inserta dos empresas y devuelve sus UUIDs
INSERT INTO companies (id, name, created_at)
VALUES
  (gen_random_uuid(), 'Empresa Uno', NOW()),
  (gen_random_uuid(), 'Empresa Dos', NOW())
RETURNING id, name;

DELETE FROM users WHERE email IN (
  'isa@empresa1.com',
  'eli@empresa1.com',
  'vero@empresa1.com',
  'pedro@empresa2.com',
  'sofi@empresa2.com',
  'luis@empresa2.com'
);

DELETE FROM companies
WHERE id NOT IN (
  SELECT sub.min_id
  FROM (
    SELECT MIN(id::text)::uuid AS min_id
    FROM companies
    GROUP BY name
  ) sub
);

INSERT INTO users (id, company_id, full_name, email, role, active)
VALUES
  (gen_random_uuid(), '10336547-ee1a-4575-9ede-ec20b6474cb5', 'Isa Admin', 'isa@empresa1.com', 'admin_empresa', true),
  (gen_random_uuid(), '10336547-ee1a-4575-9ede-ec20b6474cb5', 'Eli Editor', 'eli@empresa1.com', 'editor_empresa', true),
  (gen_random_uuid(), '10336547-ee1a-4575-9ede-ec20b6474cb5', 'Vero Viewer', 'vero@empresa1.com', 'viewer_empresa', true),
  (gen_random_uuid(), '02f01c76-a92b-4e22-a6e1-a057c8e6225e', 'Pedro Admin', 'pedro@empresa2.com', 'admin_empresa', true),
  (gen_random_uuid(), '02f01c76-a92b-4e22-a6e1-a057c8e6225e', 'Sofi Editor', 'sofi@empresa2.com', 'editor_empresa', true),
  (gen_random_uuid(), '02f01c76-a92b-4e22-a6e1-a057c8e6225e', 'Luis Viewer', 'luis@empresa2.com', 'viewer_empresa', true);

DROP POLICY IF EXISTS "Solo mi empresa" ON companies;

CREATE POLICY "Solo mi empresa"
ON companies
FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM users
    WHERE users.company_id = companies.id
      AND users.id = auth.uid()
  )
);

DROP POLICY IF EXISTS "Usuarios pueden ver su propio registro" ON users;

CREATE POLICY "Usuarios pueden ver su propio registro"
ON users
FOR SELECT
USING (id = auth.uid());

SELECT u.full_name, u.role, c.name AS company_name
FROM users u
JOIN companies c ON u.company_id = c.id
WHERE u.id = 'a4565d7a-46f8-4834-9b87-3837c9409ae4';


