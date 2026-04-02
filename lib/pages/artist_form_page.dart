import 'package:flutter/material.dart';
import 'package:traditional_gems/models/artist.dart';
import '../services/firebase_services.dart';
import '../services/cloudinary_service.dart';
import 'package:traditional_gems/services/location_services.dart';
import '../l10n/app_localizations.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ArtistFormPage extends StatefulWidget {
  final Artist? artist;

  const ArtistFormPage({super.key, this.artist});

  @override
  State<ArtistFormPage> createState() => _ArtistFormPageState();
}

class _ArtistFormPageState extends State<ArtistFormPage> {
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
  List<File> _newPickedImages = [];
  List<String> _existingImageUrls = [];

  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    final p = widget.artist;

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

    if (p != null && p.imageUrls != null) {
      _existingImageUrls = List<String>.from(p.imageUrls!);
    }

    _loadStates();
  }

  Future<void> _pickImages() async {
    final List<XFile>? picked = await _picker.pickMultiImage(imageQuality: 80, limit: 6);
    if (picked == null || picked.isEmpty) return;

    setState(() {
      _newPickedImages = picked.map((x) => File(x.path)).toList();
    });
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

    super.dispose();
  }

  Future<void> _saveArtist() async {
    // Basic validation
    if (_nameARController.text.trim().isEmpty || _nameFRController.text.trim().isEmpty || selectedStateCode == null || selectedCityName == null || _phoneController.text.trim().isEmpty || _emailController.text.trim().isEmpty) {
      final loc = AppLocalizations(Localizations.localeOf(context));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.translate('please_fill_required_fields')), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isUploading = true);

    List<String> finalImageUrls = List.from(_existingImageUrls);

    if (_newPickedImages.isNotEmpty) {
      final newUrls = await CloudinaryService.uploadImages(_newPickedImages);

      finalImageUrls.addAll(newUrls);
    } else {}

    // Optional: keep only the last 6 if somehow more
    if (finalImageUrls.length > 6) {
      finalImageUrls = finalImageUrls.sublist(finalImageUrls.length - 6);
    }

    print('DEBUG: Final imageUrls before saving to Firestore: ${finalImageUrls.length} items → $finalImageUrls');

    final art = Artist(
      id: widget.artist?.id,
      nameAR: _nameARController.text.trim(),
      nameFR: _nameFRController.text.trim(),
      wilayaCode: selectedStateCode!,
      wilayaNameAR: selectedWilayaNameAR ?? '',
      wilayaNameFR: selectedWilayaNameFR ?? '',
      cityNameAR: selectedCityNameAR ?? '',
      cityNameFR: selectedCityNameFR ?? '',

      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      imageUrls: finalImageUrls.isNotEmpty ? finalImageUrls : null,
      descriptionAR: _descriptionARController.text.trim().isNotEmpty ? _descriptionARController.text.trim() : null,
      descriptionFR: _descriptionFRController.text.trim().isNotEmpty ? _descriptionFRController.text.trim() : null,
      descriptionEN: _descriptionENController.text.trim().isNotEmpty ? _descriptionENController.text.trim() : null,
      locationLink: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null,
      facebookLink: _facebookController.text.trim().isNotEmpty ? _facebookController.text.trim() : null,
      instagramLink: _instagramController.text.trim().isNotEmpty ? _instagramController.text.trim() : null,
      tiktokLink: _tiktokController.text.trim().isNotEmpty ? _tiktokController.text.trim() : null,
      createdAt: widget.artist?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      final svc = FirebaseServices();
      if (widget.artist == null) {
        await svc.createArtist(art);
        print('DEBUG: New POI created successfully');
      } else {
        await svc.updateArtist(art);
        print('DEBUG: POI updated successfully');
      }

      if (mounted) {
        final loc = AppLocalizations(Localizations.localeOf(context));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.translate('saved_successfully')), backgroundColor: Colors.green));
        Navigator.pop(context);
      }
    } catch (e, stack) {
      print('ERROR saving POI: $e\n$stack');
      if (mounted) {
        final loc = AppLocalizations(Localizations.localeOf(context));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.translate('error_saving').replaceAll('{error}', e.toString())), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations(Localizations.localeOf(context));
    final theme = Theme.of(context);
    final isEditing = widget.artist != null;
    final currentLocale = Localizations.localeOf(context).languageCode;

    final allImages = [..._existingImageUrls.map((url) => url), ..._newPickedImages.map((f) => f.path)];

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? loc.translate('edit_artist') : loc.translate('create_artist'))),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Photos Section
              Text(loc.translate('photos_section'), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              SizedBox(
                height: 180,
                child: allImages.isEmpty
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
                              Text(loc.translate('up_to_six_images_note')),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: allImages.length + ((_newPickedImages.length + _existingImageUrls.length) < 6 ? 1 : 0),
                        itemBuilder: (context, i) {
                          final isAddButton = i == allImages.length;

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
                                    Text(loc.translate('add_more'), style: theme.textTheme.bodyMedium),
                                    Text('${_existingImageUrls.length + _newPickedImages.length}/6'),
                                  ],
                                ),
                              ),
                            );
                          }

                          final src = allImages[i];
                          final isNetwork = src.startsWith('http');
                          final isMain = i == 0;

                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: isNetwork ? Image.network(src, width: 160, height: 180, fit: BoxFit.cover) : Image.file(File(src), width: 160, height: 180, fit: BoxFit.cover),
                                ),
                                if (isMain)
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
                                    onTap: () {
                                      setState(() {
                                        if (i < _existingImageUrls.length) {
                                          _existingImageUrls.removeAt(i);
                                        } else {
                                          _newPickedImages.removeAt(i - _existingImageUrls.length);
                                        }
                                      });
                                    },
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

              // ── Basic Info Card ───────────────────────────────────────────────
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

                      TextField(
                        controller: _nameARController,
                        decoration: InputDecoration(
                          labelText: loc.translate('name_arabic'),
                          hintText: loc.translate('hint_name_arabic'),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.language),
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _nameFRController,
                        decoration: InputDecoration(
                          labelText: loc.translate('name_french'),
                          hintText: loc.translate('hint_name_french_example'),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.language),
                        ),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: isLoadingStates
                                ? const Center(child: CircularProgressIndicator())
                                : DropdownButtonFormField<String>(
                                    value: selectedStateCode,
                                    isExpanded: true,
                                    decoration: InputDecoration(
                                      labelText: loc.translate('wilaya_field'),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                      prefixIcon: Icon(Icons.location_on, color: theme.colorScheme.primary),
                                      filled: true,
                                      fillColor: theme.colorScheme.surface,
                                    ),
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
                              value: selectedCityName,
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: loc.translate('commune_field'),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                prefixIcon: Icon(Icons.location_city, color: theme.colorScheme.primary),
                                filled: true,
                                fillColor: theme.colorScheme.surface,
                              ),
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
                        controller: _descriptionARController,
                        decoration: InputDecoration(
                          labelText: loc.translate('description_arabic'),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.description),
                        ),
                        maxLines: 3,
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _descriptionFRController,
                        decoration: InputDecoration(
                          labelText: loc.translate('description_french'),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.description),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _descriptionENController,
                        decoration: InputDecoration(
                          labelText: loc.translate('description_english'),
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

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(onPressed: () => Navigator.pop(context), child: Text(loc.translate('cancel'))),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isUploading ? null : _saveArtist,
                      child: _isUploading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5)) : Text(isEditing ? loc.translate('button_update') : loc.translate('button_create')),
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
