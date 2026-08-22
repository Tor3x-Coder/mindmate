import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/support_event_model.dart';
import '../models/trusted_contact_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import 'professional/professional_directory_screen.dart';

enum _SupportRegion { nigeria, international }

class EmergencySupportScreen extends StatefulWidget {
  const EmergencySupportScreen({super.key});

  @override
  State<EmergencySupportScreen> createState() =>
      _EmergencySupportScreenState();
}

class _EmergencySupportScreenState extends State<EmergencySupportScreen> {
  String? _lastAction;
  bool _showFollowUp = false;
  String? _selectedState;
  _SupportRegion _region = _SupportRegion.nigeria;

  Future<void> _logEvent(
    String actionLabel, {
    String detail = '',
    String? followUp,
  }) async {
    final uid = context.read<AuthService>().currentUser?.uid;
    if (uid == null) return;

    try {
      await context.read<FirestoreService>().addSupportEvent(
            SupportEventModel(
              id: '',
              uid: uid,
              actionLabel: actionLabel,
              detail: detail,
              followUp: followUp,
              createdAt: DateTime.now(),
            ),
          );
    } catch (_) {
      // Logging is best-effort. Never block support because the event
      // could not be saved.
    }
  }

  Future<void> _openExternal(Uri uri, String actionLabel) async {
    final canOpen = await canLaunchUrl(uri);

    if (!canOpen) {
      await _logEvent(actionLabel, detail: 'could_not_open');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This support option could not be opened here.'),
        ),
      );
      return;
    }

    await launchUrl(uri);
    await _logEvent(actionLabel);

    if (!mounted) return;
    setState(() {
      _lastAction = actionLabel;
      _showFollowUp = true;
    });
  }

  Future<void> _call(String number, String actionLabel) {
    return _openExternal(Uri.parse('tel:$number'), actionLabel);
  }

  Future<void> _message(String phone, String actionLabel) {
    return _openExternal(Uri.parse('sms:$phone'), actionLabel);
  }

  Future<void> _openResourceDirectory(String actionLabel) {
    return _openExternal(
      Uri.parse('https://findahelpline.com/'),
      actionLabel,
    );
  }

  void _openProfessionalSupport() {
    _logEvent('Professional directory');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ProfessionalDirectoryScreen(),
      ),
    );
  }

  Future<void> _setFollowUp(String answer) async {
    await _logEvent(
      _lastAction ?? 'Support action',
      followUp: answer,
    );

    if (!mounted) return;
    setState(() {
      _showFollowUp = false;
      _lastAction = answer;
    });

    if (answer == 'I still need immediate help') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please use the emergency or crisis call options above.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Support right now')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            _buildIntro(),
            const SizedBox(height: 18),
            _buildRegionSelector(),
            const SizedBox(height: 20),
            if (_region == _SupportRegion.nigeria) ..._buildNigeriaSection()
            else ..._buildInternationalSection(),
            const SizedBox(height: 22),
            const Text(
              'Choose a way to get support',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
            ),
            const SizedBox(height: 9),
            _HelpCard(
              title: 'Call a crisis support line',
              subtitle: 'Use a trained human support service.',
              actionLabel: 'Find a line',
              icon: Icons.phone_in_talk_outlined,
              onAction: () => _openResourceDirectory('Crisis support'),
            ),
            _HelpCard(
              title: 'MANI',
              subtitle: 'Mentally Aware Nigeria Initiative support resources.',
              actionLabel: 'Open resources',
              icon: Icons.support_agent_rounded,
              onAction: () => _openResourceDirectory('MANI resources'),
            ),
            _HelpCard(
              title: 'SURPIN',
              subtitle: 'Suicide prevention and trained-counsellor resources.',
              actionLabel: 'Open resources',
              icon: Icons.chat_outlined,
              onAction: () => _openResourceDirectory('SURPIN resources'),
            ),
            _HelpCard(
              title: 'Find professional support',
              subtitle: 'For support that is not immediately urgent.',
              actionLabel: 'View professionals',
              icon: Icons.people_outline_rounded,
              onAction: _openProfessionalSupport,
            ),
            const SizedBox(height: 20),
            _buildTrustedSection(),
            if (_showFollowUp) ...[
              const SizedBox(height: 14),
              _buildFollowUpCard(),
            ],
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.secondary.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'If someone you trust is nearby, you can ask them to stay with you. MindMate does not contact anyone automatically and is not a replacement for emergency or professional care.',
                style: TextStyle(
                  color: AppTheme.textLight,
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntro() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradientLight,
        borderRadius: BorderRadius.circular(28),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SUPPORT RIGHT NOW',
            style: TextStyle(
              color: Color(0xFF59646F),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 11),
          Text(
            'You deserve support in a difficult moment.',
            style: TextStyle(
              color: AppTheme.textDark,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 7),
          Text(
            'Choose the option that fits what you need right now.',
            style: TextStyle(
              color: Color(0xFF59646F),
              fontSize: 13,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegionSelector() {
    return Row(
      children: [
        Expanded(
          child: _SegmentButton(
            label: 'In Nigeria',
            selected: _region == _SupportRegion.nigeria,
            onTap: () => setState(() => _region = _SupportRegion.nigeria),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SegmentButton(
            label: 'Outside Nigeria',
            selected: _region == _SupportRegion.international,
            onTap: () => setState(() => _region = _SupportRegion.international),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildNigeriaSection() {
    return [
      const Text(
        'Are you in immediate danger?',
        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
      ),
      const SizedBox(height: 9),
      _HelpCard(
        title: 'National Emergency Line',
        subtitle: 'For immediate danger anywhere in Nigeria.',
        actionLabel: 'Call 112',
        icon: Icons.warning_amber_rounded,
        urgent: true,
        onAction: () => _call('112', 'National emergency line'),
      ),
      _HelpCard(
        title: 'Lagos Emergency Line',
        subtitle: 'Local emergency response in Lagos.',
        actionLabel: 'Call 767',
        icon: Icons.location_on_outlined,
        urgent: true,
        onAction: () => _call('767', 'Lagos emergency line'),
      ),
      const SizedBox(height: 14),
      const Text(
        'Emergency number for your state',
        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
      ),
      const SizedBox(height: 6),
      const Text(
        'Pick your state to find the local emergency call centre. If your state is not listed, call 112.',
        style: TextStyle(color: AppTheme.textLight, fontSize: 12, height: 1.4),
      ),
      const SizedBox(height: 10),
      _buildStatePicker(),
      if (_selectedState != null) ...[
        const SizedBox(height: 10),
        _buildStateEmergencyCard(),
      ],
    ];
  }

  Widget _buildStatePicker() {
    final states = nigeriaStateEmergencies.map((e) => e.state).toList();
    return DropdownButtonFormField<String>(
      initialValue: _selectedState,
      decoration: const InputDecoration(labelText: 'Your state'),
      items: states
          .map((state) => DropdownMenuItem(value: state, child: Text(state)))
          .toList(),
      onChanged: (value) => setState(() => _selectedState = value),
    );
  }

  Widget _buildStateEmergencyCard() {
    final entry = nigeriaStateEmergencies.firstWhere(
      (e) => e.state == _selectedState,
      orElse: () => const NigeriaStateEmergency(state: ''),
    );

    final hasLocal = entry.localNumber != null && entry.localNumber!.isNotEmpty;
    final label = hasLocal ? entry.localNumber! : '112';

    return _HelpCard(
      title: entry.state.isEmpty ? 'Your state' : entry.state,
      subtitle: hasLocal
          ? 'Local emergency call centre. Verify before public release.'
          : 'No authenticated local number listed — use the national line.',
      actionLabel: hasLocal ? 'Call $label' : 'Call 112',
      icon: Icons.filter_center_focus_outlined,
      urgent: true,
      onAction: () => _call(hasLocal ? entry.localNumber! : '112', '${entry.state} emergency'),
    );
  }

  List<Widget> _buildInternationalSection() {
    return [
      const Text(
        'Emergency numbers around the world',
        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
      ),
      const SizedBox(height: 6),
      const Text(
        'If you are outside Nigeria, use the number for your country. These are general emergency lines — verify before release.',
        style: TextStyle(color: AppTheme.textLight, fontSize: 12, height: 1.4),
      ),
      const SizedBox(height: 12),
      ...internationalEmergencies.map(
        (entry) => _HelpCard(
          title: entry.country,
          subtitle: entry.note.isEmpty
              ? 'General emergency number'
              : entry.note,
          actionLabel: 'Call ${entry.number}',
          icon: Icons.public_rounded,
          urgent: true,
          onAction: () => _call(entry.number, '${entry.country} emergency'),
        ),
      ),
    ];
  }

  Widget _buildTrustedSection() {
    final authService = context.read<AuthService>();
    final firestoreService = context.read<FirestoreService>();
    final uid = authService.currentUser?.uid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'People I trust',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
              ),
            ),
            TextButton.icon(
              onPressed: () => _openContactEditor(),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'MindMate will never call or message them without you pressing the button.',
          style: TextStyle(color: AppTheme.textLight, fontSize: 12, height: 1.4),
        ),
        const SizedBox(height: 10),
        if (uid == null)
          const _InfoBox(
            text: 'Log in to save a trusted contact.',
          )
        else
          StreamBuilder<List<TrustedContactModel>>(
            stream: firestoreService.trustedContactsForUser(uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (snapshot.hasError) {
                return const _InfoBox(
                  text: 'Your trusted contacts could not be loaded right now.',
                );
              }

              final contacts = snapshot.data ?? const <TrustedContactModel>[];
              if (contacts.isEmpty) {
                return const _InfoBox(
                  text: 'Add someone you trust so you can reach them quickly when you need to.',
                );
              }

              return Column(
                children: contacts.map(_buildTrustedContactCard).toList(),
              );
            },
          ),
      ],
    );
  }

  Widget _buildTrustedContactCard(TrustedContactModel contact) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.surfaceBorder.withValues(alpha: 0.78),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.favorite_outline_rounded, color: AppTheme.primary),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 3),
                Text(
                  contact.relationship,
                  style: const TextStyle(color: AppTheme.textLight, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _call(contact.phone, 'Trusted contact ${contact.name}'),
            icon: const Icon(Icons.call_rounded),
            color: AppTheme.primary,
            tooltip: 'Call ${contact.name}',
          ),
          IconButton(
            onPressed: () => _message(contact.phone, 'Trusted contact ${contact.name}'),
            icon: const Icon(Icons.message_rounded),
            color: AppTheme.secondary,
            tooltip: 'Message ${contact.name}',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                _openContactEditor(contact: contact);
              } else if (value == 'delete') {
                _confirmDeleteContact(contact);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openContactEditor({TrustedContactModel? contact}) async {
    final nameController = TextEditingController(text: contact?.name ?? '');
    final relationshipController =
        TextEditingController(text: contact?.relationship ?? '');
    final phoneController = TextEditingController(text: contact?.phone ?? '');

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(contact == null ? 'Add a trusted person' : 'Edit trusted person'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: relationshipController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Relationship (e.g. Mum, Friend)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone number'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isEmpty || phoneController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('Add a name and a phone number.')),
                  );
                  return;
                }
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (saved != true || !mounted) return;

    final name = nameController.text.trim();
    final relationship = relationshipController.text.trim();
    final phone = phoneController.text.trim();

    await _saveTrustedContact(
      contact: contact,
      name: name,
      relationship: relationship,
      phone: phone,
    );
  }

  Future<void> _saveTrustedContact({
    required TrustedContactModel? contact,
    required String name,
    required String relationship,
    required String phone,
  }) async {
    final uid = context.read<AuthService>().currentUser?.uid;
    if (uid == null) return;

    final model = TrustedContactModel(
      id: contact?.id ?? '',
      uid: uid,
      name: name,
      relationship: relationship,
      phone: phone,
      createdAt: contact?.createdAt ?? DateTime.now(),
    );

    final firestore = context.read<FirestoreService>();
    try {
      if (contact == null) {
        await firestore.addTrustedContact(model);
      } else {
        await firestore.updateTrustedContact(model);
      }
      await _logEvent('Trusted contact saved', detail: name);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trusted contact saved.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save that contact right now.')),
      );
    }
  }

  Future<void> _confirmDeleteContact(TrustedContactModel contact) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove trusted contact?'),
        content: Text(
          'Remove ${contact.name} from your trusted contacts?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.danger),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await context
          .read<FirestoreService>()
          .deleteTrustedContact(contact.id);
      await _logEvent('Trusted contact removed', detail: contact.name);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not remove that contact right now.')),
      );
    }
  }

  Widget _buildFollowUpCard() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppTheme.primary.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _lastAction == null
                ? 'Did you manage to reach someone?'
                : 'Did you manage to use $_lastAction?',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'MindMate cannot know whether a call or message was completed, so your answer is optional and honest.',
            style: TextStyle(
              color: AppTheme.textLight,
              fontSize: 12,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FollowUpChip(
                label: 'I connected',
                onTap: () => _setFollowUp('I connected'),
              ),
              _FollowUpChip(
                label: 'Not yet',
                onTap: () => _setFollowUp('Not yet'),
              ),
              _FollowUpChip(
                label: 'Still need help',
                onTap: () => _setFollowUp('I still need immediate help'),
              ),
              _FollowUpChip(
                label: 'Not sure',
                onTap: () => _setFollowUp('Not sure'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SegmentButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primary
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? AppTheme.primary
                : AppTheme.surfaceBorder.withValues(alpha: 0.78),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppTheme.textLight,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _HelpCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String actionLabel;
  final IconData icon;
  final bool urgent;
  final VoidCallback onAction;

  const _HelpCard({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.icon,
    required this.onAction,
    this.urgent = false,
  });

  @override
  Widget build(BuildContext context) {
    final actionColor = urgent ? AppTheme.danger : AppTheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: urgent
              ? AppTheme.danger.withValues(alpha: 0.45)
              : AppTheme.surfaceBorder.withValues(alpha: 0.78),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: actionColor.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: actionColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppTheme.textLight,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: actionColor,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              actionLabel,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _FollowUpChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FollowUpChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String text;

  const _InfoBox({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceAlt.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppTheme.textLight),
      ),
    );
  }
}
