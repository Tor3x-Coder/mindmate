import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/account_deletion_service.dart';
import '../../services/app_settings_controller.dart';
import '../../services/reminder_service.dart';
import '../../utils/app_theme.dart';
import '../onboarding_carousel_screen.dart';

class DeleteAccountScreen extends StatefulWidget {
  final bool resumePendingDeletion;

  const DeleteAccountScreen({
    super.key,
    this.resumePendingDeletion = false,
  });

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final _confirmationController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isDeleting = false;
  String? _errorText;

  bool get _canDelete =>
      _confirmationController.text.trim().toUpperCase() == 'DELETE' &&
      _passwordController.text.isNotEmpty &&
      !_isDeleting;

  @override
  void initState() {
    super.initState();
    _confirmationController.addListener(_refreshButton);
    _passwordController.addListener(_refreshButton);
  }

  void _refreshButton() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _confirmationController
      ..removeListener(_refreshButton)
      ..dispose();
    _passwordController
      ..removeListener(_refreshButton)
      ..dispose();
    super.dispose();
  }

  Future<void> _confirmAndDelete() async {
    if (!_canDelete) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permanently delete your account?'),
        content: const Text(
          'This cannot be undone. Your MindMate account and stored personal data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Go back'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppTheme.danger),
            child: const Text('Delete permanently'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final settings = context.read<AppSettingsController>();
    final deletionService = context.read<AccountDeletionService>();

    setState(() {
      _isDeleting = true;
      _errorText = null;
    });

    try {
      await settings.updateAccountDeletionPending(true);
      await deletionService.deleteCurrentAccount(
        // Passwords are never trimmed. Spaces may be part of a password.
        password: _passwordController.text,
      );
      final reminderService = context.read<ReminderService>();
      await reminderService.cancelDaily();
      await reminderService.cancelTestNotification();
      await settings.clearAllLocalData();

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const OnboardingCarouselScreen(),
        ),
        (route) => false,
      );
    } on AccountDeletionFailure catch (error) {
      if (error.stage == AccountDeletionStage.reauthentication) {
        await settings.updateAccountDeletionPending(false);
      }
      if (!mounted) return;
      setState(() {
        _isDeleting = false;
        _errorText = _friendlyDeletionError(error);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isDeleting = false;
        _errorText =
            'Deletion paused before completion. Your login remains available so you can safely retry.';
      });
    }
  }

  String _friendlyDeletionError(AccountDeletionFailure error) {
    if (error.stage == AccountDeletionStage.reauthentication) {
      if (error.code == 'wrong-password' ||
          error.code == 'invalid-credential' ||
          error.code == 'invalid-login-credentials') {
        return 'That password did not match this account. Nothing was deleted.';
      }
      if (error.code == 'network-request-failed') {
        return 'MindMate could not verify your password because the network is unavailable. Nothing was deleted.';
      }
      return 'MindMate could not verify that it is you. Nothing was deleted; please sign in again and retry.';
    }

    if (error.stage == AccountDeletionStage.firestoreData) {
      return error.someDataMayAlreadyBeDeleted
          ? 'Deletion was interrupted after some data was removed. Your login remains active; retry to safely finish the remaining data.'
          : 'MindMate could not begin deleting your stored data. Nothing was confirmed deleted; please retry.';
    }

    return 'Your stored MindMate data was removed, but Firebase could not finish deleting the login account. Retry this screen to finish safely.';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isDeleting,
      child: Scaffold(
        appBar: AppBar(title: const Text('Delete account')),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.danger.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.delete_forever_outlined,
                        color: AppTheme.danger,
                        size: 30,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Permanent and irreversible',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'MindMate deletes your profile, check-ins, journals, wellness reflections, practice history, thought records, feedback, trusted contacts, support events, and appointment requests. Your Firebase login is deleted last.',
                        style: TextStyle(
                          color: AppTheme.textLight,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.resumePendingDeletion) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: AppTheme.sand.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Text(
                      'A previous deletion attempt did not confirm completion. Sign in with your password and retry; the process safely skips data that is already gone.',
                      style: TextStyle(color: AppTheme.textDark, height: 1.4),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                const Text(
                  'Type DELETE to confirm',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _confirmationController,
                  textCapitalization: TextCapitalization.characters,
                  enabled: !_isDeleting,
                  decoration: const InputDecoration(
                    hintText: 'DELETE',
                    prefixIcon: Icon(Icons.edit_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Enter your current password',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  enabled: !_isDeleting,
                  autofillHints: const [AutofillHints.password],
                  decoration: InputDecoration(
                    hintText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      onPressed: _isDeleting
                          ? null
                          : () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                ),
                if (_errorText != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    _errorText!,
                    style: const TextStyle(
                      color: AppTheme.danger,
                      height: 1.4,
                    ),
                  ),
                ],
                const SizedBox(height: 22),
                FilledButton.icon(
                  onPressed: _canDelete ? _confirmAndDelete : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.danger,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: _isDeleting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.delete_forever_outlined),
                  label: Text(
                    _isDeleting ? 'Deleting securely...' : 'Delete my account',
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'If deletion is interrupted, MindMate keeps the login available so the process can be retried instead of claiming success prematurely.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.textLight,
                    fontSize: 11.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
