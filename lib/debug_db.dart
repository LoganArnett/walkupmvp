import 'package:walkupmvp/data/local/app_db.dart';

/// Debug helper to check database state
Future<void> debugDatabase(AppDb db) async {
  print('=== DATABASE DEBUG ===');
  
  final teams = await db.getAllTeams();
  print('Teams count: ${teams.length}');
  for (final team in teams) {
    print('  - ${team.name} (id: ${team.id})');
    
    final players = await db.getPlayersByTeam(team.id);
    print('    Players: ${players.length}');
    for (final player in players) {
      print('      - ${player.name} #${player.number} (order: ${player.battingOrder})');
    }
  }
  
  print('=== END DEBUG ===');
}
