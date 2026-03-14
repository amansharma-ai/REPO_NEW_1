import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../data/models/exercise.dart';
import '../../providers/exercise_providers.dart';
import '../../providers/workout_providers.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Progress'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Strength'),
              Tab(text: 'Body'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _OverviewTab(),
            _StrengthTab(),
            _BodyTab(),
          ],
        ),
      ),
    );
  }
}

// ── Overview Tab ──────────────────────────────────────────────────────────────

class _OverviewTab extends ConsumerWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(workoutStatsProvider);
    final volumeAsync = ref.watch(weeklyVolumeProvider(8));
    final exercisesAsync = ref.watch(allExercisesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats grid
          statsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e', style: const TextStyle(color: Colors.white54)),
            data: (stats) => GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 1.3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: [
                _StatCard(
                  icon: Icons.fitness_center,
                  color: const Color(0xFF7C4DFF),
                  label: 'Workouts',
                  value: '${stats['totalWorkouts'] ?? 0}',
                ),
                _StatCard(
                  icon: Icons.layers,
                  color: const Color(0xFF00C9A7),
                  label: 'Total Sets',
                  value: '${stats['totalSets'] ?? 0}',
                ),
                _StatCard(
                  icon: Icons.monitor_weight,
                  color: const Color(0xFF7C4DFF),
                  label: 'Volume',
                  value: '${((stats['totalVolume'] as num? ?? 0) / 1000).toStringAsFixed(1)}t',
                ),
                _StatCard(
                  icon: Icons.local_fire_department,
                  color: Colors.orange,
                  label: 'Streak',
                  value: '${stats['currentStreak'] ?? 0} days',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Weekly Volume chart
          const Text('Weekly Volume',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 12),
          volumeAsync.when(
            loading: () => const SizedBox(height: 160, child: Center(child: CircularProgressIndicator())),
            error: (e, _) => Text('Error: $e', style: const TextStyle(color: Colors.white54)),
            data: (volumeData) {
              final weeks = (volumeData['weeks'] as List?) ?? [];
              if (weeks.isEmpty) {
                return const SizedBox(height: 160,
                    child: Center(child: Text('No data yet', style: TextStyle(color: Colors.white54))));
              }
              return SizedBox(
                height: 160,
                child: BarChart(BarChartData(
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (val, _) {
                          final idx = val.toInt();
                          if (idx % 2 != 0 || idx >= weeks.length) return const SizedBox.shrink();
                          return Text(
                            weeks[idx]['weekLabel'] ?? '',
                            style: const TextStyle(fontSize: 9, color: Colors.white54),
                          );
                        },
                        reservedSize: 20,
                      ),
                    ),
                  ),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIdx, rod, rodIdx) {
                        final w = weeks[group.x.toInt()];
                        final vol = (w['totalVolume'] as num?)?.toStringAsFixed(0) ?? '0';
                        return BarTooltipItem(
                          '${w['weekLabel']}\n${vol}kg',
                          const TextStyle(color: Colors.white, fontSize: 12),
                        );
                      },
                    ),
                  ),
                  barGroups: List.generate(weeks.length, (i) {
                    final vol = (weeks[i]['totalVolume'] as num?)?.toDouble() ?? 0;
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: vol,
                          width: 14,
                          borderRadius: BorderRadius.circular(4),
                          gradient: const LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Color(0xFF7C4DFF), Color(0xFF00C9A7)],
                          ),
                        ),
                      ],
                    );
                  }),
                )),
              );
            },
          ),
          const SizedBox(height: 24),

          // Personal Records
          const Text('Personal Records',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 8),
          exercisesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e', style: const TextStyle(color: Colors.white54)),
            data: (exercises) => ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: exercises.length,
              itemBuilder: (_, i) {
                final ex = exercises[i];
                return _PRListTile(exercise: ex);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PRListTile extends ConsumerWidget {
  final Exercise exercise;
  const _PRListTile({required this.exercise});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bestAsync = ref.watch(exerciseBestSetProvider(exercise.id));
    return bestAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (best) {
        if (best.containsKey('message')) return const SizedBox.shrink();
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(exercise.name, style: const TextStyle(color: Colors.white, fontSize: 14)),
          subtitle: Text(
            '${best['bestWeight']} kg × ${best['bestReps']} reps',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          trailing: Text(
            '${(best['bestOneRM'] as num).toStringAsFixed(1)} kg 1RM',
            style: const TextStyle(color: Color(0xFF00C9A7), fontWeight: FontWeight.w600),
          ),
        );
      },
    );
  }
}

