-- =========================================================
-- TallerOS — Script de configuracion para Supabase
-- =========================================================
-- Paso 1: Pegar y ejecutar TODO en Supabase > SQL Editor > New query
-- Paso 2: Si la tabla ordenes ya existe, ejecutar solo las lineas
--         que dicen ALTER TABLE al final
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

-- Si la tabla ya existia, agregar las columnas nuevas:
ALTER TABLE ordenes ADD COLUMN IF NOT EXISTS fecha_ingreso timestamptz DEFAULT now();
ALTER TABLE ordenes ADD COLUMN IF NOT EXISTS fecha_salida timestamptz;

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

-- =========================================================
-- Seguridad
-- =========================================================
alter table clientes enable row level security;
alter table vehiculos enable row level security;
alter table ordenes enable row level security;
alter table fotos enable row level security;
alter table inventario enable row level security;

-- Borrar policies viejas si existen
DROP POLICY IF EXISTS "staff_clientes" ON clientes;
DROP POLICY IF EXISTS "staff_vehiculos" ON vehiculos;
DROP POLICY IF EXISTS "staff_ordenes" ON ordenes;
DROP POLICY IF EXISTS "staff_fotos" ON fotos;
DROP POLICY IF EXISTS "staff_inventario" ON inventario;

create policy "staff_clientes" on clientes for all
  using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "staff_vehiculos" on vehiculos for all
  using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "staff_ordenes" on ordenes for all
  using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "staff_fotos" on fotos for all
  using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "staff_inventario" on inventario for all
  using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

-- =========================================================
-- Datos de ejemplo (borrar despues desde la app)
-- =========================================================
insert into clientes (id, nombre, telefono) values
  ('11111111-1111-1111-1111-111111111111', 'Marvin Xitumul', '5512-3344'),
  ('22222222-2222-2222-2222-222222222222', 'Ana Lucia Perez', '4433-2211')
ON CONFLICT (id) DO NOTHING;

insert into vehiculos (id, cliente_id, marca, modelo, anio, placa) values
  ('33333333-3333-3333-3333-333333333333', '11111111-1111-1111-1111-111111111111', 'Toyota', 'Corolla', '2016', 'P-123ABC'),
  ('44444444-4444-4444-4444-444444444444', '22222222-2222-2222-2222-222222222222', 'Mazda', '3', '2019', 'P-987XYZ')
ON CONFLICT (id) DO NOTHING;

insert into ordenes (id, cliente_id, vehiculo_id, problema, estado, mecanico, fecha_ingreso) values
  ('OT-0001', '11111111-1111-1111-1111-111111111111', '33333333-3333-3333-3333-333333333333', 'Ruido en frenos delanteros al frenar', 'proceso', 'Byron', now() - interval '5 days'),
  ('OT-0002', '22222222-2222-2222-2222-222222222222', '44444444-4444-4444-4444-444444444444', 'Cambio de aceite y revision de 20,000 km', 'pendiente', 'Sin asignar', now())
ON CONFLICT (id) DO NOTHING;

insert into inventario (nombre, cantidad, minimo, unidad) values
  ('Pastillas de freno delanteras', 3, 4, 'juego'),
  ('Filtro de aceite', 12, 5, 'pza'),
  ('Aceite 5W-30 (litro)', 18, 10, 'litro'),
  ('Bujias', 2, 8, 'pza');
