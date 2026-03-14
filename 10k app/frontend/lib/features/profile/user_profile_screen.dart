import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/nutrition_providers.dart';
import '../../providers/user_profile_providers.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({super.key, this.isTab = false});
  final bool isTab;

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();

  String _gender = 'MALE';
  String _activityLevel = 'MODERATE';
  String _fitnessGoal = 'MAINTAIN';
  bool _saving = false;
  bool _initialised = false;

  static const _activityOptions = [
    ('SEDENTARY', 'Sedentary'),
    ('LIGHT', 'Light'),
    ('MODERATE', 'Moderate'),
    ('ACTIVE', 'Active'),
    ('VERY_ACTIVE', 'Very Active'),
  ];

  static const _goalOptions = [
    ('MAINTAIN', 'Maintain'),
    ('CUT', 'Cut'),
    ('BULK', 'Bulk'),
    ('BODY_RECOMP', 'Body Recomp'),
  ];

  static const _activityMultipliers = {
    'SEDENTARY': 1.2,
    'LIGHT': 1.375,
    'MODERATE': 1.55,
    'ACTIVE': 1.725,
    'VERY_ACTIVE': 1.9,
  };

  static const _goalMultipliers = {
    'MAINTAIN': 1.0,
    'CUT': 0.80,
    'BULK': 1.15,
    'BODY_RECOMP': 1.0,
  };

  @override
  void dispose() {
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  Map<String, double> _calcPreview() {
    final w = double.tryParse(_weightCtrl.text) ?? 70;
    final h = double.tryParse(_heightCtrl.text) ?? 170;
    final a = int.tryParse(_ageCtrl.text) ?? 22;
    final bmr = 10 * w + 6.25 * h - 5 * a + (_gender == 'MALE' ? 5 : -161);
    final actMult = _activityMultipliers[_activityLevel]!;
    final goalMult = _goalMultipliers[_fitnessGoal]!;
    final goalCalories = bmr * actMult * goalMult;
    double proteinFactor;
    switch (_fitnessGoal) {
      case 'CUT':
      case 'BODY_RECOMP':
        proteinFactor = 2.2;
        break;
      case 'BULK':
        proteinFactor = 1.8;
        break;
      default:
        proteinFactor = 2.0;
    }
    final protein = w * proteinFactor;
    final fat = goalCalories * 0.25 / 9;
    final carbs = (goalCalories - protein * 4 - fat * 9) / 4;
    return {
      'calories': goalCalories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }

  Future<void> _save() async {
    final height = double.tryParse(_heightCtrl.text);
    final weight = double.tryParse(_weightCtrl.text);
    final age = int.tryParse(_ageCtrl.text);
    if (height == null ||
        height <= 0 ||
        weight == null ||
        weight <= 0 ||
        age == null ||
        age < 10 ||
        age > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid stats')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(userProfileRepositoryProvider).updateProfile(
            heightCm: height,
            weightKg: weight,
            age: age,
            gender: _gender,
            activityLevel: _activityLevel,
            fitnessGoal: _fitnessGoal,
          );
      ref.invalidate(userProfileProvider);
      ref.invalidate(nutritionGoalProvider);
      ref.invalidate(dailySummaryProvider);
      if (mounted) {
        if (widget.isTab) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile & goals updated!')),
          );
        } else {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    profileAsync.whenData((p) {
      if (!_initialised) {
        _heightCtrl.text = p.heightCm.toStringAsFixed(1);
        _weightCtrl.text = p.weightKg.toStringAsFixed(1);
        _ageCtrl.text = p.age.toString();
        _gender = p.gender;
        _activityLevel = p.activityLevel;
        _fitnessGoal = p.fitnessGoal;
        _initialised = true;
      }
    });

    final preview = _calcPreview();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: const Text('Save',
                style: TextStyle(color: Color(0xFF00C9A7))),
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(
            child: Text('Error loading profile',
                style: TextStyle(color: Colors.white54))),
        data: (_) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero stats row
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _heroStat(
                        Icons.straighten,
                        _heightCtrl.text.isEmpty
                            ? '--'
                            : '${_heightCtrl.text}cm',
                        'Height',
                        const Color(0xFF00C9A7)),
                    _heroStat(
                        Icons.monitor_weight_outlined,
                        _weightCtrl.text.isEmpty
                            ? '--'
                            : '${_weightCtrl.text}kg',
                        'Weight',
                        const Color(0xFF42A5F5)),
                    _heroStat(
                        Icons.cake_outlined,
                        _ageCtrl.text.isEmpty ? '--' : _ageCtrl.text,
                        'Age',
                        const Color(0xFFFF8A65)),
                  ],
                ),
              ),

              // Section 1: Stats
              _sectionHeader('Your Stats'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _numField(
                      controller: _heightCtrl,
                      label: 'Height (cm)',
                      color: const Color(0xFF00C9A7),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _numField(
                      controller: _weightCtrl,
                      label: 'Weight (kg)',
                      color: const Color(0xFF42A5F5),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _numField(
                      controller: _ageCtrl,
                      label: 'Age',
                      color: const Color(0xFFFF8A65),
                      isInt: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Section 2: Activity & Goal
              _sectionHeader('Activity & Goal'),
              const SizedBox(height: 12),
              const Text('Gender',
                  style: TextStyle(color: Colors.white54, fontSize: 13)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _genderChip('MALE', 'Male'),
                  const SizedBox(width: 12),
                  _genderChip('FEMALE', 'Female'),
                ],
              ),
              const SizedBox(height: 16),
              _dropdownField(
                label: 'Activity Level',
                value: _activityLevel,
                options: _activityOptions,
                onChanged: (v) => setState(() => _activityLevel = v!),
              ),
              const SizedBox(height: 16),
              _dropdownField(
                label: 'Fitness Goal',
                value: _fitnessGoal,
                options: _goalOptions,
                onChanged: (v) => setState(() => _fitnessGoal = v!),
              ),
              const SizedBox(height: 24),

              // Live preview card
              _previewCard(preview),
              const SizedBox(height: 24),

              // Gradient save button
              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF00C9A7), Color(0xFF00E5BF)]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _saving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Save & Apply Goals',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _heroStat(
      IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(value,
            style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 15)),
        const SizedBox(height: 2),
        Text(label,
            style:
                const TextStyle(color: Colors.white38, fontSize: 11)),
      ],
    );
  }

  Widget _sectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00C9A7), Color(0xFF00E5BF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(title,
            style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
      ],
    );
  }

  Widget _numField({
    required TextEditingController controller,
    required String label,
    required Color color,
    bool isInt = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isInt
          ? TextInputType.number
          : const TextInputType.numberWithOptions(decimal: true),
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: color, fontSize: 12),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: color.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: color),
          borderRadius: BorderRadius.circular(8),
        ),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      ),
      style: const TextStyle(color: Colors.white, fontSize: 14),
    );
  }

  Widget _genderChip(String value, String label) {
    final selected = _gender == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _gender = value),
      selectedColor:
          const Color(0xFF00C9A7).withValues(alpha: 0.3),
      labelStyle: TextStyle(
          color:
              selected ? const Color(0xFF00C9A7) : Colors.white54),
      side: BorderSide(
          color: selected
              ? const Color(0xFF00C9A7)
              : Colors.white24),
    );
  }

  Widget _dropdownField({
    required String label,
    required String value,
    required List<(String, String)> options,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            const TextStyle(color: Colors.white54, fontSize: 13),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white24),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide:
              const BorderSide(color: Color(0xFF00C9A7)),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      dropdownColor: const Color(0xFF1E1E2E),
      style: const TextStyle(color: Colors.white),
      onChanged: (v) {
        onChanged(v);
        setState(() {});
      },
      items: options
          .map((o) => DropdownMenuItem(value: o.$1, child: Text(o.$2)))
          .toList(),
    );
  }

  Widget _previewCard(Map<String, double> preview) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00C9A7).withValues(alpha: 0.1),
            const Color(0xFF7C4DFF).withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: const Color(0xFF00C9A7).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Calculated Goals Preview',
              style: TextStyle(
                  color: Color(0xFF00C9A7),
                  fontWeight: FontWeight.w700,
                  fontSize: 14)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _previewStat('Calories', '${preview['calories']!.toInt()}',
                  'kcal', const Color(0xFFFF8A65)),
              _previewStat('Protein', '${preview['protein']!.toInt()}',
                  'g', const Color(0xFF42A5F5)),
              _previewStat('Carbs', '${preview['carbs']!.toInt()}', 'g',
                  const Color(0xFF66BB6A)),
              _previewStat('Fat', '${preview['fat']!.toInt()}', 'g',
                  const Color(0xFFEC407A)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _previewStat(
      String label, String value, String unit, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.w700)),
        Text(unit,
            style: const TextStyle(
                color: Colors.white38, fontSize: 11)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(
                color: Colors.white54, fontSize: 11)),
      ],
    );
  }
}
