import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_db.g.dart';

/// Teams table
class Teams extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get ownerId => text().nullable()();
  TextColumn get joinCode => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Players table
class Players extends Table {
  TextColumn get id => text()();
  TextColumn get teamId => text()();
  TextColumn get name => text()();
  IntColumn get number => integer()();
  IntColumn get battingOrder => integer()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Walkup assignments table
class Assignments extends Table {
  TextColumn get playerId => text()();
  TextColumn get sourceType =>
      text()(); // 'youtube' | 'localFile' | 'builtIn'
  TextColumn get youtubeVideoId => text().nullable()();
  IntColumn get startSec => integer().nullable()();
  IntColumn get durationSec => integer().nullable()();
  TextColumn get localUri => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {playerId};
}

/// Announcements table
class Announcements extends Table {
  TextColumn get playerId => text()();
  TextColumn get mode => text()(); // 'recorded' | 'tts'
  TextColumn get localUri => text().nullable()();
  TextColumn get ttsTemplate => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {playerId};
}

/// Main database class
@DriftDatabase(tables: [Teams, Players, Assignments, Announcements])
class AppDb extends _$AppDb {
  AppDb() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Team queries
  Future<List<Team>> getAllTeams() => select(teams).get();
  Future<Team?> getTeam(String id) =>
      (select(teams)..where((t) => t.id.equals(id))).getSingleOrNull();
  Future<int> insertTeam(TeamsCompanion team) => into(teams).insert(team);
  Future<bool> updateTeam(TeamsCompanion team) => update(teams).replace(team);
  Future<int> deleteTeam(String id) =>
      (delete(teams)..where((t) => t.id.equals(id))).go();

  // Player queries
  Future<List<Player>> getPlayersByTeam(String teamId) =>
      (select(players)..where((p) => p.teamId.equals(teamId))).get();
  Future<List<Player>> getPlayersByTeamOrdered(String teamId) =>
      (select(players)
            ..where((p) => p.teamId.equals(teamId))
            ..orderBy([(p) => OrderingTerm(expression: p.battingOrder)]))
          .get();
  Future<Player?> getPlayer(String id) =>
      (select(players)..where((p) => p.id.equals(id))).getSingleOrNull();
  Future<int> insertPlayer(PlayersCompanion player) =>
      into(players).insert(player);
  Future<bool> updatePlayer(PlayersCompanion player) =>
      update(players).replace(player);
  Future<int> deletePlayer(String id) =>
      (delete(players)..where((p) => p.id.equals(id))).go();

  // Assignment queries
  Future<Assignment?> getAssignment(String playerId) =>
      (select(assignments)..where((a) => a.playerId.equals(playerId)))
          .getSingleOrNull();
  Future<int> insertAssignment(AssignmentsCompanion assignment) =>
      into(assignments).insert(assignment);
  Future<bool> updateAssignment(AssignmentsCompanion assignment) =>
      update(assignments).replace(assignment);
  Future<int> deleteAssignment(String playerId) =>
      (delete(assignments)..where((a) => a.playerId.equals(playerId))).go();

  // Announcement queries
  Future<Announcement?> getAnnouncement(String playerId) =>
      (select(announcements)..where((a) => a.playerId.equals(playerId)))
          .getSingleOrNull();
  Future<int> insertAnnouncement(AnnouncementsCompanion announcement) =>
      into(announcements).insert(announcement);
  Future<bool> updateAnnouncement(AnnouncementsCompanion announcement) =>
      update(announcements).replace(announcement);
  Future<int> deleteAnnouncement(String playerId) =>
      (delete(announcements)..where((a) => a.playerId.equals(playerId))).go();
}

/// Opens connection to the SQLite database
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'walkup_mvp.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
