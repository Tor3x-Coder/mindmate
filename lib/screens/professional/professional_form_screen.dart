import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/professional_model.dart';
import '../../services/firestore_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';

class ProfessionalFormScreen extends StatefulWidget {
  // null = adding a new professional; non-null = editing an existing one.
  final ProfessionalModel? professional;

  const ProfessionalFormScreen({super.key, this.professional});

  @override
  State<ProfessionalFormScreen> createState() =>
      _ProfessionalFormScreenState();
}

class _ProfessionalFormScreenState extends State<ProfessionalFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _bioController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _photoUrlController;
  late final TextEditingController _locationController;

  String? _selectedCategory;
  bool _offersOnline = false;
  bool _offersPhysical = false;
  bool _isSaving = false;

  bool get _isEditing => widget.professional != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.professional;
    _nameController = TextEditingController(text: existing?.fullName ?? '');
    _bioController = TextEditingController(text: existing?.bio ?? '');
    _emailController =
        TextEditingController(text: existing?.contactEmail ?? '');
    _phoneController =
        TextEditingController(text: existing?.contactPhone ?? '');
    _photoUrlController =
        TextEditingController(text: existing?.photoUrl ?? '');
    _locationController =
        TextEditingController(text: existing?.location ?? '');
    _selectedCategory = existing?.category;
    _offersOnline = existing?.offersOnline ?? false;
    _offersPhysical = existing?.offersPhysical ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _photoUrlController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a category.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final model = ProfessionalModel(
      id: widget.professional?.id ?? '',
      fullName: _nameController.text.trim(),
      category: _selectedCategory!,
      bio: _bioController.text.trim(),
      contactEmail: _emailController.text.trim(),
      contactPhone: _phoneController.text.trim(),
      photoUrl: _photoUrlController.text.trim(),
      offersOnline: _offersOnline,
      offersPhysical: _offersPhysical,
      location: _locationController.text.trim(),
    );

    try {
      final firestoreService = context.read<FirestoreService>();
      if (_isEditing) {
        await firestoreService.updateProfessional(model);
      } else {
        await firestoreService.addProfessional(model);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Professional updated.'
                : 'Professional added to the directory.',
          ),
        ),
      );
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Professional' : 'Add Professional'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Please enter a name'
                      : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: professionalCategories
                      .map(
                        (c) => DropdownMenuItem(value: c, child: Text(c)),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _selectedCategory = value),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _bioController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Bio',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration:
                      const InputDecoration(labelText: 'Contact Email'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration:
                      const InputDecoration(labelText: 'Contact Phone'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(labelText: 'Location'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _photoUrlController,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: 'Photo URL',
                    hintText: 'Paste an image link (optional)',
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Photos are not uploaded to Firebase — paste a free image hosting URL instead.',
                  style: TextStyle(color: AppTheme.textLight, fontSize: 12),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Offers online sessions'),
                  value: _offersOnline,
                  activeThumbColor: AppTheme.primary,
                  onChanged: (value) =>
                      setState(() => _offersOnline = value),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Offers in-person sessions'),
                  value: _offersPhysical,
                  activeThumbColor: AppTheme.primary,
                  onChanged: (value) =>
                      setState(() => _offersPhysical = value),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isSaving ? null : _handleSave,
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(_isEditing ? 'Save Changes' : 'Add Professional'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
