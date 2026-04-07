import 'package:flutter/material.dart';

import '../../models/customer_model.dart';

class AddFarmerScreen extends StatefulWidget {
  const AddFarmerScreen({
    super.key,
    required this.dairyId,
  });

  final String dairyId;

  @override
  State<AddFarmerScreen> createState() => _AddFarmerScreenState();
}

class _AddFarmerScreenState extends State<AddFarmerScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _villageController = TextEditingController();
  final TextEditingController _advanceController = TextEditingController(text: '0');

  String _cattleType = 'Cow';

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _villageController.dispose();
    _advanceController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final CustomerModel customer = CustomerModel(
      id: 'c_${DateTime.now().millisecondsSinceEpoch}',
      dairyId: widget.dairyId,
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      village: _villageController.text.trim(),
      cattleType: _cattleType,
      totalAdvance: double.tryParse(_advanceController.text.trim()) ?? 0,
      usedAdvance: 0,
      isActive: true,
    );

    Navigator.of(context).pop(customer);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Farmer')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Farmer name',
                border: OutlineInputBorder(),
              ),
              validator: _required,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: _required,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _villageController,
              decoration: const InputDecoration(
                labelText: 'Village',
                border: OutlineInputBorder(),
              ),
              validator: _required,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _cattleType,
              decoration: const InputDecoration(
                labelText: 'Cattle type',
                border: OutlineInputBorder(),
              ),
              items: const <DropdownMenuItem<String>>[
                DropdownMenuItem<String>(value: 'Cow', child: Text('Cow')),
                DropdownMenuItem<String>(value: 'Buffalo', child: Text('Buffalo')),
              ],
              onChanged: (String? value) {
                if (value == null) {
                  return;
                }
                setState(() {
                  _cattleType = value;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _advanceController,
              decoration: const InputDecoration(
                labelText: 'Opening advance',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _submit,
              child: const Text('Save Farmer'),
            ),
          ],
        ),
      ),
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }
}
