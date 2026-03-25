import 'package:flutter/material.dart';
import 'package:traditional_gems/services/location_services.dart';
import '../models/artist.dart';
import '../services/firebase_services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ArtistFormPage extends StatefulWidget {
  final Artist? artist;
  const ArtistFormPage({super.key, this.artist});

  @override
  State<ArtistFormPage> createState() => _ArtistFormPageState();
}

class _ArtistFormPageState extends State<ArtistFormPage> {
  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _descriptionARController;
  late TextEditingController _descriptionFRController;
  late TextEditingController _descriptionENController;
  late TextEditingController _imageLink1Controller;
  late TextEditingController _imageLink2Controller;
  late TextEditingController _imageLink3Controller;
  late TextEditingController _imageLink4Controller;
  late TextEditingController _imageLink5Controller;
  late TextEditingController _imageLink6Controller;

  // Location
  String? selectedStateCode;
  String? selectedCityName;
  String? selectedWilayaNameAR;
  String? selectedWilayaNameFR;
  String? selectedCityNameAR;
  String? selectedCityNameFR;

  List<Map<String, dynamic>> states = [];
  List<Map<String, dynamic>> cities = [];
  bool isLoadingStates = true;

  final ImagePicker _imagePicker = ImagePicker();
  List<File> _selectedImages = [];

