insert into public.sensor_data (
  id,
  zone_id,
  soil_moisture,
  temperature,
  humidity,
  recorded_at
)
values
  ('zone-1-01', 'zone-1', 62, 29, 58, now() - interval '22 hours'),
  ('zone-1-02', 'zone-1', 61, 29.2, 57, now() - interval '20 hours'),
  ('zone-1-03', 'zone-1', 60, 29.5, 56, now() - interval '18 hours'),
  ('zone-1-04', 'zone-1', 59, 29.7, 55, now() - interval '16 hours'),
  ('zone-1-05', 'zone-1', 58, 30, 54, now() - interval '14 hours'),
  ('zone-1-06', 'zone-1', 57, 30.1, 54, now() - interval '12 hours'),
  ('zone-1-07', 'zone-1', 56, 30.3, 53, now() - interval '10 hours'),
  ('zone-1-08', 'zone-1', 55, 30.4, 53, now() - interval '8 hours'),
  ('zone-1-09', 'zone-1', 54, 30.2, 54, now() - interval '6 hours'),
  ('zone-1-10', 'zone-1', 53, 30.1, 55, now() - interval '4 hours'),
  ('zone-1-11', 'zone-1', 52, 29.8, 56, now() - interval '2 hours'),
  ('zone-1-12', 'zone-1', 51, 29.4, 57, now()),
  ('zone-2-01', 'zone-2', 43, 31, 46, now() - interval '22 hours'),
  ('zone-2-02', 'zone-2', 42, 31.1, 45, now() - interval '20 hours'),
  ('zone-2-03', 'zone-2', 41, 31.3, 45, now() - interval '18 hours'),
  ('zone-2-04', 'zone-2', 40, 31.6, 44, now() - interval '16 hours'),
  ('zone-2-05', 'zone-2', 39, 31.8, 44, now() - interval '14 hours'),
  ('zone-2-06', 'zone-2', 38, 32.0, 43, now() - interval '12 hours'),
  ('zone-2-07', 'zone-2', 37, 32.2, 43, now() - interval '10 hours'),
  ('zone-2-08', 'zone-2', 36, 32.3, 42, now() - interval '8 hours'),
  ('zone-2-09', 'zone-2', 35, 32.4, 42, now() - interval '6 hours'),
  ('zone-2-10', 'zone-2', 34, 32.1, 43, now() - interval '4 hours'),
  ('zone-2-11', 'zone-2', 33, 31.8, 44, now() - interval '2 hours'),
  ('zone-2-12', 'zone-2', 32, 31.5, 45, now()),
  ('zone-3-01', 'zone-3', 73, 27, 64, now() - interval '22 hours'),
  ('zone-3-02', 'zone-3', 73, 27.1, 64, now() - interval '20 hours'),
  ('zone-3-03', 'zone-3', 72, 27.0, 63, now() - interval '18 hours'),
  ('zone-3-04', 'zone-3', 72, 27.2, 63, now() - interval '16 hours'),
  ('zone-3-05', 'zone-3', 71, 27.3, 63, now() - interval '14 hours'),
  ('zone-3-06', 'zone-3', 71, 27.4, 62, now() - interval '12 hours'),
  ('zone-3-07', 'zone-3', 71, 27.4, 62, now() - interval '10 hours'),
  ('zone-3-08', 'zone-3', 70, 27.5, 62, now() - interval '8 hours'),
  ('zone-3-09', 'zone-3', 70, 27.6, 61, now() - interval '6 hours'),
  ('zone-3-10', 'zone-3', 69, 27.5, 61, now() - interval '4 hours'),
  ('zone-3-11', 'zone-3', 69, 27.3, 62, now() - interval '2 hours'),
  ('zone-3-12', 'zone-3', 68, 27.1, 63, now())
on conflict (id) do nothing;

insert into public.predictions (
  zone_id,
  stress_probability,
  stress_level,
  forecast_hours,
  summary
)
values
  ('zone-1', 0.46, 'warning', 6, 'Mild drought stress may appear later today.'),
  ('zone-2', 0.82, 'critical', 3, 'Rapid moisture decline detected.'),
  ('zone-3', 0.18, 'healthy', 8, 'Plant health is stable.');

insert into public.alerts (
  id,
  zone_id,
  title,
  message,
  type,
  is_read,
  created_at
)
values
  ('alert-1', 'zone-2', 'Drought Predicted', 'Greenhouse A may enter drought stress in 3 hours.', 'prediction', false, now() - interval '15 minutes'),
  ('alert-2', 'zone-1', 'Irrigation Triggered', 'Automatic irrigation completed for North Field.', 'action', true, now() - interval '1 hour'),
  ('alert-3', 'zone-3', 'Anomaly Detected', 'Humidity spike detected in Seedling Bed.', 'anomaly', false, now() - interval '2 hours')
on conflict (id) do update set
  title = excluded.title,
  message = excluded.message,
  type = excluded.type,
  is_read = excluded.is_read,
  created_at = excluded.created_at;

insert into public.actions (
  id,
  zone_id,
  action_type,
  status,
  notes,
  created_at
)
values
  ('action-1', 'zone-1', 'auto_irrigation', 'completed', 'Automatic drip cycle finished.', now() - interval '2 hours'),
  ('action-2', 'zone-2', 'manual_irrigation', 'completed', 'Pump activated successfully.', now() - interval '30 minutes')
on conflict (id) do update set
  action_type = excluded.action_type,
  status = excluded.status,
  notes = excluded.notes,
  created_at = excluded.created_at;

insert into public.iot_devices (
  id,
  zone_id,
  name,
  connection_state,
  last_seen,
  battery_level,
  signal_strength,
  firmware_version,
  pump_online,
  pending_sync
)
values
  ('node-1', 'zone-1', 'ESP32 North Field', 'online', now() - interval '2 minutes', 92, 88, '1.2.4', true, false),
  ('node-2', 'zone-2', 'ESP32 Greenhouse A', 'warning', now() - interval '12 minutes', 44, 57, '1.2.3', true, true),
  ('node-3', 'zone-3', 'ESP32 Seedling Bed', 'online', now() - interval '5 minutes', 76, 80, '1.2.4', false, false)
on conflict (id) do update set
  zone_id = excluded.zone_id,
  name = excluded.name,
  connection_state = excluded.connection_state,
  last_seen = excluded.last_seen,
  battery_level = excluded.battery_level,
  signal_strength = excluded.signal_strength,
  firmware_version = excluded.firmware_version,
  pump_online = excluded.pump_online,
  pending_sync = excluded.pending_sync;
