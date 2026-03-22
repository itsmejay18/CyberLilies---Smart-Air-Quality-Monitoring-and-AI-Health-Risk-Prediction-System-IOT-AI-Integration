# ESP32 IoT Payload Contract

Use this payload shape when an ESP32 node sends telemetry to your backend or edge collector before writing to Supabase.

## Recommended JSON

```json
{
  "device_id": "node-1",
  "zone_id": "zone-1",
  "device_name": "ESP32 North Field",
  "timestamp": "2026-03-22T15:45:00Z",
  "firmware_version": "1.2.4",
  "connectivity": {
    "connection_state": "online",
    "signal_strength": 88,
    "battery_level": 92,
    "pending_sync": false
  },
  "environment": {
    "soil_moisture": 51.4,
    "temperature": 29.6,
    "humidity": 57.2
  },
  "actuators": {
    "pump_online": true,
    "relay_state": "off",
    "last_action": "auto_irrigation"
  },
  "optional": {
    "gas_ppm": 0,
    "crop_type": "lettuce",
    "growth_stage": "vegetative"
  }
}
```

## Suggested Backend Mapping

- Write `environment` into `sensor_data`
- Update the latest zone snapshot in `zones`
- Write AI output into `predictions`
- Write device health into `iot_devices`
- Write irrigation/relay events into `actions`
- Write important warnings into `alerts`

## Supabase Mapping Example

### `iot_devices`

```json
{
  "id": "node-1",
  "zone_id": "zone-1",
  "name": "ESP32 North Field",
  "connection_state": "online",
  "last_seen": "2026-03-22T15:45:00Z",
  "battery_level": 92,
  "signal_strength": 88,
  "firmware_version": "1.2.4",
  "pump_online": true,
  "pending_sync": false
}
```

### `sensor_data`

```json
{
  "id": "zone-1-20260322154500",
  "zone_id": "zone-1",
  "soil_moisture": 51.4,
  "temperature": 29.6,
  "humidity": 57.2,
  "recorded_at": "2026-03-22T15:45:00Z"
}
```

## Good Device-Side Rules

- Send timestamps in UTC ISO-8601
- Keep `zone_id` stable and identical to the app/Supabase zone ids
- Clamp battery and signal values to `0-100`
- Send a heartbeat every 1-5 minutes even if sensor values barely change
- Send an immediate update after irrigation events or anomaly detections
