import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:myapp/config/supabase_config.dart';

import 'package:myapp/models/finance.dart';
import 'package:myapp/services/finance_data_service.dart';

class FinanceController extends ChangeNotifier {
  FinanceController({
    required SupabaseClient client,
    FinanceDataService? dataService,
  }) : _client = client,
       _service = dataService ?? FinanceDataService(client);

  final SupabaseClient _client;
  final FinanceDataService _service;

  final List<Quote> _quotes = [];
  final List<Invoice> _invoices = [];
  final List<Expense> _expenses = [];

  // Global time filter (applies to invoices, quotes, expenses)
  TimeFilter _timeFilter = TimeFilter.month;
  bool _hasInitialized = false;
  bool _isLoading = false;
  String? _errorMessage;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> initialize() async {
    if (_hasInitialized) {
      return;
    }
    if (_client.auth.currentUser?.id == null) {
      return;
    }
    _hasInitialized = true;
    await refresh();
  }

  Future<void> refresh() async {
    final ownerId = _requireUserId();
    _setLoading(true);
    try {
      final snapshot = await _service.fetchSnapshot(ownerId);
      _quotes
        ..clear()
        ..addAll(snapshot.quotes);
      _invoices
        ..clear()
        ..addAll(snapshot.invoices);
      _expenses
        ..clear()
        ..addAll(snapshot.expenses);
      _errorMessage = null;
      notifyListeners();
    } catch (error, stackTrace) {
      _errorMessage = 'Unable to load finance data';
      _logError('refresh', error, stackTrace);
    } finally {
      _setLoading(false);
    }
  }

  List<Quote> get quotes => List.unmodifiable(_quotes);
  List<Invoice> get invoices => List.unmodifiable(_invoices);
  List<Expense> get expenses => List.unmodifiable(_expenses);

  // Time filter API
  TimeFilter get timeFilter => _timeFilter;
  void setTimeFilter(TimeFilter filter) {
    if (_timeFilter == filter) return;
    _timeFilter = filter;
    notifyListeners();
  }

  bool _inRange(DateTime d) => _inRangeWithFilter(d, _timeFilter);

  bool _inRangeWithFilter(DateTime date, TimeFilter filter) {
    final now = DateTime.now();
    switch (filter) {
      case TimeFilter.week:
        return date.isAfter(now.subtract(const Duration(days: 7)));
      case TimeFilter.month:
        return date.year == now.year && date.month == now.month;
      case TimeFilter.year:
        return date.year == now.year;
    }
  }

  List<Invoice> _invoicesFor(TimeFilter filter) => _invoices
      .where((i) => _inRangeWithFilter(i.issuedAt, filter))
      .toList(growable: false);

  List<Expense> _expensesFor(TimeFilter filter) => _expenses
      .where((e) => _inRangeWithFilter(e.date, filter))
      .toList(growable: false);

  List<Invoice> get filteredInvoices =>
      _invoices.where((i) => _inRange(i.issuedAt)).toList(growable: false);
  List<Quote> get filteredQuotes =>
      _quotes.where((q) => _inRange(q.createdAt)).toList(growable: false);
  List<Expense> get filteredExpenses =>
      _expenses.where((e) => _inRange(e.date)).toList(growable: false);

  double get globalBalance => collectedTotalFor(TimeFilter.month);

  double collectedTotalFor(TimeFilter filter) => _invoicesFor(filter)
      .where((i) => i.status == InvoiceStatus.paid)
      .fold(0.0, (sum, inv) => sum + inv.amount);

  double get unpaidTotal => filteredInvoices
      .where((i) => i.status == InvoiceStatus.unpaid)
      .fold(0.0, (sum, inv) => sum + inv.amount);

  int get unpaidCount =>
      filteredInvoices.where((i) => i.status == InvoiceStatus.unpaid).length;

  double get monthVariationPercent => variationPercentFor(TimeFilter.month);

