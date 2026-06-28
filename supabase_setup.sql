-- ============================================================================
--  CONFIGURACIÓN DE LA BASE DE DATOS PARA "Menú Semanal" (app pública, sin login)
-- ============================================================================
--  Esta versión RECREA la tabla "kv" desde cero con EXACTAMENTE las columnas
--  que la app necesita. Es necesario porque la tabla anterior se había creado
--  con columnas de una plantilla con login (p.ej. "user_id NOT NULL"), y eso
--  bloqueaba el guardado en una app pública que no tiene usuarios
--  (error: 23502 "null value in column user_id ... violates not-null").
--
--  ES SEGURO: la tabla está vacía, no se pierde ningún dato.
--
--  CÓMO USARLO:
--   1. Entra en https://supabase.com  ->  tu proyecto.
--   2. Menú lateral  ->  "SQL Editor"  ->  "New query".
--   3. Pega TODO este archivo y pulsa "Run".
--   4. Recarga la app: ya se guardará todo en la base de datos.
-- ============================================================================

-- 1) Borrar la tabla anterior (está vacía) y crearla limpia.
drop table if exists public.kv cascade;

create table public.kv (
  key        text primary key,
  data       jsonb,
  updated_at timestamptz default now()
);

-- 2) Activar Row Level Security en la tabla.
alter table public.kv enable row level security;

-- 3) App pública: permitir LEER y ESCRIBIR a cualquiera (clave anónima/pública).
--    No hay login, así que los datos son compartidos por todos los que abren
--    la app, identificados solo por la "key" de cada caja de datos.
create policy "kv_public_select" on public.kv
  for select to anon, authenticated using (true);

create policy "kv_public_insert" on public.kv
  for insert to anon, authenticated with check (true);

create policy "kv_public_update" on public.kv
  for update to anon, authenticated using (true) with check (true);

create policy "kv_public_delete" on public.kv
  for delete to anon, authenticated using (true);
