import 'package:flutter/material.dart';

import '../../core/app_localizations.dart';
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
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.t('addFarmerTitle'))),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.t('farmerName'),
                border: const OutlineInputBorder(),
              ),
              validator: (String? value) => _required(value, l10n),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: l10n.t('phone'),
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: (String? value) => _required(value, l10n),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _villageController,
              decoration: InputDecoration(
                labelText: l10n.t('village'),
                border: const OutlineInputBorder(),
              ),
              validator: (String? value) => _required(value, l10n),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _cattleType,
              decoration: InputDecoration(
                labelText: l10n.t('cattleType'),
                border: const OutlineInputBorder(),
              ),
              items: <DropdownMenuItem<String>>[
                DropdownMenuItem<String>(value: 'Cow', child: Text(l10n.t('cow'))),
                DropdownMenuItem<String>(value: 'Buffalo', child: Text(l10n.t('buffalo'))),
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
              decoration: InputDecoration(
                labelText: l10n.t('openingAdvance'),
                border: const OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _submit,
              child: Text(l10n.t('saveFarmer')),
            ),
          ],
        ),
      ),
    );
  }

  String? _required(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) {
      return l10n.t('required');
    }
    return null;
  }
}
