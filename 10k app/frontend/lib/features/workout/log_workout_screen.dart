import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/models/workout.dart';
import '../../data/models/workout_set.dart' as ws;
import '../../data/models/exercise.dart';
import '../../providers/exercise_providers.dart';
import '../../providers/workout_providers.dart';

class LogWorkoutScreen extends ConsumerStatefulWidget {
  final List<ws.WorkoutSet>? repeatSets;
  const LogWorkoutScreen({super.key, this.repeatSets});

  @override
  ConsumerState<LogWorkoutScreen> createState() => _LogWorkoutScreenState();
}

class _LogWorkoutScreenState extends ConsumerState<LogWorkoutScreen> {
  final _notesCtrl = TextEditingController();
  // Grouped by exercise
  final List<_ExerciseGroup> _groups = [];
  bool _saving = false;

  // Active workout timer
  final Stopwatch _workoutStopwatch = Stopwatch();
  Timer? _ticker;
  String _elapsedDisplay = '00:00:00';

  // Rest timer
  int _restDuration = 90;
  int _restSecondsRemaining = 0;
  Timer? _restTimer;
  bool _restActive = false;

  bool get _hasAnySets => _groups.any((g) => g.sets.isNotEmpty);

  @override
  void initState() {
    super.initState();
    _workoutStopwatch.start();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      final e = _workoutStopwatch.elapsed;
      setState(() {
        _elapsedDisplay =
            '${e.inHours.toString().padLeft(2, '0')}:'
            '${(e.inMinutes % 60).toString().padLeft(2, '0')}:'
            '${(e.inSeconds % 60).toString().padLeft(2, '0')}';
      });
    });

    // Pre-fill sets grouped by exercise if repeating
    if (widget.repeatSets != null && widget.repeatSets!.isNotEmpty) {
      for (final s in widget.repeatSets!) {
        final existing = _groups
            .where((g) => g.exerciseId == s.exerciseId)
            .firstOrNull;
        if (existing != null) {
          existing.sets.add(_SetEntry(
            setNumber: existing.sets.length + 1,
            weight: s.weightKg ?? 0,
            reps: s.reps ?? 0,
          ));
        } else {
          final group = _ExerciseGroup(
            exerciseId: s.exerciseId,
            exerciseName: s.exerciseName ?? 'Exercise ${s.exerciseId}',
          );
          group.sets.add(_SetEntry(
            setNumber: 1,
            weight: s.weightKg ?? 0,
            reps: s.reps ?? 0,
          ));
          _groups.add(group);
        }
      }
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _restTimer?.cancel();
    _workoutStopwatch.stop();
    _notesCtrl.dispose();
    for (final g in _groups) {
      for (final s in g.sets) s.dispose();
    }
    super.dispose();
  }

  void _startRestTimer() {
    _restTimer?.cancel();
    setState(() {
      _restSecondsRemaining = _restDuration;
      _restActive = true;
    });
    _restTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        if (_restSecondsRemaining <= 1) {
          _restSecondsRemaining = 0;
          _restActive = false;
          t.cancel();
          HapticFeedback.vibrate();
        } else {
          _restSecondsRemaining--;
        }
      });
    });
  }

  void _stopRestTimer() {
    _restTimer?.cancel();
    setState(() {
      _restActive = false;
      _restSecondsRemaining = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(allExercisesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Log Workout  $_elapsedDisplay',
            style: const TextStyle(fontSize: 15)),
        actions: [
          TextButton(
            onPressed: _saving || !_hasAnySets ? null : _saveWorkout,
            child: _saving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Save',
                    style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: exercisesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (exercises) => Column(
          children: [
            // Rest duration chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  const Text('Rest: ',
                      style: TextStyle(color: Colors.white54, fontSize: 13)),
                  ...[30, 60, 90, 120, 180, 300].map((s) => Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(s >= 60 ? '${s ~/ 60}m' : '${s}s'),
                          selected: _restDuration == s,
                          onSelected: (_) =>
                              setState(() => _restDuration = s),
                          selectedColor: const Color(0xFF7C4DFF),
                          labelStyle: TextStyle(
                            color: _restDuration == s
                                ? Colors.white
                                : Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      )),
                ],
              ),
            ),
            // Rest timer banner
            if (_restActive)
              Container(
                width: double.infinity,
                color: const Color(0xFF0D2A20),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.timer,
                        color: Color(0xFF00C9A7), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Rest: ${_restSecondsRemaining}s',
                      style: const TextStyle(
                          color: Color(0xFF00C9A7),
                          fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => setState(() {
                        _restSecondsRemaining =
                            (_restSecondsRemaining + 30).clamp(0, 600);
                      }),
                      child: const Text('+30s',
                          style:
                              TextStyle(fontSize: 12, color: Colors.white70)),
                    ),
                    TextButton(
                      onPressed: _stopRestTimer,
                      child: const Text('Skip',
                          style: TextStyle(
                              fontSize: 12, color: Colors.white38)),
                    ),
                  ],
                ),
              ),
            // Notes
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: TextField(
                controller: _notesCtrl,
                decoration: const InputDecoration(
                    hintText: 'Workout notes (optional)', isDense: true),
              ),
            ),
            // Exercise groups
            Expanded(
              child: _groups.isEmpty
                  ? Center(
                      child: Text('Tap + to add exercises',
                          style: TextStyle(color: Colors.white38)))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                      itemCount: _groups.length,
                      itemBuilder: (ctx, i) =>
                          _buildExerciseGroup(i, exercises),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: exercisesAsync.maybeWhen(
        data: (exercises) => FloatingActionButton.extended(
          onPressed: () => _showExercisePicker(exercises),
          backgroundColor: const Color(0xFF7C4DFF),
          icon: const Icon(Icons.add),
          label: const Text('Add Exercise'),
        ),
        orElse: () => null,
      ),
    );
  }

  Widget _buildExerciseGroup(int groupIdx, List<Exercise> exercises) {
    final group = _groups[groupIdx];
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise header
            Row(
              children: [
                Expanded(
                  child: Text(
                    group.exerciseName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF7C4DFF),
                        fontSize: 15),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      size: 18, color: Colors.white38),
                  onPressed: () => setState(() {
                    for (final s in group.sets) s.dispose();
                    _groups.removeAt(groupIdx);
                  }),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            // Column headers
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                      width: 32,
                      child: Text('Set',
                          style: TextStyle(
                              color: Colors.white38, fontSize: 11))),
                  SizedBox(width: 8),
                  Expanded(
                      child: Text('kg',
                          style: TextStyle(
                              color: Colors.white38, fontSize: 11))),
                  SizedBox(width: 8),
                  Expanded(
                      child: Text('Reps',
                          style: TextStyle(
                              color: Colors.white38, fontSize: 11))),
                  SizedBox(width: 40), // tick button space
                ],
              ),
            ),
            // Set rows
            ...group.sets.asMap().entries.map((entry) {
              final setIdx = entry.key;
              final set = entry.value;
              return _buildSetRow(group, groupIdx, setIdx, set);
            }),
            const SizedBox(height: 8),
            // Add set button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => setState(() {
                  final prev =
                      group.sets.isNotEmpty ? group.sets.last : null;
                  group.sets.add(_SetEntry(
                    setNumber: group.sets.length + 1,
                    weight: prev?.weight ?? 0,
                    reps: prev?.reps ?? 0,
                  ));
                }),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Set', style: TextStyle(fontSize: 13)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF7C4DFF),
                  side: const BorderSide(color: Color(0xFF7C4DFF)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSetRow(
      _ExerciseGroup group, int groupIdx, int setIdx, _SetEntry set) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          // Set number
          SizedBox(
            width: 32,
            child: Text(
              '${setIdx + 1}',
              style: TextStyle(
                color: set.confirmed
                    ? const Color(0xFF00C9A7)
                    : Colors.white54,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Weight
          Expanded(
            child: TextField(
              controller: set.weightCtrl,
              decoration: InputDecoration(
                hintText: '0',
                isDense: true,
                filled: set.confirmed,
                fillColor: set.confirmed
                    ? const Color(0xFF0D2A20)
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 8),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                        color: set.confirmed
                            ? const Color(0xFF00C9A7)
                            : Colors.white24)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                        color: set.confirmed
                            ? const Color(0xFF00C9A7)
                            : Colors.white24)),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              enabled: !set.confirmed,
              onChanged: (v) => set.weight = double.tryParse(v) ?? 0,
            ),
          ),
          const SizedBox(width: 8),
          // Reps
          Expanded(
            child: TextField(
              controller: set.repsCtrl,
              decoration: InputDecoration(
                hintText: '0',
                isDense: true,
                filled: set.confirmed,
                fillColor: set.confirmed
                    ? const Color(0xFF0D2A20)
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 8),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                        color: set.confirmed
                            ? const Color(0xFF00C9A7)
                            : Colors.white24)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                        color: set.confirmed
                            ? const Color(0xFF00C9A7)
                            : Colors.white24)),
              ),
              keyboardType: TextInputType.number,
              enabled: !set.confirmed,
              onChanged: (v) => set.reps = int.tryParse(v) ?? 0,
            ),
          ),
          const SizedBox(width: 8),
          // Tick / Undo button
          GestureDetector(
            onTap: () {
              setState(() {
                if (!set.confirmed) {
                  // Confirm the set → start rest timer
                  set.confirmed = true;
                  _startRestTimer();
                } else {
                  // Undo confirmation
                  set.confirmed = false;
                }
              });
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: set.confirmed
                    ? const Color(0xFF00C9A7)
                    : const Color(0xFF2A2A3E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                set.confirmed ? Icons.check : Icons.check,
                color: set.confirmed ? Colors.white : Colors.white38,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showExercisePicker(List<Exercise> exercises) {
    String selectedGroup = 'All';
    final allGroups = [
      'All',
      ...exercises.map((e) => e.muscleGroup).toSet().toList()..sort()
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) {
          final filtered = selectedGroup == 'All'
              ? exercises
              : exercises
                  .where((e) => e.muscleGroup == selectedGroup)
                  .toList();

          return DraggableScrollableSheet(
            initialChildSize: 0.75,
            minChildSize: 0.4,
            maxChildSize: 0.95,
            expand: false,
            builder: (ctx, scrollCtrl) => Column(
              children: [
                // Handle
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 12),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Pick Exercise',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 10),
                // Muscle group filter chips
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: allGroups
                        .map((g) => Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: ChoiceChip(
                                label: Text(
                                  g == 'FULL_BODY'
                                      ? 'Full Body'
                                      : g == 'All'
                                          ? 'All'
                                          : _titleCase(g),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: selectedGroup == g
                                        ? Colors.white
                                        : Colors.white54,
                                  ),
                                ),
                                selected: selectedGroup == g,
                                onSelected: (_) =>
                                    setSheet(() => selectedGroup = g),
                                selectedColor: const Color(0xFF7C4DFF),
                                padding: EdgeInsets.zero,
                              ),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 8),
                // Exercise list
                Expanded(
                  child: ListView.builder(
                    controller: scrollCtrl,
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) {
                      final ex = filtered[i];
                      final alreadyAdded = _groups
                          .any((g) => g.exerciseId == ex.id);
                      return ListTile(
                        dense: true,
                        title: Text(ex.name,
                            style:
                                const TextStyle(color: Colors.white)),
                        subtitle: Text(ex.muscleGroup,
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 11)),
                        trailing: alreadyAdded
                            ? TextButton(
                                onPressed: () {
                                  setState(() {
                                    final group = _groups.firstWhere(
                                        (g) => g.exerciseId == ex.id);
                                    final prev = group.sets.isNotEmpty
                                        ? group.sets.last
                                        : null;
                                    group.sets.add(_SetEntry(
                                      setNumber: group.sets.length + 1,
                                      weight: prev?.weight ?? 0,
                                      reps: prev?.reps ?? 0,
                                    ));
                                  });
                                  Navigator.pop(ctx);
                                },
                                child: const Text('+ Set',
                                    style: TextStyle(
                                        color: Color(0xFF00C9A7),
                                        fontSize: 12)),
                              )
                            : IconButton(
                                icon: const Icon(Icons.add_circle_outline,
                                    color: Color(0xFF7C4DFF), size: 22),
                                onPressed: () {
                                  setState(() {
                                    final group = _ExerciseGroup(
                                      exerciseId: ex.id,
                                      exerciseName: ex.name,
                                    );
                                    group.sets.add(_SetEntry(setNumber: 1));
                                    _groups.add(group);
                                  });
                                  Navigator.pop(ctx);
                                },
                              ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _titleCase(String s) =>
      s[0].toUpperCase() + s.substring(1).toLowerCase();

  Future<void> _saveWorkout() async {
    setState(() => _saving = true);
    try {
      // Flatten groups → sets
      final allSets = <ws.WorkoutSet>[];
      int globalSetNum = 1;
      for (final group in _groups) {
        for (final set in group.sets) {
          allSets.add(ws.WorkoutSet(
            exerciseId: group.exerciseId,
            setNumber: globalSetNum++,
            reps: set.reps,
            weightKg: set.weight,
          ));
        }
      }

      final workout = Workout(
        workoutDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        notes: _notesCtrl.text.isEmpty ? null : _notesCtrl.text,
        sets: allSets,
      );
      final saved =
          await ref.read(workoutRepositoryProvider).createWorkout(workout);

      final prExercises = saved.sets
          .where((s) => s.isPR && s.exerciseName != null)
          .map((s) => s.exerciseName!)
          .toSet()
          .toList();

      if (mounted) {
        if (prExercises.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('New PR on ${prExercises.join(', ')}!'),
              backgroundColor: const Color(0xFFFFD700),
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Workout saved!'),
                backgroundColor: Color(0xFF7C4DFF)),
          );
        }
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

// ── Data classes ──────────────────────────────────────────────

class _ExerciseGroup {
  final int exerciseId;
  final String exerciseName;
  final List<_SetEntry> sets;

  _ExerciseGroup({required this.exerciseId, required this.exerciseName})
      : sets = [];
}

class _SetEntry {
  int setNumber;
  double weight;
  int reps;
  bool confirmed;
  late TextEditingController weightCtrl;
  late TextEditingController repsCtrl;

  _SetEntry({
    required this.setNumber,
    this.weight = 0,
    this.reps = 0,
    this.confirmed = false,
  }) {
    weightCtrl = TextEditingController(
        text: weight > 0 ? weight.toStringAsFixed(weight % 1 == 0 ? 0 : 1) : '');
    repsCtrl = TextEditingController(
        text: reps > 0 ? reps.toString() : '');
  }

  void dispose() {
    weightCtrl.dispose();
    repsCtrl.dispose();
  }
}
