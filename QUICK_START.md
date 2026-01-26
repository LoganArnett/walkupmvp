# Quick Start Guide

## Running the App Right Now

The MVP is ready to run! Follow these steps:

### 1. Launch the App
```bash
flutter run
```

Select your device when prompted (iOS simulator, Android emulator, or physical device).

### 2. What You'll See

The app launches directly into the **Game Day Controller** screen with:
- A dark theme optimized for outdoor use
- Mock batting lineup with 4 players
- Large PLAY and STOP buttons
- Team name display at the top

### 3. Try It Out

- **Tap a player** in the list to select them (they'll turn blue)
- **Tap PLAY** to see a snackbar notification (audio playback not yet implemented)
- **Tap STOP** at any time to stop playback

## Current State

✅ **What's Working:**
- Full project structure
- Local database (Drift) with all tables
- Immutable data models (Freezed)
- State management (Riverpod)
- Game Day UI
- Audio controller infrastructure
- Supabase client setup
- Clean architecture

⚠️ **What's NOT Yet Implemented:**
- Team management screens
- Roster management screens
- Audio assignment screens
- Actual audio playback logic
- YouTube integration
- Local file import
- TTS integration
- Supabase sync logic

## Next Development Steps

### Priority 1: Core Functionality
1. **Connect Database to UI**: Wire up providers to display real teams/players
2. **Team Management Screen**: Create/edit teams
3. **Roster Management Screen**: Add/edit players with batting order

### Priority 2: Audio Features
4. **Audio Assignment Screen**: 
   - YouTube video search and selection
   - Start/end time picker
   - Local file import
5. **Implement Playback Logic**: Wire up AudioController to play selected audio

### Priority 3: Polish
6. **Settings Screen**: Volume controls, app preferences
7. **Onboarding Flow**: First-time user guide
8. **Error Handling**: Proper loading/error states
9. **Testing**: Unit and widget tests

### Priority 4: Sync (Optional)
10. **Supabase Authentication**: Magic link login
11. **Sync Logic**: Upload/download teams and players
12. **Team Sharing**: Join teams via code

## Testing Commands

```bash
# Run tests
flutter test

# Check for issues
flutter analyze

# Run on specific device
flutter run -d <device-id>

# List available devices
flutter devices

# Hot reload while running
# Press 'r' in terminal or save file

# Hot restart while running
# Press 'R' in terminal
```

## Need Help?

- Check `README_MVP.md` for full documentation
- Review `supabase_schema.sql` for database schema
- Look at existing code in `lib/` for patterns
- All generated files (*.g.dart, *.freezed.dart) are auto-created by build_runner

## Troubleshooting

**Code generation errors?**
```bash
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

**Analysis errors?**
```bash
flutter clean
flutter pub get
flutter analyze
```

**Build errors?**
```bash
flutter clean
flutter pub get
cd ios && pod install && cd ..  # iOS only
flutter run
```

## Development Workflow

1. Make changes to code
2. Hot reload (save file or press 'r')
3. If changing models/database: run build_runner
4. Test locally
5. Run `flutter analyze` before committing
6. Push to version control

Enjoy building your MVP! 🎵⚾
