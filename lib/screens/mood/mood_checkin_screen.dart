import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/mood_log_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';

class MoodCheckinScreen extends StatefulWidget {
  const MoodCheckinScreen({super.key});

  @override
  State<MoodCheckinScreen> createState() => _MoodCheckinScreenState();
}

class _MoodCheckinScreenState extends State<MoodCheckinScreen> {
  // Each mood option has an emoji + a label that gets saved to Firestore.
  final List<Map<String, String>> _moods = const [
    {'emoji': '😊', 'label': 'Happy'},
    {'emoji': '😄', 'label': 'Excited'},
    {'emoji': '😐', 'label': 'Neutral'},
    {'emoji': '😔', 'label': 'Sad'},
    {'emoji': '😣', 'label': 'Stressed'},
    {'emoji': '😡', 'label': 'Angry'},
    {'emoji': '😴', 'label': 'Tired'},
  ];

  // Keeps track of which mood the user has tapped on.
  String? _selectedEmoji;
  String? _selectedLabel;

  final TextEditingController _noteController = TextEditingController();

  bool _isSaving = false;
  String? _errorText;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  // Converts raw Firebase/Firestore errors into something a user can
  // actually understand, same pattern used elsewhere in the app.
  String _friendlyError(Object e) {
    return 'Something went wrong saving your mood. Please try again.';
  }

  Future<void> _saveMood() async {
    setState(() => _errorText = null);

    if (_selectedEmoji == null || _selectedLabel == null) {
      setState(() => _errorText = 'Please pick how you\'re feeling first.');
      return;
    }

    final authService = context.read<AuthService>();
    final firestoreService = context.read<FirestoreService>();
    final uid = authService.currentUser?.uid;

    if (uid == null) {
      setState(() => _errorText = 'You need to be logged in to save a mood.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final log = MoodLogModel(
        id: '', // Firestore generates this automatically when we call .add()
        uid: uid,
        emoji: _selectedEmoji!,
        label: _selectedLabel!,
        note: _noteController.text.trim(),
        date: DateTime.now(),
      );

      await firestoreService.addMoodLog(log);

      if (!mounted) return;

      // Let the user know it worked, then send them back to the dashboard.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mood check-in saved!')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      setState(() => _errorText = _friendlyError(e));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('How are you feeling?'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Pick the mood that best matches right now',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),

              // The row/grid of emoji mood options.
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: _moods.map((mood) {
                  final isSelected = _selectedEmoji == mood['emoji'];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedEmoji = mood['emoji'];
                        _selectedLabel = mood['label'];
                        _errorText = null;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF5B9A8B).withValues(alpha: 0.15)
                            : Colors.grey.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF5B9A8B)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            mood['emoji']!,
                            style: const TextStyle(fontSize: 32),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            mood['label']!,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? const Color(0xFF5B9A8B)
                                  : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 28),

              const Text(
                'Want to add a note? (optional)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _noteController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'What\'s on your mind...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              if (_errorText != null) ...[
                const SizedBox(height: 14),
                Text(
                  _errorText!,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                ),
              ],

              const SizedBox(height: 28),

              ElevatedButton(
                onPressed: _isSaving ? null : _saveMood,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B9A8B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Save Check-In',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}