  @override
  void initState() {
    super.initState();
    final a = widget.artist;
    _nameController = TextEditingController(text: a?.name ?? '');
    _phoneController = TextEditingController(text: a?.phone ?? '');
    _emailController = TextEditingController(text: a?.email ?? '');
    _descriptionARController = TextEditingController(text: a?.descriptionAR ?? '');
    _descriptionFRController = TextEditingController(text: a?.descriptionFR ?? '');
    _descriptionENController = TextEditingController(text: a?.descriptionEN ?? '');

    _imageLink1Controller = TextEditingController(text: a?.imageUrls != null && a!.imageUrls!.isNotEmpty ? a.imageUrls![0] : '');
    _imageLink2Controller = TextEditingController(text: a?.imageUrls != null && a!.imageUrls!.length > 1 ? a!.imageUrls![1] : '');
    _imageLink3Controller = TextEditingController(text: a?.imageUrls != null && a!.imageUrls!.length > 2 ? a!.imageUrls![2] : '');
    _imageLink4Controller = TextEditingController(text: a?.imageUrls != null && a!.imageUrls!.length > 3 ? a!.imageUrls![3] : '');
    _imageLink5Controller = TextEditingController(text: a?.imageUrls != null && a!.imageUrls!.length > 4 ? a!.imageUrls![4] : '');
    _imageLink6Controller = TextEditingController(text: a?.imageUrls != null && a!.imageUrls!.length > 5 ? a!.imageUrls![5] : '');

    if (a != null) {
      selectedStateCode = a.wilayaCode;
      selectedWilayaNameAR = a.wilayaNameAR;
      selectedWilayaNameFR = a.wilayaNameFR;
      selectedCityNameAR = a.cityNameAR;
      selectedCityNameFR = a.cityNameFR;
      selectedCityName = a.cityNameFR;
    }

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
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading states: $e')));
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
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading cities: $e')));
    }
  }

  Future<void> _pickImages() async {
    final List<XFile> pickedFiles = await _imagePicker.pickMultiImage(imageQuality: 85);
    if (pickedFiles.isEmpty) return;
    setState(() {
      _selectedImages = pickedFiles.take(6).map((x) => File(x.path)).toList();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _descriptionARController.dispose();
    _descriptionFRController.dispose();
    _descriptionENController.dispose();
    _imageLink1Controller.dispose();
    _imageLink2Controller.dispose();
    _imageLink3Controller.dispose();
    _imageLink4Controller.dispose();
    _imageLink5Controller.dispose();
    _imageLink6Controller.dispose();
    super.dispose();
  }

  Future<void> _saveArtist() async {
    // Validate required fields
    final missing = <String>[];
    if (_nameController.text.trim().isEmpty) missing.add('Name');
    if (selectedStateCode == null) missing.add('Wilaya');
    if (selectedCityName == null) missing.add('City');
    if (_phoneController.text.trim().isEmpty) missing.add('Phone');
    if (_emailController.text.trim().isEmpty) missing.add('Email');

    if (missing.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Missing: ${missing.join(', ')}'), backgroundColor: Colors.red));
      return;
    }

    final artist = Artist(
      name: _nameController.text.trim(),
      wilayaCode: selectedStateCode!,
      wilayaNameAR: selectedWilayaNameAR!,
      wilayaNameFR: selectedWilayaNameFR!,
      cityNameAR: selectedCityNameAR!,
      cityNameFR: selectedCityNameFR!,
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      descriptionAR: _descriptionARController.text.trim().isNotEmpty ? _descriptionARController.text.trim() : null,
      descriptionFR: _descriptionFRController.text.trim().isNotEmpty ? _descriptionFRController.text.trim() : null,
      descriptionEN: _descriptionENController.text.trim().isNotEmpty ? _descriptionENController.text.trim() : null,
      imageUrls: [
        if (_imageLink1Controller.text.trim().isNotEmpty) _imageLink1Controller.text.trim(),
        if (_imageLink2Controller.text.trim().isNotEmpty) _imageLink2Controller.text.trim(),
        if (_imageLink3Controller.text.trim().isNotEmpty) _imageLink3Controller.text.trim(),
        if (_imageLink4Controller.text.trim().isNotEmpty) _imageLink4Controller.text.trim(),
        if (_imageLink5Controller.text.trim().isNotEmpty) _imageLink5Controller.text.trim(),
        if (_imageLink6Controller.text.trim().isNotEmpty) _imageLink6Controller.text.trim(),
      ],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final svc = FirebaseServices();
    try {
      if (widget.artist?.id == null) {
        await svc.createArtist(artist);
      } else {
        final updated = Artist(
          id: widget.artist!.id,
          name: artist.name,
          wilayaCode: artist.wilayaCode,
          wilayaNameAR: artist.wilayaNameAR,
          wilayaNameFR: artist.wilayaNameFR,
          cityNameAR: artist.cityNameAR,
          cityNameFR: artist.cityNameFR,
          phone: artist.phone,
          email: artist.email,
          descriptionAR: artist.descriptionAR,
          descriptionFR: artist.descriptionFR,
          descriptionEN: artist.descriptionEN,
          imageUrls: artist.imageUrls,
          createdAt: widget.artist!.createdAt,
          updatedAt: DateTime.now(),
        );
        await svc.updateArtist(updated);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Artist saved'), backgroundColor: Colors.green));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.artist != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Artist' : 'Create Artist')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Photos
          Text('Photos', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SizedBox(
            height: 160,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ..._selectedImages.map(
                  (file) => Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(file, width: 200, height: 160, fit: BoxFit.cover),
                    ),
                  ),
                ),
                if (_selectedImages.length < 6)
                  GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      width: 160,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.add_a_photo_outlined), const SizedBox(height: 8), Text('${_selectedImages.length}/6')]),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Name', prefixIcon: const Icon(Icons.person)),
                  ),
                  const SizedBox(height: 12),
                  isLoadingStates
                      ? const Center(child: CircularProgressIndicator())
                      : DropdownButtonFormField<String>(
                          initialValue: selectedStateCode,
                          decoration: const InputDecoration(labelText: 'Wilaya', prefixIcon: Icon(Icons.location_on)),
                          items: states.map<DropdownMenuItem<String>>((s) => DropdownMenuItem<String>(value: s['code'] as String?, child: Text(s['nameFR'] as String? ?? ''))).toList(),
                          onChanged: (v) {
                            if (v != null) {
                              final state = states.firstWhere((s) => s['code'] == v);
                              setState(() {
                                selectedStateCode = v;
                                selectedWilayaNameAR = state['nameAR'];
                                selectedWilayaNameFR = state['nameFR'];
                              });
                              _loadCitiesForState(v);
                            }
                          },
                        ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCityName,
                    decoration: const InputDecoration(labelText: 'City', prefixIcon: Icon(Icons.location_city)),
                    items: selectedStateCode == null ? [] : cities.map<DropdownMenuItem<String>>((c) => DropdownMenuItem<String>(value: c['nameFR'] as String?, child: Text(c['nameFR'] as String? ?? ''))).toList(),
                    onChanged: selectedStateCode == null
                        ? null
                        : (v) {
                            if (v != null) {
                              final city = cities.firstWhere((c) => c['nameFR'] == v);
                              setState(() {
                                selectedCityName = v;
                                selectedCityNameAR = city['nameAR'];
                                selectedCityNameFR = city['nameFR'];
                              });
                            }
                          },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Phone', prefixIcon: Icon(Icons.phone)),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descriptionARController,
                    decoration: const InputDecoration(labelText: 'Description (Arabic)', prefixIcon: Icon(Icons.description)),
                    maxLines: 3,
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descriptionFRController,
                    decoration: const InputDecoration(labelText: 'Description (French)', prefixIcon: Icon(Icons.description)),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descriptionENController,
                    decoration: const InputDecoration(labelText: 'Description (English)', prefixIcon: Icon(Icons.description)),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  TextField(
                    controller: _imageLink1Controller,
                    decoration: const InputDecoration(labelText: 'Image Link 1', prefixIcon: Icon(Icons.link)),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _imageLink2Controller,
                    decoration: const InputDecoration(labelText: 'Image Link 2', prefixIcon: Icon(Icons.link)),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _imageLink3Controller,
                    decoration: const InputDecoration(labelText: 'Image Link 3', prefixIcon: Icon(Icons.link)),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _imageLink4Controller,
                    decoration: const InputDecoration(labelText: 'Image Link 4', prefixIcon: Icon(Icons.link)),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _imageLink5Controller,
                    decoration: const InputDecoration(labelText: 'Image Link 5', prefixIcon: Icon(Icons.link)),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _imageLink6Controller,
                    decoration: const InputDecoration(labelText: 'Image Link 6', prefixIcon: Icon(Icons.link)),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(onPressed: _saveArtist, child: Text(isEditing ? 'Update' : 'Create')),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
