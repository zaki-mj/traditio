import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:traditional_gems/services/image_services.dart';
import '../services/firebase_services.dart';
import 'package:traditional_gems/services/location_services.dart';
import '../models/place.dart';
import '../l10n/app_localizations.dart';

class PlaceFormPage extends StatefulWidget {
  final PointOfInterest? place;

  const PlaceFormPage({super.key, this.place});

  @override
  State<PlaceFormPage> createState() => _PlaceFormPageState();
}

class _PlaceFormPageState extends State<PlaceFormPage> {
  // Form state
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _nameARController;
  late TextEditingController _nameFRController;
  late TextEditingController _descriptionController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _facebookController;
  late TextEditingController _instagramController;
  late TextEditingController _tiktokController;
  late TextEditingController _ratingController;

  // Dropdown & Location state
  late String _selectedType;
  String? selectedStateCode;
  String? selectedCityNameFR; // Use French name as the key for cities
  String? selectedWilayaNameAR;
  String? selectedWilayaNameFR;
  String? selectedCityNameAR;

  List<Map<String, dynamic>> states = [];
  List<Map<String, dynamic>> cities = [];
  bool isLoadingStates = true;
  bool isLoadingCities = false;

  // Image management state
  final List<XFile> _newImages = [];
  final List<String> _existingImageUrls = [];
  final List<String> _removedImageUrls = [];

  @override
  void initState() {
    super.initState();
    final place = widget.place;

    // Initialize controllers
    _nameARController = TextEditingController(text: place?.nameAR ?? '');
    _nameFRController = TextEditingController(text: place?.nameFR ?? '');
    _descriptionController = TextEditingController(text: place?.description ?? '');
    _phoneController = TextEditingController(text: place?.phone ?? '');
    _emailController = TextEditingController(text: place?.email ?? '');
    _addressController = TextEditingController(text: place?.locationLink ?? '');
    _facebookController = TextEditingController(text: place?.facebookLink ?? '');
    _instagramController = TextEditingController(text: place?.instagramLink ?? '');
    _tiktokController = TextEditingController(text: place?.tiktokLink ?? '');
    _ratingController = TextEditingController(text: place?.rating.toString() ?? '4.0');
    _selectedType = place?.category.name ?? POICategory.hotel.name;

    // Pre-fill image and location data if editing
    if (place != null) {
      if (place.imageUrls.isNotEmpty) {
        _existingImageUrls.addAll(place.imageUrls);
      }
      selectedStateCode = place.wilayaCode;
      selectedWilayaNameAR = place.wilayaNameAR;
      selectedWilayaNameFR = place.wilayaNameFR;
      selectedCityNameFR = place.cityNameFR;
      selectedCityNameAR = place.cityNameAR;
    }

    // Load initial location data
    _loadStates().then((_) {
      if (selectedStateCode != null) {
        _loadCitiesForState(selectedStateCode!);
      }
    });
  }

  @override
  void dispose() {
    // Dispose all controllers
    _nameARController.dispose();
    _nameFRController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _facebookController.dispose();
    _instagramController.dispose();
    _tiktokController.dispose();
    _ratingController.dispose();
    super.dispose();
  }

  Future<void> _loadStates() async {
    setState(() => isLoadingStates = true);
    try {
      final loadedStates = await AlgeriaLocationService.getStates();
      setState(() {
        states = loadedStates;
        isLoadingStates = false;
      });
    } catch (e) {
      setState(() => isLoadingStates = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading states: $e')));
      }
    }
  }

  Future<void> _loadCitiesForState(String stateCode) async {
    setState(() => isLoadingCities = true);
    try {
      final loadedCities = await AlgeriaLocationService.getCitiesForState(stateCode);
      setState(() {
        cities = loadedCities;
        isLoadingCities = false;
      });
    } catch (e) {
      setState(() => isLoadingCities = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading cities: $e')));
      }
    }
  }

  Future<void> _pickImages() async {
    if ((_existingImageUrls.length + _newImages.length) >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You can only select up to 3 images.')));
      return;
    }
    final imageService = ImageService();
    final pickedFiles = await imageService.pickImages();

    if (pickedFiles.isNotEmpty) {
      setState(() {
        _newImages.addAll(pickedFiles);
      });
    }
  }

  void _removeNewImage(int index) {
    setState(() {
      _newImages.removeAt(index);
    });
  }

  void _removeExistingImage(int index) {
    setState(() {
      final removedUrl = _existingImageUrls.removeAt(index);
      _removedImageUrls.add(removedUrl);
    });
  }

