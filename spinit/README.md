# SpinIt 🎡

A fun, vibrant wheel spinner app with local customization and cloud sharing features.

## ✨ Features

- **Phase 1**: Beautiful animated spinning wheel, real-time editor, and confetti celebrations.
- **Phase 2**: Preset packs (What to Eat, Truth or Dare, etc.), spin history log, sound effects, and haptic feedback.
- **Phase 3**: cloud sharing via 6-character short codes, anonymous user sessions, and spin analytics.

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (stable)
- Go (Golang) 1.22+ (for backend)
- Docker & Docker Compose (for backend & database)

### Backend Setup (Phase 3)

1. Navigate to the `backend` directory:
   ```bash
   cd backend
   ```
2. Start the API and PostgreSQL database using Docker:
   ```bash
   docker-compose up -d
   ```
3. The API will be available at `http://localhost:8080/v1`.

### Mobile Setup (Flutter)

1. Install dependencies:
   ```bash
   flutter pub get
   ```
2. Run on your target device:
   ```bash
   flutter run
   ```
   *Note: For Android Emulator, you may need to change the API base URL in `lib/services/api_service.dart` from `localhost` to `10.0.2.2`.*

## 📂 Project Structure (Phase 3)

```
├── backend/                  # Golang Fiber Backend
│   ├── handlers/             # API request controllers
│   ├── services/             # Business logic & background jobs
│   ├── models/               # GORM database entities
│   └── migrations/           # SQL schema
├── lib/                      # Flutter Mobile App
│   ├── services/             # API & Session management
│   ├── providers/            # Riverpod state management
│   ├── screens/              # App screens (Spin, Presets, History, Editor)
│   └── widgets/              # Reusable UI components
```

## 🛠 Tech Stack

- **Frontend**: Flutter, Riverpod, Shared Preferences, AudioPlayers, Confetti.
- **Backend**: Go (Fiber), GORM, PostgreSQL, JWT, Redis-style Rate Limiting.
- **Infrastructure**: Docker, Docker Compose.

---
Built with ❤️ for rapid decision making.
