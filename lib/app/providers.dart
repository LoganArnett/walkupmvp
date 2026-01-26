import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:walkupmvp/data/local/app_db.dart';
import 'package:walkupmvp/features/audio/audio_controller.dart';

/// Database provider - single instance for the app
final databaseProvider = Provider<AppDb>((ref) {
  final db = AppDb();
  ref.onDispose(() => db.close());
  return db;
});

/// Audio controller provider - single instance for the app
final audioControllerProvider = Provider<AudioController>((ref) {
  final controller = AudioController();
  ref.onDispose(() => controller.dispose());
  return controller;
});

/// All teams provider
final allTeamsProvider = StreamProvider((ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.teams).watch();
});

/// Current team ID provider (can be overridden by user selection)
final currentTeamIdProvider = StateProvider<String?>((ref) => null);

/// Players for current team provider
final currentTeamPlayersProvider = FutureProvider((ref) async {
  final db = ref.watch(databaseProvider);
  final teamId = ref.watch(currentTeamIdProvider);
  
  if (teamId == null) {
    return <Player>[];
  }
  
  return db.getPlayersByTeamOrdered(teamId);
});

/// Selected player index for game day
final selectedPlayerIndexProvider = StateProvider<int?>((ref) => null);

/// Audio playing state
final isPlayingProvider = StateProvider<bool>((ref) => false);

/// Get assignment for a specific player
final playerAssignmentProvider = FutureProvider.family<Assignment?, String>((ref, playerId) async {
  final db = ref.watch(databaseProvider);
  return db.getAssignment(playerId);
});

/// Get announcement for a specific player
final playerAnnouncementProvider = FutureProvider.family<Announcement?, String>((ref, playerId) async {
  final db = ref.watch(databaseProvider);
  return db.getAnnouncement(playerId);
});
