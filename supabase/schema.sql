create extension if not exists pgcrypto;

create or replace function public.handle_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create table if not exists public.users (
  id uuid primary key references auth.users (id) on delete cascade,
  email text not null,
  full_name text not null default 'Farmer',
  auto_irrigation_enabled boolean not null default true,
  notifications_enabled boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.zones (
  id text primary key,
  name text not null,
  soil_moisture numeric(5,2) not null default 0,
  temperature numeric(5,2) not null default 0,
  humidity numeric(5,2) not null default 0,
  current_stress text not null default 'healthy'
    check (current_stress in ('healthy', 'warning', 'critical')),
  predicted_stress text not null default 'healthy'
    check (predicted_stress in ('healthy', 'warning', 'critical')),
  auto_irrigation_enabled boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.sensor_data (
  id text primary key,
  zone_id text not null references public.zones (id) on delete cascade,
  soil_moisture numeric(5,2) not null,
  temperature numeric(5,2) not null,
  humidity numeric(5,2) not null,
  recorded_at timestamptz not null default now()
);

create table if not exists public.predictions (
  id uuid primary key default gen_random_uuid(),
  zone_id text not null references public.zones (id) on delete cascade,
  stress_probability numeric(5,4) not null,
  stress_level text not null
    check (stress_level in ('healthy', 'warning', 'critical')),
  forecast_hours integer not null default 4,
  summary text not null default 'Conditions stable.',
  created_at timestamptz not null default now()
);

create table if not exists public.alerts (
  id text primary key,
  zone_id text not null references public.zones (id) on delete cascade,
  title text not null,
  message text not null,
  type text not null,
  is_read boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.actions (
  id text primary key,
  zone_id text not null references public.zones (id) on delete cascade,
  action_type text not null,
  status text not null,
  notes text not null default '',
  created_at timestamptz not null default now()
);

create table if not exists public.iot_devices (
  id text primary key,
  zone_id text not null references public.zones (id) on delete cascade,
  name text not null,
  connection_state text not null default 'online'
    check (connection_state in ('online', 'warning', 'offline')),
  last_seen timestamptz not null default now(),
  battery_level integer not null default 100,
  signal_strength integer not null default 100,
  firmware_version text not null default '1.0.0',
  pump_online boolean not null default true,
  pending_sync boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_sensor_data_zone_recorded_at
  on public.sensor_data (zone_id, recorded_at desc);

create index if not exists idx_predictions_zone_created_at
  on public.predictions (zone_id, created_at desc);

create index if not exists idx_alerts_created_at
  on public.alerts (created_at desc);

create index if not exists idx_actions_zone_created_at
  on public.actions (zone_id, created_at desc);

create index if not exists idx_iot_devices_zone_last_seen
  on public.iot_devices (zone_id, last_seen desc);

drop trigger if exists trg_users_updated_at on public.users;
create trigger trg_users_updated_at
before update on public.users
for each row
execute function public.handle_updated_at();

drop trigger if exists trg_zones_updated_at on public.zones;
create trigger trg_zones_updated_at
before update on public.zones
for each row
execute function public.handle_updated_at();

drop trigger if exists trg_iot_devices_updated_at on public.iot_devices;
create trigger trg_iot_devices_updated_at
before update on public.iot_devices
for each row
execute function public.handle_updated_at();

alter table public.users enable row level security;
alter table public.zones enable row level security;
alter table public.sensor_data enable row level security;
alter table public.predictions enable row level security;
alter table public.alerts enable row level security;
alter table public.actions enable row level security;
alter table public.iot_devices enable row level security;

drop policy if exists "users_select_own_profile" on public.users;
create policy "users_select_own_profile"
on public.users
for select
to authenticated
using (auth.uid() = id);

drop policy if exists "users_upsert_own_profile" on public.users;
create policy "users_upsert_own_profile"
on public.users
for all
to authenticated
using (auth.uid() = id)
with check (auth.uid() = id);

drop policy if exists "zones_read_authenticated" on public.zones;
create policy "zones_read_authenticated"
on public.zones
for select
to authenticated
using (true);

drop policy if exists "zones_update_authenticated" on public.zones;
create policy "zones_update_authenticated"
on public.zones
for update
to authenticated
using (true)
with check (true);

drop policy if exists "sensor_data_read_authenticated" on public.sensor_data;
create policy "sensor_data_read_authenticated"
on public.sensor_data
for select
to authenticated
using (true);

drop policy if exists "sensor_data_insert_authenticated" on public.sensor_data;
create policy "sensor_data_insert_authenticated"
on public.sensor_data
for insert
to authenticated
with check (true);

drop policy if exists "predictions_read_authenticated" on public.predictions;
create policy "predictions_read_authenticated"
on public.predictions
for select
to authenticated
using (true);

drop policy if exists "predictions_insert_authenticated" on public.predictions;
create policy "predictions_insert_authenticated"
on public.predictions
for insert
to authenticated
with check (true);

drop policy if exists "alerts_read_authenticated" on public.alerts;
create policy "alerts_read_authenticated"
on public.alerts
for select
to authenticated
using (true);

drop policy if exists "alerts_update_authenticated" on public.alerts;
create policy "alerts_update_authenticated"
on public.alerts
for update
to authenticated
using (true)
with check (true);

drop policy if exists "alerts_insert_authenticated" on public.alerts;
create policy "alerts_insert_authenticated"
on public.alerts
for insert
to authenticated
with check (true);

drop policy if exists "actions_read_authenticated" on public.actions;
create policy "actions_read_authenticated"
on public.actions
for select
to authenticated
using (true);

drop policy if exists "actions_insert_authenticated" on public.actions;
create policy "actions_insert_authenticated"
on public.actions
for insert
to authenticated
with check (true);

drop policy if exists "iot_devices_read_authenticated" on public.iot_devices;
create policy "iot_devices_read_authenticated"
on public.iot_devices
for select
to authenticated
using (true);

drop policy if exists "iot_devices_insert_authenticated" on public.iot_devices;
create policy "iot_devices_insert_authenticated"
on public.iot_devices
for insert
to authenticated
with check (true);

drop policy if exists "iot_devices_update_authenticated" on public.iot_devices;
create policy "iot_devices_update_authenticated"
on public.iot_devices
for update
to authenticated
using (true)
with check (true);

insert into public.zones (
  id,
  name,
  soil_moisture,
  temperature,
  humidity,
  current_stress,
  predicted_stress,
  auto_irrigation_enabled
)
values
  ('zone-1', 'North Field', 62, 29, 58, 'healthy', 'warning', true),
  ('zone-2', 'Greenhouse A', 41, 31, 46, 'warning', 'critical', true),
  ('zone-3', 'Seedling Bed', 73, 27, 64, 'healthy', 'healthy', false)
on conflict (id) do update set
  name = excluded.name,
  soil_moisture = excluded.soil_moisture,
  temperature = excluded.temperature,
  humidity = excluded.humidity,
  current_stress = excluded.current_stress,
  predicted_stress = excluded.predicted_stress,
  auto_irrigation_enabled = excluded.auto_irrigation_enabled,
  updated_at = now();
