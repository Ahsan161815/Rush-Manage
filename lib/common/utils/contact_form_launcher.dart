import 'package:flutter/material.dart';

import 'package:myapp/common/models/contact_form_models.dart';
import 'package:myapp/widgets/contact_request_sheet.dart';

class ContactFormLauncher {
  const ContactFormLauncher._();

  static Future<ContactFormSubmission?> show(
    BuildContext context, {
    ContactFormMode mode = ContactFormMode.create,
    ContactFormData data = const ContactFormData(),
    String? contactId,
  }) async {
    final nameController = TextEditingController(text: data.name ?? '');
    final emailController = TextEditingController(text: data.email ?? '');
    final phoneController = TextEditingController(text: data.phone ?? '');
    final addressController = TextEditingController(text: data.address ?? '');
    final typeController = TextEditingController(text: data.type ?? '');
    final notesController = TextEditingController(text: data.notes ?? '');

    try {
      final submission = await showModalBottomSheet<ContactFormSubmission>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (sheetContext) {
          final bottomInset = MediaQuery.of(sheetContext).viewInsets.bottom;
          return SafeArea(
            top: false,
            child: ContactRequestSheet(
              contactId: contactId,
              nameController: nameController,
              emailController: emailController,
              phoneController: phoneController,
              addressController: addressController,
              typeController: typeController,
              notesController: notesController,
              mode: mode,
              bottomInset: bottomInset,
            ),
          );
        },
      );
      return submission;
    } finally {
      nameController.dispose();
      emailController.dispose();
      phoneController.dispose();
      addressController.dispose();
      typeController.dispose();
      notesController.dispose();
    }
  }
}
