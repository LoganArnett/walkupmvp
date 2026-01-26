# Walkup MVP - Youth Baseball Walk-Up Songs App

A Flutter mobile app for managing and playing walk-up songs for youth baseball teams. Built with a local-first architecture using Flutter and Supabase.

## 🎯 Features (MVP)

- **Game Day Controller**: Large, easy-to-use interface for playing walk-up songs during games
- **Local-First Architecture**: All data stored locally with SQLite (Drift)
- **Audio Playback**: Support for local audio files and text-to-speech announcements
- **Team Management**: Create teams, manage rosters, and assign walk-up songs
- **Optional Sync**: Supabase backend for team sharing (optional)

## 🏗️ Architecture

### Tech Stack
- **Frontend**: Flutter 3.38.7 with Material 3
- **State Management**: Riverpod
- **Local Database**: Drift (SQLite)
- **Audio**: just_audio, flutter_tts
- **Backend (Optional)**: Supabase
- **YouTube**: youtube_player_iframe (stream-only, no downloading)

### Project Structure
```
lib/
├── app/
│   └── providers.dart           # Riverpod providers
├── features/
│   ├── audio/
│   │   └── audio_controller.dart
│   ├── game_day/
│   │   └── game_day_screen.dart
│   ├── roster/                  # TODO
│   ├── teams/                   # TODO
│   └── sync/                    # TODO
├── data/
│   ├── local/
│   │   └── app_db.dart         # Drift database
│   ├── models/
│   │   └── models.dart         # Freezed data models
│   └── repositories/            # TODO
├── services/
│   └── supabase_service.dart
└── main.dart
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.10.7 or higher
- Dart 3.10.7 or higher
- iOS Simulator / Android Emulator / Physical Device
- (Optional) Supabase project for team sharing

### Installation

1. **Clone and navigate to the project**
   ```bash
   cd walkupmvp
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Optional: Supabase Setup

1. Create a Supabase project at [supabase.com](https://supabase.com)
2. Run the SQL schema from `supabase_schema.sql` in the Supabase SQL editor
3. Get your project URL and anon key
4. Update `lib/main.dart`:
   ```dart
   await SupabaseService.init(
     url: 'YOUR_SUPABASE_URL',
     anonKey: 'YOUR_SUPABASE_ANON_KEY',
   );
   ```

## 📱 Usage

### Current MVP Functionality

The app currently launches with a **Game Day Controller** screen featuring:
- Mock batting lineup display
- Player selection
- Large PLAY/STOP buttons (optimized for field use)
- Dark theme for outdoor visibility

### Next Steps

To complete the MVP, implement:
1. **Team Management Screen**: Create/edit teams
2. **Roster Management Screen**: Add/edit players
3. **Audio Assignment Screen**: 
   - Search and select YouTube videos
   - Set start/stop times
   - Import local audio files
   - Record custom announcements
   - Configure TTS templates
4. **Settings Screen**: Volume controls, preferences
5. **Onboarding Flow**: First-time user setup

## 🛠️ Development

### Code Generation

Anytime you modify Drift tables or Freezed models, regenerate code:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Running Tests
```bash
flutter test
```

### Linting
```bash
flutter analyze
```

## 📊 Data Models

### Team
- `id`: Unique identifier
- `name`: Team name
- `ownerId`: Owner user ID (for Supabase sync)
- `joinCode`: 6-character code for team sharing
- `updatedAt`: Last update timestamp

### Player
- `id`: Unique identifier
- `teamId`: Parent team
- `name`: Player name
- `number`: Jersey number
- `battingOrder`: Position in lineup
- `updatedAt`: Last update timestamp

### WalkupAssignment
- `playerId`: Associated player
- `sourceType`: youtube | localFile | builtIn
- `youtubeVideoId`: YouTube video ID (if applicable)
- `startSec`: Start time in seconds
- `durationSec`: Duration in seconds
- `localUri`: Local file path (if applicable)
- `updatedAt`: Last update timestamp

### Announcement
- `playerId`: Associated player
- `mode`: recorded | tts
- `localUri`: Recorded announcement path
- `ttsTemplate`: Template for TTS (e.g., "Now batting, {name}, number {number}")
- `updatedAt`: Last update timestamp

## 🎨 Design Philosophy

### Local-First
- All data stored locally by default
- App works 100% offline
- Sync is additive, not required

### Game-Day Optimized
- Large, touch-friendly buttons
- High contrast dark theme
- Instant playback (no buffering)
- Predictable audio behavior

### Cost-Conscious
- No media hosting required
- YouTube streaming (no downloads)
- Minimal compute/bandwidth
- Self-hosted option available

## 🔐 Supabase Schema

The database schema includes:
- Row Level Security (RLS) policies
- Automatic join code generation
- Automatic timestamp updates
- Role-based access control (owner/editor/viewer)

See `supabase_schema.sql` for full details.

## 📝 TODO

- [ ] Implement team management UI
- [ ] Implement roster management UI
- [ ] Implement audio assignment UI
- [ ] Add YouTube search/preview
- [ ] Add local file import
- [ ] Add announcement recording
- [ ] Implement actual audio playback logic
- [ ] Add volume controls
- [ ] Add settings screen
- [ ] Implement Supabase sync logic
- [ ] Add authentication flow
- [ ] Add team sharing via join codes
- [ ] Add offline support indicators
- [ ] Add loading/error states
- [ ] Improve game day UX (pre-loading, auto-advance)

## 🤝 Contributing

This is an MVP. Contributions welcome for:
- Bug fixes
- Feature implementations from TODO list
- UI/UX improvements
- Performance optimizations

## 📄 License

[Your License Here]

## 🙏 Acknowledgments

Built with:
- [Flutter](https://flutter.dev)
- [Riverpod](https://riverpod.dev)
- [Drift](https://drift.simonbinder.eu)
- [just_audio](https://pub.dev/packages/just_audio)
- [Supabase](https://supabase.com)
