import 'package:equatable/equatable.dart';

enum QuoteStatus { draft, pendingSignature, signed, declined }

enum InvoiceStatus { draft, unpaid, paid }

enum PaymentMethod { bankTransfer, card, applePay }

class Quote extends Equatable {
  final String id;
  final String clientName;
  final String description;
  final DateTime createdAt;
  final QuoteStatus status;
  final double total;
  final double vat;

  const Quote({
    required this.id,
    required this.clientName,
    required this.description,
    required this.createdAt,
    required this.status,
    required this.total,
    required this.vat,
  });

  Quote copyWith({
    String? clientName,
    String? description,
    QuoteStatus? status,
    double? total,
    double? vat,
  }) => Quote(
    id: id,
    clientName: clientName ?? this.clientName,
    description: description ?? this.description,
    createdAt: createdAt,
    status: status ?? this.status,
    total: total ?? this.total,
    vat: vat ?? this.vat,
  );

  @override
  List<Object?> get props => [
    id,
    clientName,
    description,
    createdAt,
    status,
    total,
    vat,
  ];
}

class Invoice extends Equatable {
  final String id;
  final String quoteId;
  final String clientName;
  final DateTime issuedAt;
  final InvoiceStatus status;
  final double amount;
  final DateTime? dueDate;
  final PaymentMethod? paymentMethod;

  const Invoice({
    required this.id,
    required this.quoteId,
    required this.clientName,
    required this.issuedAt,
    required this.status,
    required this.amount,
    this.dueDate,
    this.paymentMethod,
  });

  Invoice copyWith({
    InvoiceStatus? status,
    DateTime? dueDate,
    PaymentMethod? paymentMethod,
  }) => Invoice(
    id: id,
    quoteId: quoteId,
    clientName: clientName,
    issuedAt: issuedAt,
    status: status ?? this.status,
    amount: amount,
    dueDate: dueDate ?? this.dueDate,
    paymentMethod: paymentMethod ?? this.paymentMethod,
  );

  @override
  List<Object?> get props => [
    id,
    quoteId,
    clientName,
    issuedAt,
    status,
    amount,
    dueDate,
    paymentMethod,
  ];
}

enum ExpenseRecurrence { oneTime, weekly, monthly }

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
}
