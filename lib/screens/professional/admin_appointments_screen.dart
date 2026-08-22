import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/appointment_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../utils/app_theme.dart';

class AdminAppointmentsScreen extends StatefulWidget {
  const AdminAppointmentsScreen({super.key});

  @override
  State<AdminAppointmentsScreen> createState() =>
      _AdminAppointmentsScreenState();
}

class _AdminAppointmentsScreenState extends State<AdminAppointmentsScreen> {
  bool _checkingAccess = true;
  bool _isAdmin = false;
  String? _updatingRequestId;

  @override
  void initState() {
    super.initState();
    _checkAdminAccess();
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
      final isAdmin = await firestore.isUserAdmin(uid);
      if (!mounted) return;
      setState(() {
        _isAdmin = isAdmin;
        _checkingAccess = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _checkingAccess = false);
    }
  }

  Future<void> _updateStatus(
    AppointmentModel appointment,
    String status,
  ) async {
    setState(() => _updatingRequestId = appointment.id);

    try {
      await context.read<FirestoreService>().updateAppointmentStatus(
            appointment.id,
            status,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request marked ${_statusLabel(status)}.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update this request.')),
      );
    } finally {
      if (mounted) setState(() => _updatingRequestId = null);
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'approved':
        return 'approved';
      case 'declined':
        return 'declined';
      default:
        return 'pending';
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
        appBar: AppBar(title: const Text('Appointment review')),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Text(
              'You do not have admin access to review appointment requests.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final firestore = context.watch<FirestoreService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Appointment review')),
      body: SafeArea(
        child: StreamBuilder<List<AppointmentModel>>(
          stream: firestore.allAppointmentsForAdmin(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Appointment requests could not load right now. Check the connection and try again.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.danger),
                  ),
                ),
              );
            }

            final appointments = snapshot.data ?? const <AppointmentModel>[];
            final pending = appointments
                .where((appointment) => appointment.status == 'pending')
                .toList();
            final reviewed = appointments
                .where((appointment) => appointment.status != 'pending')
                .toList();

            if (appointments.isEmpty) return _buildEmptyState();

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              children: [
                _buildQueueSummary(pending.length),
                const SizedBox(height: 22),
                if (pending.isNotEmpty) ...[
                  const Text(
                    'Requests needing review',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  ...pending.map(_buildPendingCard),
                ],
                if (reviewed.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  const Text(
                    'Recently reviewed',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  ...reviewed.map(_buildReviewedCard),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildQueueSummary(int pendingCount) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradientLight,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PENDING QUEUE',
                  style: TextStyle(
                    color: Color(0xFF806B59),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '$pendingCount request${pendingCount == 1 ? '' : 's'} need review',
                  style: const TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Review the details before approving or declining.',
                  style: TextStyle(
                    color: Color(0xFF59646F),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.65),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$pendingCount',
              style: const TextStyle(
                color: AppTheme.primary,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingCard(AppointmentModel appointment) {
    final isUpdating = _updatingRequestId == appointment.id;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppTheme.primary.withValues(alpha: 0.45),
            width: 1.4,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    appointment.professionalName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const _StatusPill(
                  label: 'Pending',
                  color: AppTheme.secondary,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${appointment.consultationType} · ${appointment.preferredDate} at ${appointment.preferredTime}',
              style: const TextStyle(
                color: AppTheme.textLight,
                fontSize: 13,
              ),
            ),
            if (appointment.note.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                appointment.note,
                style: const TextStyle(fontSize: 13, height: 1.35),
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isUpdating
                        ? null
                        : () => _updateStatus(appointment, 'declined'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.danger,
                      side: BorderSide(
                        color: AppTheme.danger.withValues(alpha: 0.55),
                      ),
                    ),
                    child: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isUpdating
                        ? null
                        : () => _updateStatus(appointment, 'approved'),
                    child: isUpdating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Approve'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewedCard(AppointmentModel appointment) {
    final approved = appointment.status == 'approved';
    final color = approved ? AppTheme.success : AppTheme.danger;

    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: AppTheme.surfaceBorder.withValues(alpha: 0.78),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.professionalName,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  '${appointment.consultationType} · ${appointment.preferredDate}',
                  style: const TextStyle(
                    color: AppTheme.textLight,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          _StatusPill(
            label: approved ? 'Approved' : 'Declined',
            color: color,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Text(
          'No appointment requests yet.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.textLight),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
