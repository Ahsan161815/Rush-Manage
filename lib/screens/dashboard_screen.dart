
import 'package:flutter/material.dart';
import 'package:myapp/main.dart';
import 'package:myapp/screens/create_project_screen.dart';
import 'package:provider/provider.dart';


class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: Icon(themeProvider.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeProvider.toggleTheme(),
            tooltip: 'Toggle Theme',
          ),
        ],
      ),
      body: Center(
        child: Text(
          'No projects yet. Create one!',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateProjectScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
