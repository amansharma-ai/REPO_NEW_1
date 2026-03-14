import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/widgets/loading_widget.dart';
import '../../providers/workout_providers.dart';

class ExerciseDetailScreen extends ConsumerWidget {
  final int exerciseId;
  final String exerciseName;

  const ExerciseDetailScreen({
    super.key,
    required this.exerciseId,
    required this.exerciseName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(exerciseHistoryProvider(exerciseId));
    final bestSetAsync = ref.watch(exerciseBestSetProvider(exerciseId));
    final progressAsync = ref.watch(exerciseProgressProvider(exerciseId));

    return Scaffold(
      appBar: AppBar(title: Text(exerciseName)),
      body: historyAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => Center(child: Text('Error: $e',
            style: const TextStyle(color: Colors.white54))),
        data: (data) {
          final sessions = (data['sessions'] as List?) ?? [];
          if (sessions.isEmpty) {
            return const Center(child: Text('No history yet',
                style: TextStyle(color: Colors.white54)));
          }

          // Build volume chart data
          final reversedSessions = sessions.reversed.toList();
          final spots = <FlSpot>[];
          for (int i = 0; i < reversedSessions.length; i++) {
            final vol = (reversedSessions[i]['totalVolume'] as num?)?.toDouble() ?? 0;
            spots.add(FlSpot(i.toDouble(), vol));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // All-Time Best card
                bestSetAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (best) {
                    if (best.containsKey('message')) return const SizedBox.shrink();
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 28),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Best 1RM: ${(best['bestOneRM'] as num).toStringAsFixed(1)} kg',
                                  style: const TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                Text(
                                  '${best['bestWeight']} kg × ${best['bestReps']} reps',
                                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // Estimated 1RM Trend
                const Text('Estimated 1RM Trend',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 12),
                progressAsync.when(
                  loading: () => const SizedBox(
                      height: 200, child: Center(child: CircularProgressIndicator())),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (progressData) {
                    final points = (progressData['dataPoints'] as List?) ?? [];
                    if (points.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text('Log some sets to see your 1RM trend',
                            style: TextStyle(color: Colors.white54)),
                      );
                    }
                    final oneRMSpots = <FlSpot>[];
                    for (int i = 0; i < points.length; i++) {
                      final val = (points[i]['estimatedOneRM'] as num?)?.toDouble() ?? 0;
                      oneRMSpots.add(FlSpot(i.toDouble(), val));
                    }
                    return SizedBox(
                      height: 200,
                      child: LineChart(LineChartData(
                        gridData: FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (val, _) => Text(
                                val.toStringAsFixed(0),
                                style: const TextStyle(fontSize: 10, color: Colors.white38),
                              ),
                              reservedSize: 36,
                            ),
                          ),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipItems: (touchedSpots) => touchedSpots.map((s) {
                              final idx = s.spotIndex;
                              final date = points[idx]['date'] ?? '';
                              final orm = (points[idx]['estimatedOneRM'] as num?)
                                      ?.toStringAsFixed(1) ??
                                  '';
                              return LineTooltipItem(
                                '$date\n${orm}kg 1RM',
                                const TextStyle(color: Colors.white, fontSize: 12),
                              );
                            }).toList(),
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: oneRMSpots,
                            isCurved: true,
                            color: const Color(0xFF00C9A7),
                            barWidth: 3,
                            dotData: FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  const Color(0xFF00C9A7).withOpacity(0.25),
                                  const Color(0xFF00C9A7).withOpacity(0.0),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Volume chart
                const Text('Volume Over Time',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                        color: Colors.white)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: LineChart(LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: const Color(0xFF7C4DFF),
                        barWidth: 3,
                        dotData: FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: const Color(0xFF7C4DFF).withOpacity(0.1),
                        ),
                      ),
                    ],
                  )),
                ),
                const SizedBox(height: 24),

                // Session history
                const Text('Session History',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                        color: Colors.white)),
                const SizedBox(height: 12),
                ...sessions.map((s) {
                  final date = s['date'] ?? '';
                  final sets = (s['sets'] as List?) ?? [];
                  final vol = (s['totalVolume'] as num?)?.toStringAsFixed(0) ?? '0';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(date, style: const TextStyle(
                                  color: Color(0xFF7C4DFF),
                                  fontWeight: FontWeight.w600)),
                              Text('Vol: $vol kg',
                                  style: const TextStyle(
                                      color: Colors.white38, fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: sets.map<Widget>((set) => Chip(
                              label: Text(
                                '${(set['weightKg'] as num?)?.toStringAsFixed(1) ?? '-'}kg x ${set['reps'] ?? '-'}',
                                style: const TextStyle(fontSize: 11, color: Colors.white),
                              ),
                              backgroundColor: const Color(0xFF2A2A3E),
                              padding: EdgeInsets.zero,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            )).toList(),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
