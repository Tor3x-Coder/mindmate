import 'package:flutter/material.dart';

import '../../models/structured_programme_model.dart';
import '../../services/demo_entitlement_service.dart';
import '../../utils/app_theme.dart';
import 'programme_detail_screen.dart';

class ProgrammeListScreen extends StatefulWidget {
  const ProgrammeListScreen({super.key});

  @override
  State<ProgrammeListScreen> createState() => _ProgrammeListScreenState();
}

class _ProgrammeListScreenState extends State<ProgrammeListScreen> {
  final DemoEntitlementService _entitlementService = DemoEntitlementService();
  Set<String> _unlockedIds = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEntitlements();
  }

  Future<void> _loadEntitlements() async {
    final ids = await _entitlementService.getUnlockedIds();
    if (!mounted) return;
    setState(() {
      _unlockedIds = ids;
      _isLoading = false;
    });
  }

  void _openProgramme(StructuredProgramme programme) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProgrammeDetailScreen(programme: programme),
      ),
    );
    // Refresh after returning from detail (might have unlocked)
    _loadEntitlements();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Programmes — Demo'),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                children: [
                  _buildDemoBanner(),
                  const SizedBox(height: 18),
                  Text(
                    'Structured programmes',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Illustrative future paid depth — competition demo only. No bank details, no Paystack, no real charge.',
                    style: TextStyle(
                      color: AppTheme.textLight,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 18),
                  ...demoProgrammes.map((p) => _buildProgrammeCard(p)),
                  const SizedBox(height: 20),
                  _buildFooter(),
                ],
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DEMO — No payment processed',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    color: Color(0xFF856404),
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'This screen shows how future structured programmes could work. Tapping “Simulate demo unlock” does NOT request bank details, does NOT call any payment provider, and does NOT charge you. Access is stored locally on this device only.',
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.35,
                    color: Color(0xFF856404),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgrammeCard(StructuredProgramme programme) {
    final isUnlocked = _unlockedIds.contains(programme.id);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: () => _openProgramme(programme),
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isUnlocked
                  ? programme.color.withValues(alpha: 0.5)
                  : AppTheme.surfaceBorder.withValues(alpha: 0.8),
              width: isUnlocked ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: programme.color.withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: programme.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(programme.icon, color: programme.color),
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
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF3CD),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'DEMO',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.6,
                                  color: Color(0xFF856404),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            if (isUnlocked)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.success
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'UNLOCKED',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.success,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          programme.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppTheme.textLight),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                programme.description,
                style: const TextStyle(
                  color: AppTheme.textLight,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 14, color: programme.color),
                  const SizedBox(width: 6),
                  Text(
                    '${programme.durationDays} days • ${programme.category}',
                    style: TextStyle(
                      color: programme.color,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Price: ${programme.priceLabel}',
                    style: const TextStyle(
                      color: AppTheme.textLight,
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
        'MindMate core (check-in, One Safe Step, breathing, journal, chat, learn, emergency support) remains free. Structured programmes are illustrative future paid depth and are NOT paywalled in this demo — access is simulated locally with no payment provider.',
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
