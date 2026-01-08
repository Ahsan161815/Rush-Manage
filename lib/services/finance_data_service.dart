import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:myapp/models/finance.dart';

class FinanceSnapshot {
  const FinanceSnapshot({
    required this.quotes,
    required this.invoices,
    required this.expenses,
  });

  final List<Quote> quotes;
  final List<Invoice> invoices;
  final List<Expense> expenses;
}

class FinanceDataService {
  FinanceDataService(this._client);

  final SupabaseClient _client;

  static const String _quotesTable = 'finance_quotes';
  static const String _invoicesTable = 'finance_invoices';
  static const String _expensesTable = 'finance_expenses';

  Future<FinanceSnapshot> fetchSnapshot(String ownerId) async {
    final results = await Future.wait([
      _client
          .from(_quotesTable)
          .select()
          .eq('owner_id', ownerId)
          .order('created_at', ascending: false),
      _client
          .from(_invoicesTable)
          .select()
          .eq('owner_id', ownerId)
          .order('issued_at', ascending: false),
      _client
          .from(_expensesTable)
          .select()
          .eq('owner_id', ownerId)
          .order('date', ascending: false),
    ]);

    final quotes = (results[0] as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map(Quote.fromJson)
        .toList(growable: false);
    final invoices = (results[1] as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map(Invoice.fromJson)
        .toList(growable: false);
    final expenses = (results[2] as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map(Expense.fromJson)
        .toList(growable: false);
    return FinanceSnapshot(
      quotes: quotes,
      invoices: invoices,
      expenses: expenses,
    );
  }

  Future<Quote> insertQuote(Quote quote, {required String ownerId}) async {
    final payload = quote.toJson()
      ..addAll({
        'owner_id': ownerId,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
    final record = await _client
        .from(_quotesTable)
        .insert(payload)
        .select()
        .single();
    return Quote.fromJson(record);
  }

  Future<Quote> updateQuoteStatus(String quoteId, QuoteStatus status) async {
    final record = await _client
        .from(_quotesTable)
        .update({
          'status': status.storageValue,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', quoteId)
        .select()
        .single();
    return Quote.fromJson(record);
  }

  Future<Invoice> insertInvoice(
    Invoice invoice, {
    required String ownerId,
  }) async {
    final payload = invoice.toJson()
      ..addAll({
        'owner_id': ownerId,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
    final record = await _client
        .from(_invoicesTable)
        .insert(payload)
        .select()
        .single();
    return Invoice.fromJson(record);
  }

  Future<Invoice> updateInvoice(Invoice invoice) async {
    final payload = invoice.toJson()
      ..addAll({'updated_at': DateTime.now().toUtc().toIso8601String()});
    final record = await _client
        .from(_invoicesTable)
        .update(payload)
        .eq('id', invoice.id)
        .select()
        .single();
    return Invoice.fromJson(record);
  }

  Future<Expense> insertExpense(
    Expense expense, {
    required String ownerId,
  }) async {
    final payload = expense.toJson()..addAll({'owner_id': ownerId});
    final record = await _client
        .from(_expensesTable)
        .insert(payload)
        .select()
        .single();
    return Expense.fromJson(record);
  }
}