// ── Strength Tab ──────────────────────────────────────────────────────────────

class _StrengthTab extends ConsumerStatefulWidget {
  const _StrengthTab();

  @override
  ConsumerState<_StrengthTab> createState() => _StrengthTabState();
}

class _StrengthTabState extends ConsumerState<_StrengthTab> {
  Exercise? _selectedExercise;

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(allExercisesProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: exercisesAsync.when(
            loading: () => const CircularProgressIndicator(),
            error: (e, _) => Text('Error: $e', style: const TextStyle(color: Colors.white54)),
            data: (exercises) => DropdownButtonFormField<Exercise>(
              value: _selectedExercise,
              hint: const Text('Select Exercise', style: TextStyle(color: Colors.white54)),
              dropdownColor: const Color(0xFF1E1E2E),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF2A2A3E),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              ),
              items: exercises.map((ex) => DropdownMenuItem(
                value: ex,
                child: Text(ex.name),
              )).toList(),
              onChanged: (v) => setState(() => _selectedExercise = v),
            ),
          ),
        ),
        Expanded(
          child: _selectedExercise == null
              ? const EmptyStateWidget(
                  icon: Icons.show_chart,
                  title: 'Select an exercise',
                  subtitle: 'Track 1RM over time',
                )
              : _ExerciseProgressView(exercise: _selectedExercise!),
        ),
      ],
    );
  }
}

class _ExerciseProgressView extends ConsumerWidget {
  final Exercise exercise;
  const _ExerciseProgressView({required this.exercise});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(exerciseProgressProvider(exercise.id));

    return progressAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.white54))),
      data: (data) {
        final points = (data['dataPoints'] as List?) ?? [];
        if (points.isEmpty) {
          return const Center(
            child: Text('No data yet. Log some sets!',
                style: TextStyle(color: Colors.white54)),
          );
        }

        final spots = <FlSpot>[];
        for (int i = 0; i < points.length; i++) {
          final val = (points[i]['estimatedOneRM'] as num?)?.toDouble() ?? 0;
          spots.add(FlSpot(i.toDouble(), val));
        }

        final last5 = points.length > 5 ? points.sublist(points.length - 5) : points;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Estimated 1RM Trend',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(height: 8),
              SizedBox(
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
                        final orm = (points[idx]['estimatedOneRM'] as num?)?.toStringAsFixed(1) ?? '';
                        return LineTooltipItem(
                          '$date\n${orm}kg 1RM',
                          const TextStyle(color: Colors.white, fontSize: 12),
                        );
                      }).toList(),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
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
              ),
              const SizedBox(height: 16),
              const Text('Recent Sessions',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(height: 8),
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(1.5),
                  2: FlexColumnWidth(1),
                  3: FlexColumnWidth(1.5),
                },
                children: [
                  TableRow(
                    decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.white24))),
                    children: ['Date', 'Weight', 'Reps', 'Est. 1RM'].map((h) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(h,
                          style: const TextStyle(color: Colors.white54, fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    )).toList(),
                  ),
                  ...last5.reversed.map((p) => TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text(p['date'] ?? '', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text('${p['weightKg']} kg', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text('${p['reps']}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text(
                          '${(p['estimatedOneRM'] as num?)?.toStringAsFixed(1)} kg',
                          style: const TextStyle(color: Color(0xFF00C9A7), fontSize: 12),
                        ),
                      ),
                    ],
                  )),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Body Tab ──────────────────────────────────────────────────────────────────

class _BodyTab extends ConsumerStatefulWidget {
  const _BodyTab();

