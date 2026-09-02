import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/app_settings_controller.dart';
import '../../services/auth_service.dart';
import '../../services/reminder_service.dart';
import '../../utils/app_theme.dart';
import '../onboarding/onboarding_screen.dart';
import '../settings/delete_account_screen.dart';
import 'login_screen.dart';

class MissingProfileScreen extends StatefulWidget {
  const MissingProfileScreen({super.key});

  @override
  State<MissingProfileScreen> createState() => _MissingProfileScreenState();
}

class _MissingProfileScreenState extends State<MissingProfileScreen> {
  late final TextEditingController _nameController;
  bool _isRestoring = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthService>().currentUser;
    final suggestedName = user?.displayName?.trim();
    _nameController = TextEditingController(
      text: suggestedName == null || suggestedName.isEmpty ? '' : suggestedName,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _restoreProfile() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorText = 'Enter your name to restore the profile.');
      return;
    }

    setState(() {
      _isRestoring = true;
      _errorText = null;
    });

    try {
      await context.read<AuthService>().restoreMissingProfile(fullName: name);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        (route) => false,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isRestoring = false;
        _errorText =
            'MindMate could not restore your profile. Check your connection and try again.';
      });
    }
  }

  Future<void> _logout() async {
    final reminderService = context.read<ReminderService>();
    await reminderService.cancelDaily();
    await reminderService.cancelTestNotification();
    await context.read<AuthService>().logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final deletionPending =
        context.watch<AppSettingsController>().accountDeletionPending;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Finish account setup'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppTheme.heroGradientLight,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.manage_accounts_outlined,
                      color: AppTheme.primary,
                      size: 32,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Your login exists, but your profile is missing.',
                      style: TextStyle(
                        color: AppTheme.textDark,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'This can happen if account setup was interrupted. Restore a minimal profile and finish setup, or permanently delete the account.',
                      style: TextStyle(
                        color: Color(0xFF59646F),
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              if (deletionPending) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: AppTheme.sand.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Text(
                    'A deletion attempt is waiting to finish. Choose Delete account below to retry safely instead of restoring the profile.',
                    style: TextStyle(color: AppTheme.textDark, height: 1.4),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              const Text(
                'Restore profile',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                enabled: !_isRestoring && !deletionPending,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Full name',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
              ),
              if (_errorText != null) ...[
                const SizedBox(height: 10),
                Text(
                  _errorText!,
                  style: const TextStyle(color: AppTheme.danger),
                ),
              ],
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed:
                    _isRestoring || deletionPending ? null : _restoreProfile,
                child: _isRestoring
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Restore and finish setup'),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _isRestoring
                    ? null
                    : () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => DeleteAccountScreen(
                              resumePendingDeletion: deletionPending,
                            ),
                          ),
                        ),
                icon: const Icon(Icons.delete_forever_outlined),
                label: Text(
                  deletionPending
                      ? 'Retry account deletion'
                      : 'Delete this account instead',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.danger,
                  side: BorderSide(
                    color: AppTheme.danger.withValues(alpha: 0.55),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: _isRestoring ? null : _logout,
                child: const Text('Log out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
