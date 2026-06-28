-- ============================================================================
--  CONFIGURACIÓN DE LA BASE DE DATOS PARA "Menú Semanal" (app pública, sin login)
-- ============================================================================
--  PROBLEMA QUE ARREGLA: la tabla "kv" existía y se podía LEER, pero las reglas
--  de seguridad (Row Level Security) BLOQUEABAN la escritura con la clave
--  pública. Por eso no se guardaba nada (error: 42501 "new row violates
--  row-level security policy for table kv").
--
--  CÓMO USARLO:
--   1. Entra en https://supabase.com  ->  tu proyecto.
--   2. Menú lateral  ->  "SQL Editor"  ->  "New query".
--   3. Pega TODO este archivo y pulsa "Run".
--   4. Recarga la app: ya se guardará todo en la base de datos.
--
--  Es seguro ejecutarlo más de una vez (es idempotente).
-- ============================================================================

-- 1) Tabla clave-valor (si no existe ya).
create table if not exists public.kv (
  key        text primary key,
  data       jsonb,
  updated_at timestamptz default now()
);

-- 2) Activar Row Level Security en la tabla.
alter table public.kv enable row level security;

-- 3) Borrar políticas anteriores con estos nombres (para no duplicarlas).
drop policy if exists "kv_public_select" on public.kv;
drop policy if exists "kv_public_insert" on public.kv;
drop policy if exists "kv_public_update" on public.kv;
drop policy if exists "kv_public_delete" on public.kv;

-- 4) App pública: permitir LEER y ESCRIBIR a cualquiera (clave anónima/pública).
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
