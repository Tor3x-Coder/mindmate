import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/professional_model.dart';
import '../../services/firestore_service.dart';
import '../../utils/app_theme.dart';
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
  String? _selectedNeed;

  // These are support needs, not diagnoses. They only help narrow the
  // directory using the categories already stored on ProfessionalModel.
  static const Map<String, List<String>> _needCategories = {
    'Stress': ['Counselor', 'Psychologist'],
    'Relationships': ['Counselor', 'Psychologist'],
    'Sleep': ['Counselor', 'Psychologist', 'Psychiatrist', 'General Practitioner'],
  };

  List<ProfessionalModel> _filterProfessionals(
    List<ProfessionalModel> all,
  ) {
    final need = _selectedNeed;
    if (need == null) return all;

    final categories = _needCategories[need] ?? const <String>[];
    return all
        .where((professional) => categories.contains(professional.category))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = context.watch<FirestoreService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find support'),
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
            _buildIntro(),
            const SizedBox(height: 14),
            _buildNeedChoices(),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<List<ProfessionalModel>>(
                stream: firestoreService.allProfessionals(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return _buildEmptyState(
                      icon: Icons.cloud_off_outlined,
                      title: 'Support is unavailable right now',
                      message:
                          'Check your connection and try opening the directory again.',
                    );
                  }

                  final all = snapshot.data ?? const <ProfessionalModel>[];
                  final professionals = _filterProfessionals(all);

                  if (all.isEmpty) {
                    return _buildEmptyState(
                      icon: Icons.people_outline_rounded,
                      title: 'No professionals yet',
                      message:
                          'The directory is empty for now. Listings added by the admin will appear here.',
                    );
                  }

                  if (professionals.isEmpty) {
                    return _buildEmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'No matches yet',
                      message:
                          'There are no listed professionals for this need yet. Browse everyone or try another option.',
                      action: TextButton(
                        onPressed: () => setState(() => _selectedNeed = null),
                        child: const Text('Browse everyone'),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
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

  Widget _buildIntro() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradientLight,
        borderRadius: BorderRadius.circular(28),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'START HERE',
            style: TextStyle(
              color: Color(0xFF59646F),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 11),
          Text(
            'What kind of support do you want?',
            style: TextStyle(
              color: AppTheme.textDark,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Choose a reason, not a diagnosis. MindMate helps you connect — it does not confirm bookings automatically.',
            style: TextStyle(
              color: Color(0xFF59646F),
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNeedChoices() {
    return SizedBox(
      height: 66,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: _needCategories.keys.map((need) {
          final selected = _selectedNeed == need;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(need),
              selected: selected,
              onSelected: (_) => setState(() {
                _selectedNeed = selected ? null : need;
              }),
              selectedColor: AppTheme.primary.withValues(alpha: 0.18),
              labelStyle: TextStyle(
                color: selected ? AppTheme.primary : AppTheme.textDark,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
              ),
              side: BorderSide(
                color: selected
                    ? AppTheme.primary
                    : AppTheme.surfaceBorder.withValues(alpha: 0.8),
              ),
              backgroundColor: Theme.of(context).colorScheme.surface,
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
    Widget? action,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 56,
              color: AppTheme.textLight.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textLight,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            if (action != null) ...[
              const SizedBox(height: 10),
              action,
            ],
          ],
        ),
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
    final hasContact = professional.contactEmail.isNotEmpty ||
        professional.contactPhone.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppTheme.surfaceBorder.withValues(alpha: 0.78),
            ),
          ),
          child: Row(
            children: [
              _Avatar(photoUrl: professional.photoUrl, size: 58),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      professional.fullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      professional.category,
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
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
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (professional.offersOnline)
                          const _AvailabilityTag(label: 'Online'),
                        if (professional.offersPhysical)
                          const _AvailabilityTag(label: 'In person'),
                        if (hasContact)
                          const _AvailabilityTag(label: 'Contact listed'),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textLight,
              ),
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
          fontWeight: FontWeight.w600,
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
