import 'package:flutter/material.dart';

import '../../core/app_localizations.dart';
import '../../models/customer_model.dart';
import '../../models/khata_entry_model.dart';

class AddKhataEntryScreen extends StatefulWidget {
  const AddKhataEntryScreen({
    super.key,
    required this.customer,
  });

  final CustomerModel customer;

  @override
  State<AddKhataEntryScreen> createState() => _AddKhataEntryScreenState();
}

class _AddKhataEntryScreenState extends State<AddKhataEntryScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  String _type = 'deposit';

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final KhataEntryModel entry = KhataEntryModel(
      id: 'k_${DateTime.now().millisecondsSinceEpoch}',
      dairyId: widget.customer.dairyId,
      customerId: widget.customer.id,
      type: _type,
      amount: double.parse(_amountController.text.trim()),
      note: _noteController.text.trim(),
      createdAt: DateTime.now(),
    );

    Navigator.of(context).pop(entry);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('addKhataEntry')),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Text(
              widget.customer.name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _type,
              decoration: InputDecoration(
                labelText: l10n.t('entryType'),
                border: const OutlineInputBorder(),
              ),
              items: <DropdownMenuItem<String>>[
                DropdownMenuItem<String>(value: 'deposit', child: Text(l10n.t('deposit'))),
                DropdownMenuItem<String>(value: 'feed', child: Text(l10n.t('feed'))),
                DropdownMenuItem<String>(value: 'advance', child: Text(l10n.t('advance'))),
                DropdownMenuItem<String>(value: 'deduction', child: Text(l10n.t('manualDeduction'))),
              ],
              onChanged: (String? value) {
                if (value == null) {
                  return;
                }
                setState(() {
                  _type = value;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: l10n.t('amount'),
                border: const OutlineInputBorder(),
              ),
              validator: (String? value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.t('amountRequired');
                }
                final double? parsed = double.tryParse(value);
                if (parsed == null || parsed <= 0) {
                  return l10n.t('enterValidAmount');
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _noteController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: l10n.t('note'),
                border: const OutlineInputBorder(),
              ),
              validator: (String? value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.t('noteRequired');
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _submit,
              child: Text(l10n.t('saveKhataEntry')),
            ),
          ],
        ),
      ),
    );
  }
}
