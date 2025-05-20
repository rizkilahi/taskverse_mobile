import 'package:flutter/material.dart';
import '../../../data/models/project_model.dart';

class HomeProvider with ChangeNotifier {
  List<ProjectModel> _projects = ProjectModel.dummyProjects;
  DateTime _selectedDate = DateTime.now();
  
  List<ProjectModel> get projects => _projects;
  DateTime get selectedDate => _selectedDate;
  
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }
  
  void addProject(ProjectModel project) {
    _projects.add(project);
    notifyListeners();
  }
}