  @override
  ConsumerState<_BodyTab> createState() => _BodyTabState();
}

class _BodyTabState extends ConsumerState<_BodyTab> {
  final TextEditingController _weightCtrl = TextEditingController();
  bool _logging = false;

  @override
  void dispose() {
    _weightCtrl.dispose();
    super.dispose();
  }

  Future<void> _logWeight() async {
    final text = _weightCtrl.text.trim();
    final weight = double.tryParse(text);
    if (weight == null || weight <= 0) return;

    setState(() => _logging = true);
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      await ref.read(bodyWeightRepositoryProvider).logWeight(date: today, weightKg: weight);
      ref.invalidate(bodyWeightHistoryProvider);
      ref.invalidate(bodyWeightLatestProvider);
      _weightCtrl.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _logging = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final latestAsync = ref.watch(bodyWeightLatestProvider);
    final historyAsync = ref.watch(bodyWeightHistoryProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current weight card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.monitor_weight_outlined, color: Color(0xFF00C9A7), size: 28),
                  const SizedBox(width: 12),
                  latestAsync.when(
                    loading: () => const CircularProgressIndicator(),
                    error: (_, __) => const Text('—', style: TextStyle(color: Colors.white54)),
                    data: (d) => d != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${d['weightKg']} kg',
                                  style: const TextStyle(
                                      fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                              Text('${d['date']}',
                                  style: const TextStyle(color: Colors.white54, fontSize: 13)),
                            ],
                          )
                        : const Text('No weight logged yet',
                            style: TextStyle(color: Colors.white54)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Log weight input
          TextField(
            controller: _weightCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: "Today's weight (kg)",
              labelStyle: const TextStyle(color: Colors.white54),
              suffixText: 'kg',
              suffixStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: const Color(0xFF2A2A3E),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _logging ? null : _logWeight,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C4DFF),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: _logging
                  ? const SizedBox(height: 20, width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Log Weight', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 24),

          // Weight history chart
          const Text('Last 30 Days',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 12),
          historyAsync.when(
            loading: () => const SizedBox(height: 220, child: Center(child: CircularProgressIndicator())),
            error: (e, _) => Text('Error: $e', style: const TextStyle(color: Colors.white54)),
            data: (history) {
              if (history.isEmpty) {
                return const EmptyStateWidget(
                  icon: Icons.scale,
                  title: 'No data',
                  subtitle: 'Log your weight daily',
                );
              }
              final spots = <FlSpot>[];
              for (int i = 0; i < history.length; i++) {
                final w = (history[i]['weightKg'] as num?)?.toDouble() ?? 0;
                spots.add(FlSpot(i.toDouble(), w));
              }
              return SizedBox(
                height: 220,
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
                        final date = history[idx]['date'] ?? '';
                        final wkg = (history[idx]['weightKg'] as num?)?.toStringAsFixed(1) ?? '';
                        return LineTooltipItem(
                          '$date\n${wkg}kg',
                          const TextStyle(color: Colors.white, fontSize: 12),
                        );
                      }).toList(),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: const Color(0xFF7C4DFF),
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color(0xFF7C4DFF).withOpacity(0.25),
                            const Color(0xFF7C4DFF).withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  ],
                )),
              );
            },
          ),
          const SizedBox(height: 16),

          // Weight history table
          historyAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (history) {
              if (history.isEmpty) return const SizedBox.shrink();
              final recent = history.reversed.take(7).toList();
              return DataTable(
                columnSpacing: 24,
                columns: const [
                  DataColumn(label: Text('Date', style: TextStyle(color: Colors.white54))),
                  DataColumn(label: Text('Weight (kg)', style: TextStyle(color: Colors.white54))),
                ],
                rows: recent.map((entry) => DataRow(cells: [
                  DataCell(Text(entry['date'] ?? '', style: const TextStyle(color: Colors.white70, fontSize: 13))),
                  DataCell(Text('${entry['weightKg']}', style: const TextStyle(color: Colors.white, fontSize: 13))),
                ])).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── StatCard helper ───────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const Spacer(),
            Text(value,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
