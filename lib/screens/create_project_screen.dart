
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:myapp/app/app_theme.dart';
import 'package:myapp/app/widgets/gradient_button.dart';
import 'package:myapp/controllers/dashboard_controller.dart';
import 'package:myapp/models/project.dart';

class CreateProjectScreen extends StatefulWidget {
  const CreateProjectScreen({super.key});

  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Project'),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Project Name',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Project Description',
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 32),
            GradientButton(
              onPressed: () async {
                if (_nameController.text.isNotEmpty &&
                    _descriptionController.text.isNotEmpty) {
                  setState(() {
                    _isLoading = true;
                  });
                  // Simulate a network request
                  await Future.delayed(const Duration(seconds: 1));

                  if (!mounted) return;

                  final project = Project(
                    name: _nameController.text,
                    description: _descriptionController.text,
                  );
                  context.read<DashboardController>().addProject(project);

                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill all fields.'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              text: 'Create Project',
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
