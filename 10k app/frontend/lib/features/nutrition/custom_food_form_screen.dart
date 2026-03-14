import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/nutrition_providers.dart';

class CustomFoodFormScreen extends ConsumerStatefulWidget {
  const CustomFoodFormScreen({super.key});

  @override
  ConsumerState<CustomFoodFormScreen> createState() => _CustomFoodFormScreenState();
}

class _CustomFoodFormScreenState extends ConsumerState<CustomFoodFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _calCtrl = TextEditingController();
  final _proteinCtrl = TextEditingController();
  final _carbsCtrl = TextEditingController();
  final _fatCtrl = TextEditingController();
  final _servingCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _calCtrl.dispose();
    _proteinCtrl.dispose();
    _carbsCtrl.dispose();
    _fatCtrl.dispose();
    _servingCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom Food')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Food Name'),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _calCtrl,
              decoration: const InputDecoration(labelText: 'Calories', suffixText: 'kcal'),
              keyboardType: TextInputType.number,
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: TextFormField(
                  controller: _proteinCtrl,
                  decoration: const InputDecoration(labelText: 'Protein', suffixText: 'g'),
                  keyboardType: TextInputType.number,
                )),
                const SizedBox(width: 12),
                Expanded(child: TextFormField(
                  controller: _carbsCtrl,
                  decoration: const InputDecoration(labelText: 'Carbs', suffixText: 'g'),
                  keyboardType: TextInputType.number,
                )),
                const SizedBox(width: 12),
                Expanded(child: TextFormField(
                  controller: _fatCtrl,
                  decoration: const InputDecoration(labelText: 'Fat', suffixText: 'g'),
                  keyboardType: TextInputType.number,
                )),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _servingCtrl,
              decoration: const InputDecoration(
                  labelText: 'Serving Size', hintText: 'e.g. 1 bowl, 2 pieces'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(height: 20, width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Save Food Item'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref.read(nutritionRepositoryProvider).addCustomFood(
        name: _nameCtrl.text,
        calories: double.parse(_calCtrl.text),
        proteinG: double.tryParse(_proteinCtrl.text) ?? 0,
        carbsG: double.tryParse(_carbsCtrl.text) ?? 0,
        fatG: double.tryParse(_fatCtrl.text) ?? 0,
        servingSize: _servingCtrl.text.isEmpty ? null : _servingCtrl.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Custom food added!'),
              backgroundColor: Color(0xFF00C9A7)),
        );
        Navigator.pop(context);
      }
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
}
