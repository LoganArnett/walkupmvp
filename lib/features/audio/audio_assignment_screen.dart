import 'package:drift/drift.dart' show Value;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:walkupmvp/app/providers.dart';
import 'package:walkupmvp/data/local/app_db.dart' as drift;

class AudioAssignmentScreen extends ConsumerStatefulWidget {
  final drift.Player player;

  const AudioAssignmentScreen({
    super.key,
    required this.player,
  });

  @override
  ConsumerState<AudioAssignmentScreen> createState() =>
      _AudioAssignmentScreenState();
}

class _AudioAssignmentScreenState extends ConsumerState<AudioAssignmentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final assignmentAsync = ref.watch(playerAssignmentProvider(widget.player.id));
    final announcementAsync = ref.watch(playerAnnouncementProvider(widget.player.id));

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.player.name} #${widget.player.number}'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.play_circle), text: 'Walkup Song'),
            Tab(icon: Icon(Icons.record_voice_over), text: 'Announcement'),
            Tab(icon: Icon(Icons.preview), text: 'Preview'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Walkup Song Tab
          _WalkupSongTab(
            player: widget.player,
            assignment: assignmentAsync.value,
          ),
          // Announcement Tab
          _AnnouncementTab(
            player: widget.player,
            announcement: announcementAsync.value,
          ),
          // Preview Tab
          _PreviewTab(
            player: widget.player,
            assignment: assignmentAsync.value,
            announcement: announcementAsync.value,
          ),
        ],
      ),
    );
  }
}

class _WalkupSongTab extends ConsumerWidget {
  final drift.Player player;
  final drift.Assignment? assignment;

  const _WalkupSongTab({
    required this.player,
    this.assignment,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (assignment != null) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(_getSourceIcon(assignment!.sourceType)),
                      const SizedBox(width: 8),
                      Text(
                        _getSourceName(assignment!.sourceType),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          await db.deleteAssignment(player.id);
                        },
                      ),
                    ],
                  ),
                  const Divider(),
                  if (assignment!.sourceType == 'youtube') ...[
                    Text('Video: ${assignment!.youtubeVideoId}'),
                    Text('Start: ${assignment!.startSec}s'),
                    Text('Duration: ${assignment!.durationSec}s'),
                  ] else if (assignment!.sourceType == 'localFile') ...[
                    Text('File: ${assignment!.localUri}'),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        const Text(
          'Choose Audio Source',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _AudioSourceCard(
          icon: Icons.music_video,
          title: 'YouTube Video',
          subtitle: 'Stream from YouTube (requires internet)',
          onTap: () => _showYouTubeDialog(context, db),
        ),
        const SizedBox(height: 12),
        _AudioSourceCard(
          icon: Icons.folder,
          title: 'Local File',
          subtitle: 'Import audio from device',
          onTap: () => _pickLocalFile(context, db),
        ),
        const SizedBox(height: 12),
        _AudioSourceCard(
          icon: Icons.library_music,
          title: 'Built-in Song',
          subtitle: 'Coming soon',
          enabled: false,
          onTap: () {},
        ),
      ],
    );
  }

  IconData _getSourceIcon(String sourceType) {
    switch (sourceType) {
      case 'youtube':
        return Icons.music_video;
      case 'localFile':
        return Icons.folder;
      default:
        return Icons.music_note;
    }
  }

  String _getSourceName(String sourceType) {
    switch (sourceType) {
      case 'youtube':
        return 'YouTube Video';
      case 'localFile':
        return 'Local File';
      default:
        return 'Unknown';
    }
  }

  Future<void> _showYouTubeDialog(BuildContext context, drift.AppDb db) async {
    final videoIdController = TextEditingController();
    final startController = TextEditingController(text: '0');
    final durationController = TextEditingController(text: '10');
    final formKey = GlobalKey<FormState>();

    if (!context.mounted) return;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('YouTube Video'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: videoIdController,
                    decoration: const InputDecoration(
                      labelText: 'Video ID or URL',
                      hintText: 'dQw4w9WgXcQ',
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: startController,
                    decoration: const InputDecoration(
                      labelText: 'Start (seconds)',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final num = int.tryParse(v ?? '');
                      if (num == null || num < 0) return 'Invalid';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: durationController,
                    decoration: const InputDecoration(
                      labelText: 'Duration (seconds)',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final num = int.tryParse(v ?? '');
                      if (num == null || num < 1) return 'Invalid';
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  // Extract video ID from URL if needed
                  String videoId = videoIdController.text.trim();
                  if (videoId.contains('youtube.com') ||
                      videoId.contains('youtu.be')) {
                    final uri = Uri.tryParse(videoId);
                    if (uri != null) {
                      videoId = uri.queryParameters['v'] ??
                          uri.pathSegments.last;
                    }
                  }

                  // Use insert or replace mode to handle existing assignments
                  await db.into(db.assignments).insertOnConflictUpdate(
                    drift.AssignmentsCompanion.insert(
                      playerId: player.id,
                      sourceType: 'youtube',
                      youtubeVideoId: Value(videoId),
                      startSec: Value(int.parse(startController.text)),
                      durationSec: Value(int.parse(durationController.text)),
                      updatedAt: DateTime.now(),
                    ),
                  );
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickLocalFile(BuildContext context, drift.AppDb db) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      // Use insert or replace mode to handle existing assignments
      await db.into(db.assignments).insertOnConflictUpdate(
        drift.AssignmentsCompanion.insert(
          playerId: player.id,
          sourceType: 'localFile',
          localUri: Value(file.path ?? ''),
          updatedAt: DateTime.now(),
        ),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Added: ${file.name}')),
        );
      }
    }
  }
}

class _AudioSourceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool enabled;

  const _AudioSourceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 40),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        enabled: enabled,
        onTap: enabled ? onTap : null,
      ),
    );
  }
}