  double variationPercentFor(TimeFilter filter) {
    final now = DateTime.now();
    double current = 0;
    double previous = 0;

    switch (filter) {
      case TimeFilter.month:
        current = _sumPaidInvoicesByMonth(now.year, now.month);
        final prevMonthDate = DateTime(now.year, now.month - 1, 1);
        previous = _sumPaidInvoicesByMonth(
          prevMonthDate.year,
          prevMonthDate.month,
        );
        break;
      case TimeFilter.year:
        current = _sumPaidInvoicesByYear(now.year);
        previous = _sumPaidInvoicesByYear(now.year - 1);
        break;
      case TimeFilter.week:
        final currentRangeStart = now.subtract(const Duration(days: 7));
        final previousRangeStart = currentRangeStart.subtract(
          const Duration(days: 7),
        );
        current = _sumPaidInvoicesInRange(currentRangeStart, now);
        previous = _sumPaidInvoicesInRange(
          previousRangeStart,
          currentRangeStart,
        );
        break;
    }

    if (previous == 0) return 100;
    return ((current - previous) / previous) * 100;
  }

  double _sumPaidInvoicesByMonth(int year, int month) => _invoices
      .where(
        (i) =>
            i.status == InvoiceStatus.paid &&
            i.issuedAt.year == year &&
            i.issuedAt.month == month,
      )
      .fold(0.0, (s, i) => s + i.amount);

  double _sumPaidInvoicesByYear(int year) => _invoices
      .where((i) => i.status == InvoiceStatus.paid && i.issuedAt.year == year)
      .fold(0.0, (s, i) => s + i.amount);

  double _sumPaidInvoicesInRange(DateTime start, DateTime end) => _invoices
      .where(
        (i) =>
            i.status == InvoiceStatus.paid &&
            !i.issuedAt.isBefore(start) &&
            i.issuedAt.isBefore(end),
      )
      .fold(0.0, (s, i) => s + i.amount);

  List<String> get latestDocuments {
    final docs = <String>[];
    for (final q in filteredQuotes.take(4)) {
      final label = switch (q.status) {
        QuoteStatus.pendingSignature =>
          'Quote #${q.id.substring(1)} – Pending signature',
        QuoteStatus.signed => 'Quote #${q.id.substring(1)} – Signed',
        QuoteStatus.declined => 'Quote #${q.id.substring(1)} – Declined',
        QuoteStatus.draft => 'Quote #${q.id.substring(1)} – Draft',
      };
      docs.add(label);
    }
    for (final inv in filteredInvoices.take(4)) {
      final status = switch (inv.status) {
        InvoiceStatus.paid => 'Paid',
        InvoiceStatus.unpaid => 'Unpaid',
        InvoiceStatus.draft => 'Draft',
      };
      String extra = '';
      if (inv.status == InvoiceStatus.unpaid && inv.dueDate != null) {
        final overdueDays = DateTime.now().difference(inv.dueDate!).inDays;
        if (overdueDays > 0) extra = ' ($overdueDays days overdue)';
      }
      docs.add('Invoice #${inv.id.substring(3)} – $status$extra');
    }
    return docs.take(8).toList(growable: false);
  }

  List<double> get trendValues => revenueTrendFor(TimeFilter.month);

  List<double> revenueTrendFor(TimeFilter filter) {
    final now = DateTime.now();
    if (filter == TimeFilter.year) {
      final values = <double>[];
      for (int i = 11; i >= 0; i--) {
        final date = DateTime(now.year, now.month - i, 1);
        double value = _sumPaidInvoicesByMonth(date.year, date.month);
        values.add(value);
      }
      final hasRealData = values.any((v) => v > 0);
      if (hasRealData) {
        for (int i = 0; i < values.length; i++) {
          if (values[i] == 0) values[i] = _syntheticTrendValue(i, 620);
        }
      }
      return values;
    }

    final values = <double>[];
    for (int i = 7; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      double daily = _invoices
          .where(
            (inv) =>
                inv.status == InvoiceStatus.paid &&
                inv.issuedAt.year == day.year &&
                inv.issuedAt.month == day.month &&
                inv.issuedAt.day == day.day,
          )
          .fold(0.0, (s, inv) => s + inv.amount);
      values.add(daily);
    }
    final hasRealData = values.any((v) => v > 0);
    if (hasRealData) {
      for (int i = 0; i < values.length; i++) {
        if (values[i] == 0) values[i] = _syntheticTrendValue(i, 320);
      }
    }
    return values;
  }

