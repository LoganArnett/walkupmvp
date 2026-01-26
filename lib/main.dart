import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:walkupmvp/app/providers.dart';
import 'package:walkupmvp/features/game_day/game_day_screen.dart';
// import 'package:walkupmvp/services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase (optional - can be skipped for MVP)
  // Uncomment when you have credentials:
  // await SupabaseService.init(
  //   url: 'YOUR_SUPABASE_URL',
  //   anonKey: 'YOUR_SUPABASE_ANON_KEY',
  // );

  runApp(
    const ProviderScope(
      child: WalkupApp(),
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
  }

  Future<void> _initializeAudio() async {
    final audioController = ref.read(audioControllerProvider);
    await audioController.init();
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
