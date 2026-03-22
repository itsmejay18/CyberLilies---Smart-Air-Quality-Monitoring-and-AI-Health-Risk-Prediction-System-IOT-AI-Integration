# AI-Powered Plant Stress Prediction and Self-Healing Smart Farm System

Production-ready Flutter frontend for a smart farming platform with Supabase auth/data, FastAPI AI predictions, realtime alerts, manual irrigation control, and farm analytics.

## Setup

1. Install Flutter stable.
2. Copy `.env.example` to `.env`.
3. Fill in `SUPABASE_URL` and `SUPABASE_ANON_KEY`.
4. In the Supabase SQL Editor, run [schema.sql](c:/Users/Jay/Documents/GitHub/CyberLilies---Smart-Air-Quality-Monitoring-and-AI-Health-Risk-Prediction-System-IOT-AI-Integration/supabase/schema.sql).
5. Run [seed.sql](c:/Users/Jay/Documents/GitHub/CyberLilies---Smart-Air-Quality-Monitoring-and-AI-Health-Risk-Prediction-System-IOT-AI-Integration/supabase/seed.sql) only if you want sample development rows.
6. Keep `AI_BASE_URL` pointed at your FastAPI server, default `http://localhost:8000`.
7. Run:

```bash
flutter pub get
flutter run
```

The app no longer preloads sample telemetry on first install. If your database has no real rows yet, the UI stays empty and shows setup or waiting-for-live-data states until zones, devices, and sensor records actually arrive.

## Backend Setup

The repo now includes a FastAPI backend that matches the Flutter app contract and the ESP32 payload format.

1. Add `SUPABASE_SERVICE_ROLE_KEY` to `.env`.
2. Install backend dependencies:

```bash
pip install -r backend/requirements.txt
```

3. Start the API:

```bash
uvicorn backend.app.main:app --reload --host 0.0.0.0 --port 8000
```

Backend docs:

- [backend/README.md](c:/Users/Jay/Documents/GitHub/CyberLilies---Smart-Air-Quality-Monitoring-and-AI-Health-Risk-Prediction-System-IOT-AI-Integration/backend/README.md)

ESP32 example sender:

- [esp32_http_sender.ino](c:/Users/Jay/Documents/GitHub/CyberLilies---Smart-Air-Quality-Monitoring-and-AI-Health-Risk-Prediction-System-IOT-AI-Integration/firmware/esp32_http_sender/esp32_http_sender.ino)

## Suggested Supabase Tables

- `users`
- `zones`
- `sensor_data`
- `predictions`
- `alerts`
- `actions`
- `iot_devices`

## Included Features

- Email/password authentication
- Dashboard with zone health cards
- Honest empty states when no real telemetry exists yet
- Zone details with AI prediction and plant translator insights
- Alerts feed with unread badge
- History and analytics charts
- Settings with auto-irrigation and notifications toggles
- Device registration screen for ESP32 pairing setup

## Included Supabase Setup Files

- [supabasetable.txt](c:/Users/Jay/Documents/GitHub/CyberLilies---Smart-Air-Quality-Monitoring-and-AI-Health-Risk-Prediction-System-IOT-AI-Integration/supabasetable.txt)
- [schema.sql](c:/Users/Jay/Documents/GitHub/CyberLilies---Smart-Air-Quality-Monitoring-and-AI-Health-Risk-Prediction-System-IOT-AI-Integration/supabase/schema.sql)
- [seed.sql](c:/Users/Jay/Documents/GitHub/CyberLilies---Smart-Air-Quality-Monitoring-and-AI-Health-Risk-Prediction-System-IOT-AI-Integration/supabase/seed.sql)
- [iot_payload.md](c:/Users/Jay/Documents/GitHub/CyberLilies---Smart-Air-Quality-Monitoring-and-AI-Health-Risk-Prediction-System-IOT-AI-Integration/docs/iot_payload.md)
- [backend/README.md](c:/Users/Jay/Documents/GitHub/CyberLilies---Smart-Air-Quality-Monitoring-and-AI-Health-Risk-Prediction-System-IOT-AI-Integration/backend/README.md)
