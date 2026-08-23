import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/appointment_model.dart';
import '../../models/professional_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../utils/app_theme.dart';

class AppointmentRequestScreen extends StatefulWidget {
  final ProfessionalModel professional;

  const AppointmentRequestScreen({
    super.key,
    required this.professional,
  });

  @override
  State<AppointmentRequestScreen> createState() =>
      _AppointmentRequestScreenState();
}

class _AppointmentRequestScreenState extends State<AppointmentRequestScreen> {
  final _noteController = TextEditingController();

  String? _consultationType;
  DateTime? _preferredDate;
  TimeOfDay? _preferredTime;
  int _currentStep = 0;
  bool _isSaving = false;
  bool _hasPendingRequest = false;
  String? _errorText;

  List<String> get _availableTypes {
    final types = <String>[];
    if (widget.professional.offersOnline) types.add('Online');
    if (widget.professional.offersPhysical) types.add('Physical');
    return types;
  }

  @override
  void initState() {
    super.initState();
    final types = _availableTypes;
    if (types.length == 1) _consultationType = types.first;
    _checkPendingRequest();
  }

  Future<void> _checkPendingRequest() async {
    final uid = context.read<AuthService>().currentUser?.uid;
    if (uid == null || !mounted) return;

    try {
      final hasPending = await context
          .read<FirestoreService>()
          .hasPendingAppointmentForProfessional(uid, widget.professional.id);
      if (!mounted) return;
      setState(() => _hasPendingRequest = hasPending);
    } catch (_) {
      // If the check fails, allow the request screen to continue normally.
      // The submit flow re-checks and will block duplicates if needed.
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  bool _canContinueFromCurrentStep() {
    if (_currentStep == 0) return _consultationType != null;
    if (_currentStep == 1) {
      return _preferredDate != null && _preferredTime != null;
    }
    return true;
  }

  void _nextStep() {
    setState(() => _errorText = null);

    if (!_canContinueFromCurrentStep()) {
      setState(() {
        _errorText = _currentStep == 0
            ? 'Please choose Online or Physical.'
            : 'Please choose a preferred date and time.';
      });
      return;
    }

    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      _handleSubmit();
    }
  }

  void _previousStep() {
    if (_currentStep == 0) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _currentStep--;
        _errorText = null;
      });
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _preferredDate ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null && mounted) {
      setState(() => _preferredDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _preferredTime ?? const TimeOfDay(hour: 10, minute: 0),
    );
    if (picked != null && mounted) {
      setState(() => _preferredTime = picked);
    }
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String _formatTime(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _handleSubmit() async {
    final uid = context.read<AuthService>().currentUser?.uid;
    if (uid == null) {
      setState(() => _errorText = 'Please log in to send a request.');
      return;
    }

    if (_consultationType == null ||
        _preferredDate == null ||
        _preferredTime == null) {
      setState(() => _errorText = 'Please complete the request details.');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorText = null;
    });

    final firestore = context.read<FirestoreService>();

    try {
      // Re-check immediately before sending. This query can fail because of a
      // network/index problem, so it belongs inside the same friendly handler
      // as the write instead of escaping as an unhandled Future error.
      final hasPending = await firestore.hasPendingAppointmentForProfessional(
        uid,
        widget.professional.id,
      );
      if (!mounted) return;

      if (hasPending) {
        setState(() {
          _isSaving = false;
          _hasPendingRequest = true;
          _errorText =
              'You already have a pending request with this professional. Wait for their response before sending another.';
        });
        return;
      }

      final appointment = AppointmentModel(
        id: '',
        uid: uid,
        professionalId: widget.professional.id,
        professionalName: widget.professional.fullName,
        consultationType: _consultationType!,
        preferredDate: _formatDate(_preferredDate!),
        preferredTime: _formatTime(_preferredTime!),
        note: _noteController.text.trim(),
        status: 'pending',
        requestedAt: DateTime.now(),
      );

      await firestore.requestAppointment(appointment);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Request sent'),
          content: const Text(
            'Your request is pending review. This is not a confirmed booking yet.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _errorText =
            'MindMate could not verify or send this request. Check your connection and try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _currentStep == 0
        ? 'How would you like to meet?'
        : _currentStep == 1
            ? 'Choose a preferred time'
            : 'Review your request';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Request a session'),
        leading: IconButton(
          onPressed: _isSaving ? null : _previousStep,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildStepHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildProfessionalSummary(),
                    const SizedBox(height: 24),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'A request is reviewed before anything is confirmed.',
                      style: TextStyle(
                        color: AppTheme.textLight,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_hasPendingRequest) _buildPendingNotice(),
                    const SizedBox(height: 20),
                    if (_currentStep == 0) _buildTypeStep(),
                    if (_currentStep == 1) _buildTimeStep(),
                    if (_currentStep == 2) _buildReviewStep(),
                    if (_errorText != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _errorText!,
                        style: const TextStyle(
                          color: AppTheme.danger,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingNotice() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppTheme.danger.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.danger.withValues(alpha: 0.35),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: AppTheme.danger, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'You already have a pending request with this professional. You can check its status in My Requests and wait for a response before sending another.',
              style: TextStyle(
                color: AppTheme.danger,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: List.generate(3, (index) {
          final active = index <= _currentStep;
          return Expanded(
            child: Container(
              height: 5,
              margin: EdgeInsets.only(right: index == 2 ? 0 : 7),
              decoration: BoxDecoration(
                color: active
                    ? AppTheme.primary
                    : AppTheme.surfaceBorder.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildProfessionalSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradientLight,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.65),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'WITH',
                  style: TextStyle(
                    color: Color(0xFF59646F),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.professional.fullName,
                  style: const TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '${widget.professional.category} · request-based support',
                  style: const TextStyle(
                    color: Color(0xFF59646F),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeStep() {
    final types = _availableTypes;

    if (types.isEmpty) {
      return const _InfoBox(
        text: 'This professional has no session type listed yet.',
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: types.map((type) {
        final selected = _consultationType == type;
        return _ChoiceCard(
          label: type,
          subtitle: type == 'Online'
              ? 'Talk from wherever you are'
              : 'Meet in person',
          icon: type == 'Online'
              ? Icons.videocam_outlined
              : Icons.place_outlined,
          selected: selected,
          onTap: () => setState(() => _consultationType = type),
        );
      }).toList(),
    );
  }

  Widget _buildTimeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PickerRow(
          icon: Icons.calendar_today_outlined,
          title: _preferredDate == null
              ? 'Choose a date'
              : _formatDate(_preferredDate!),
          onTap: _pickDate,
        ),
        const SizedBox(height: 10),
        _PickerRow(
          icon: Icons.access_time_rounded,
          title: _preferredTime == null
              ? 'Choose a time'
              : _formatTime(_preferredTime!),
          onTap: _pickTime,
        ),
      ],
    );
  }

  Widget _buildReviewStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ReviewRow(
          label: 'Type',
          value: _consultationType ?? 'Not chosen',
        ),
        _ReviewRow(
          label: 'Date',
          value: _preferredDate == null
              ? 'Not chosen'
              : _formatDate(_preferredDate!),
        ),
        _ReviewRow(
          label: 'Time',
          value: _preferredTime == null
              ? 'Not chosen'
              : _formatTime(_preferredTime!),
        ),
        const SizedBox(height: 16),
        const Text(
          'Note (optional)',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _noteController,
          maxLines: 4,
          maxLength: 1000,
          decoration: InputDecoration(
            hintText: 'Anything you would like them to know...',
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _nextStep,
            child: _isSaving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(_currentStep == 2 ? 'Send request' : 'Continue'),
          ),
        ),
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ChoiceCard({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primary.withValues(alpha: 0.13)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected
                ? AppTheme.primary
                : AppTheme.surfaceBorder.withValues(alpha: 0.78),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? AppTheme.primary : AppTheme.textLight,
              size: 25,
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: selected
                          ? AppTheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppTheme.textLight,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppTheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}

class _PickerRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _PickerRow({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(19),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(19),
          border: Border.all(
            color: AppTheme.surfaceBorder.withValues(alpha: 0.78),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.textLight,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReviewRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: AppTheme.surfaceBorder.withValues(alpha: 0.78),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textLight)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
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
