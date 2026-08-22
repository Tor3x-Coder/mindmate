import 'package:flutter/material.dart';
import '../../models/professional_model.dart';
import '../../utils/app_theme.dart';
import 'appointment_request_screen.dart';

class ProfessionalDetailScreen extends StatelessWidget {
  final ProfessionalModel professional;

  const ProfessionalDetailScreen({
    super.key,
    required this.professional,
  });

  bool get _canRequest =>
      professional.offersOnline || professional.offersPhysical;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Professional profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProfileHero(),
              const SizedBox(height: 22),
              const Text(
                'Available sessions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 9,
                runSpacing: 9,
                children: [
                  _InfoChip(
                    icon: Icons.videocam_outlined,
                    label: 'Online sessions',
                    active: professional.offersOnline,
                  ),
                  _InfoChip(
                    icon: Icons.place_outlined,
                    label: 'In-person sessions',
                    active: professional.offersPhysical,
                  ),
                ],
              ),
              if (professional.bio.isNotEmpty) ...[
                const SizedBox(height: 22),
                _buildSectionCard(
                  title: 'About',
                  child: Text(
                    professional.bio,
                    style: const TextStyle(
                      color: AppTheme.textLight,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              _buildContactCard(),
              const SizedBox(height: 20),
              if (_canRequest)
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AppointmentRequestScreen(
                          professional: professional,
                        ),
                      ),
                    );
                  },
                  child: const Text('Request a session'),
                ),
              if (!_canRequest)
                const _UnavailableCard(),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: AppTheme.secondary.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Text(
                  'This sends a request only. It is not an instant booking. The request stays pending until it is reviewed.',
                  style: TextStyle(
                    color: AppTheme.textLight,
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHero() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradientLight,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          _LargeAvatar(photoUrl: professional.photoUrl),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  professional.fullName,
                  style: const TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  professional.category,
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (professional.location.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    professional.location,
                    style: const TextStyle(
                      color: Color(0xFF59646F),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: AppTheme.surfaceBorder.withValues(alpha: 0.78),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 9),
          child,
        ],
      ),
    );
  }

  Widget _buildContactCard() {
    final hasEmail = professional.contactEmail.isNotEmpty;
    final hasPhone = professional.contactPhone.isNotEmpty;

    return _buildSectionCard(
      title: 'Contact details',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasEmail)
            _ContactRow(
              icon: Icons.email_outlined,
              value: professional.contactEmail,
            ),
          if (hasPhone)
            _ContactRow(
              icon: Icons.phone_outlined,
              value: professional.contactPhone,
            ),
          if (!hasEmail && !hasPhone)
            const Text(
              'No direct contact details listed. You can still send a request through MindMate.',
              style: TextStyle(
                color: AppTheme.textLight,
                fontSize: 13,
                height: 1.4,
              ),
            ),
        ],
      ),
    );
  }
}

class _LargeAvatar extends StatelessWidget {
  final String photoUrl;

  const _LargeAvatar({required this.photoUrl});

  @override
  Widget build(BuildContext context) {
    const size = 86.0;
    return ClipRRect(
      borderRadius: BorderRadius.circular(size / 2),
      child: Container(
        width: size,
        height: size,
        color: Colors.white.withValues(alpha: 0.65),
        child: photoUrl.isEmpty
            ? const Icon(Icons.person, color: AppTheme.primary, size: 42)
            : Image.network(
                photoUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.person,
                  color: AppTheme.primary,
                  size: 42,
                ),
              ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? AppTheme.primary : AppTheme.textLight;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: active
            ? AppTheme.primary.withValues(alpha: 0.10)
            : AppTheme.textLight.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: color),
          const SizedBox(width: 7),
          Text(
            active ? label : 'Not offered',
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String value;

  const _ContactRow({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Icon(icon, size: 19, color: AppTheme.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}

class _UnavailableCard extends StatelessWidget {
  const _UnavailableCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppTheme.surfaceAlt.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Text(
        'This professional has no session type listed yet.',
        textAlign: TextAlign.center,
        style: TextStyle(color: AppTheme.textLight, fontSize: 13),
      ),
    );
  }
}
