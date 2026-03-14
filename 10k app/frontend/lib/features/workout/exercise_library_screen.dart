import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/exercise.dart';
import '../../providers/exercise_providers.dart';

class ExerciseLibraryScreen extends ConsumerStatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  ConsumerState<ExerciseLibraryScreen> createState() =>
      _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState
    extends ConsumerState<ExerciseLibraryScreen> {
  String _search = '';
  String _selectedGroup = 'All';

  static const _muscleGroups = [
    'All',
    'CHEST',
    'BACK',
    'SHOULDERS',
    'BICEPS',
    'TRICEPS',
    'LEGS',
    'CORE',
    'FULL_BODY',
  ];

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(allExercisesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Exercise Library')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddExerciseSheet(context),
        backgroundColor: const Color(0xFF7C4DFF),
        icon: const Icon(Icons.add),
        label: const Text('Custom Exercise'),
      ),
      body: exercisesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text('Error: $e')),
        data: (exercises) {
          // Filter by search and muscle group
          final filtered = exercises.where((ex) {
            final matchSearch = _search.isEmpty ||
                ex.name.toLowerCase().contains(_search.toLowerCase());
            final matchGroup =
                _selectedGroup == 'All' || ex.muscleGroup == _selectedGroup;
            return matchSearch && matchGroup;
          }).toList();

          // Group by muscle group
          final Map<String, List<Exercise>> grouped = {};
          for (final ex in filtered) {
            grouped.putIfAbsent(ex.muscleGroup, () => []).add(ex);
          }

          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search exercises...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    isDense: true,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onChanged: (v) => setState(() => _search = v),
                ),
              ),
              // Filter chips
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  children: _muscleGroups
                      .map((g) => Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ChoiceChip(
                              label: Text(
                                g == 'FULL_BODY' ? 'Full Body' : _title(g),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _selectedGroup == g
                                      ? Colors.white
                                      : Colors.white54,
                                ),
                              ),
                              selected: _selectedGroup == g,
                              onSelected: (_) =>
                                  setState(() => _selectedGroup = g),
                              selectedColor: const Color(0xFF7C4DFF),
                            ),
                          ))
                      .toList(),
                ),
              ),
              // Exercise list
              Expanded(
                child: filtered.isEmpty
                    ? const Center(
                        child: Text('No exercises found',
                            style: TextStyle(color: Colors.white54)))
                    : ListView(
                        children: grouped.entries.map((entry) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Sticky-style header
                              Container(
                                width: double.infinity,
                                color: const Color(0xFF12122A),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 6),
                                child: Text(
                                  entry.key == 'FULL_BODY'
                                      ? 'Full Body'
                                      : _title(entry.key),
                                  style: const TextStyle(
                                      color: Color(0xFF00C9A7),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13),
                                ),
                              ),
                              ...entry.value.map((ex) => ListTile(
                                    dense: true,
                                    title: Text(ex.name,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14)),
                                    trailing: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: ex.exerciseType == 'BODYWEIGHT'
                                            ? const Color(0xFF1A3A2A)
                                            : const Color(0xFF1A1A3A),
                                        borderRadius:
                                            BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        ex.exerciseType == 'BODYWEIGHT'
                                            ? 'BW'
                                            : 'WT',
                                        style: TextStyle(
                                          color: ex.exerciseType == 'BODYWEIGHT'
                                              ? const Color(0xFF00C9A7)
                                              : const Color(0xFF7C4DFF),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  )),
                            ],
                          );
                        }).toList(),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _title(String s) =>
      s[0].toUpperCase() + s.substring(1).toLowerCase();

  void _showAddExerciseSheet(BuildContext context) {
    final nameCtrl = TextEditingController();
    String selectedType = 'WEIGHT';
    String selectedGroup = 'CHEST';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
              16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add Custom Exercise',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                    labelText: 'Exercise Name', isDense: true),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(
                    labelText: 'Type', isDense: true),
                dropdownColor: const Color(0xFF1A1A2E),
                items: ['WEIGHT', 'BODYWEIGHT']
                    .map((t) => DropdownMenuItem(
                        value: t,
                        child: Text(t,
                            style:
                                const TextStyle(color: Colors.white))))
                    .toList(),
                onChanged: (v) =>
                    setSheetState(() => selectedType = v ?? selectedType),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedGroup,
                decoration: const InputDecoration(
                    labelText: 'Muscle Group', isDense: true),
                dropdownColor: const Color(0xFF1A1A2E),
                items: [
                  'CHEST',
                  'BACK',
                  'SHOULDERS',
                  'BICEPS',
                  'TRICEPS',
                  'LEGS',
                  'CORE',
                  'FULL_BODY'
                ]
                    .map((g) => DropdownMenuItem(
                        value: g,
                        child: Text(g,
                            style:
                                const TextStyle(color: Colors.white))))
                    .toList(),
                onChanged: (v) =>
                    setSheetState(() => selectedGroup = v ?? selectedGroup),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final name = nameCtrl.text.trim();
                    if (name.isEmpty) return;
                    try {
                      await ref
                          .read(exerciseRepositoryProvider)
                          .addExercise(Exercise(
                            id: 0,
                            name: name,
                            exerciseType: selectedType,
                            muscleGroup: selectedGroup,
                          ));
                      ref.invalidate(allExercisesProvider);
                      if (ctx.mounted) Navigator.pop(ctx);
                    } catch (e) {
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: Colors.red));
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C4DFF)),
                  child: const Text('Add Exercise'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
