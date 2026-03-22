# AI-Powered Plant Stress Prediction and Self-Healing Smart Farm System

Production-ready Flutter frontend for a smart farming platform with Supabase auth/data, FastAPI AI predictions, realtime alerts, manual irrigation control, and farm analytics.

## Setup

1. Install Flutter stable.
2. Copy `.env.example` to `.env`.
3. Fill in `SUPABASE_URL` and `SUPABASE_ANON_KEY`.
4. Keep `AI_BASE_URL` pointed at your FastAPI server, default `http://localhost:8000`.
5. Run:

```bash
flutter pub get
flutter run
```

If Supabase credentials are missing, the app starts in a local demo mode with mock zones, predictions, alerts, and session persistence so the UI still runs end to end.

## Suggested Supabase Tables

- `users`
- `zones`
- `sensor_data`
- `predictions`
- `alerts`
- `actions`

## Included Features

- Email/password authentication
- Dashboard with zone health cards
- Zone details with AI prediction and plant translator insights
- Alerts feed with unread badge
- History and analytics charts
- Settings with auto-irrigation and notifications toggles
