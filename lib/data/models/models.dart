import 'package:freezed_annotation/freezed_annotation.dart';

part 'models.freezed.dart';
part 'models.g.dart';

/// Enum for audio source types
enum AudioSourceType {
  youtube,
  localFile,
  builtIn,
}

/// Enum for announcement modes
enum AnnouncementMode {
  recorded,
  tts,
}

/// Team model - represents a baseball team
@freezed
class Team with _$Team {
  const factory Team({
    required String id,
    required String name,
    required DateTime updatedAt,
    String? ownerId,
    String? joinCode,
  }) = _Team;

  factory Team.fromJson(Map<String, dynamic> json) => _$TeamFromJson(json);
}

/// Player model - represents a player on a team
@freezed
class Player with _$Player {
  const factory Player({
    required String id,
    required String teamId,
    required String name,
    required int number,
    required int battingOrder,
    required DateTime updatedAt,
  }) = _Player;

  factory Player.fromJson(Map<String, dynamic> json) =>
      _$PlayerFromJson(json);
}

/// WalkupAssignment model - represents audio assignment for a player's walkup
@freezed
class WalkupAssignment with _$WalkupAssignment {
  const factory WalkupAssignment({
    required String playerId,
    required AudioSourceType sourceType,
    required DateTime updatedAt,
    // YouTube fields
    String? youtubeVideoId,
    int? startSec,
    int? durationSec,
    // Local file fields
    String? localUri,
  }) = _WalkupAssignment;

  factory WalkupAssignment.fromJson(Map<String, dynamic> json) =>
      _$WalkupAssignmentFromJson(json);
}

/// Announcement model - represents announcement audio for a player
@freezed
class Announcement with _$Announcement {
  const factory Announcement({
    required String playerId,
    required AnnouncementMode mode,
    required DateTime updatedAt,
    // Recorded announcement
    String? localUri,
    // TTS template
    String? ttsTemplate,
  }) = _Announcement;

  factory Announcement.fromJson(Map<String, dynamic> json) =>
      _$AnnouncementFromJson(json);
}
