import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../mood/mood_checkin_screen.dart';
import '../journal/journal_screen.dart';
import '../breathing/breathing_screen.dart';
import '../progress/progress_screen.dart';
import '../welcome_screen.dart';
import '../wellness/wellness_assessment_screen.dart';
import '../meditation/meditation_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _userName = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final authService = context.read<AuthService>();
    final firestoreService = context.read<FirestoreService>();
    final uid = authService.currentUser?.uid;

    if (uid != null) {
      final profile = await firestoreService.getUserProfile(uid);
      if (mounted) {
        setState(() {
          _userName = profile?['fullName']?.toString().split(' ').first ?? 'there';
          _isLoading = false;
        });
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLogout() async {
    final authService = context.read<AuthService>();
    await authService.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MindMate'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hi, $_userName 👋',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'How are you feeling today?',
                      style: TextStyle(color: AppTheme.textLight, fontSize: 15),
                    ),
                    const SizedBox(height: 20),

                    // Mood check-in card
                    _DashboardCard(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const MoodCheckinScreen()),
                      ),
                      child: Row(
                        children: [
                          const Text('😊', style: TextStyle(fontSize: 32)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Daily Mood Check-In',
                                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Tap to log how you\'re feeling',
                                  style: TextStyle(color: AppTheme.textLight, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: AppTheme.textLight),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Wellness score placeholder
                    _DashboardCard(
onTap: () => Navigator.of(context).push(
  MaterialPageRoute(builder: (_) => const WellnessAssessmentScreen()),
),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              '--%',
                              style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.primary),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Wellness Score',
                                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Complete today\'s assessment to see your score',
                                  style: TextStyle(color: AppTheme.textLight, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Quick Actions',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.3,
                      children: [
                        _QuickActionTile(
                          icon: Icons.book_outlined,
                          label: 'Journal',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const JournalScreen()),
                          ),
                        ),
                        _QuickActionTile(
                          icon: Icons.air,
                          label: 'Breathing',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const BreathingScreen()),
                          ),
                        ),
                        _QuickActionTile(
                          icon: Icons.self_improvement,
                          label: 'Meditation',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const MeditationScreen()),
                          ),
                      
                        ),
                        _QuickActionTile(
                          icon: Icons.show_chart,
                          label: 'Progress',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const ProgressScreen()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const _DashboardCard({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.textLight.withValues(alpha: 0.15)),
        ),
        child: child,
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.textLight.withValues(alpha: 0.15)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.primary, size: 28),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}