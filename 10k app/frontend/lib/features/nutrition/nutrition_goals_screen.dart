import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/nutrition_providers.dart';
import '../../providers/user_profile_providers.dart';
import '../profile/user_profile_screen.dart';

class NutritionGoalsScreen extends ConsumerStatefulWidget {
  const NutritionGoalsScreen({super.key});

  @override
  ConsumerState<NutritionGoalsScreen> createState() => _NutritionGoalsScreenState();
}

class _NutritionGoalsScreenState extends ConsumerState<NutritionGoalsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  bool _saving = false;
  bool _initialised = false;

  @override
  void dispose() {
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  void _populateFields(goal) {
    _caloriesController.text = goal.goalCalories.toInt().toString();
    _proteinController.text = goal.goalProtein.toInt().toString();
    _carbsController.text = goal.goalCarbs.toInt().toString();
    _fatController.text = goal.goalFat.toInt().toString();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref.read(nutritionRepositoryProvider).updateGoal(
            goalCalories: double.parse(_caloriesController.text),
            goalProtein: double.parse(_proteinController.text),
            goalCarbs: double.parse(_carbsController.text),
            goalFat: double.parse(_fatController.text),
          );
      ref.invalidate(nutritionGoalProvider);
      ref.invalidate(dailySummaryProvider);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final goalAsync = ref.watch(nutritionGoalProvider);

    goalAsync.whenData((goal) {
      if (!_initialised) {
        _populateFields(goal);
        _initialised = true;
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition Goals'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: const Text('Save', style: TextStyle(color: Color(0xFF00C9A7))),
          ),
        ],
      ),
      body: goalAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
            child: Text('Could not load goals',
                style: const TextStyle(color: Colors.white54))),
        data: (_) => Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Calculate from Profile shortcut
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    icon: const Icon(Icons.person, size: 18,
                        color: Color(0xFF00C9A7)),
                    label: const Text('Calculate from Profile →',
                        style: TextStyle(color: Color(0xFF00C9A7))),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const UserProfileScreen()),
                      );
                      ref.invalidate(nutritionGoalProvider);
                      setState(() => _initialised = false);
                    },
                  ),
                ),
                const Divider(color: Colors.white12),
                const SizedBox(height: 8),
                _buildField(
                  controller: _caloriesController,
                  label: 'Daily Calories (kcal)',
                  color: const Color(0xFFFF8A65),
                ),
                const SizedBox(height: 16),
                _buildField(
                  controller: _proteinController,
                  label: 'Protein Goal (g)',
                  color: const Color(0xFF42A5F5),
                ),
                const SizedBox(height: 16),
                _buildField(
                  controller: _carbsController,
                  label: 'Carbs Goal (g)',
                  color: const Color(0xFF66BB6A),
                ),
                const SizedBox(height: 16),
                _buildField(
                  controller: _fatController,
                  label: 'Fat Goal (g)',
                  color: const Color(0xFFEC407A),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00C9A7),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _saving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Save Goals',
                            style: TextStyle(
                                color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required Color color,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: color),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: color.withOpacity(0.4)),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: color),
          borderRadius: BorderRadius.circular(8),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      style: const TextStyle(color: Colors.white),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Required';
        final n = double.tryParse(v);
        if (n == null || n <= 0) return 'Must be a positive number';
        return null;
      },
    );
  }
}
