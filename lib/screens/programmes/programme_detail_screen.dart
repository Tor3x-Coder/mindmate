import 'package:flutter/material.dart';

import '../../models/structured_programme_model.dart';
import '../../services/demo_entitlement_service.dart';
import '../../utils/app_theme.dart';
import 'programme_player_screen.dart';

class ProgrammeDetailScreen extends StatefulWidget {
  final StructuredProgramme programme;

  const ProgrammeDetailScreen({super.key, required this.programme});

  @override
  State<ProgrammeDetailScreen> createState() => _ProgrammeDetailScreenState();
}

class _ProgrammeDetailScreenState extends State<ProgrammeDetailScreen> {
  final DemoEntitlementService _entitlementService = DemoEntitlementService();
  bool _isUnlocked = false;
  bool _isLoading = true;
  bool _isUnlocking = false;

  @override
  void initState() {
    super.initState();
    _checkUnlocked();
  }

  Future<void> _checkUnlocked() async {
    final unlocked =
        await _entitlementService.isUnlocked(widget.programme.id);
    if (!mounted) return;
    setState(() {
      _isUnlocked = unlocked;
      _isLoading = false;
    });
  }

  Future<void> _simulateUnlock() async {
    // Show confirmation dialog that explains demo nature
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Simulate demo unlock?'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This is a competition-only demonstration.',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 10),
            Text(
              '• No bank details will be requested\n'
              '• No payment provider (Paystack etc) will be called\n'
              '• No money will be charged\n'
              '• Access is stored locally on this device only\n'
              '• You can clear it anytime from settings',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
            SizedBox(height: 12),
            Text(
              'You will see: “Demo access unlocked — no payment was processed.”',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: AppTheme.textLight,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Simulate unlock'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isUnlocking = true);
    await _entitlementService.unlock(widget.programme.id);
    if (!mounted) return;
    setState(() {
      _isUnlocked = true;
      _isUnlocking = false;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Demo access unlocked — no payment was processed. No bank details were requested.',
        ),
        duration: Duration(seconds: 4),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  void _openPlayer() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProgrammePlayerScreen(programme: widget.programme),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.programme;

    return Scaffold(
      appBar: AppBar(
        title: Text(p.title),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildDemoBanner(),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            p.color.withValues(alpha: 0.18),
                            p.color.withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(
                          color: p.color.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: p.color.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(p.icon, color: p.color, size: 28),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFF3CD),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'ILLUSTRATIVE FUTURE PAID FEATURE — DEMO',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.4,
                                          color: Color(0xFF856404),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      p.title,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        height: 1.15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            p.longDescription,
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.45,
                              color: AppTheme.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _buildInfoRow(Icons.timer_outlined, 'Duration',
                        '${p.durationDays} days • ~5 min/day'),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.category_outlined, 'Focus', p.category),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.payments_outlined,
                      'Price',
                      '${p.priceLabel} — no payment in demo',
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'What you get in this demo',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 10),
                    ...p.whatYouGet.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.check_circle_rounded,
                                  size: 18, color: p.color),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  item,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: 22),
                    if (_isUnlocked) ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.success.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.success.withValues(alpha: 0.25),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.verified_rounded,
                                color: AppTheme.success),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Demo access unlocked — no payment was processed. No bank details were requested.',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.success,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      FilledButton.icon(
                        onPressed: _openPlayer,
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Open programme'),
                        style: FilledButton.styleFrom(
                          backgroundColor: p.color,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ] else ...[
                      FilledButton.icon(
                        onPressed: _isUnlocking ? null : _simulateUnlock,
                        icon: _isUnlocking
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.lock_open_rounded),
                        label: Text(_isUnlocking
                            ? 'Unlocking demo...'
                            : 'Simulate demo unlock'),
                        style: FilledButton.styleFrom(
                          backgroundColor: p.color,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Tapping this does NOT open any payment page, does NOT ask for card/bank details, and does NOT charge you. It only saves a local flag on this device.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.textLight,
                          fontSize: 11,
                          height: 1.35,
                        ),
                      ),
                    ],
                    const SizedBox(height: 22),
                    Text(
                      'Daily outline',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 10),
                    ...p.days.map((d) => _buildDayPreview(d, p.color)),
                    const SizedBox(height: 20),
                    _buildFooter(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildDemoBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE69C)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 20, color: Color(0xFF856404)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'DEMO ONLY — This programme preview is a simulated unlock. No payment provider is called, no bank details are requested, and no money is charged. Access is local only.',
              style: TextStyle(
                fontSize: 11,
                height: 1.35,
                color: Color(0xFF856404),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.surfaceBorder.withValues(alpha: 0.7),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.textLight),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayPreview(ProgrammeDay day, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.surfaceBorder.withValues(alpha: 0.75),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.13),
              shape: BoxShape.circle,
            ),
            child: Text(
              '${day.dayNumber}',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: color,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        day.focus,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        day.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  day.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textLight,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceAlt.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text(
        'MindMate is an AI wellbeing companion, not a therapist. This structured programme demo is illustrative only and does not provide diagnosis, prescription, or emergency support. For urgent help, use Emergency Support.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppTheme.textLight,
          fontSize: 11,
          height: 1.35,
        ),
      ),
    );
  }
}
