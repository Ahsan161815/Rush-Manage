import 'package:flutter/material.dart';
import 'package:myapp/models/finance.dart';

class FinanceController extends ChangeNotifier {
  final List<Quote> _quotes = [];
  final List<Invoice> _invoices = [];
  final List<Expense> _expenses = [];

  // Global time filter (applies to invoices, quotes, expenses)
  TimeFilter _timeFilter = TimeFilter.month;

  FinanceController() {
    _seed();
  }

  void _seed() {
    _quotes.addAll([
      Quote(
        id: 'q145',
        clientName: 'Dupont Family',
        description: 'Catering service — Dupont Wedding',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        status: QuoteStatus.pendingSignature,
        total: 3200,
        vat: 640,
      ),
      Quote(
        id: 'q146',
        clientName: 'StudioX',
        description: 'Photo package extended',
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
        status: QuoteStatus.signed,
        total: 1850,
        vat: 370,
      ),
    ]);
    _invoices.addAll([
      Invoice(
        id: 'inv243',
        quoteId: 'q146',
        clientName: 'StudioX',
        issuedAt: DateTime.now().subtract(const Duration(days: 10)),
        status: InvoiceStatus.paid,
        amount: 2220,
        dueDate: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Invoice(
        id: 'inv244',
        quoteId: 'q145',
        clientName: 'Dupont Family',
        issuedAt: DateTime.now().subtract(const Duration(days: 14)),
        status: InvoiceStatus.unpaid,
        amount: 3840,
        dueDate: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ]);
    _expenses.addAll([
      Expense(
        id: 'exp101',
        projectId: 'p1',
        description: 'Equipment rental',
        amount: 240,
        date: DateTime.now().subtract(const Duration(days: 2)),
        recurrence: ExpenseRecurrence.oneTime,
      ),
      Expense(
        id: 'exp102',
        description: 'Fuel',
        amount: 90,
        date: DateTime.now().subtract(const Duration(days: 6)),
      ),
      Expense(
        id: 'exp103',
        description: 'Snacks for crew',
        amount: 45,
        date: DateTime.now().subtract(const Duration(days: 15)),
      ),
    ]);
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

  bool _inRange(DateTime d) {
    final now = DateTime.now();
    switch (_timeFilter) {
      case TimeFilter.week:
        return d.isAfter(now.subtract(const Duration(days: 7)));
      case TimeFilter.month:
        return d.year == now.year && d.month == now.month;
      case TimeFilter.year:
        return d.year == now.year;
    }
  }

  List<Invoice> get filteredInvoices =>
      _invoices.where((i) => _inRange(i.issuedAt)).toList(growable: false);
  List<Quote> get filteredQuotes =>
      _quotes.where((q) => _inRange(q.createdAt)).toList(growable: false);
  List<Expense> get filteredExpenses =>
      _expenses.where((e) => _inRange(e.date)).toList(growable: false);

  double get globalBalance => filteredInvoices
      .where((i) => i.status == InvoiceStatus.paid)
      .fold(0.0, (sum, inv) => sum + inv.amount);

  double get unpaidTotal => filteredInvoices
      .where((i) => i.status == InvoiceStatus.unpaid)
      .fold(0.0, (sum, inv) => sum + inv.amount);

  int get unpaidCount =>
      filteredInvoices.where((i) => i.status == InvoiceStatus.unpaid).length;

  double get monthVariationPercent {
    // Mock: compare paid invoices this month vs last month.
    final now = DateTime.now();
    final thisMonth = filteredInvoices
        .where(
          (i) =>
              i.status == InvoiceStatus.paid && i.issuedAt.month == now.month,
        )
        .fold(0.0, (s, i) => s + i.amount);
    final lastMonth = _invoices
        .where(
          (i) =>
              i.status == InvoiceStatus.paid &&
              i.issuedAt.month == (now.month - 1),
        )
        .fold(0.0, (s, i) => s + i.amount);
    if (lastMonth == 0) return 100; // baseline growth
    return ((thisMonth - lastMonth) / lastMonth) * 100;
  }

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

  List<double> get trendValues {
    // Mock: generate last 8 points combining paid/unpaid totals
    final values = <double>[];
    for (int i = 7; i >= 0; i--) {
      final day = DateTime.now().subtract(Duration(days: i));
      final daily = filteredInvoices
          .where((inv) => inv.issuedAt.day == day.day)
          .fold(0.0, (s, inv) => s + inv.amount);
      values.add(daily == 0 ? (i + 1) * 120 : daily);
    }
    return values;
  }

  // KPI helpers
  double get pendingQuotesTotal => filteredQuotes
      .where((q) => q.status == QuoteStatus.pendingSignature)
      .fold(0.0, (s, q) => s + q.total);
  int get pendingQuotesCount => filteredQuotes
      .where((q) => q.status == QuoteStatus.pendingSignature)
      .length;
  double get currentMonthExpensesTotal =>
      filteredExpenses.fold(0.0, (s, e) => s + e.amount);

  // --- Quote lifecycle methods ---
  Quote createDraftQuote({
    required String clientName,
    required String description,
    required double subtotal,
    double vatRate = 0.20,
  }) {
    final id = 'q${DateTime.now().millisecondsSinceEpoch}';
    final vat = subtotal * vatRate;
    final quote = Quote(
      id: id,
      clientName: clientName,
      description: description,
      createdAt: DateTime.now(),
      status: QuoteStatus.draft,
      total: subtotal + vat,
      vat: vat,
    );
    _quotes.insert(0, quote);
    notifyListeners();
    return quote;
  }

  void updateQuoteStatus(String quoteId, QuoteStatus status) {
    final index = _quotes.indexWhere((q) => q.id == quoteId);
    if (index == -1) return;
    _quotes[index] = _quotes[index].copyWith(status: status);
    // Auto-convert to invoice draft when signed
    if (status == QuoteStatus.signed) {
      _convertQuoteToInvoice(_quotes[index]);
    }
    notifyListeners();
  }

  void _convertQuoteToInvoice(Quote quote) {
    // Avoid duplicate invoice
    final exists = _invoices.any((inv) => inv.quoteId == quote.id);
    if (exists) return;
    final invoice = Invoice(
      id: 'inv${DateTime.now().millisecondsSinceEpoch}',
      quoteId: quote.id,
      clientName: quote.clientName,
      issuedAt: DateTime.now(),
      status: InvoiceStatus.draft,
      amount: quote.total,
    );
    _invoices.insert(0, invoice);
  }

  void markInvoicePaid(String invoiceId) {
    final index = _invoices.indexWhere((inv) => inv.id == invoiceId);
    if (index == -1) return;
    _invoices[index] = _invoices[index].copyWith(status: InvoiceStatus.paid);
    notifyListeners();
  }

  Invoice? getInvoice(String id) => _invoices.firstWhere(
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

  Quote? getQuote(String id) => _quotes.firstWhere(
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
}

enum TimeFilter { week, month, year }