  Future<void> _savePlace() async {
    if (!_formKey.currentState!.validate()) {
      return; // Validation failed
    }

    // Additional manual validation for dropdowns
    if (selectedStateCode == null || selectedCityNameFR == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a Wilaya and Commune.'), backgroundColor: Colors.red));
      return;
    }

    final rating = double.tryParse(_ratingController.text) ?? 4.0;

    try {
      final poi = PointOfInterest(
        id: widget.place?.id,
        nameAR: _nameARController.text.trim(),
        nameFR: _nameFRController.text.trim(),
        wilayaCode: selectedStateCode!,
        wilayaNameAR: selectedWilayaNameAR!,
        wilayaNameFR: selectedWilayaNameFR!,
        cityNameAR: selectedCityNameAR!,
        cityNameFR: selectedCityNameFR!,
        rating: rating,
        recommended: widget.place?.recommended ?? false,
        category: POICategory.values.firstWhere((e) => e.name == _selectedType),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        imageUrls: _existingImageUrls, // Start with the current list of URLs
        description: _descriptionController.text.trim(),
        locationLink: _addressController.text.trim(),
        facebookLink: _facebookController.text.trim(),
        instagramLink: _instagramController.text.trim(),
        tiktokLink: _tiktokController.text.trim(),
        createdAt: widget.place?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final svc = FirebaseServices();
      if (widget.place == null) {
        await svc.createPOI(poi, images: _newImages);
      } else {
        await svc.updatePOI(poi, newImages: _newImages, removedImageUrls: _removedImageUrls);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc(context).translate('poi_saved_successfully')), backgroundColor: Colors.green));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${loc(context).translate('error_saving')}: $e'), backgroundColor: Colors.red));
      }
    }
  }

  AppLocalizations loc(BuildContext context) => AppLocalizations(Localizations.localeOf(context));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.place != null;
    final currentLocale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? loc(context).translate('edit_place') : loc(context).translate('create_place'))),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildImagePicker(loc(context)),
            const SizedBox(height: 24),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(loc(context).translate('basic_information'), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameARController,
                      decoration: InputDecoration(labelText: loc(context).translate('name_ar'), hintText: 'اسم المكان', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), prefixIcon: const Icon(Icons.language)),
                      textDirection: TextDirection.rtl,
                      validator: (value) => value == null || value.isEmpty ? loc(context).translate('field_required') : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nameFRController,
                      decoration: InputDecoration(labelText: loc(context).translate('name_fr'), hintText: 'Nom du lieu', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), prefixIcon: const Icon(Icons.language)),
                      validator: (value) => value == null || value.isEmpty ? loc(context).translate('field_required') : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: InputDecoration(labelText: loc(context).translate('type_label'), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), prefixIcon: const Icon(Icons.category)),
                      items: POICategory.values.map((cat) => DropdownMenuItem(value: cat.name, child: Text(loc(context).translate('type_${cat.name}')))).toList(),
                      onChanged: (value) {
                        setState(() => _selectedType = value ?? POICategory.hotel.name);
                      },
                    ),
                    const SizedBox(height: 12),
                    // Location Dropdowns
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: isLoadingStates
                              ? const Center(child: CircularProgressIndicator())
                              : DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  value: selectedStateCode,
                                  decoration: InputDecoration(labelText: currentLocale == 'ar' ? 'الولاية' : 'Wilaya', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), prefixIcon: const Icon(Icons.location_on)),
                                  hint: Text(loc(context).translate('select_wilaya')),
                                  items: states.map((state) {
                                    return DropdownMenuItem<String>(value: state['code'], child: Text(currentLocale == 'ar' ? state['nameAR'] : state['nameFR']));
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      final state = states.firstWhere((s) => s['code'] == value);
                                      setState(() {
                                        selectedStateCode = value;
                                        selectedWilayaNameAR = state['nameAR'];
                                        selectedWilayaNameFR = state['nameFR'];
                                        cities = [];
                                        selectedCityNameFR = null;
                                        selectedCityNameAR = null;
                                      });
                                      _loadCitiesForState(value);
                                    }
                                  },
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: isLoadingCities
                              ? const Center(child: CircularProgressIndicator())
                              : DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  value: selectedCityNameFR,
                                  decoration: InputDecoration(labelText: currentLocale == 'ar' ? 'البلدية' : 'Commune', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), prefixIcon: const Icon(Icons.location_city)),
                                  hint: Text(loc(context).translate('select_commune')),
                                  items: cities.map((city) {
                                    return DropdownMenuItem<String>(value: city['nameFR'], child: Text(currentLocale == 'ar' ? city['nameAR'] : city['nameFR']));
                                  }).toList(),
                                  onChanged: selectedStateCode == null
                                      ? null
                                      : (value) {
                                          if (value != null) {
                                            final city = cities.firstWhere((c) => c['nameFR'] == value);
                                            setState(() {
                                              selectedCityNameFR = value;
                                              selectedCityNameAR = city['nameAR'];
                                            });
                                          }
                                        },
                                ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _ratingController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: loc(context).translate('rating'), hintText: 'e.g. 4.5', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), prefixIcon: const Icon(Icons.star)),
                      validator: (value) {
                        if (value == null || value.isEmpty) return loc(context).translate('field_required');
                        final rating = double.tryParse(value);
                        if (rating == null || rating < 0 || rating > 5) return loc(context).translate('rating_error');
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(labelText: loc(context).translate('description_label'), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), prefixIcon: const Icon(Icons.description)),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // ... other cards ...
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: Text(loc(context).translate('cancel')))),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton(onPressed: _savePlace, child: Text(isEditing ? loc(context).translate('update_button') : loc(context).translate('create_button')))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker(AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(loc.translate('images'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ..._existingImageUrls.asMap().entries.map((entry) => _buildImageThumbnail(entry.key, entry.value, isExisting: true)),
              ..._newImages.asMap().entries.map((entry) => _buildImageThumbnail(entry.key, entry.value.path, isExisting: false)),
              if ((_existingImageUrls.length + _newImages.length) < 3) _buildAddImageButton(loc),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageThumbnail(int index, String path, {required bool isExisting}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: isExisting
                ? Image.network(path, width: 100, height: 100, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 100))
                : Image.file(File(path), width: 100, height: 100, fit: BoxFit.cover),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => isExisting ? _removeExistingImage(index) : _removeNewImage(index),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                child: const Icon(Icons.close, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddImageButton(AppLocalizations loc) {
    return GestureDetector(
      onTap: _pickImages,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(8)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_a_photo, color: Colors.black54, size: 40),
            const SizedBox(height: 4),
            Text(loc.translate('add_images'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
