import 'package:flutter/material.dart';
// removed unused import: flutter/services
import '../services/firebase_services.dart';
import 'package:traditional_gems/services/location_services.dart';
import '../models/place.dart';
import '../l10n/app_localizations.dart';

class PlaceFormPage extends StatefulWidget {
  // Accept a PointOfInterest for editing, null when creating new
  final PointOfInterest? place;

  const PlaceFormPage({super.key, this.place});

  @override
  State<PlaceFormPage> createState() => _PlaceFormPageState();
}

class _PlaceFormPageState extends State<PlaceFormPage> {
  // Controllers for Place compatibility
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _facebookController;
  late TextEditingController _instagramController;
  late TextEditingController _twitterController;
  late TextEditingController _imageUrlController;
  late TextEditingController _ratingController;
  late String _selectedType;

  // Additional controllers for PointOfInterest
  late TextEditingController _nameARController;
  late TextEditingController _nameFRController;
  late TextEditingController _tiktokController;

  // Location data
  String? selectedStateCode;
  String? selectedCityName;
  String? selectedWilayaNameAR;
  String? selectedWilayaNameFR;
  String? selectedCityNameAR;
  String? selectedCityNameFR;

  List<Map<String, dynamic>> states = [];
  List<Map<String, dynamic>> cities = [];
  bool isLoadingStates = true;

  @override
  void initState() {
    super.initState();
    final place = widget.place;

    // Initialize Place controllers
    _nameController = TextEditingController(text: place?.nameFR ?? '');
    _descriptionController = TextEditingController(text: place?.description ?? '');
    // locationController was previously used for the old Place model; keep address controller mapped to POI.locationLink
    _phoneController = TextEditingController(text: place?.phone ?? '');
    _emailController = TextEditingController(text: place?.email ?? '');
    _addressController = TextEditingController(text: place?.locationLink ?? '');
    _facebookController = TextEditingController(text: place?.facebookLink ?? '');
    _instagramController = TextEditingController(text: place?.instagramLink ?? '');
    _twitterController = TextEditingController(text: place?.tiktokLink ?? '');
    _imageUrlController = TextEditingController(text: place?.imageUrl?.isNotEmpty ?? false ? place!.imageUrl : '');
    _ratingController = TextEditingController(text: place?.rating.toString() ?? '4.0');
    _selectedType = place != null ? place.category.name : 'hotel';

    // Initialize PointOfInterest controllers
    _nameARController = TextEditingController(text: place?.nameAR ?? '');
    _nameFRController = TextEditingController(text: place?.nameFR ?? '');
    _tiktokController = TextEditingController();

    _loadStates();
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading cities: $e')));
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    // _locationController was removed (replaced by _addressController)
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _facebookController.dispose();
    _instagramController.dispose();
    _twitterController.dispose();
    _imageUrlController.dispose();
    _ratingController.dispose();
    _nameARController.dispose();
    _nameFRController.dispose();
    _tiktokController.dispose();
    super.dispose();
  }

  Future<void> _savePlace() async {
    // localization object not required here

    // Validation: Check mandatory fields
    List<String> missingFields = [];

    if (_nameARController.text.trim().isEmpty) {
      missingFields.add('Name (Arabic)');
    }
    if (_nameFRController.text.trim().isEmpty) {
      missingFields.add('Name (French)');
    }
    if (selectedStateCode == null) {
      missingFields.add('Wilaya');
    }
    if (selectedCityName == null) {
      missingFields.add('City/Commune');
    }
    if (_phoneController.text.trim().isEmpty) {
      missingFields.add('Phone');
    }
    if (_emailController.text.trim().isEmpty) {
      missingFields.add('Email');
    }

    if (missingFields.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Missing required fields: ${missingFields.join(', ')}'), backgroundColor: Colors.red, duration: const Duration(seconds: 4)));
      return;
    }

    final rating = double.tryParse(_ratingController.text) ?? 4.0;

    // Create PointOfInterest object
    try {
      final poi = PointOfInterest(
        nameAR: _nameARController.text.trim(),
        nameFR: _nameFRController.text.trim(),
        wilayaCode: selectedStateCode!,
        wilayaNameAR: selectedWilayaNameAR!,
        wilayaNameFR: selectedWilayaNameFR!,
        cityNameAR: selectedCityNameAR!,
        cityNameFR: selectedCityNameFR!,
        rating: rating,
        category: POICategory.fromValue(['hotel', 'restaurant', 'attraction', 'store', 'other'].indexOf(_selectedType) + 1),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        imageUrl: _imageUrlController.text.isNotEmpty ? _imageUrlController.text.trim() : null,
        description: _descriptionController.text.trim().isNotEmpty ? _descriptionController.text.trim() : null,
        locationLink: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null,
        facebookLink: _facebookController.text.trim().isNotEmpty ? _facebookController.text.trim() : null,
        instagramLink: _instagramController.text.trim().isNotEmpty ? _instagramController.text.trim() : null,
        tiktokLink: _tiktokController.text.trim().isNotEmpty ? _tiktokController.text.trim() : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to Firestore using service
      final svc = FirebaseServices();
      if (widget.place?.id == null) {
        await svc.createPOI(poi);
      } else {
        // Editing existing POI: make sure id is preserved
        final updated = PointOfInterest(
          id: widget.place!.id,
          nameAR: poi.nameAR,
          nameFR: poi.nameFR,
          wilayaCode: poi.wilayaCode,
          wilayaNameAR: poi.wilayaNameAR,
          wilayaNameFR: poi.wilayaNameFR,
          cityNameAR: poi.cityNameAR,
          cityNameFR: poi.cityNameFR,
          rating: poi.rating,
          recommended: widget.place!.recommended,
          category: poi.category,
          phone: poi.phone,
          email: poi.email,
          imageUrl: poi.imageUrl,
          description: poi.description,
          locationLink: poi.locationLink,
          facebookLink: poi.facebookLink,
          instagramLink: poi.instagramLink,
          tiktokLink: poi.tiktokLink,
          createdAt: widget.place!.createdAt,
          updatedAt: DateTime.now(),
        );
        await svc.updatePOI(updated);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Point of Interest created successfully!'), backgroundColor: Colors.green));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving: $e'), backgroundColor: Colors.red, duration: const Duration(seconds: 4)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations(Localizations.localeOf(context));
    final theme = Theme.of(context);
    final isEditing = widget.place != null;
    final currentLocale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? loc.translate('edit_place') : loc.translate('create_place'))),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Image Preview
          if (_imageUrlController.text.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
              child: Image.network(
                _imageUrlController.text,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(height: 200, color: theme.colorScheme.surfaceContainerHighest, child: const Icon(Icons.image, size: 80)),
              ),
            )
          else
            Container(
              height: 200,
              decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.image, size: 80),
            ),
          const SizedBox(height: 24),

