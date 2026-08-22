import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/appointment_model.dart';
import '../../models/professional_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import 'admin_appointments_screen.dart';
import 'professional_form_screen.dart';

class AdminProfessionalsScreen extends StatefulWidget {
  const AdminProfessionalsScreen({super.key});

  @override
  State<AdminProfessionalsScreen> createState() =>
      _AdminProfessionalsScreenState();
}

class _AdminProfessionalsScreenState extends State<AdminProfessionalsScreen> {
  bool _checkingAccess = true;
  bool _isAdmin = false;
  String? _selectedCategory;
  String _searchText = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkAdminAccess();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _checkAdminAccess() async {
    final auth = context.read<AuthService>();
    final firestore = context.read<FirestoreService>();
    final uid = auth.currentUser?.uid;

    if (uid == null) {
      if (!mounted) return;
      setState(() => _checkingAccess = false);
      return;
    }

    try {
      final admin = await firestore.isUserAdmin(uid);
      if (!mounted) return;
      setState(() {
        _isAdmin = admin;
        _checkingAccess = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _checkingAccess = false);
    }
  }

  List<ProfessionalModel> _filteredProfessionals(
    List<ProfessionalModel> professionals,
  ) {
    final query = _searchText.trim().toLowerCase();

    return professionals.where((professional) {
      final matchesCategory = _selectedCategory == null ||
          professional.category == _selectedCategory;
      final matchesSearch = query.isEmpty ||
          professional.fullName.toLowerCase().contains(query) ||
          professional.category.toLowerCase().contains(query) ||
          professional.location.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _openForm({ProfessionalModel? professional}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProfessionalFormScreen(professional: professional),
      ),
    );
  }

  void _openAppointmentReview() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const AdminAppointmentsScreen(),
      ),
    );
  }

  Future<void> _confirmDelete(ProfessionalModel professional) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete professional?'),
        content: Text(
          'Remove ${professional.fullName} from the directory? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await context.read<FirestoreService>().deleteProfessional(professional.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${professional.fullName} deleted.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not delete. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingAccess) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin')),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Text(
              'You do not have admin access to manage the directory.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final firestore = context.watch<FirestoreService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage professionals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.event_note_outlined),
            tooltip: 'Review appointment requests',
            onPressed: _openAppointmentReview,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add', style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: StreamBuilder<List<ProfessionalModel>>(
          stream: firestore.allProfessionals(),
          builder: (context, professionalSnapshot) {
            if (professionalSnapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (professionalSnapshot.hasError) {
              return _buildErrorState();
            }

            final allProfessionals =
                professionalSnapshot.data ?? const <ProfessionalModel>[];
            final professionals = _filteredProfessionals(allProfessionals);

            return StreamBuilder<List<AppointmentModel>>(
              stream: firestore.allAppointmentsForAdmin(),
              builder: (context, appointmentSnapshot) {
                final pendingCount = (appointmentSnapshot.data ??
                        const <AppointmentModel>[])
                    .where((appointment) => appointment.status == 'pending')
                    .length;

                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
                  children: [
                    _buildAdminHero(
                      professionalCount: allProfessionals.length,
                      pendingCount: pendingCount,
                    ),
                    const SizedBox(height: 18),
                    _buildManagementTabs(pendingCount),
                    const SizedBox(height: 14),
                    _buildSearchField(),
                    const SizedBox(height: 12),
                    _buildCategoryFilters(),
                    const SizedBox(height: 18),
                    Text(
                      'Directory listings',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    if (allProfessionals.isEmpty)
                      _buildEmptyState()
                    else if (professionals.isEmpty)
                      _buildNoMatchesState()
                    else
                      ...professionals.map(_buildProfessionalCard),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildAdminHero({
    required int professionalCount,
    required int pendingCount,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradientLight,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ADMIN WORKSPACE',
            style: TextStyle(
              color: Color(0xFF806B59),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$professionalCount professional${professionalCount == 1 ? '' : 's'}',
            style: const TextStyle(
              color: AppTheme.textDark,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '$pendingCount appointment request${pendingCount == 1 ? '' : 's'} pending review',
            style: const TextStyle(
              color: Color(0xFF59646F),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagementTabs(int pendingCount) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 13),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Text(
              'Professionals',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: InkWell(
            onTap: _openAppointmentReview,
            borderRadius: BorderRadius.circular(17),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 13),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(17),
                border: Border.all(
                  color: AppTheme.surfaceBorder.withValues(alpha: 0.78),
                ),
              ),
              child: Text(
                'Requests${pendingCount > 0 ? ' ($pendingCount)' : ''}',
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: (value) => setState(() => _searchText = value),
      decoration: InputDecoration(
        hintText: 'Search listings',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: _searchText.isEmpty
            ? null
            : IconButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchText = '');
                },
                icon: const Icon(Icons.close_rounded),
              ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _AdminFilter(
            label: 'All',
            selected: _selectedCategory == null,
            onTap: () => setState(() => _selectedCategory = null),
          ),
          ...professionalCategories.map(
            (category) => _AdminFilter(
              label: category,
              selected: _selectedCategory == category,
              onTap: () => setState(() => _selectedCategory = category),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalCard(ProfessionalModel professional) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(21),
          border: Border.all(
            color: AppTheme.surfaceBorder.withValues(alpha: 0.78),
          ),
        ),
        child: Row(
          children: [
            _AdminAvatar(photoUrl: professional.photoUrl),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    professional.fullName,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    professional.category,
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (professional.location.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      professional.location,
                      style: const TextStyle(
                        color: AppTheme.textLight,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              onPressed: () => _openForm(professional: professional),
              icon: const Icon(Icons.edit_outlined),
              color: AppTheme.primary,
              tooltip: 'Edit',
            ),
            IconButton(
              onPressed: () => _confirmDelete(professional),
              icon: const Icon(Icons.delete_outline_rounded),
              color: AppTheme.danger,
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.all(32),
      child: Text(
        'No professionals yet. Tap Add to create the first listing.',
        textAlign: TextAlign.center,
        style: TextStyle(color: AppTheme.textLight),
      ),
    );
  }

  Widget _buildNoMatchesState() {
    return const Padding(
      padding: EdgeInsets.all(32),
      child: Text(
        'No listings match this search or category.',
        textAlign: TextAlign.center,
        style: TextStyle(color: AppTheme.textLight),
      ),
    );
  }

  Widget _buildErrorState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'The directory could not load right now. Check your connection and try again.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.danger),
        ),
      ),
    );
  }
}

class _AdminFilter extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _AdminFilter({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        selectedColor: AppTheme.primary.withValues(alpha: 0.18),
        labelStyle: TextStyle(
          color: selected ? AppTheme.primary : AppTheme.textDark,
          fontSize: 12,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        ),
        side: BorderSide(
          color: selected
              ? AppTheme.primary
              : AppTheme.surfaceBorder.withValues(alpha: 0.78),
        ),
        onSelected: (_) => onTap(),
      ),
    );
  }
}

class _AdminAvatar extends StatelessWidget {
  final String photoUrl;

  const _AdminAvatar({required this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(29),
      child: Container(
        width: 58,
        height: 58,
        color: AppTheme.primary.withValues(alpha: 0.12),
        child: photoUrl.isEmpty
            ? const Icon(Icons.person, color: AppTheme.primary, size: 28)
            : Image.network(
                photoUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.person,
                  color: AppTheme.primary,
                  size: 28,
                ),
              ),
      ),
    );
  }
}
