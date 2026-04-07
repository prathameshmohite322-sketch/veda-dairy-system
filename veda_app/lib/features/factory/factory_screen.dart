import 'package:flutter/material.dart';

import '../../core/app_localizations.dart';
import '../../models/factory_sale_model.dart';
import '../../services/factory_service.dart';

class FactoryScreen extends StatefulWidget {
  const FactoryScreen({
    super.key,
    required this.dairyId,
    required this.factoryService,
  });

  final String dairyId;
  final FactoryService factoryService;

  @override
  State<FactoryScreen> createState() => _FactoryScreenState();
}

class _FactoryScreenState extends State<FactoryScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _factoryNameController = TextEditingController();
  final TextEditingController _litersController = TextEditingController();
  final TextEditingController _saleRateController = TextEditingController();
  final TextEditingController _commissionController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  List<FactorySaleModel> _sales = <FactorySaleModel>[];
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  @override
  void dispose() {
    _factoryNameController.dispose();
    _litersController.dispose();
    _saleRateController.dispose();
    _commissionController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadSales() async {
    final List<FactorySaleModel> sales =
        await widget.factoryService.fetchSales(widget.dairyId);
    if (!mounted) {
      return;
    }
    setState(() {
      _sales = sales;
      _loading = false;
    });
  }

  Future<void> _saveSale() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _saving = true;
    });

    await widget.factoryService.addSale(
      dairyId: widget.dairyId,
      factoryName: _factoryNameController.text.trim(),
      liters: double.parse(_litersController.text.trim()),
      saleRate: double.parse(_saleRateController.text.trim()),
      commissionPerLiter: double.parse(_commissionController.text.trim()),
      note: _noteController.text.trim(),
    );

    _factoryNameController.clear();
    _litersController.clear();
    _saleRateController.clear();
    _commissionController.clear();
    _noteController.clear();

    await _loadSales();
    if (!mounted) {
      return;
    }
    setState(() {
      _saving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final double totalLiters = _sales.fold(
      0,
      (double sum, FactorySaleModel sale) => sum + sale.liters,
    );
    final double totalSaleAmount = _sales.fold(
      0,
      (double sum, FactorySaleModel sale) => sum + sale.totalAmount,
    );
    final double totalCommission = _sales.fold(
      0,
      (double sum, FactorySaleModel sale) => sum + sale.commissionAmount,
    );
    final double totalProfit = _sales.fold(
      0,
      (double sum, FactorySaleModel sale) => sum + sale.netProfit,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('factorySales')),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadSales,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  _SummaryCard(
                    title: l10n.t('factoryTotalLiters'),
                    value: '${totalLiters.toStringAsFixed(1)} L',
                    subtitle: l10n.t(
                      'factorySalesCount',
                      <String, String>{'count': _sales.length.toString()},
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SummaryCard(
                    title: l10n.t('factoryTotalAmount'),
                    value: 'Rs ${totalSaleAmount.toStringAsFixed(0)}',
                    subtitle: l10n.t(
                      'factoryCommissionAmount',
                      <String, String>{
                        'value': totalCommission.toStringAsFixed(0)
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SummaryCard(
                    title: l10n.t('factoryProfit'),
                    value: 'Rs ${totalProfit.toStringAsFixed(0)}',
                    subtitle: l10n.t('factoryProfitSubtitle'),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.t('addFactorySale'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                              controller: _factoryNameController,
                              decoration: InputDecoration(
                                labelText: l10n.t('factoryName'),
                              ),
                              validator: (String? value) {
                                if (value == null || value.trim().isEmpty) {
                                  return l10n.t('required');
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _litersController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              decoration: InputDecoration(
                                labelText: l10n.t('liters'),
                              ),
                              validator: _numberValidator,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _saleRateController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              decoration: InputDecoration(
                                labelText: l10n.t('factorySaleRate'),
                              ),
                              validator: _numberValidator,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _commissionController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              decoration: InputDecoration(
                                labelText: l10n.t('factoryCommissionPerLiter'),
                              ),
                              validator: _numberValidator,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _noteController,
                              decoration: InputDecoration(
                                labelText: l10n.t('note'),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: _saving ? null : _saveSale,
                                child: Text(
                                  _saving
                                      ? l10n.t('saving')
                                      : l10n.t('saveFactorySale'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.t('factoryReports'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  if (_sales.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(l10n.t('noFactorySales')),
                      ),
                    ),
                  ..._sales.map(
                    (FactorySaleModel sale) => Card(
                      child: ListTile(
                        title: Text(sale.factoryName),
                        subtitle: Text(
                          '${_dateLabel(sale.createdAt)} | ${sale.liters.toStringAsFixed(1)} L | Rs ${sale.saleRate.toStringAsFixed(2)}/L',
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Text('Rs ${sale.totalAmount.toStringAsFixed(0)}'),
                            Text(
                              l10n.t(
                                'factoryProfitShort',
                                <String, String>{
                                  'value': sale.netProfit.toStringAsFixed(0),
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  String? _numberValidator(String? value) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    if (value == null || value.trim().isEmpty) {
      return l10n.t('required');
    }
    if (double.tryParse(value.trim()) == null) {
      return l10n.t('enterValidNumber');
    }
    return null;
  }

  String _dateLabel(DateTime value) {
    return '${value.day}/${value.month}/${value.year}';
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text(subtitle),
          ],
        ),
      ),
    );
  }
}
