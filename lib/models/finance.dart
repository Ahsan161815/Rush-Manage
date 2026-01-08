import 'package:equatable/equatable.dart';

typedef JsonMap = Map<String, dynamic>;

enum QuoteStatus { draft, pendingSignature, signed, declined }

extension QuoteStatusMapper on QuoteStatus {
  static const Map<QuoteStatus, String> _storage = {
    QuoteStatus.draft: 'draft',
    QuoteStatus.pendingSignature: 'pending_signature',
    QuoteStatus.signed: 'signed',
    QuoteStatus.declined: 'declined',
  };

  String get storageValue => _storage[this] ?? 'draft';

  static QuoteStatus fromStorage(String? value) {
    final entry = _storage.entries.firstWhere(
      (item) => item.value == value,
      orElse: () => const MapEntry(QuoteStatus.draft, ''),
    );
    return entry.key;
  }
}

enum InvoiceStatus { draft, unpaid, paid }

extension InvoiceStatusMapper on InvoiceStatus {
  static const Map<InvoiceStatus, String> _storage = {
    InvoiceStatus.draft: 'draft',
    InvoiceStatus.unpaid: 'unpaid',
    InvoiceStatus.paid: 'paid',
  };

  String get storageValue => _storage[this] ?? 'draft';

  static InvoiceStatus fromStorage(String? value) {
    final entry = _storage.entries.firstWhere(
      (item) => item.value == value,
      orElse: () => const MapEntry(InvoiceStatus.draft, ''),
    );
    return entry.key;
  }
}

enum PaymentMethod { bankTransfer, card, applePay }

extension PaymentMethodMapper on PaymentMethod {
  static const Map<PaymentMethod, String> _storage = {
    PaymentMethod.bankTransfer: 'bank_transfer',
    PaymentMethod.card: 'card',
    PaymentMethod.applePay: 'apple_pay',
  };

  String get storageValue => _storage[this] ?? 'bank_transfer';

  static PaymentMethod? fromStorage(String? value) {
    final entry = _storage.entries.firstWhere(
      (item) => item.value == value,
      orElse: () => const MapEntry(PaymentMethod.bankTransfer, ''),
    );
    if (value == null) {
      return null;
    }
    return entry.value == value ? entry.key : null;
  }
}

class Quote extends Equatable {
  final String id;
  final String? contactId;
  final String clientName;
  final String? clientEmail;
  final String description;
  final DateTime createdAt;
  final QuoteStatus status;
  final double total;
  final double vat;
  final bool requireSignature;

  const Quote({
    required this.id,
    this.contactId,
    required this.clientName,
    this.clientEmail,
    required this.description,
    required this.createdAt,
    required this.status,
    required this.total,
    required this.vat,
    this.requireSignature = true,
  });

  Quote copyWith({
    String? contactId,
    String? clientName,
    String? clientEmail,
    String? description,
    QuoteStatus? status,
    double? total,
    double? vat,
    bool? requireSignature,
  }) => Quote(
    id: id,
    contactId: contactId ?? this.contactId,
    clientName: clientName ?? this.clientName,
    clientEmail: clientEmail ?? this.clientEmail,
    description: description ?? this.description,
    createdAt: createdAt,
    status: status ?? this.status,
    total: total ?? this.total,
    vat: vat ?? this.vat,
    requireSignature: requireSignature ?? this.requireSignature,
  );

  @override
  List<Object?> get props => [
    id,
    contactId,
    clientName,
    clientEmail,
    description,
    createdAt,
    status,
    total,
    vat,
    requireSignature,
  ];

  factory Quote.fromJson(JsonMap json) => Quote(
    id: json['id'] as String,
    contactId: json['contact_id'] as String?,
    clientName: json['client_name'] as String? ?? '',
    clientEmail: json['client_email'] as String?,
    description: json['description'] as String? ?? '',
    createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
    status: QuoteStatusMapper.fromStorage(json['status'] as String?),
    total: _doubleValue(json['total']),
    vat: _doubleValue(json['vat']),
    requireSignature: (json['require_signature'] is bool)
        ? json['require_signature'] as bool
        : (json['require_signature'] is int)
        ? (json['require_signature'] as int) == 1
        : false,
  );

  JsonMap toJson() => {
    'id': id,
    'contact_id': contactId,
    'client_name': clientName,
    'client_email': clientEmail,
    'description': description,
    'created_at': createdAt.toIso8601String(),
    'status': status.storageValue,
    'total': total,
    'vat': vat,
    'require_signature': requireSignature,
  };
}

class Invoice extends Equatable {
  final String id;
  final String quoteId;
  final String? contactId;
  final String clientName;
  final String? clientEmail;
  final String? projectId;
  final DateTime issuedAt;
  final InvoiceStatus status;
  final double amount;
  final DateTime? dueDate;
  final PaymentMethod? paymentMethod;

