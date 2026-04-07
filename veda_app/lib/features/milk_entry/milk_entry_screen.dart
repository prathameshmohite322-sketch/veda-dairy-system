import 'package:flutter/material.dart';

import '../../models/customer_model.dart';
import '../../services/milk_entry_service.dart';

class MilkEntryScreen extends StatefulWidget {
  const MilkEntryScreen({
    super.key,
    required this.customers,
    required this.milkEntryService,
    required this.dairyId,
  });

  final List<CustomerModel> customers;
  final MilkEntryService milkEntryService;
  final String dairyId;

  @override
  State<MilkEntryScreen> createState() => _MilkEntryScreenState();
}

class _MilkEntryScreenState extends State<MilkEntryScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _litersController = TextEditingController();
  final TextEditingController _fatController = TextEditingController();
  final TextEditingController _snfController = TextEditingController();

  CustomerModel? _selectedCustomer;
  String _selectedShift = 'Morning';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.customers.isNotEmpty) {
      _selectedCustomer = widget.customers.first;
    }
  }

  @override
  void dispose() {
    _litersController.dispose();
    _fatController.dispose();
    _snfController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedCustomer == null) {
      return;
    }

    setState(() {
      _saving = true;
    });

    await widget.milkEntryService.addEntry(
      dairyId: widget.dairyId,
      customer: _selectedCustomer!,
      shift: _selectedShift,
      liters: double.parse(_litersController.text),
      fat: double.parse(_fatController.text),
      snf: double.parse(_snfController.text),
    );

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Milk Entry')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            DropdownButtonFormField<CustomerModel>(
              initialValue: _selectedCustomer,
              decoration: const InputDecoration(
                labelText: 'Farmer',
                border: OutlineInputBorder(),
              ),
              items: widget.customers
                  .map(
                    (CustomerModel customer) => DropdownMenuItem<CustomerModel>(
                      value: customer,
                      child: Text('${customer.name} (${customer.cattleType})'),
                    ),
                  )
                  .toList(),
              onChanged: (CustomerModel? value) {
                setState(() {
                  _selectedCustomer = value;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedShift,
              decoration: const InputDecoration(
                labelText: 'Shift',
                border: OutlineInputBorder(),
              ),
              items: const <DropdownMenuItem<String>>[
                DropdownMenuItem<String>(value: 'Morning', child: Text('Morning')),
                DropdownMenuItem<String>(value: 'Evening', child: Text('Evening')),
              ],
              onChanged: (String? value) {
                if (value == null) {
                  return;
                }
                setState(() {
                  _selectedShift = value;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _litersController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Liters',
                border: OutlineInputBorder(),
              ),
              validator: _requiredNumber,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _fatController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Fat',
                border: OutlineInputBorder(),
              ),
              validator: _requiredNumber,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _snfController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'SNF',
                border: OutlineInputBorder(),
              ),
              validator: _requiredNumber,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _saving ? null : _submit,
              child: Text(_saving ? 'Saving...' : 'Save Entry'),
            ),
          ],
        ),
      ),
    );
  }

  String? _requiredNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    final double? parsed = double.tryParse(value);
    if (parsed == null || parsed <= 0) {
      return 'Enter a valid number';
    }
    return null;
  }
}
