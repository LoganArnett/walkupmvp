import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:walkupmvp/app/providers.dart';
import 'package:walkupmvp/data/local/app_db.dart';

class RosterScreen extends ConsumerWidget {
  const RosterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTeamId = ref.watch(currentTeamIdProvider);
    final playersAsync = ref.watch(currentTeamPlayersProvider);
    final db = ref.watch(databaseProvider);

    if (currentTeamId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Roster')),
        body: const Center(child: Text('No team selected')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Roster'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddPlayerDialog(context, db, currentTeamId),
        icon: const Icon(Icons.person_add),
        label: const Text('Add Player'),
      ),
      body: playersAsync.when(
        data: (players) {
          if (players.isEmpty) {
            return const Center(
              child: Text('No players yet. Add some!'),
            );
          }
          return ReorderableListView.builder(
            itemCount: players.length,
            onReorder: (oldIndex, newIndex) async {
              // Update batting orders
              if (newIndex > oldIndex) newIndex--;
              final reordered = List<Player>.from(players);
              final item = reordered.removeAt(oldIndex);
              reordered.insert(newIndex, item);

              // Update all batting orders
              for (int i = 0; i < reordered.length; i++) {
                await db.updatePlayer(
                  PlayersCompanion(
                    id: Value(reordered[i].id),
                    battingOrder: Value(i + 1),
                  ),
                );
              }
            },
            itemBuilder: (context, index) {
              final player = players[index];
              return ListTile(
                key: ValueKey(player.id),
                leading: CircleAvatar(
                  child: Text('${player.number}'),
                ),
                title: Text(player.name),
                subtitle: Text('Batting ${player.battingOrder}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showEditPlayerDialog(
                        context,
                        db,
                        player,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        await db.deletePlayer(player.id);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Future<void> _showAddPlayerDialog(
    BuildContext context,
    AppDb db,
    String teamId,
  ) async {
    final nameController = TextEditingController();
    final numberController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    // Get current max batting order
    final players = await db.getPlayersByTeam(teamId);
    final maxOrder = players.isEmpty
        ? 0
        : players.map((p) => p.battingOrder).reduce((a, b) => a > b ? a : b);

    if (!context.mounted) return;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Player'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Player name'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: numberController,
                  decoration: const InputDecoration(labelText: 'Jersey #'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    final num = int.tryParse(v);
                    if (num == null || num < 0 || num > 99) {
                      return 'Enter 0-99';
                    }
                    return null;
                  },
                ),
              ],
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
                  await db.insertPlayer(
                    PlayersCompanion.insert(
                      id: const Uuid().v4(),
                      teamId: teamId,
                      name: nameController.text.trim(),
                      number: int.parse(numberController.text),
                      battingOrder: maxOrder + 1,
                      updatedAt: DateTime.now(),
                    ),
                  );
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditPlayerDialog(
    BuildContext context,
    AppDb db,
    Player player,
  ) async {
    final nameController = TextEditingController(text: player.name);
    final numberController =
        TextEditingController(text: player.number.toString());
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Player'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Player name'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: numberController,
                  decoration: const InputDecoration(labelText: 'Jersey #'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    final num = int.tryParse(v);
                    if (num == null || num < 0 || num > 99) {
                      return 'Enter 0-99';
                    }
                    return null;
                  },
                ),
              ],
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
                  await db.updatePlayer(
                    PlayersCompanion(
                      id: Value(player.id),
                      name: Value(nameController.text.trim()),
                      number: Value(int.parse(numberController.text)),
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
}
