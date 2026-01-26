import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:walkupmvp/app/providers.dart';
import 'package:walkupmvp/features/teams/teams_screen.dart';
import 'package:walkupmvp/features/roster/roster_screen.dart';

/// Game Day screen - main controller for playing walkup songs during games
class GameDayScreen extends ConsumerStatefulWidget {
  const GameDayScreen({super.key});

  @override
  ConsumerState<GameDayScreen> createState() => _GameDayScreenState();
}

class _GameDayScreenState extends ConsumerState<GameDayScreen> {
  int? _selectedPlayerIndex;

  @override
  Widget build(BuildContext context) {
    final currentTeamId = ref.watch(currentTeamIdProvider);
    final playersAsync = ref.watch(currentTeamPlayersProvider);

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text(
          'Game Day Controller',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            tooltip: 'Manage Roster',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RosterScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              // TODO: Navigate to settings
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Team selector
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.black,
            child: Row(
              children: [
                const Icon(Icons.sports_baseball, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    currentTeamId == null ? 'No Team Selected' : 'Team Selected',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TeamsScreen(),
                      ),
                    );
                  },
                  child: const Text('Change'),
                ),
              ],
            ),
          ),

          // Batting order list
          Expanded(
            child: playersAsync.when(
              data: (players) {
                if (players.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.people_outline, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text('No players in roster'),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RosterScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.person_add),
                          label: const Text('Add Players'),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: players.length,
                  itemBuilder: (context, index) {
                    final player = players[index];
                    final isSelected = _selectedPlayerIndex == index;

                    return Card(
                      color: isSelected ? Colors.blue[700] : Colors.grey[800],
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        leading: CircleAvatar(
                          backgroundColor:
                              isSelected ? Colors.blue[900] : Colors.grey[700],
                          child: Text(
                            '${player.number}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        title: Text(
                          player.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Text(
                          'Batting ${player.battingOrder}',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                        trailing: Icon(
                          Icons.music_note,
                          color: isSelected ? Colors.white : Colors.grey[600],
                        ),
                        onTap: () {
                          setState(() {
                            _selectedPlayerIndex = index;
                          });
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: $e'),
                  ],
                ),
              ),
            ),
          ),

          // Control buttons
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.black,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // PLAY button
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _selectedPlayerIndex != null
                          ? () {
                              playersAsync.whenData((players) {
                                if (_selectedPlayerIndex! < players.length) {
                                  final player = players[_selectedPlayerIndex!];
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Playing walkup for ${player.name}'),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                              });
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey[700],
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_arrow, size: 32),
                          SizedBox(width: 8),
                          Text(
                            'PLAY',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // STOP button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Stop all audio
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Audio stopped'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.stop, size: 32),
                          SizedBox(height: 4),
                          Text(
                            'STOP',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
