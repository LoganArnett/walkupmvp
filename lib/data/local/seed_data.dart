import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:walkupmvp/data/local/app_db.dart';

const _uuid = Uuid();

/// Seed data helper for development and testing
class SeedData {
  final AppDb db;

  SeedData(this.db);

  /// Create a sample team with players
  Future<Team> createSampleTeam({
    String name = 'Wildcats',
    int playerCount = 9,
  }) async {
    final teamId = _uuid.v4();
    final now = DateTime.now();

    // Insert team
    await db.insertTeam(
      TeamsCompanion.insert(
        id: teamId,
        name: name,
        ownerId: const Value(null),
        joinCode: const Value(null),
        updatedAt: now,
      ),
    );

    // Get the team
    final team = await db.getTeam(teamId);
    if (team == null) {
      throw Exception('Failed to create team');
    }

    // Create players
    final playerNames = [
      'John Doe',
      'Jane Smith',
      'Mike Johnson',
      'Sarah Williams',
      'Tom Brown',
      'Emily Davis',
      'Chris Wilson',
      'Alex Martinez',
      'Sam Taylor',
    ];

    for (int i = 0; i < playerCount && i < playerNames.length; i++) {
      await db.insertPlayer(
        PlayersCompanion.insert(
          id: _uuid.v4(),
          teamId: teamId,
          name: playerNames[i],
          number: i + 1,
          battingOrder: i + 1,
          updatedAt: now,
        ),
      );
    }

    return team;
  }

  /// Clear all data from database
  Future<void> clearAllData() async {
    // Delete in correct order due to foreign keys
    await db.delete(db.announcements).go();
    await db.delete(db.assignments).go();
    await db.delete(db.players).go();
    await db.delete(db.teams).go();
  }

  /// Seed multiple teams for testing
  Future<List<Team>> seedMultipleTeams() async {
    final teams = <Team>[];

    teams.add(await createSampleTeam(name: 'Wildcats', playerCount: 9));
    teams.add(await createSampleTeam(name: 'Tigers', playerCount: 9));
    teams.add(await createSampleTeam(name: 'Eagles', playerCount: 8));

    return teams;
  }

  /// Check if database has any data
  Future<bool> hasData() async {
    final teams = await db.getAllTeams();
    return teams.isNotEmpty;
  }
}
