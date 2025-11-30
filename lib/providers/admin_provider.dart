import 'package:flutter/material.dart';
import '../models/place.dart';

class AdminProvider extends ChangeNotifier {
  bool _editMode = false;
  String _searchQuery = '';
  String _selectedLocation = 'All';
  String _selectedType = '';

  // Editable place (for edit mode)
  PointOfInterest? _editingPlace;

  bool get editMode => _editMode;
  String get searchQuery => _searchQuery;
  String get selectedLocation => _selectedLocation;
  String get selectedType => _selectedType;
  PointOfInterest? get editingPlace => _editingPlace;

  void toggleEditMode() {
    _editMode = !_editMode;
    if (!_editMode) {
      _editingPlace = null; // Clear editing place when exiting edit mode
    }
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    notifyListeners();
  }

  void setLocation(String location) {
    _selectedLocation = location;
    notifyListeners();
  }

  void setType(String type) {
    _selectedType = _selectedType == type ? '' : type;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedLocation = 'All';
    _selectedType = '';
    notifyListeners();
  }

  void setEditingPlace(PointOfInterest? place) {
    _editingPlace = place;
    notifyListeners();
  }
}
