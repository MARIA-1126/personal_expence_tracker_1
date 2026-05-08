import 'package:get_storage/get_storage.dart';

import '../../models/transaction.dart';

String generateId() {
  // Simple ID generator (no extra dependencies).
  return DateTime.now().microsecondsSinceEpoch.toString();
}

/// Local storage using GetStorage.
class TransactionStorage {
  TransactionStorage(this._box);

  static const String boxName = 'expense_tracker';
  static const String transactionsKey = 'transactions';

  final GetStorage _box;

  /// Exposes the underlying GetStorage so other storages (e.g. categories)
  /// can use the same box for beginner-friendly shared persistence.
  GetStorage get box => _box;

  String generateId() => DateTime.now().microsecondsSinceEpoch.toString();

  List<TransactionModel> readTransactions() {
    final raw = _box.read(
      transactionsKey,
    ); //jo bhi transactions store hui ha un ko read krne k liye read method use krte ha aur usme transactions key pass krte ha taki wo transactions read kr le
    if (raw == null) return []; //agr raw null hoi to empty list return kr de

    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((e) => TransactionModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } //agr raw list ha to usme se map type ke elements ko filter krke unko TransactionModel main convert kr ke list return kr de
    return []; //agr raw list nahi ha to empty list return kr de
  }

  Future<void> writeTransactions(List<TransactionModel> txs) async {
    final jsonList = txs.map((t) => t.toJson()).toList();
    await _box.write(transactionsKey, jsonList);
  }

  Future<void> addTransaction(TransactionModel tx) async {
    final txs = readTransactions();
    txs.insert(0, tx);
    await writeTransactions(txs);
  }

  Future<void> updateTransaction(TransactionModel updated) async {
    final txs = readTransactions();
    final index = txs.indexWhere((t) => t.id == updated.id);
    if (index == -1) return;
    txs[index] = updated;
    await writeTransactions(txs);
  }

  Future<void> deleteTransaction(String id) async {
    final txs = readTransactions();
    txs.removeWhere((t) => t.id == id);
    await writeTransactions(txs);
  }
}
