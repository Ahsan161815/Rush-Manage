
import 'package:flutter/material.dart';
import 'package:myapp/models/project.dart';

class DashboardController extends ChangeNotifier {
  final List<Project> _projects = [];

  List<Project> get projects => _projects;

  void addProject(Project project) {
    _projects.add(project);
    notifyListeners();
  }

  void removeProject(Project project) {
    _projects.remove(project);
    notifyListeners();
  }
}