  void _replaceQuote(Quote quote) {
    final index = _quotes.indexWhere((item) => item.id == quote.id);
    if (index == -1) {
      _quotes.insert(0, quote);
    } else {
      _quotes[index] = quote;
    }
    notifyListeners();
  }

  void _replaceInvoice(Invoice invoice) {
    final index = _invoices.indexWhere((item) => item.id == invoice.id);
    if (index == -1) {
      _invoices.insert(0, invoice);
    } else {
      _invoices[index] = invoice;
    }
    notifyListeners();
  }

  void _replaceExpense(Expense expense) {
    final index = _expenses.indexWhere((item) => item.id == expense.id);
    if (index == -1) {
      _expenses.insert(0, expense);
    } else {
      _expenses[index] = expense;
    }
    notifyListeners();
  }

  double _syntheticTrendValue(int index, double amplitude) {
    final base = 380 + (index % 4) * 140;
    final wave = math.sin(index / 1.4) * amplitude * 0.45;
    final jitter = (index * 47) % 160;
    final value = base + wave + jitter;
    return value.clamp(120, 3200).toDouble();
  }

  // KPI helpers
  double get pendingQuotesTotal => filteredQuotes
      .where((q) => q.status == QuoteStatus.pendingSignature)
      .fold(0.0, (s, q) => s + q.total);
  int get pendingQuotesCount => filteredQuotes
      .where((q) => q.status == QuoteStatus.pendingSignature)
      .length;
  double get currentMonthExpensesTotal =>
      _expensesFor(TimeFilter.month).fold(0.0, (s, e) => s + e.amount);

  Expense? get topExpenseThisMonth {
    final monthExpenses = _expensesFor(TimeFilter.month);
    if (monthExpenses.isEmpty) return null;
    monthExpenses.sort((a, b) => b.amount.compareTo(a.amount));
    return monthExpenses.first;
  }

  Future<Expense> addExpense({
    required String description,
    required double amount,
    DateTime? date,
    String? projectId,
    ExpenseRecurrence recurrence = ExpenseRecurrence.oneTime,
  }) async {
    final ownerId = _requireUserId();
    final expense = Expense(
      id: _generateExpenseId(),
      projectId: projectId,
      description: description,
      amount: amount,
      date: date ?? DateTime.now(),
      recurrence: recurrence,
    );
    _expenses.insert(0, expense);
    notifyListeners();
    try {
      final saved = await _service.insertExpense(expense, ownerId: ownerId);
      _replaceExpense(saved);
      return saved;
    } catch (error, stackTrace) {
      _expenses.removeWhere((item) => item.id == expense.id);
      notifyListeners();
      _logError('addExpense', error, stackTrace);
      rethrow;
    }
  }

  List<Invoice> get unpaidInvoices => _invoices
      .where((i) => i.status == InvoiceStatus.unpaid)
      .toList(growable: false);

  List<Invoice> get upcomingInvoices {
    final pending = unpaidInvoices.where((i) => i.dueDate != null).toList();
    pending.sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
    return pending;
  }

  // --- Quote lifecycle methods ---
  Future<Quote> createDraftQuote({
    required String clientName,
    required String description,
    required double subtotal,
    double vatRate = 0.20,
    bool requireSignature = true,
    String? contactId,
    String? clientEmail,
  }) async {
    final ownerId = _requireUserId();
    final vat = subtotal * vatRate;
    final quote = Quote(
      id: _generateQuoteId(),
      contactId: contactId,
      clientName: clientName,
      clientEmail: clientEmail,
      description: description,
      createdAt: DateTime.now(),
      status: QuoteStatus.draft,
      total: subtotal + vat,
      vat: vat,
      requireSignature: requireSignature,
    );
    _quotes.insert(0, quote);
    notifyListeners();
    try {
      final saved = await _service.insertQuote(quote, ownerId: ownerId);
      _replaceQuote(saved);
      return saved;
    } catch (error, stackTrace) {
      _quotes.removeWhere((item) => item.id == quote.id);
      notifyListeners();
      _logError('createDraftQuote', error, stackTrace);
      rethrow;
    }
  }

