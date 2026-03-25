-- Seed data for Greentor MVP with RLS policies
-- 1) Crear políticas RLS (si no existen)

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'companies'
      AND policyname = 'companies_select_by_company'
  ) THEN
    CREATE POLICY companies_select_by_company
      ON public.companies
      FOR SELECT TO authenticated
      USING (id = get_current_company_id());
  END IF;
END$$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'companies'
      AND policyname = 'companies_update_by_company'
  ) THEN
    CREATE POLICY companies_update_by_company
      ON public.companies
      FOR UPDATE TO authenticated
      USING (id = get_current_company_id())
      WITH CHECK (id = get_current_company_id());
  END IF;
END$$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'companies'
      AND policyname = 'companies_delete_by_company'
  ) THEN
    CREATE POLICY companies_delete_by_company
      ON public.companies
      FOR DELETE TO authenticated
      USING (id = get_current_company_id());
  END IF;
END$$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'companies'
      AND policyname = 'companies_insert_self'
  ) THEN
    CREATE POLICY companies_insert_self
      ON public.companies
      FOR INSERT TO authenticated
      WITH CHECK (id = get_current_company_id());
  END IF;
END$$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'profiles'
      AND policyname = 'profiles_select_by_company'
  ) THEN
    CREATE POLICY profiles_select_by_company
      ON public.profiles
      FOR SELECT TO authenticated
      USING (company_id = get_current_company_id());
  END IF;
END$$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'profiles'
      AND policyname = 'profiles_insert_by_company'
  ) THEN
    CREATE POLICY profiles_insert_by_company
      ON public.profiles
      FOR INSERT TO authenticated
      WITH CHECK (company_id = get_current_company_id());
  END IF;
END$$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'profiles'
      AND policyname = 'profiles_update_by_company'
  ) THEN
    CREATE POLICY profiles_update_by_company
      ON public.profiles
      FOR UPDATE TO authenticated
      USING (company_id = get_current_company_id())
      WITH CHECK (company_id = get_current_company_id());
  END IF;
END$$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'profiles'
      AND policyname = 'profiles_delete_by_company'
  ) THEN
    CREATE POLICY profiles_delete_by_company
      ON public.profiles
      FOR DELETE TO authenticated
      USING (company_id = get_current_company_id());
  END IF;
END$$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'diagnostic_responses'
      AND policyname = 'diag_select_by_company'
  ) THEN
    CREATE POLICY diag_select_by_company
      ON public.diagnostic_responses
      FOR SELECT TO authenticated
      USING (company_id = get_current_company_id());
  END IF;
END$$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'diagnostic_responses'
      AND policyname = 'diag_insert_by_company'
  ) THEN
    CREATE POLICY diag_insert_by_company
      ON public.diagnostic_responses
      FOR INSERT TO authenticated
      WITH CHECK (company_id = get_current_company_id());
  END IF;
END$$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'diagnostic_responses'
      AND policyname = 'diag_update_by_company'
  ) THEN
    CREATE POLICY diag_update_by_company
      ON public.diagnostic_responses
      FOR UPDATE TO authenticated
      USING (company_id = get_current_company_id())
      WITH CHECK (company_id = get_current_company_id());
  END IF;
END$$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'diagnostic_responses'
      AND policyname = 'diag_delete_by_company'
  ) THEN
    CREATE POLICY diag_delete_by_company
      ON public.diagnostic_responses
      FOR DELETE TO authenticated
      USING (company_id = get_current_company_id());
  END IF;
END$$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'esg_scores'
      AND policyname = 'esg_select_by_company'
  ) THEN
    CREATE POLICY esg_select_by_company
      ON public.esg_scores
      FOR SELECT TO authenticated
      USING (company_id = get_current_company_id());
  END IF;
END$$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'esg_scores'
      AND policyname = 'esg_insert_by_company'
  ) THEN
    CREATE POLICY esg_insert_by_company
      ON public.esg_scores
      FOR INSERT TO authenticated
      WITH CHECK (company_id = get_current_company_id());
  END IF;
END$$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'esg_scores'
      AND policyname = 'esg_update_by_company'
  ) THEN
    CREATE POLICY esg_update_by_company
      ON public.esg_scores
      FOR UPDATE TO authenticated
      USING (company_id = get_current_company_id())
      WITH CHECK (company_id = get_current_company_id());
  END IF;
END$$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'esg_scores'
      AND policyname = 'esg_delete_by_company'
  ) THEN
    CREATE POLICY esg_delete_by_company
      ON public.esg_scores
      FOR DELETE TO authenticated
      USING (company_id = get_current_company_id());
  END IF;
END$$;

-- 2) Insertar datos dummy en orden correcto

