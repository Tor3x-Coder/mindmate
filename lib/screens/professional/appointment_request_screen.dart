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
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();

  String? _consultationType;
  DateTime? _preferredDate;
  TimeOfDay? _preferredTime;
  bool _isSaving = false;

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
    if (types.length == 1) {
      _consultationType = types.first;
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _preferredDate ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _preferredDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _preferredTime ?? const TimeOfDay(hour: 10, minute: 0),
    );
    if (picked != null) {
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
    if (!_formKey.currentState!.validate()) return;

    if (_consultationType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose Online or Physical.')),
      );
      return;
    }
    if (_preferredDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick a preferred date.')),
      );
      return;
    }
    if (_preferredTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick a preferred time.')),
      );
      return;
    }

    final authService = context.read<AuthService>();
    final uid = authService.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to send a request.')),
      );
      return;
    }

    setState(() => _isSaving = true);

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

    try {
      await context.read<FirestoreService>().requestAppointment(appointment);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Request sent. It stays pending until reviewed — this is not a confirmed booking.',
          ),
        ),
      );
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final professional = widget.professional;
    final types = _availableTypes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Appointment'),
      ),
      body: SafeArea(
        child: types.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'This professional has no session types listed yet.',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Request a session with ${professional.fullName}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'This sends a request only — MindMate does not confirm bookings automatically.',
                        style: TextStyle(
                          color: AppTheme.textLight,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Consultation type',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: types.map((type) {
                          final selected = _consultationType == type;
                          return ChoiceChip(
                            label: Text(type),
                            selected: selected,
                            onSelected: (_) =>
                                setState(() => _consultationType = type),
                            selectedColor:
                                AppTheme.primary.withValues(alpha: 0.2),
                            labelStyle: TextStyle(
                              color: selected
                                  ? AppTheme.primary
                                  : AppTheme.textDark,
                              fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                            showCheckmark: false,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.calendar_today_outlined,
                            color: AppTheme.primary),
                        title: Text(
                          _preferredDate == null
                              ? 'Preferred date'
                              : _formatDate(_preferredDate!),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: _pickDate,
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.access_time,
                            color: AppTheme.primary),
                        title: Text(
                          _preferredTime == null
                              ? 'Preferred time'
                              : _formatTime(_preferredTime!),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: _pickTime,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _noteController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Note (optional)',
                          alignLabelWithHint: true,
                          hintText: 'Anything you\'d like them to know…',
                        ),
                      ),
                      const SizedBox(height: 28),
                      ElevatedButton(
                        onPressed: _isSaving ? null : _handleSubmit,
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Send Request'),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
