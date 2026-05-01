import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import '../services/firebase_services.dart';
import '../services/cloudinary_service.dart';
import '../services/location_services.dart'; // Make sure the path is correct
import '../models/place.dart';
import '../l10n/app_localizations.dart';

class PlaceFormPage extends StatefulWidget {
  final PointOfInterest? place;
  const PlaceFormPage({super.key, this.place});

  @override
  State<PlaceFormPage> createState() => _PlaceFormPageState();
}

class _PlaceFormPageState extends State<PlaceFormPage> {
  // Controllers
  late TextEditingController _nameARController;
  late TextEditingController _nameFRController;
  late TextEditingController _descriptionARController;
  late TextEditingController _descriptionFRController;
  late TextEditingController _descriptionENController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _facebookController;
  late TextEditingController _instagramController;
  late TextEditingController _tiktokController;
  late TextEditingController _ratingController;

  late String _selectedType;

  // Location fields
  String? selectedStateCode;
  String? selectedCityName;
  String? selectedWilayaNameAR;
  String? selectedWilayaNameFR;
  String? selectedCityNameAR;
  String? selectedCityNameFR;

  List<Map<String, dynamic>> states = [];
  List<Map<String, dynamic>> cities = [];
  bool isLoadingStates = true;

  final ImagePicker _picker = ImagePicker();

  // Image management
  List<String> _existingImageUrls = []; // URLs from database (can be removed)
  List<File> _newPickedImages = []; // New images selected by user

  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    final p = widget.place;

    // Initialize controllers
    _nameARController = TextEditingController(text: p?.nameAR ?? '');
    _nameFRController = TextEditingController(text: p?.nameFR ?? '');
    _descriptionARController = TextEditingController(text: p?.descriptionAR ?? '');
    _descriptionFRController = TextEditingController(text: p?.descriptionFR ?? '');
    _descriptionENController = TextEditingController(text: p?.descriptionEN ?? '');
    _phoneController = TextEditingController(text: p?.phone ?? '');
    _emailController = TextEditingController(text: p?.email ?? '');
    _addressController = TextEditingController(text: p?.locationLink ?? '');
    _facebookController = TextEditingController(text: p?.facebookLink ?? '');
    _instagramController = TextEditingController(text: p?.instagramLink ?? '');
    _tiktokController = TextEditingController(text: p?.tiktokLink ?? '');
    _ratingController = TextEditingController(text: (p?.rating ?? 4.0).toString());

    _selectedType = p?.category.name.toLowerCase() ?? 'hotel';

    // Load existing images when editing
    if (p != null && p.imageUrls != null) {
      _existingImageUrls = List<String>.from(p.imageUrls!);
    }