          // Basic Info Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.translate('basic_information'),
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(height: 16),

                  // Dual language name fields
                  TextField(
                    controller: _nameARController,
                    decoration: InputDecoration(
                      labelText: 'Name (Arabic)',
                      hintText: 'اسم المكان',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.language),
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nameFRController,
                    decoration: InputDecoration(
                      labelText: 'Name (French)',
                      hintText: 'Nom du lieu',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.language),
                    ),
                  ),

                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedType,
                    decoration: InputDecoration(
                      labelText: loc.translate('type_label'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.category),
                    ),
                    items: ['hotel', 'restaurant', 'attraction', 'store', 'other'].map((type) => DropdownMenuItem(value: type, child: Text(loc.translate('type_$type')))).toList(),
                    onChanged: (value) {
                      setState(() => _selectedType = value ?? 'hotel');
                    },
                  ),
                  const SizedBox(height: 12),

                  // State and City Dropdowns
                  Row(
                    children: [
                      Expanded(
                        child: isLoadingStates
                            ? const Center(child: CircularProgressIndicator())
                            : DropdownButtonFormField<String>(
                                isExpanded: true,
                                initialValue: selectedStateCode,
                                decoration: InputDecoration(
                                  labelText: currentLocale == 'ar' ? 'الولاية' : 'Wilaya',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  prefixIcon: Icon(Icons.location_on, color: theme.colorScheme.primary),
                                  filled: true,
                                  fillColor: theme.colorScheme.surface,
                                ),
                                hint: Text(currentLocale == 'ar' ? 'الولاية' : 'Wilaya'),
                                items: states.map((state) {
                                  return DropdownMenuItem<String>(
                                    value: state['code'],
                                    child: currentLocale == 'ar' ? Text('${state['code']} ${state['nameAR']}', overflow: TextOverflow.ellipsis, maxLines: 1) : Text('${state['code']} ${state['nameFR']}', overflow: TextOverflow.ellipsis, maxLines: 1),
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
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          initialValue: selectedCityName,
                          decoration: InputDecoration(
                            labelText: currentLocale == 'ar' ? 'البلدية' : 'Commune',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: Icon(Icons.location_city, color: theme.colorScheme.primary),
                            filled: true,
                            fillColor: theme.colorScheme.surface,
                          ),
                          hint: Text(currentLocale == 'ar' ? 'البلدية' : 'Commune'),
                          items: selectedStateCode == null
                              ? []
                              : cities.map((city) {
                                  return DropdownMenuItem<String>(
                                    value: city['nameFR'],
                                    child: currentLocale == 'ar' ? Text(city['nameAR'], overflow: TextOverflow.ellipsis, maxLines: 1) : Text(city['nameFR'], overflow: TextOverflow.ellipsis, maxLines: 1),
                                  );
                                }).toList(),
                          onChanged: selectedStateCode == null
                              ? null
                              : (value) {
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
                    decoration: InputDecoration(
                      labelText: 'Rating (0-5)',
                      hintText: '4.5',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.star),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: loc.translate('description_label'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.description),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Details Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Details',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _imageUrlController,
                    decoration: InputDecoration(
                      labelText: 'Image URL',
                      hintText: 'https://example.com/image.jpg',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.image),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Contact Card
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
                      labelText: 'Phone',
                      hintText: '+213 555 123 456',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.phone),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'info@example.com',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: 'Location Link (Google Maps)',
                      hintText: 'https://maps.google.com/...',
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
                      labelText: 'Facebook URL',
                      hintText: 'https://facebook.com/...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.link),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _instagramController,
                    decoration: InputDecoration(
                      labelText: 'Instagram URL',
                      hintText: 'https://instagram.com/...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.link),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _twitterController,
                    decoration: InputDecoration(
                      labelText: 'Twitter URL',
                      hintText: 'https://twitter.com/...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.link),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _tiktokController,
                    decoration: InputDecoration(
                      labelText: 'TikTok URL',
                      hintText: 'https://tiktok.com/@...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.link),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _savePlace,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(isEditing ? 'Update' : 'Create', style: TextStyle(color: theme.colorScheme.onPrimary)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