  const Invoice({
    required this.id,
    required this.quoteId,
    this.contactId,
    required this.clientName,
    this.clientEmail,
    this.projectId,
    required this.issuedAt,
    required this.status,
    required this.amount,
    this.dueDate,
    this.paymentMethod,
  });

  Invoice copyWith({
    InvoiceStatus? status,
    DateTime? issuedAt,
    DateTime? dueDate,
    PaymentMethod? paymentMethod,
    String? projectId,
    String? contactId,
    String? clientEmail,
  }) => Invoice(
    id: id,
    quoteId: quoteId,
    contactId: contactId ?? this.contactId,
    clientName: clientName,
    clientEmail: clientEmail ?? this.clientEmail,
    projectId: projectId ?? this.projectId,
    issuedAt: issuedAt ?? this.issuedAt,
    status: status ?? this.status,
    amount: amount,
    dueDate: dueDate ?? this.dueDate,
    paymentMethod: paymentMethod ?? this.paymentMethod,
  );

  @override
  List<Object?> get props => [
    id,
    quoteId,
    contactId,
    clientName,
    clientEmail,
    projectId,
    issuedAt,
    status,
    amount,
    dueDate,
    paymentMethod,
  ];

  factory Invoice.fromJson(JsonMap json) => Invoice(
    id: json['id'] as String,
    quoteId: json['quote_id'] as String? ?? 'manual',
    contactId: json['contact_id'] as String?,
    clientName: json['client_name'] as String? ?? '',
    clientEmail: json['client_email'] as String?,
    projectId: json['project_id'] as String?,
    issuedAt: _parseDate(json['issued_at']) ?? DateTime.now(),
    status: InvoiceStatusMapper.fromStorage(json['status'] as String?),
    amount: _doubleValue(json['amount']),
    dueDate: _parseDate(json['due_date']),
    paymentMethod: PaymentMethodMapper.fromStorage(
      json['payment_method'] as String?,
    ),
  );

  JsonMap toJson() => {
    'id': id,
    'quote_id': quoteId,
    'contact_id': contactId,
    'client_name': clientName,
    'client_email': clientEmail,
    'project_id': projectId,
    'issued_at': issuedAt.toIso8601String(),
    'status': status.storageValue,
    'amount': amount,
    'due_date': dueDate?.toIso8601String(),
    'payment_method': paymentMethod?.storageValue,
  };
}

enum ExpenseRecurrence { oneTime, weekly, monthly }

extension ExpenseRecurrenceMapper on ExpenseRecurrence {
  static const Map<ExpenseRecurrence, String> _storage = {
    ExpenseRecurrence.oneTime: 'one_time',
    ExpenseRecurrence.weekly: 'weekly',
    ExpenseRecurrence.monthly: 'monthly',
  };

  String get storageValue => _storage[this] ?? 'one_time';

  static ExpenseRecurrence fromStorage(String? value) {
    final entry = _storage.entries.firstWhere(
      (item) => item.value == value,
      orElse: () => const MapEntry(ExpenseRecurrence.oneTime, ''),
    );
    return entry.key;
  }
}

class Expense extends Equatable {
  final String id;
  final String? projectId;
  final String description;
  final double amount;
  final DateTime date;
  final ExpenseRecurrence recurrence;

  const Expense({
    required this.id,
    this.projectId,
    required this.description,
    required this.amount,
    required this.date,
    this.recurrence = ExpenseRecurrence.oneTime,
  });

  Expense copyWith({
    String? projectId,
    String? description,
    double? amount,
    DateTime? date,
    ExpenseRecurrence? recurrence,
  }) => Expense(
    id: id,
    projectId: projectId ?? this.projectId,
    description: description ?? this.description,
    amount: amount ?? this.amount,
    date: date ?? this.date,
    recurrence: recurrence ?? this.recurrence,
  );

  @override
  List<Object?> get props => [
    id,
    projectId,
    description,
    amount,
    date,
    recurrence,
  ];

  factory Expense.fromJson(JsonMap json) => Expense(
    id: json['id'] as String,
    projectId: json['project_id'] as String?,
    description: json['description'] as String? ?? '',
    amount: _doubleValue(json['amount']),
    date: _parseDate(json['date']) ?? DateTime.now(),
    recurrence: ExpenseRecurrenceMapper.fromStorage(
      json['recurrence'] as String?,
    ),
  );

  JsonMap toJson() => {
    'id': id,
    'project_id': projectId,
    'description': description,
    'amount': amount,
    'date': date.toIso8601String(),
    'recurrence': recurrence.storageValue,
  };
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}

double _doubleValue(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value) ?? 0;
  }
  return 0;
}