class _AnnouncementTab extends ConsumerWidget {
  final drift.Player player;
  final drift.Announcement? announcement;

  const _AnnouncementTab({
    required this.player,
    this.announcement,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (announcement != null) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(announcement!.mode == 'tts'
                          ? Icons.text_fields
                          : Icons.mic),
                      const SizedBox(width: 8),
                      Text(
                        announcement!.mode == 'tts'
                            ? 'Text-to-Speech'
                            : 'Recorded',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          await db.deleteAnnouncement(player.id);
                        },
                      ),
                    ],
                  ),
                  const Divider(),
                  if (announcement!.mode == 'tts') ...[
                    Text('Template: ${announcement!.ttsTemplate}'),
                  ] else ...[
                    Text('File: ${announcement!.localUri}'),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        const Text(
          'Announcement Type',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _AudioSourceCard(
          icon: Icons.text_fields,
          title: 'Text-to-Speech',
          subtitle: 'Auto-generate announcement',
          onTap: () => _showTtsDialog(context, db),
        ),
        const SizedBox(height: 12),
        _AudioSourceCard(
          icon: Icons.mic,
          title: 'Record Audio',
          subtitle: 'Coming soon',
          enabled: false,
          onTap: () {},
        ),
      ],
    );
  }

  Future<void> _showTtsDialog(BuildContext context, drift.AppDb db) async {
    final controller = TextEditingController(
      text: 'Now batting, ${player.name}, number ${player.number}',
    );

    if (!context.mounted) return;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('TTS Template'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Use {name} and {number} as placeholders',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                // Use insert or replace mode to handle existing announcements
                await db.into(db.announcements).insertOnConflictUpdate(
                  drift.AnnouncementsCompanion.insert(
                    playerId: player.id,
                    mode: 'tts',
                    ttsTemplate: Value(controller.text),
                    updatedAt: DateTime.now(),
                  ),
                );
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

class _PreviewTab extends ConsumerWidget {
  final drift.Player player;
  final drift.Assignment? assignment;
  final drift.Announcement? announcement;

  const _PreviewTab({
    required this.player,
    this.assignment,
    this.announcement,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioController = ref.watch(audioControllerProvider);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            player.name,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Text(
            '#${player.number}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 32),
          if (announcement != null) ...[
            ElevatedButton.icon(
              onPressed: () async {
                if (announcement!.mode == 'tts') {
                  // Replace placeholders
                  String text = announcement!.ttsTemplate ?? '';
                  text = text.replaceAll('{name}', player.name);
                  text = text.replaceAll('{number}', '${player.number}');
                  await audioController.speak(text);
                }
              },
              icon: const Icon(Icons.record_voice_over),
              label: const Text('Test Announcement'),
            ),
            const SizedBox(height: 16),
          ],
          if (assignment != null) ...[
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Audio preview coming soon!'),
                  ),
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Test Walkup Song'),
            ),
          ],
          if (assignment == null && announcement == null) ...[
            const Icon(Icons.music_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No audio assigned yet'),
          ],
        ],
      ),
    );
  }
}