    _loadStates();
  }

  // ==================== LOCATION ====================
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
        final loc = AppLocalizations(Localizations.localeOf(context));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.translate('error_loading_states').replaceAll('{error}', e.toString()))));
      }
    }
  }

  Future<void> _loadCitiesForState(String stateCode) async {
    try {
      final loadedCities = await AlgeriaLocationService.getCitiesForState(stateCode);
      setState(() {
        cities = loadedCities;
        selectedCityName = null;
        selectedCityNameAR = null;
        selectedCityNameFR = null;
      });
    } catch (e) {
      if (mounted) {
        final loc = AppLocalizations(Localizations.localeOf(context));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.translate('error_loading_cities').replaceAll('{error}', e.toString()))));
      }
    }
  }

  // ==================== IMAGE HANDLING ====================
  Future<void> _pickImages() async {
    final int currentTotal = _existingImageUrls.length + _newPickedImages.length;
    final int remaining = 6 - currentTotal;
    if (remaining <= 0) return;

    final List<XFile>? picked = await _picker.pickMultiImage(imageQuality: 80, limit: remaining);

    if (picked == null || picked.isEmpty) return;

    setState(() {
      _newPickedImages.addAll(picked.map((x) => File(x.path)));
    });
  }

  void _removeImage(int index) {
    setState(() {
      if (index < _existingImageUrls.length) {
        _existingImageUrls.removeAt(index);
      } else {
        final newIndex = index - _existingImageUrls.length;
        _newPickedImages.removeAt(newIndex);
      }
    });
  }

  // ==================== SAVE ====================
  Future<void> _savePlace() async {
    // Validation
    if (_nameARController.text.trim().isEmpty || _nameFRController.text.trim().isEmpty || selectedStateCode == null || selectedCityName == null || _phoneController.text.trim().isEmpty || _emailController.text.trim().isEmpty) {
      final loc = AppLocalizations(Localizations.localeOf(context));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.translate('please_fill_required_fields')), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isUploading = true);

    // Start with the CURRENT existing images (after user removals)
    List<String> finalImageUrls = List.from(_existingImageUrls);

    // Upload and add any NEW picked images
    if (_newPickedImages.isNotEmpty) {
      try {
        final newUrls = await CloudinaryService.uploadImages(_newPickedImages);
        finalImageUrls.addAll(newUrls);
      } catch (e) {
        print('Image upload error: $e');
        if (mounted) {
          final loc = AppLocalizations(Localizations.localeOf(context));
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.translate('some_images_failed_upload')), backgroundColor: Colors.orange));
        }
      }
    }

    // Limit to maximum 6 images
    if (finalImageUrls.length > 6) {
      finalImageUrls = finalImageUrls.sublist(0, 6);
    }

    final rating = double.tryParse(_ratingController.text) ?? 4.0;
    final clampedRating = rating.clamp(0.0, 5.0);

    final poi = PointOfInterest(
      id: widget.place?.id,
      nameAR: _nameARController.text.trim(),
      nameFR: _nameFRController.text.trim(),
      wilayaCode: selectedStateCode!,
      wilayaNameAR: selectedWilayaNameAR ?? '',
      wilayaNameFR: selectedWilayaNameFR ?? '',
      cityNameAR: selectedCityNameAR ?? '',
      cityNameFR: selectedCityNameFR ?? '',
      rating: clampedRating,
      category: POICategory.fromValue(['hotel', 'restaurant', 'attraction', 'store', 'other'].indexOf(_selectedType) + 1),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      imageUrls: finalImageUrls, // ← Always a list (empty = [])
      descriptionAR: _descriptionARController.text.trim().isNotEmpty ? _descriptionARController.text.trim() : null,
      descriptionFR: _descriptionFRController.text.trim().isNotEmpty ? _descriptionFRController.text.trim() : null,
      descriptionEN: _descriptionENController.text.trim().isNotEmpty ? _descriptionENController.text.trim() : null,
      locationLink: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null,
      facebookLink: _facebookController.text.trim().isNotEmpty ? _facebookController.text.trim() : null,
      instagramLink: _instagramController.text.trim().isNotEmpty ? _instagramController.text.trim() : null,
      tiktokLink: _tiktokController.text.trim().isNotEmpty ? _tiktokController.text.trim() : null,
      createdAt: widget.place?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      final svc = FirebaseServices();

      if (widget.place == null) {
        await svc.createPOI(poi);
      } else {
        await svc.updatePOI(poi);
      }

      if (mounted) {
        final loc = AppLocalizations(Localizations.localeOf(context));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.translate('saved_successfully')), backgroundColor: Colors.green));
        Navigator.pop(context, true); // Optional: return true to refresh previous page
      }
    } catch (e) {
      print('Error saving place: $e');
      if (mounted) {
        final loc = AppLocalizations(Localizations.localeOf(context));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.translate('failed_to_save').replaceAll('{error}', e.toString())), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  void dispose() {
    _nameARController.dispose();
    _nameFRController.dispose();
    _descriptionARController.dispose();
    _descriptionFRController.dispose();
    _descriptionENController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _facebookController.dispose();
    _instagramController.dispose();
    _tiktokController.dispose();
    _ratingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations(Localizations.localeOf(context));
    final theme = Theme.of(context);
    final isEditing = widget.place != null;
    final currentLocale = Localizations.localeOf(context).languageCode;

    final int totalImages = _existingImageUrls.length + _newPickedImages.length;
    final bool canAddMore = totalImages < 6;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? loc.translate('edit_place') : loc.translate('create_place'))),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ====================== PHOTOS SECTION ======================
              Text(loc.translate('photos_with_count').replaceAll('{current}', '$totalImages').replaceAll('{max}', '6'), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              SizedBox(
                height: 180,
                child: totalImages == 0
                    ? GestureDetector(
                        onTap: _pickImages,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add_a_photo, size: 64, color: theme.colorScheme.primary),
                              const SizedBox(height: 16),
                              Text(loc.translate('tap_to_add_photos'), style: theme.textTheme.titleMedium),
                              const SizedBox(height: 8),
                              Text(loc.translate('max_six_images_note')),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: totalImages + (canAddMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          final bool isAddButton = canAddMore && index == totalImages;

                          if (isAddButton) {
                            return GestureDetector(
                              onTap: _pickImages,
                              child: Container(
                                width: 160,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: theme.dividerColor),
                                  borderRadius: BorderRadius.circular(16),
                                  color: theme.colorScheme.surfaceContainerHighest,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_photo_alternate, size: 40, color: theme.colorScheme.primary),
                                    const SizedBox(height: 8),
                                    Text(loc.translate('add_more')),
                                    Text('$totalImages/6'),
                                  ],
                                ),
                              ),
                            );
                          }

                          // Show image
                          final bool isExisting = index < _existingImageUrls.length;
                          final String src = isExisting ? _existingImageUrls[index] : _newPickedImages[index - _existingImageUrls.length].path;

                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: isExisting ? Image.network(src, width: 160, height: 180, fit: BoxFit.cover) : Image.file(File(src), width: 160, height: 180, fit: BoxFit.cover),
                                ),
                                if (index == 0)
                                  Positioned(
                                    bottom: 8,
                                    left: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(color: theme.colorScheme.primary, borderRadius: BorderRadius.circular(12)),
                                      child: Text(loc.translate('photo_main_badge'), style: TextStyle(color: theme.colorScheme.onPrimary, fontSize: 12)),
                                    ),
                                  ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: InkWell(
                                    onTap: () => _removeImage(index),
                                    child: CircleAvatar(
                                      radius: 14,
                                      backgroundColor: Colors.black54,
                                      child: const Icon(Icons.close, size: 18, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),

              const SizedBox(height: 32),

              // ==================== BASIC INFORMATION ====================
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.translate('basic_information'),
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                      ),
                      const SizedBox(height: 16),

                      TextField(
                        controller: _nameARController,
                        decoration: InputDecoration(labelText: loc.translate('name_arabic'), border: const OutlineInputBorder()),
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _nameFRController,
                        decoration: InputDecoration(labelText: loc.translate('name_french'), border: const OutlineInputBorder()),
                      ),
                      const SizedBox(height: 12),

                      DropdownButtonFormField<String>(
                        value: _selectedType,
                        decoration: InputDecoration(labelText: loc.translate('type_field'), border: const OutlineInputBorder()),
                        items: ['hotel', 'restaurant', 'attraction', 'store', 'other'].map((type) => DropdownMenuItem(value: type, child: Text(loc.translate('type_$type')))).toList(),
                        onChanged: (value) => setState(() => _selectedType = value ?? 'hotel'),
                      ),
                      const SizedBox(height: 20),

                      // Location Dropdowns (keep your original logic)
                      Row(
                        children: [
                          Expanded(
                            child: isLoadingStates
                                ? const Center(child: CircularProgressIndicator())
                                : DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    value: selectedStateCode,
                                    decoration: InputDecoration(labelText: loc.translate('wilaya_field'), border: const OutlineInputBorder()),
                                    items: states.map((state) {
                                      return DropdownMenuItem<String>(
                                        value: state['code'],
                                        child: Text(
                                          '${state['code']} ${state['nameAR'] ?? state['nameFR']}',
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      if (value != null) {
                                        final state = states.firstWhere((s) => s['code'] == value);
                                        setState(() {
                                          selectedStateCode = value;
                                          selectedWilayaNameAR = state['nameAR'];
                                          selectedWilayaNameFR = state['nameFR'];
                                        });
                                        _loadCitiesForState(value);
                                      }
                                    },
                                  ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              value: selectedCityName,
                              decoration: InputDecoration(labelText: loc.translate('commune_field'), labelStyle: TextStyle(), border: const OutlineInputBorder()),
                              items: cities.map((city) => DropdownMenuItem<String>(
                                    value: city['nameFR'],
                                    child: Text(
                                      currentLocale == 'ar' ? (city['nameAR'] ?? city['nameFR']) : city['nameFR'],
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  )).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  final city = cities.firstWhere((c) => c['nameFR'] == value);
                                  setState(() {
                                    selectedCityName = value;
                                    selectedCityNameAR = city['nameAR'];
                                    selectedCityNameFR = city['nameFR'];
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),
                      TextField(
                        controller: _ratingController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(labelText: loc.translate('rating_range'), border: const OutlineInputBorder()),
                      ),
                    ],
                  ),
                ),
              ),

              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.translate('contact'),
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: loc.translate('phone'),
                          hintText: loc.translate('phone_example_hint'),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.phone),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: loc.translate('email'),
                          hintText: loc.translate('email_example_hint'),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.email),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: loc.translate('maps_link_label'),
                          hintText: loc.translate('maps_link_hint'),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.map),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Social Media Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.translate('social'),
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _facebookController,
                        decoration: InputDecoration(
                          labelText: loc.translate('facebook_url_label'),
                          hintText: loc.translate('facebook_url_hint'),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.link),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _instagramController,
                        decoration: InputDecoration(
                          labelText: loc.translate('instagram_url_label'),
                          hintText: loc.translate('instagram_url_hint'),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.link),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _tiktokController,
                        decoration: InputDecoration(
                          labelText: loc.translate('tiktok_url_label'),
                          hintText: loc.translate('tiktok_url_hint'),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.link),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Save Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(onPressed: () => Navigator.pop(context), child: Text(loc.translate('cancel'))),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isUploading ? null : _savePlace,
                      child: _isUploading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text(isEditing ? loc.translate('button_update') : loc.translate('button_create')),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),

          if (_isUploading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
