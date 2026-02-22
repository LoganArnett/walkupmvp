import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walkupmvp/app/providers.dart';
import 'package:walkupmvp/features/game_day/game_day_screen.dart';
// import 'package:walkupmvp/services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  // Initialize Supabase (optional - can be skipped for MVP)
  // Uncomment when you have credentials:
  // await SupabaseService.init(
  //   url: 'YOUR_SUPABASE_URL',
  //   anonKey: 'YOUR_SUPABASE_ANON_KEY',
  // );

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const WalkupApp(),
    ),
  );
}

class WalkupApp extends ConsumerStatefulWidget {
  const WalkupApp({super.key});

  @override
  ConsumerState<WalkupApp> createState() => _WalkupAppState();
}

class _WalkupAppState extends ConsumerState<WalkupApp> {
  @override
  void initState() {
    super.initState();
    _initializeAudio();
    _initializeTeam();
  }

  Future<void> _initializeAudio() async {
    final audioController = ref.read(audioControllerProvider);
    await audioController.init();
  }

  Future<void> _initializeTeam() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final db = ref.read(databaseProvider);
    final lastTeamId = prefs.getString('lastTeamId');

    if (lastTeamId != null) {
      // Try to restore the last viewed team
      final team = await db.getTeam(lastTeamId);
      if (team != null) {
        ref.read(currentTeamIdProvider.notifier).state = team.id;
        ref.read(currentTeamNameProvider.notifier).state = team.name;
        return;
      }
    }

    // No last team (or it was deleted) — if exactly 1 team exists, auto-select it
    final teams = await db.getAllTeams();
    if (teams.length == 1) {
      final team = teams.first;
      ref.read(currentTeamIdProvider.notifier).state = team.id;
      ref.read(currentTeamNameProvider.notifier).state = team.name;
      await prefs.setString('lastTeamId', team.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Walkup MVP',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      home: const GameDayScreen(),
    );
  }
}
