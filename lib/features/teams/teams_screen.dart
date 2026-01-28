import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:walkupmvp/app/providers.dart';
import 'package:walkupmvp/data/local/app_db.dart';
import 'package:walkupmvp/data/local/seed_data.dart';
import 'package:walkupmvp/debug_db.dart';

class TeamsScreen extends ConsumerWidget {
  const TeamsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamsAsync = ref.watch(allTeamsProvider);
    final db = ref.watch(databaseProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teams'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            tooltip: 'Debug DB',
            onPressed: () async {
              await debugDatabase(db);
            },
          ),
          IconButton(
            icon: const Icon(Icons.science),
            tooltip: 'Seed sample data',
            onPressed: () async {
              final seeder = SeedData(db);
              if (!await seeder.hasData()) {
                await seeder.seedMultipleTeams();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Seeded sample teams')),
                  );
                }
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Data already present')),
                  );
                }
              }
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateTeamDialog(context, db),
        icon: const Icon(Icons.add),
        label: const Text('New Team'),
      ),
      body: teamsAsync.when(
        data: (teams) {
          if (teams.isEmpty) {
            return const Center(child: Text('No teams yet. Create one!'));
          }
          return ListView.builder(
            itemCount: teams.length,
            itemBuilder: (context, index) {
              final team = teams[index];
              final isCurrent = ref.watch(currentTeamIdProvider) == team.id;
              return ListTile(
                title: Text(team.name),
                subtitle: Text('Updated ${team.updatedAt.toLocal()}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isCurrent)
                      const Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: Icon(Icons.check, color: Colors.green),
                      ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        await db.deleteTeam(team.id);
                      },
                    ),
                  ],
                ),
                onTap: () {
                  ref.read(currentTeamIdProvider.notifier).state = team.id;
                  ref.read(currentTeamNameProvider.notifier).state = team.name;
                  Navigator.pop(context);
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Future<void> _showCreateTeamDialog(BuildContext context, AppDb db) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Team'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Team name'),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Please enter a name'
                  : null,
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
                  final id = const Uuid().v4();
                  await db.insertTeam(
                    TeamsCompanion.insert(
                      id: id,
                      name: controller.text.trim(),
                      ownerId: const Value(null),
                      joinCode: const Value(null),
                      updatedAt: DateTime.now(),
                    ),
                  );
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}
