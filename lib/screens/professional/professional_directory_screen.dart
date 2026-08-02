import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/professional_model.dart';
import '../../services/firestore_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import 'professional_detail_screen.dart';
import 'my_appointments_screen.dart';

class ProfessionalDirectoryScreen extends StatefulWidget {
  const ProfessionalDirectoryScreen({super.key});

  @override
  State<ProfessionalDirectoryScreen> createState() =>
      _ProfessionalDirectoryScreenState();
}

class _ProfessionalDirectoryScreenState
    extends State<ProfessionalDirectoryScreen> {
  // null means "show everyone" — no category filter applied.
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final firestoreService = context.watch<FirestoreService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Professional Support'),
        actions: [
          IconButton(
            icon: const Icon(Icons.event_note_outlined),
            tooltip: 'My Requests',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const MyAppointmentsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(
                'Find a professional who can support you. MindMate only helps you connect — it does not diagnose or book appointments automatically.',
                style: TextStyle(color: AppTheme.textLight, fontSize: 13),
              ),
            ),
            const SizedBox(height: 12),
            _buildCategoryFilters(),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<List<ProfessionalModel>>(
                stream: firestoreService.allProfessionals(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'ERROR: ${snapshot.error}',
                          style:
                              const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    );
                  }

                  final all = snapshot.data ?? [];
                  final professionals = _selectedCategory == null
                      ? all
                      : all
                          .where((p) => p.category == _selectedCategory)
                          .toList();

                  if (all.isEmpty) {
                    return _buildEmptyState(
                      title: 'No professionals yet',
                      message:
                          'The directory is empty for now. Once entries are added (via the admin tools or Firebase console), they will show up here.',
                    );
                  }

                  if (professionals.isEmpty) {
                    return _buildEmptyState(
                      title: 'No matches',
                      message:
                          'No professionals in this category yet. Try another filter.',
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: professionals.length,
                    itemBuilder: (context, index) {
                      return _ProfessionalCard(
                        professional: professionals[index],
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ProfessionalDetailScreen(
                                professional: professionals[index],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _FilterChip(
            label: 'All',
            selected: _selectedCategory == null,
            onTap: () => setState(() => _selectedCategory = null),
          ),
          ...professionalCategories.map(
            (category) => _FilterChip(
              label: category,
              selected: _selectedCategory == category,
              onTap: () => setState(() => _selectedCategory = category),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({required String title, required String message}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.people_outline,
              size: 56,
              color: AppTheme.textLight.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textLight, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
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
        onSelected: (_) => onTap(),
        selectedColor: AppTheme.primary.withValues(alpha: 0.2),
        labelStyle: TextStyle(
          color: selected ? AppTheme.primary : AppTheme.textDark,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          fontSize: 13,
        ),
        side: BorderSide(
          color: selected
              ? AppTheme.primary
              : AppTheme.textLight.withValues(alpha: 0.3),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        showCheckmark: false,
      ),
    );
  }
}

class _ProfessionalCard extends StatelessWidget {
  final ProfessionalModel professional;
  final VoidCallback onTap;

  const _ProfessionalCard({
    required this.professional,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
             color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.textLight.withValues(alpha: 0.15),
            ),
          ),
          child: Row(
            children: [
              _Avatar(photoUrl: professional.photoUrl, size: 52),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      professional.fullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      professional.category,
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (professional.location.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        professional.location,
                        style: const TextStyle(
                          color: AppTheme.textLight,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      children: [
                        if (professional.offersOnline)
                          const _AvailabilityTag(label: 'Online'),
                        if (professional.offersPhysical)
                          const _AvailabilityTag(label: 'In person'),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppTheme.textLight),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvailabilityTag extends StatelessWidget {
  final String label;

  const _AvailabilityTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.secondary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          color: AppTheme.secondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String photoUrl;
  final double size;

  const _Avatar({required this.photoUrl, required this.size});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size / 2),
      child: Container(
        width: size,
        height: size,
        color: AppTheme.primary.withValues(alpha: 0.12),
        child: photoUrl.isEmpty
            ? Icon(Icons.person, color: AppTheme.primary, size: size * 0.5)
            : Image.network(
                photoUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.person,
                  color: AppTheme.primary,
                  size: size * 0.5,
                ),
              ),
      ),
    );
  }
}