-- Companies
INSERT INTO companies (
  id, name, industry, country, website_url, linkedin_url, size_range, plan,
  active, scraping_status, created_at, mrr, logins_last_7_days, diagnostic_progress
) VALUES
('00000000-0000-0000-0000-000000000001', 'EcoFoods S.A.', 'Alimentos', 'CL', 'https://ecofoods.cl',
 'https://linkedin.com/company/ecofoods', '51-200', 'Startup', true, 'completed', NOW() - INTERVAL '45 days',
 2500, 5, 70),
('00000000-0000-0000-0000-000000000002', 'VerdeTech LLC', 'Tecnología', 'MX', 'https://verdetech.mx',
 'https://linkedin.com/company/verdetech', '11-50', 'Growth', true, 'in_progress', NOW() - INTERVAL '20 days',
 4200, 3, 38),
('00000000-0000-0000-0000-000000000003', 'AguaNet SAS', 'Servicios', 'CO', 'https://aguanet.co',
 'https://linkedin.com/company/aguanet', '201-500', 'Corporate', false, 'failed', NOW() - INTERVAL '80 days',
 6800, 0, 15)
ON CONFLICT (id) DO NOTHING;

-- Users
INSERT INTO users (
  id, company_id, full_name, email, role, active, created_at
) VALUES
('11111111-1111-1111-1111-111111111111', '00000000-0000-0000-0000-000000000001', 'Ana Martínez', 'ana@ecofoods.cl', 'admin', true, NOW() - INTERVAL '44 days'),
('11111111-1111-1111-1111-111111111112', '00000000-0000-0000-0000-000000000002', 'Juan Pérez', 'juan@verdetech.mx', 'editor', true, NOW() - INTERVAL '19 days'),
('11111111-1111-1111-1111-111111111113', '00000000-0000-0000-0000-000000000003', 'Laura Gómez', 'laura@aguanet.co', 'viewer', false, NOW() - INTERVAL '79 days')
ON CONFLICT (id) DO NOTHING;

-- Profiles
INSERT INTO profiles (
  id, company_id, full_name, email, role, active, created_at
) VALUES
('11111111-1111-1111-1111-111111111111', '00000000-0000-0000-0000-000000000001', 'Ana Martínez', 'ana@ecofoods.cl', 'admin', true, NOW() - INTERVAL '44 days'),
('11111111-1111-1111-1111-111111111112', '00000000-0000-0000-0000-000000000002', 'Juan Pérez', 'juan@verdetech.mx', 'editor', true, NOW() - INTERVAL '19 days'),
('11111111-1111-1111-1111-111111111113', '00000000-0000-0000-0000-000000000003', 'Laura Gómez', 'laura@aguanet.co', 'viewer', false, NOW() - INTERVAL '79 days')
ON CONFLICT (id) DO NOTHING;

-- Diagnostic responses
INSERT INTO diagnostic_responses (
  id, company_id, section, question_id, iro, responsible_value, response_score,
  source_hint, is_prepopulated, validated_by_client, created_at
) VALUES
('22222222-2222-2222-2222-222222222221', '00000000-0000-0000-0000-000000000001', 'E', 'E1',
 'Emisiones', '70', 70, 'Análisis interno 2025', true, true, NOW() - INTERVAL '20 days'),
('22222222-2222-2222-2222-222222222222', '00000000-0000-0000-0000-000000000001', 'S', 'S1',
 'Condiciones laborales', '80', 80, 'Encuesta RRHH 2025', false, true, NOW() - INTERVAL '18 days'),
('22222222-2222-2222-2222-222222222223', '00000000-0000-0000-0000-000000000002', 'G', 'G1',
 'Gobierno corporativo', '65', 65, 'Política publicada Q1', true, false, NOW() - INTERVAL '5 days'),
('22222222-2222-2222-2222-222222222224', '00000000-0000-0000-0000-000000000002', 'E', 'E2',
 'Agua', '55', 55, 'Informe de consumo 2025', false, false, NOW() - INTERVAL '4 days')
ON CONFLICT (id) DO NOTHING;

-- ESG scores
INSERT INTO esg_scores (
  id, company_id, pillar, iro, score_e, score_b, score_country_multiplier,
  score_final, risk_level, calculated_at
) VALUES
('33333333-3333-3333-3333-333333333331', '00000000-0000-0000-0000-000000000001', 'E', 'Emisiones', 70, 60, 1.05, 66, 'medio', NOW() - INTERVAL '19 days'),
('33333333-3333-3333-3333-333333333332', '00000000-0000-0000-0000-000000000001', 'S', 'Condiciones laborales', 80, 75, 1.02, 78, 'bajo', NOW() - INTERVAL '18 days'),
('33333333-3333-3333-3333-333333333333', '00000000-0000-0000-0000-000000000002', 'G', 'Gobierno corporativo', 65, 67, 1.10, 71, 'medio', NOW() - INTERVAL '4 days')
ON CONFLICT (id) DO NOTHING;
