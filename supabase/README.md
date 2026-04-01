# Poblar Base de Datos con Datos Dummy - Greentor

Este documento explica cómo poblar la base de datos de Supabase con datos dummy para las tablas principales de Greentor MVP.

## Tablas Incluidas

### Principales (Semana 1)
- `companies`: Empresas con información básica (3 registros)
- `users`: Usuarios asociados a empresas (3 registros)
- `profiles`: Perfiles de usuarios (3 registros, id = users.id)
- `diagnostic_responses`: Respuestas de diagnóstico ESG (4 registros)
- `esg_scores`: Puntajes ESG calculados (3 registros)

### Adicionales (Semana 1)
- `survey_responses`: Respuestas de encuestas de usuarios (3 registros)
- `iros`: Indicadores de Riesgo Operacional (3 registros)
- `documents`: Documentos subidos por empresas (3 registros)
- `subscriptions`: Suscripciones de empresas (3 registros)
- `financial_scores`: Puntajes financieros (3 registros)
- `companies_profile`: Perfil generado por scraping (3 registros)
- `audit_log`: Registro de actividad (3 registros)
- `onboarding_jobs`: Estado de jobs de onboarding (3 registros)

## Requisitos

- Proyecto Supabase configurado
- Acceso al SQL Editor en dashboard.supabase.com
- Archivo `supabase/seed.sql` con el script completo

## Pasos para Poblar la Base de Datos

### 1. Preparación (opcional, si necesitas resetear)

Si tienes datos existentes y quieres empezar desde cero:

```sql
-- Ejecuta en orden para evitar errores de FK
DROP TABLE IF EXISTS public.documents;
DROP TABLE IF EXISTS public.esg_scores;
DROP TABLE IF EXISTS public.diagnostic_responses;
DROP TABLE IF EXISTS public.profiles;
DROP TABLE IF EXISTS public.users;
DROP TABLE IF EXISTS public.companies;
```

### 2. Ejecutar el Script de Seed

1. Ve a tu proyecto en Supabase.
2. Abre **SQL Editor**.
3. Copia y pega el contenido completo de `supabase/seed.sql`.
4. Haz click en **Run** (o ejecuta por bloques si prefieres validar paso a paso).

El script es idempotente: puedes ejecutarlo múltiples veces sin errores gracias a `ON CONFLICT (id) DO NOTHING`.

### 3. Verificación

Ejecuta estas consultas para confirmar:

```sql
-- Conteo de registros por tabla
SELECT
  (SELECT COUNT(*) FROM public.companies) AS companies,
  (SELECT COUNT(*) FROM public.users) AS users,
  (SELECT COUNT(*) FROM public.profiles) AS profiles,
  (SELECT COUNT(*) FROM public.diagnostic_responses) AS diagnostics,
  (SELECT COUNT(*) FROM public.esg_scores) AS esg,
  (SELECT COUNT(*) FROM public.survey_responses) AS survey_responses,
  (SELECT COUNT(*) FROM public.iros) AS iros,
  (SELECT COUNT(*) FROM public.documents) AS documents,
  (SELECT COUNT(*) FROM public.subscriptions) AS subscriptions,
  (SELECT COUNT(*) FROM public.financial_scores) AS financial_scores,
  (SELECT COUNT(*) FROM public.companies_profile) AS companies_profile,
  (SELECT COUNT(*) FROM public.audit_log) AS audit_log,
  (SELECT COUNT(*) FROM public.onboarding_jobs) AS onboarding_jobs;

-- Ver datos de ejemplo
SELECT * FROM public.companies LIMIT 3;
SELECT * FROM public.users LIMIT 3;
```

**Resultados esperados:**
- companies: 3
- users: 3
- profiles: 3
- diagnostics: 4
- esg: 3
- survey_responses: 3
- iros: 3
- documents: 3
- subscriptions: 3
- financial_scores: 3
- companies_profile: 3
- audit_log: 3
- onboarding_jobs: 3

## Notas Importantes

- **Orden de ejecución**: El script crea tablas en orden de dependencias (companies → users → profiles → diagnostic_responses → esg_scores → survey_responses → iros → documents → subscriptions → financial_scores).
- **FKs**: Todas las FK están definidas correctamente (users.company_id → companies.id, profiles.id → users.id, etc.).
- **Idempotente**: Usa `ON CONFLICT (id) DO NOTHING` para evitar duplicados.
- **Triggers**: Incluye triggers para `updated_at` en `users` y `profiles`.
- **Ambiente**: Diseñado para desarrollo/test. No uses en producción sin backup.

## Troubleshooting

- **Error 23503 (FK violation)**: Verifica que `companies` esté poblada antes de `users`.
- **Error 23505 (PK duplicate)**: El script es idempotente, pero si tienes constraints rotos, resetea con `DROP TABLE`.
- **Error 2BP01 (dependencias)**: Borra tablas dependientes primero (ej: `documents` antes de `companies`).

## Datos de Ejemplo

- **Empresas**: EcoFoods S.A. (Chile), VerdeTech LLC (México), AguaNet SAS (Colombia)
- **Usuarios**: Ana Martínez (admin), Juan Pérez (editor), Laura Gómez (viewer)
- **Diagnósticos**: Respuestas ESG en pilares E, S, G
- **Puntajes ESG**: Cálculos de riesgo (bajo, medio)
- **Encuestas**: Respuestas de usuarios a surveys 2025
- **IROs**: Emisiones CO2, Índice de Accidentes, Diversidad en Junta
- **Documentos**: Informes anuales, políticas ESG, certificaciones
- **Suscripciones**: Planes Startup/Growth/Corporate con MRR
- **Puntajes Financieros**: Revenue, profit margin, debt ratio por año

Si necesitas más datos o modificar el seed, edita `supabase/seed.sql` y re-ejecuta.