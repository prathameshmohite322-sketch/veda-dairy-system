import '../models/transaction_model.dart';

class TransactionService {
  Future<List<TransactionModel>> fetchTransactions(String dairyId) async {
    return <TransactionModel>[
      TransactionModel(
        id: 't1',
        dairyId: dairyId,
        customerId: 'c1',
        type: 'milkEntry',
        amount: 450.0,
        createdAtIso: DateTime.now().toIso8601String(),
      ),
    ];
  }
}
