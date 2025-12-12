import 'package:equatable/equatable.dart';

enum ContactFormMode { create, edit }

class ContactFormData extends Equatable {
  const ContactFormData({
    this.name,
    this.email,
    this.phone,
    this.address,
    this.type,
    this.notes,
  });

  final String? name;
  final String? email;
  final String? phone;
  final String? address;
  final String? type;
  final String? notes;

  ContactFormData copyWith({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? type,
    String? notes,
  }) {
    return ContactFormData(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      type: type ?? this.type,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [name, email, phone, address, type, notes];
}
