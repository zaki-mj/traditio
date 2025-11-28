import 'package:flutter/material.dart';
import '../models/place.dart';
import '../l10n/app_localizations.dart';

class PlaceFormPage extends StatefulWidget {
  final Place? place; // null if creating, non-null if editing

  const PlaceFormPage({super.key, this.place});

  @override
  State<PlaceFormPage> createState() => _PlaceFormPageState();
}

class _PlaceFormPageState extends State<PlaceFormPage> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _facebookController;
  late TextEditingController _instagramController;
  late TextEditingController _twitterController;
  late TextEditingController _imageUrlController;
  late TextEditingController _ratingController;
  late String _selectedType;

  @override
  void initState() {
    super.initState();
    final place = widget.place;

    _nameController = TextEditingController(text: place?.name ?? '');
    _descriptionController = TextEditingController(text: place?.description ?? '');
    _locationController = TextEditingController(text: place?.location ?? '');
    _phoneController = TextEditingController(text: place?.phone ?? '');
    _emailController = TextEditingController(text: place?.email ?? '');
    _addressController = TextEditingController(text: place?.address ?? '');
    _facebookController = TextEditingController(text: place?.facebookUrl ?? '');
    _instagramController = TextEditingController(text: place?.instagramUrl ?? '');
    _twitterController = TextEditingController(text: place?.twitterUrl ?? '');
    _imageUrlController = TextEditingController(text: place?.imageUrl ?? '');
    _ratingController = TextEditingController(text: place?.rating.toString() ?? '4.0');
    _selectedType = place?.type ?? 'hotel';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _facebookController.dispose();
    _instagramController.dispose();
    _twitterController.dispose();
    _imageUrlController.dispose();
    _ratingController.dispose();
    super.dispose();
  }

  void _savePlace() {
    if (_nameController.text.isEmpty || _descriptionController.text.isEmpty || _locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations(Localizations.localeOf(context)).translate('please_fill_required_fields'))));
      return;
    }

    final rating = double.tryParse(_ratingController.text) ?? 4.0;

    // Build the place object to save
    // TODO: Use newPlace with provider add/update methods when implemented
    Place(
      id: widget.place?.id ?? 'p_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text,
      description: _descriptionController.text,
      type: _selectedType,
      location: _locationController.text,
      imageUrl: _imageUrlController.text.isNotEmpty ? _imageUrlController.text : 'https://picsum.photos/seed/${_nameController.text.replaceAll(' ', '_')}/600/400',
      rating: rating,
      phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
      email: _emailController.text.isNotEmpty ? _emailController.text : null,
      address: _addressController.text.isNotEmpty ? _addressController.text : null,
      facebookUrl: _facebookController.text.isNotEmpty ? _facebookController.text : null,
      instagramUrl: _instagramController.text.isNotEmpty ? _instagramController.text : null,
      twitterUrl: _twitterController.text.isNotEmpty ? _twitterController.text : null,
    );

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.place == null ? AppLocalizations(Localizations.localeOf(context)).translate('place_created_successfully') : AppLocalizations(Localizations.localeOf(context)).translate('place_updated_successfully'))));

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations(Localizations.localeOf(context));
    final theme = Theme.of(context);
    final isEditing = widget.place != null;
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
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: loc.translate('name_label'),
                      hintText: 'e.g., Old Town Hotel',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.location_city),
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
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedType,
                          decoration: InputDecoration(
                            labelText: "City",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.location_city),
                          ),
                          items: ['hotel', 'restaurant', 'attraction', 'store', 'other'].map((type) => DropdownMenuItem(value: type, child: Text(loc.translate('type_$type')))).toList(),
                          onChanged: (value) {
                            setState(() => _selectedType = value ?? 'hotel');
                          },
                        ),
                      ),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedType,
                          decoration: InputDecoration(
                            labelText: "wilaya",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.location_on),
                          ),
                          items: ['hotel', 'restaurant', 'attraction', 'store', 'other'].map((type) => DropdownMenuItem(value: type, child: Text(loc.translate('type_$type')))).toList(),
                          onChanged: (value) {
                            setState(() => _selectedType = value ?? 'hotel');
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
                      hintText: '+20 100 123 4567',
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
                      labelText: 'Address/Map URL',
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
