import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/professional_model.dart';
import '../../services/firestore_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';

class ProfessionalFormScreen extends StatefulWidget {
  final ProfessionalModel? professional;

  const ProfessionalFormScreen({super.key, this.professional});

  @override
  State<ProfessionalFormScreen> createState() =>
      _ProfessionalFormScreenState();
}

class _ProfessionalFormScreenState extends State<ProfessionalFormScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _bioController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _photoUrlController;
  late final TextEditingController _locationController;

  int _currentStep = 0;
  String? _selectedCategory;
  bool _offersOnline = false;
  bool _offersPhysical = false;
  bool _isSaving = false;
  String? _errorText;

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

  bool _canContinue() {
    if (_currentStep == 0) {
      return _nameController.text.trim().isNotEmpty &&
          _selectedCategory != null;
    }
    if (_currentStep == 1) {
      return _offersOnline || _offersPhysical;
    }
    return true;
  }

  void _nextStep() {
    setState(() => _errorText = null);

    if (!_canContinue()) {
      setState(() {
        _errorText = _currentStep == 0
            ? 'Add a name and choose a professional category.'
            : 'Choose at least one session type.';
      });
      return;
    }

    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      _handleSave();
    }
  }

  void _previousStep() {
    if (_currentStep == 0) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _currentStep--;
        _errorText = null;
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_canContinue()) {
      setState(() {
        _errorText = 'Complete the required listing details first.';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorText = null;
    });

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
      final firestore = context.read<FirestoreService>();
      if (_isEditing) {
        await firestore.updateProfessional(model);
      } else {
        await firestore.addProfessional(model);
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
      setState(() {
        _isSaving = false;
        _errorText = 'Could not save this listing. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit professional' : 'Add professional'),
        leading: IconButton(
          onPressed: _isSaving ? null : _previousStep,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildIntro(),
                    const SizedBox(height: 22),
                    if (_currentStep == 0) _buildIdentityStep(),
                    if (_currentStep == 1) _buildAvailabilityStep(),
                    if (_currentStep == 2) _buildReviewStep(),
                    if (_errorText != null) ...[
                      const SizedBox(height: 15),
                      Text(
                        _errorText!,
                        style: const TextStyle(
                          color: AppTheme.danger,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: List.generate(3, (index) {
          final active = index <= _currentStep;
          return Expanded(
            child: Container(
              height: 5,
              margin: EdgeInsets.only(right: index == 2 ? 0 : 7),
              decoration: BoxDecoration(
                color: active
                    ? AppTheme.primary
                    : AppTheme.surfaceBorder.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildIntro() {
    final stepLabel = switch (_currentStep) {
      0 => 'ABOUT THE PERSON',
      1 => 'AVAILABILITY AND CONTACT',
      _ => 'FINAL REVIEW',
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradientLight,
        borderRadius: BorderRadius.circular(27),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stepLabel,
            style: const TextStyle(
              color: Color(0xFF806B59),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 11),
          Text(
            _currentStep == 0
                ? 'Who will users be contacting?'
                : _currentStep == 1
                    ? 'How can users reach them?'
                    : 'Check the listing before saving.',
            style: const TextStyle(
              color: AppTheme.textDark,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            _currentStep == 0
                ? 'Use details that have been checked before publishing.'
                : _currentStep == 1
                    ? 'Give users clear information about the available options.'
                    : 'This listing will appear in the professional directory after saving.',
            style: const TextStyle(
              color: Color(0xFF59646F),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdentityStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _nameController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Full name'),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _selectedCategory,
          decoration: const InputDecoration(labelText: 'Professional category'),
          items: professionalCategories
              .map((category) => DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  ))
              .toList(),
          onChanged: (value) => setState(() => _selectedCategory = value),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _bioController,
          maxLines: 5,
          maxLength: 400,
          decoration: const InputDecoration(
            labelText: 'Short bio (optional)',
            alignLabelWithHint: true,
            hintText: 'What should a user know before reaching out?',
          ),
        ),
      ],
    );
  }

  Widget _buildAvailabilityStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Session types',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        _ToggleChoice(
          title: 'Online sessions',
          subtitle: 'Users can request a remote session.',
          icon: Icons.videocam_outlined,
          selected: _offersOnline,
          onTap: () => setState(() => _offersOnline = !_offersOnline),
        ),
        const SizedBox(height: 10),
        _ToggleChoice(
          title: 'In-person sessions',
          subtitle: 'Users can request a physical session.',
          icon: Icons.place_outlined,
          selected: _offersPhysical,
          onTap: () => setState(() => _offersPhysical = !_offersPhysical),
        ),
        const SizedBox(height: 18),
        TextFormField(
          controller: _locationController,
          decoration: const InputDecoration(
            labelText: 'Location (optional for online-only)',
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'Contact email'),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(labelText: 'Contact phone'),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _photoUrlController,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(
            labelText: 'Photo URL (optional)',
            hintText: 'Paste an image link',
          ),
        ),
        const SizedBox(height: 7),
        const Text(
          'Only publish contact details that the professional has agreed to share.',
          style: TextStyle(color: AppTheme.textLight, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildReviewStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ReviewRow(label: 'Name', value: _nameController.text.trim()),
        _ReviewRow(label: 'Category', value: _selectedCategory ?? 'Not chosen'),
        _ReviewRow(
          label: 'Sessions',
          value: [
            if (_offersOnline) 'Online',
            if (_offersPhysical) 'In person',
          ].join(' · '),
        ),
        _ReviewRow(
          label: 'Location',
          value: _locationController.text.trim().isEmpty
              ? 'Not listed'
              : _locationController.text.trim(),
        ),
        _ReviewRow(
          label: 'Contact',
          value: _emailController.text.trim().isNotEmpty
              ? _emailController.text.trim()
              : _phoneController.text.trim().isNotEmpty
                  ? _phoneController.text.trim()
                  : 'No direct contact listed',
        ),
        const SizedBox(height: 15),
        const Text(
          'Before saving, confirm that the information is accurate and that the professional has agreed to be listed.',
          style: TextStyle(
            color: AppTheme.textLight,
            fontSize: 13,
            height: 1.45,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _nextStep,
            child: _isSaving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(_currentStep == 2 ? 'Save listing' : 'Continue'),
          ),
        ),
      ),
    );
  }
}

class _ToggleChoice extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleChoice({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primary.withValues(alpha: 0.13)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppTheme.primary
                : AppTheme.surfaceBorder.withValues(alpha: 0.78),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? AppTheme.primary : AppTheme.textLight,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppTheme.textLight,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded, color: AppTheme.primary),
          ],
        ),
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReviewRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      margin: const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: AppTheme.surfaceBorder.withValues(alpha: 0.78),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(color: AppTheme.textLight, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'Not listed' : value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
