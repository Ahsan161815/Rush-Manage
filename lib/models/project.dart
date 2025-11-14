
import 'package:equatable/equatable.dart';

class Project extends Equatable {
  final String name;
  final String description;

  const Project({required this.name, required this.description});

  @override
  List<Object> get props => [name, description];
}
