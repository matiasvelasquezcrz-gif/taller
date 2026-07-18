-- =========================================================
-- TallerOS - Copiar TODO y pegar en Supabase SQL Editor > RUN
-- =========================================================

create extension if not exists "pgcrypto";

-- Clientes
create table if not exists clientes (
  id uuid primary key default gen_random_uuid(),
  nombre text not null,
  telefono text,
  created_at timestamptz default now()
);

-- Vehiculos
create table if not exists vehiculos (
  id uuid primary key default gen_random_uuid(),
  cliente_id uuid references clientes(id) on delete cascade,
  marca text,
  modelo text,
  anio text,
  placa text,
  created_at timestamptz default now()
);

-- Ordenes de trabajo
create table if not exists ordenes (
  id text primary key,
  cliente_id uuid references clientes(id),
  vehiculo_id uuid references vehiculos(id),
  problema text,
  estado text default 'pendiente',
  mecanico text default 'Sin asignar',
  fecha date default current_date,
  fecha_ingreso timestamptz default now(),
  fecha_salida timestamptz,
  created_at timestamptz default now()
);

-- Fotos
create table if not exists fotos (
  id uuid primary key default gen_random_uuid(),
  orden_id text references ordenes(id) on delete cascade,
  url text not null,
  created_at timestamptz default now()
);

-- Inventario
create table if not exists inventario (
  id uuid primary key default gen_random_uuid(),
  nombre text not null,
  cantidad int default 0,
  minimo int default 0,
  unidad text default 'pza'
);

-- Seguridad - borrar viejas y crear nuevas
ALTER TABLE clientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE vehiculos ENABLE ROW LEVEL SECURITY;
ALTER TABLE ordenes ENABLE ROW LEVEL SECURITY;
ALTER TABLE fotos ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventario ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "staff_clientes" ON clientes;
DROP POLICY IF EXISTS "staff_vehiculos" ON vehiculos;
DROP POLICY IF EXISTS "staff_ordenes" ON ordenes;
DROP POLICY IF EXISTS "staff_fotos" ON fotos;
DROP POLICY IF EXISTS "staff_inventario" ON inventario;
DROP POLICY IF EXISTS "allow_all_clientes" ON clientes;
DROP POLICY IF EXISTS "allow_all_vehiculos" ON vehiculos;
DROP POLICY IF EXISTS "allow_all_ordenes" ON ordenes;
DROP POLICY IF EXISTS "allow_all_fotos" ON fotos;
DROP POLICY IF EXISTS "allow_all_inventario" ON inventario;

CREATE POLICY "allow_all_clientes" ON clientes FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "allow_all_vehiculos" ON vehiculos FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "allow_all_ordenes" ON ordenes FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "allow_all_fotos" ON fotos FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "allow_all_inventario" ON inventario FOR ALL USING (true) WITH CHECK (true);
