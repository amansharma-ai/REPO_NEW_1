import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../providers/challenge_providers.dart';
import '../../data/models/daily_challenge.dart';

class ChallengesScreen extends ConsumerWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challengesAsync = ref.watch(todayChallengesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Challenges'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Regenerate',
            onPressed: () async {
              try {
                await ref.read(challengeRepositoryProvider).forceRegenerate();
                ref.invalidate(todayChallengesProvider);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: challengesAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => const Center(
            child: Text('Error loading challenges',
                style: TextStyle(color: Colors.white54))),
        data: (challenges) {
          if (challenges.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.emoji_events,
              title: 'No challenges yet',
              subtitle:
                  'Log some workouts first to get personalized challenges!',
            );
          }

          final completed = challenges.where((c) => c.completed).length;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Gradient progress header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF00C9A7).withValues(alpha: 0.2),
                      const Color(0xFF7C4DFF).withValues(alpha: 0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: const Color(0xFF00C9A7).withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator(
                            value: challenges.isEmpty
                                ? 0
                                : completed / challenges.length,
                            strokeWidth: 6,
                            backgroundColor: Colors.white12,
                            valueColor: const AlwaysStoppedAnimation(
                                Color(0xFF00C9A7)),
                          ),
                        ),
                        Text('$completed/${challenges.length}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Today\'s Progress',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: Colors.white)),
                          const SizedBox(height: 4),
                          Text(
                            completed == challenges.length
                                ? 'All challenges completed! Great work!'
                                : '${challenges.length - completed} challenges remaining',
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Challenge cards
              ...challenges.map((c) => _ChallengeCard(challenge: c)),
            ],
          );
        },
      ),
    );
  }
}

class _ChallengeCard extends ConsumerWidget {
  final DailyChallenge challenge;
  const _ChallengeCard({required this.challenge});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typeColors = {
      'MORE_WEIGHT': const Color(0xFFFF8A65),
      'MORE_REPS': const Color(0xFF42A5F5),
      'MORE_SETS': const Color(0xFF66BB6A),
      'DELOAD': const Color(0xFFEC407A),
    };
    final typeIcons = {
      'MORE_WEIGHT': Icons.trending_up,
      'MORE_REPS': Icons.repeat,
      'MORE_SETS': Icons.add_box_outlined,
      'DELOAD': Icons.trending_down,
    };
    final typeLabels = {
      'MORE_WEIGHT': 'More Weight',
      'MORE_REPS': 'More Reps',
      'MORE_SETS': 'More Sets',
      'DELOAD': 'Deload',
    };

    final color = typeColors[challenge.challengeType] ?? Colors.white;
    final icon = typeIcons[challenge.challengeType] ?? Icons.fitness_center;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF151528),
        borderRadius: BorderRadius.circular(20),
        border: Border(
          left: BorderSide(color: color, width: 3),
          top: BorderSide(color: Colors.white.withValues(alpha: 0.07)),
          right: BorderSide(color: Colors.white.withValues(alpha: 0.07)),
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.07)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(challenge.exerciseName ?? 'Exercise',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: Colors.white)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              typeLabels[challenge.challengeType] ?? '',
                              style: TextStyle(
                                  color: color,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          if (challenge.muscleGroup != null) ...[
                            const SizedBox(width: 8),
                            Text(challenge.muscleGroup!,
                                style: const TextStyle(
                                    color: Colors.white38, fontSize: 11)),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                if (challenge.completed)
                  const Icon(Icons.check_circle,
                      color: Colors.green, size: 28)
                else
                  OutlinedButton(
                    onPressed: () async {
                      try {
                        await ref
                            .read(challengeRepositoryProvider)
                            .markCompleted(challenge.id!);
                        ref.invalidate(todayChallengesProvider);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: color, width: 1.5),
                      foregroundColor: color,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Done',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // Target
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0E0E1F),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.07)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _metric('Weight', '${challenge.suggestedWeight ?? '-'}kg'),
                  _metric('Reps', '${challenge.suggestedReps ?? '-'}'),
                  _metric('Sets', '${challenge.suggestedSets ?? '-'}'),
                ],
              ),
            ),
            if (challenge.reason != null) ...[
              const SizedBox(height: 10),
              Text(challenge.reason!,
                  style: const TextStyle(
                      color: Colors.white54, fontSize: 12)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _metric(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Colors.white)),
        const SizedBox(height: 2),
        Text(label,
            style:
                const TextStyle(color: Colors.white38, fontSize: 11)),
      ],
    );
  }
}