  Future<Quote> updateQuoteStatus(String quoteId, QuoteStatus status) async {
    final index = _quotes.indexWhere((q) => q.id == quoteId);
    if (index == -1) {
      throw StateError('Quote $quoteId not found');
    }
    final previous = _quotes[index];
    final next = previous.copyWith(status: status);
    _quotes[index] = next;
    notifyListeners();
    try {
      final saved = await _service.updateQuoteStatus(quoteId, status);
      _quotes[index] = saved;
      notifyListeners();
      if (status == QuoteStatus.signed) {
        await _convertQuoteToInvoice(saved);
      }
      return saved;
    } catch (error, stackTrace) {
      _quotes[index] = previous;
      notifyListeners();
      _logError('updateQuoteStatus', error, stackTrace);
      rethrow;
    }
  }

  Future<void> _convertQuoteToInvoice(Quote quote) async {
    final exists = _invoices.any((inv) => inv.quoteId == quote.id);
    if (exists) return;
    final ownerId = _requireUserId();
    final invoice = Invoice(
      id: _generateInvoiceId(),
      quoteId: quote.id,
      contactId: quote.contactId,
      clientName: quote.clientName,
      clientEmail: quote.clientEmail,
      projectId: null,
      issuedAt: DateTime.now(),
      status: InvoiceStatus.draft,
      amount: quote.total,
    );
    _invoices.insert(0, invoice);
    notifyListeners();
    try {
      final saved = await _service.insertInvoice(invoice, ownerId: ownerId);
      _replaceInvoice(saved);
    } catch (error, stackTrace) {
      _invoices.removeWhere((inv) => inv.id == invoice.id);
      notifyListeners();
      _logError('convertQuoteToInvoice', error, stackTrace);
      rethrow;
    }
  }

  /// Generate a simple HTML representation of a quote and upload it to
  /// Supabase Storage under the `documents` bucket. Returns a public URL
  /// that can be opened/downloaded by the client.
  Future<String> generateQuoteDocument(String quoteId) async {
    final quote = getQuote(quoteId);
    if (quote.id == 'missing') {
      throw StateError('Quote $quoteId not found');
    }

    final ownerId = _requireUserId();
    final html =
        '''
<!doctype html>
<html>
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1" />
    <title>Quote ${quote.id}</title>
    <style>
      body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Arial; color: #222; padding: 24px; }
      .header { display:flex; justify-content:space-between; align-items:center }
      .items { margin-top:18px }
      .total { margin-top:22px; font-weight:700; font-size:1.2rem }
    </style>
  </head>
  <body>
    <div class="header">
      <div>
        <h2>Quote</h2>
        <div>Client: ${quote.clientName}</div>
        <div>Description: ${quote.description}</div>
      </div>
      <div>
        <div>Quote ID: ${quote.id}</div>
        <div>Date: ${quote.createdAt.toIso8601String()}</div>
      </div>
    </div>
    <div class="items">
      <div>Subtotal: €${(quote.total - (quote.vat)).toStringAsFixed(2)}</div>
      <div>VAT: €${quote.vat.toStringAsFixed(2)}</div>
    </div>
    <div class="total">Total: €${quote.total.toStringAsFixed(2)}</div>
  </body>
</html>
''';

    final bytes = Uint8List.fromList(utf8.encode(html));
    const bucketName = 'documents';
    final objectPath = 'quotes/$ownerId/${quote.id}.html';
    final bucket = _client.storage.from(bucketName);
    try {
      await bucket.uploadBinary(
        objectPath,
        bytes,
        fileOptions: FileOptions(upsert: true, contentType: 'text/html'),
      );
    } catch (error, stackTrace) {
      _logError('generateQuoteDocument', error, stackTrace);
      rethrow;
    }

    final publicUrl = bucket.getPublicUrl(objectPath);
    return publicUrl;
  }

