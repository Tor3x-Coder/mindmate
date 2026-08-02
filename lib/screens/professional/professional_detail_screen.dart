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
      appBar: AppBar(
        title: const Text('Professional Profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    _LargeAvatar(photoUrl: professional.photoUrl),
                    const SizedBox(height: 16),
                    Text(
                      professional.fullName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      professional.category,
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (professional.location.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        professional.location,
                        style: const TextStyle(
                          color: AppTheme.textLight,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Availability
              const Text(
                'Availability',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
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
              const SizedBox(height: 24),

              // Bio
              if (professional.bio.isNotEmpty) ...[
                const Text(
                  'About',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  professional.bio,
                  style: const TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Contact
              const Text(
                'Contact',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              if (professional.contactEmail.isNotEmpty)
                _ContactRow(
                  icon: Icons.email_outlined,
                  value: professional.contactEmail,
                ),
              if (professional.contactPhone.isNotEmpty)
                _ContactRow(
                  icon: Icons.phone_outlined,
                  value: professional.contactPhone,
                ),
              if (professional.contactEmail.isEmpty &&
                  professional.contactPhone.isEmpty)
                const Text(
                  'No contact details listed yet.',
                  style: TextStyle(color: AppTheme.textLight, fontSize: 14),
                ),

              const SizedBox(height: 28),
              if (_canRequest)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AppointmentRequestScreen(
                            professional: professional,
                          ),
                        ),
                      );
                    },
                    child: const Text('Request Appointment'),
                  ),
                ),
              if (_canRequest) const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.secondary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'MindMate helps you find support — it does not diagnose conditions or confirm bookings. A request starts as pending until someone reviews it.',
                  style: TextStyle(
                    color: AppTheme.textLight,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LargeAvatar extends StatelessWidget {
  final String photoUrl;

  const _LargeAvatar({required this.photoUrl});

  @override
  Widget build(BuildContext context) {
    const size = 100.0;
    return ClipRRect(
      borderRadius: BorderRadius.circular(size / 2),
      child: Container(
        width: size,
        height: size,
        color: AppTheme.primary.withValues(alpha: 0.12),
        child: photoUrl.isEmpty
            ? const Icon(Icons.person, color: AppTheme.primary, size: 48)
            : Image.network(
                photoUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.person,
                  color: AppTheme.primary,
                  size: 48,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: active
            ? AppTheme.primary.withValues(alpha: 0.1)
            : AppTheme.textLight.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            active ? label : 'Not offered',
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w500,
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
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
