import 'dart:math' as math;

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
        final sampleIndex = 11 - i;
        final date = DateTime(now.year, now.month - i, 1);
        double value = _sumPaidInvoicesByMonth(date.year, date.month);
        if (value == 0) value = _syntheticTrendValue(sampleIndex, 620);
        values.add(value);
      }
      return values;
    }

    final values = <double>[];
    for (int i = 7; i >= 0; i--) {
      final sampleIndex = 7 - i;
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
      if (daily == 0) daily = _syntheticTrendValue(sampleIndex, 320);
      values.add(daily);
    }
    return values;
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

  Expense addExpense({
    required String description,
    required double amount,
    DateTime? date,
    String? projectId,
    ExpenseRecurrence recurrence = ExpenseRecurrence.oneTime,
  }) {
    final expense = Expense(
      id: 'exp${DateTime.now().millisecondsSinceEpoch}',
      projectId: projectId,
      description: description,
      amount: amount,
      date: date ?? DateTime.now(),
      recurrence: recurrence,
    );
    _expenses.insert(0, expense);
    notifyListeners();
    return expense;
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

  Invoice createInvoice({
    required String clientName,
    required double amount,
    DateTime? dueDate,
    String? referenceId,
  }) {
    final invoice = Invoice(
      id: 'inv${DateTime.now().millisecondsSinceEpoch}',
      quoteId: referenceId ?? 'manual',
      clientName: clientName,
      issuedAt: DateTime.now(),
      status: InvoiceStatus.unpaid,
      amount: amount,
      dueDate: dueDate,
    );
    _invoices.insert(0, invoice);
    notifyListeners();
    return invoice;
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
