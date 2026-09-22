-- Esquema de la base de datos en Supabase (PostgreSQL).
-- Pegar este archivo completo en: Supabase > SQL Editor > New query > Run.

-- Cada prestamista ve unicamente su propia cartera. La columna usuario_id
-- guarda quien creo el registro y las politicas de abajo lo hacen cumplir.

create table clientes (
  id           text primary key,
  usuario_id   uuid not null default auth.uid() references auth.users (id),
  nombre       text not null,
  telefono     text not null default '',
  direccion    text not null default '',
  creado_en    timestamptz not null default now()
);

create table prestamos (
  id                text primary key,
  usuario_id        uuid not null default auth.uid() references auth.users (id),
  cliente_id        text not null references clientes (id) on delete cascade,
  capital           numeric(12, 2) not null check (capital > 0),
  total_a_devolver  numeric(12, 2) not null check (total_a_devolver > 0),
  moneda            text not null default 'BOB' check (moneda in ('BOB', 'USD')),
  frecuencia        text not null check (frecuencia in ('diario', 'semanal', 'quincenal', 'mensual')),
  cantidad_cuotas   int not null check (cantidad_cuotas > 0),
  fecha_inicio      timestamptz not null,
  mora_por_dia      numeric(12, 2) not null default 0 check (mora_por_dia >= 0),
  creado_en         timestamptz not null default now()
);

create table cuotas (
  id           text primary key,
  usuario_id   uuid not null default auth.uid() references auth.users (id),
  prestamo_id  text not null references prestamos (id) on delete cascade,
  numero       int not null,
  vence        timestamptz not null,
  monto        numeric(12, 2) not null check (monto >= 0),
  abonado      numeric(12, 2) not null default 0 check (abonado >= 0),
  -- No se puede abonar mas de lo que vale la cuota.
  constraint abono_no_pasa_del_monto check (abonado <= monto)
);

create table pagos (
  id           text primary key,
  usuario_id   uuid not null default auth.uid() references auth.users (id),
  cuota_id     text not null references cuotas (id) on delete cascade,
  prestamo_id  text not null references prestamos (id) on delete cascade,
  monto        numeric(12, 2) not null check (monto > 0),
  fecha        timestamptz not null default now()
);

-- Indices para las dos consultas que mas se usan: la agenda del dia
-- (cuotas ordenadas por vencimiento) y los prestamos de un cliente.
create index cuotas_por_vencimiento on cuotas (usuario_id, vence);
create index prestamos_por_cliente on prestamos (cliente_id);
create index pagos_por_prestamo on pagos (prestamo_id, fecha desc);

-- Seguridad a nivel de fila: sin esto cualquiera con la llave publica
-- podria leer los nombres, telefonos y deudas de todos los clientes.
alter table clientes  enable row level security;
alter table prestamos enable row level security;
alter table cuotas    enable row level security;
alter table pagos     enable row level security;

create policy "cartera propia" on clientes
  for all using (usuario_id = auth.uid()) with check (usuario_id = auth.uid());

create policy "cartera propia" on prestamos
  for all using (usuario_id = auth.uid()) with check (usuario_id = auth.uid());

create policy "cartera propia" on cuotas
  for all using (usuario_id = auth.uid()) with check (usuario_id = auth.uid());

create policy "cartera propia" on pagos
  for all using (usuario_id = auth.uid()) with check (usuario_id = auth.uid());

-- ---------------------------------------------------------------------------
-- Perfil del prestamista
-- ---------------------------------------------------------------------------
-- Supabase identifica a la gente por correo, pero la app pide ademas un
-- nombre de usuario. Ese nombre, y la pregunta secreta que sirve para
-- recuperar la cuenta, se guardan aca.
--
-- La respuesta secreta nunca se guarda tal cual: se guarda su hash. Asi, si
-- alguien llegara a ver la tabla, no puede leer la respuesta.

create table perfiles (
  usuario_id        uuid primary key references auth.users (id) on delete cascade,
  nombre_usuario    text not null unique,
  pregunta_secreta  text not null,
  respuesta_hash    text not null,
  creado_en         timestamptz not null default now()
);

alter table perfiles enable row level security;

create policy "perfil propio" on perfiles
  for all using (usuario_id = auth.uid()) with check (usuario_id = auth.uid());

-- ---------------------------------------------------------------------------
-- Funciones para la recuperacion de cuenta
-- ---------------------------------------------------------------------------
-- Estas tres se llaman ANTES de iniciar sesion, cuando el RLS todavia no deja
-- leer nada. Por eso van como "security definer": corren con permisos del
-- dueno de la base en vez de los del visitante. Cada una devuelve lo minimo
-- indispensable y nada mas.

-- Dice si un nombre de usuario esta libre, para avisar al momento de crearlo.
create function usuario_disponible(p_usuario text)
returns boolean
language sql
security definer
set search_path = public
as $$
  select not exists (
    select 1 from perfiles where lower(nombre_usuario) = lower(trim(p_usuario))
  );
$$;

-- Devuelve la pregunta secreta de un usuario para mostrarsela al recuperar.
-- Si el usuario no existe devuelve null: no se confirma ni se niega nada mas.
create function pregunta_de(p_usuario text)
returns text
language sql
security definer
set search_path = public
as $$
  select pregunta_secreta from perfiles
  where lower(nombre_usuario) = lower(trim(p_usuario));
$$;

-- Si el nombre de usuario y el hash de la respuesta coinciden, devuelve el
-- correo de esa cuenta para poder mandarle el enlace de recuperacion.
-- Si no coinciden devuelve null, sin decir cual de los dos fallo.
create function correo_para_recuperar(p_usuario text, p_respuesta_hash text)
returns text
language sql
security definer
set search_path = public
as $$
  select u.email
  from perfiles p
  join auth.users u on u.id = p.usuario_id
  where lower(p.nombre_usuario) = lower(trim(p_usuario))
    and p.respuesta_hash = p_respuesta_hash;
$$;

-- Se habilitan para quien todavia no inicio sesion, que es justo cuando hacen falta.
grant execute on function usuario_disponible(text)          to anon, authenticated;
grant execute on function pregunta_de(text)                 to anon, authenticated;
grant execute on function correo_para_recuperar(text, text) to anon, authenticated;
