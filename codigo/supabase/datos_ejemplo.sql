-- Datos de ejemplo para probar la aplicacion.
--
-- Se corre una sola vez, en: Supabase > SQL Editor > New query > Run.
-- Vuelve a dejar la cartera como estaba cada vez que se ejecuta, asi que se
-- puede correr de nuevo sin miedo a duplicar nada.
--
-- Las fechas se calculan desde el dia en que se corre, no son fijas: por eso
-- siempre hay cuotas vencidas, una que vence hoy y otras por vencer, sin
-- importar cuando se ejecute.
--
-- ANTES DE CORRERLO: cambiar el correo de la linea de abajo por el correo con
-- el que se entro a la aplicacion.

do $$
declare
  v_usuario  uuid;
  v_correo   text := 'adalidgragedrojas@gmail.com';  -- <<< CAMBIAR ACA
  v_inicio   date;
begin

  select id into v_usuario from auth.users where email = v_correo;

  if v_usuario is null then
    raise exception 'No hay ninguna cuenta con el correo %. Revisa que sea el mismo con el que entraste a la app.', v_correo;
  end if;

  -- Se borra lo anterior de este usuario. El "on delete cascade" del esquema
  -- se lleva tambien sus prestamos, cuotas y pagos.
  delete from clientes where usuario_id = v_usuario;

  -- --- Clientes ------------------------------------------------------------

  insert into clientes (id, usuario_id, nombre, telefono, direccion) values
    ('cli-maria',  v_usuario, 'María Gutiérrez', '70011223', 'Av. Cristo Redentor, 3er anillo'),
    ('cli-juan',   v_usuario, 'Juan Pérez',      '69988776', 'Villa 1ro de Mayo, calle 4'),
    ('cli-rosa',   v_usuario, 'Rosa Chávez',     '71234567', 'Mercado Abasto, puesto 42'),
    ('cli-pedro',  v_usuario, 'Pedro Salazar',   '76543210', 'Plan 3000, av. principal');

  -- --- Prestamo 1: Maria, mensual, al dia ----------------------------------
  -- Presto 2.000 y le devuelve 2.400 en 6 cuotas de 400.
  -- Las dos primeras ya las pago; la tercera vence hoy.

  v_inicio := current_date - interval '2 months';

  insert into prestamos (id, usuario_id, cliente_id, capital, total_a_devolver,
                         moneda, frecuencia, cantidad_cuotas, fecha_inicio, mora_por_dia)
  values ('pre-maria', v_usuario, 'cli-maria', 2000, 2400, 'BOB', 'mensual', 6, v_inicio, 20);

  insert into cuotas (id, usuario_id, prestamo_id, numero, vence, monto, abonado)
  select 'cuo-maria-' || n, v_usuario, 'pre-maria', n,
         v_inicio + ((n - 1) * interval '1 month'),
         400,
         case when n <= 2 then 400 else 0 end
  from generate_series(1, 6) as n;

  insert into pagos (id, usuario_id, cuota_id, prestamo_id, monto, fecha)
  select 'pag-maria-' || n, v_usuario, 'cuo-maria-' || n, 'pre-maria', 400,
         v_inicio + ((n - 1) * interval '1 month')
  from generate_series(1, 2) as n;

  -- --- Prestamo 2: Juan, diario, atrasado ----------------------------------
  -- Presto 500 y le devuelve 650 en 26 cuotas de 25, todos los dias.
  -- Pago las 5 primeras y despues dejo de aparecer: la cuota 6 esta vencida.

  v_inicio := current_date - interval '10 days';

  insert into prestamos (id, usuario_id, cliente_id, capital, total_a_devolver,
                         moneda, frecuencia, cantidad_cuotas, fecha_inicio, mora_por_dia)
  values ('pre-juan', v_usuario, 'cli-juan', 500, 650, 'BOB', 'diario', 26, v_inicio, 5);

  insert into cuotas (id, usuario_id, prestamo_id, numero, vence, monto, abonado)
  select 'cuo-juan-' || n, v_usuario, 'pre-juan', n,
         v_inicio + ((n - 1) * interval '1 day'),
         25,
         case when n <= 5 then 25 else 0 end
  from generate_series(1, 26) as n;

  insert into pagos (id, usuario_id, cuota_id, prestamo_id, monto, fecha)
  select 'pag-juan-' || n, v_usuario, 'cuo-juan-' || n, 'pre-juan', 25,
         v_inicio + ((n - 1) * interval '1 day')
  from generate_series(1, 5) as n;

  -- --- Prestamo 3: Rosa, semanal, con una semana de atraso -----------------
  -- Presto 1.200 y le devuelve 1.440 en 12 cuotas semanales de 120.

  v_inicio := current_date - interval '3 weeks';

  insert into prestamos (id, usuario_id, cliente_id, capital, total_a_devolver,
                         moneda, frecuencia, cantidad_cuotas, fecha_inicio, mora_por_dia)
  values ('pre-rosa', v_usuario, 'cli-rosa', 1200, 1440, 'BOB', 'semanal', 12, v_inicio, 8);

  insert into cuotas (id, usuario_id, prestamo_id, numero, vence, monto, abonado)
  select 'cuo-rosa-' || n, v_usuario, 'pre-rosa', n,
         v_inicio + ((n - 1) * interval '1 week'),
         120,
         case when n <= 2 then 120 else 0 end
  from generate_series(1, 12) as n;

  insert into pagos (id, usuario_id, cuota_id, prestamo_id, monto, fecha)
  select 'pag-rosa-' || n, v_usuario, 'cuo-rosa-' || n, 'pre-rosa', 120,
         v_inicio + ((n - 1) * interval '1 week')
  from generate_series(1, 2) as n;

  -- --- Prestamo 4: Pedro, en dolares, todavia no vence ---------------------
  -- Presto 300 dolares y le devuelve 360 en 6 cuotas de 60.
  -- Sirve para ver que los totales en Bs y en dolares no se mezclan.

  v_inicio := current_date + interval '5 days';

  insert into prestamos (id, usuario_id, cliente_id, capital, total_a_devolver,
                         moneda, frecuencia, cantidad_cuotas, fecha_inicio, mora_por_dia)
  values ('pre-pedro', v_usuario, 'cli-pedro', 300, 360, 'USD', 'mensual', 6, v_inicio, 0);

  insert into cuotas (id, usuario_id, prestamo_id, numero, vence, monto, abonado)
  select 'cuo-pedro-' || n, v_usuario, 'pre-pedro', n,
         v_inicio + ((n - 1) * interval '1 month'),
         60,
         0
  from generate_series(1, 6) as n;

  raise notice 'Listo: 4 clientes, 4 prestamos y sus cuotas cargados.';

end $$;