  Future<Invoice> createInvoice({
    required String clientName,
    required double amount,
    DateTime? dueDate,
    String? referenceId,
    String? projectId,
    String? contactId,
    String? clientEmail,
  }) async {
    final ownerId = _requireUserId();
    final invoice = Invoice(
      id: _generateInvoiceId(),
      quoteId: referenceId ?? 'manual',
      contactId: contactId,
      clientName: clientName,
      clientEmail: clientEmail,
      projectId: projectId,
      issuedAt: DateTime.now(),
      status: InvoiceStatus.unpaid,
      amount: amount,
      dueDate: dueDate,
    );
    _invoices.insert(0, invoice);
    notifyListeners();
    try {
      final saved = await _service.insertInvoice(invoice, ownerId: ownerId);
      _replaceInvoice(saved);
      return saved;
    } catch (error, stackTrace) {
      _invoices.removeWhere((inv) => inv.id == invoice.id);
      notifyListeners();
      _logError('createInvoice', error, stackTrace);
      rethrow;
    }
  }

  Future<Invoice> markInvoicePaid(String invoiceId) async {
    final index = _invoices.indexWhere((inv) => inv.id == invoiceId);
    if (index == -1) {
      throw StateError('Invoice $invoiceId not found');
    }
    final previous = _invoices[index];
    final next = previous.copyWith(status: InvoiceStatus.paid);
    _invoices[index] = next;
    notifyListeners();
    try {
      final saved = await _service.updateInvoice(next);
      _invoices[index] = saved;
      notifyListeners();
      return saved;
    } catch (error, stackTrace) {
      _invoices[index] = previous;
      notifyListeners();
      _logError('markInvoicePaid', error, stackTrace);
      rethrow;
    }
  }

  Future<Invoice> updateInvoiceMetadata(
    String invoiceId, {
    DateTime? issuedAt,
    DateTime? dueDate,
    PaymentMethod? paymentMethod,
  }) async {
    final index = _invoices.indexWhere((inv) => inv.id == invoiceId);
    if (index == -1) {
      throw StateError('Invoice $invoiceId not found');
    }
    final previous = _invoices[index];
    final next = previous.copyWith(
      issuedAt: issuedAt,
      dueDate: dueDate,
      paymentMethod: paymentMethod,
    );
    _invoices[index] = next;
    notifyListeners();
    try {
      final saved = await _service.updateInvoice(next);
      _invoices[index] = saved;
      notifyListeners();
      return saved;
    } catch (error, stackTrace) {
      _invoices[index] = previous;
      notifyListeners();
      _logError('updateInvoiceMetadata', error, stackTrace);
      rethrow;
    }
  }

  Invoice getInvoice(String id) => _invoices.firstWhere(
    (inv) => inv.id == id,
    orElse: () => Invoice(
      id: 'missing',
      quoteId: 'n/a',
      clientName: 'Unknown',
      issuedAt: DateTime.fromMillisecondsSinceEpoch(0),
      status: InvoiceStatus.draft,
      amount: 0,
    ),
  );

  Quote getQuote(String id) => _quotes.firstWhere(
    (q) => q.id == id,
    orElse: () => Quote(
      id: 'missing',
      clientName: 'Unknown',
      description: 'Not found',
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      status: QuoteStatus.draft,
      total: 0,
      vat: 0,
    ),
  );

  void _setLoading(bool value) {
    if (_isLoading == value) {
      return;
    }
    _isLoading = value;
    notifyListeners();
  }

  void reset() {
    _hasInitialized = false;
    _quotes.clear();
    _invoices.clear();
    _expenses.clear();
    _errorMessage = null;
    notifyListeners();
  }

  String _requireUserId() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null || userId.isEmpty) {
      throw const AuthException('User not authenticated');
    }
    return userId;
  }

  void _logError(String action, Object error, StackTrace stackTrace) {
    debugPrint('FinanceController.$action failed: $error');
    debugPrint(stackTrace.toString());
  }

  String _generateQuoteId() => 'q${DateTime.now().millisecondsSinceEpoch}';

  String _generateInvoiceId() => 'inv${DateTime.now().millisecondsSinceEpoch}';

  String _generateExpenseId() => 'exp${DateTime.now().millisecondsSinceEpoch}';

  /// Send an invoice reminder via an Edge Function.
  ///
  /// This looks up the client's email by matching the invoice.clientName
  /// against the `crm_contacts` table (case-insensitive), then invokes the
  /// `invoice-reminder` Edge Function with a payload containing HTML and a
  /// push notification payload. The Edge Function is responsible for sending
  /// the email and delivering push notifications to any registered devices.
  Future<void> sendInvoiceReminder(String invoiceId) async {
    final invoice = getInvoice(invoiceId);
    if (invoice.id == 'missing') {
      throw StateError('Invoice $invoiceId not found');
    }

    // Resolve an email address for the invoice.
    // Prefer persisted metadata, then CRM lookup by contact ID, then legacy
    // case-insensitive name match.
    String? email = invoice.clientEmail?.trim();
    if (email != null && email.isEmpty) {
      email = null;
    }
    try {
      if (email == null && invoice.contactId != null) {
        final resp = await _client
            .from('crm_contacts')
            .select('email')
            .eq('id', invoice.contactId as Object)
            .maybeSingle();
        if (resp is Map<String, dynamic>) {
          email = (resp['email'] as String?)?.trim();
        }
      }
      if (email == null || email.isEmpty) {
        final resp = await _client
            .from('crm_contacts')
            .select('email')
            .ilike('name', invoice.clientName)
            .maybeSingle();
        if (resp is Map<String, dynamic>) {
          email = (resp['email'] as String?)?.trim();
        }
      }
    } catch (error, stackTrace) {
      _logError('lookupClientEmail', error, stackTrace);
    }

    if (email == null || email.isEmpty) {
      throw StateError('No email found for client "${invoice.clientName}"');
    }

    final due = invoice.dueDate?.toIso8601String();
    final invoiceDeepLink = 'rushmanage://invoice/${invoice.id}';

    final html =
        '''
<html>
  <body style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial; color: #222;">
    <h2>Invoice Reminder</h2>
    <p>Hi ${invoice.clientName},</p>
    <p>This is a friendly reminder that invoice <strong>${invoice.id}</strong> for <strong>€${invoice.amount.toStringAsFixed(2)}</strong> is ${invoice.status == InvoiceStatus.unpaid ? 'still unpaid' : invoice.status.name}.</p>
    ${due != null ? '<p>Due date: <strong>${invoice.dueDate}</strong></p>' : ''}
    <p>You can view the invoice in your app: <a href="$invoiceDeepLink">Open invoice</a></p>
    <p>Thanks,<br/>Rush Manage</p>
  </body>
</html>
''';

    final payload = {
      'to': email,
      'client_name': invoice.clientName,
      'invoice_id': invoice.id,
      'amount': invoice.amount,
      'due_date': due,
      'invoice_link': invoiceDeepLink,
      'html': html,
      'push': {
        'title': 'Invoice reminder',
        'body':
            'Invoice ${invoice.id} — €${invoice.amount.toStringAsFixed(2)} is due',
        'deep_link': invoiceDeepLink,
      },
    };

    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (SupabaseConfig.inviteEmailSecret.isNotEmpty)
        'x-invite-secret': SupabaseConfig.inviteEmailSecret,
    };

    try {
      await _client.functions.invoke(
        'invoice-reminder',
        headers: headers,
        body: jsonEncode(payload),
      );
    } catch (error, stackTrace) {
      _logError('sendInvoiceReminder', error, stackTrace);
      rethrow;
    }
  }
}

enum TimeFilter { week, month, year }
