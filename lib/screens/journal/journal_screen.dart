import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/journal_entry_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  // A few optional starter prompts the user can tap to fill the box,
  // so they're not stuck staring at a blank page.
  final List<String> _prompts = const [
    'What made you smile today?',
    'What\'s something on your mind right now?',
    'What are you grateful for today?',
    'What was challenging about today?',
  ];

  void _openNewEntrySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // lets the sheet grow with the keyboard
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _NewJournalEntrySheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final firestoreService = context.watch<FirestoreService>();
    final uid = authService.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openNewEntrySheet,
        backgroundColor: const Color(0xFF5B9A8B),
        icon: const Icon(Icons.edit, color: Colors.white),
        label: const Text('New Entry', style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: uid == null
            ? const Center(child: Text('Please log in to view your journal.'))
            : StreamBuilder<List<JournalEntryModel>>(
                stream: firestoreService.journalEntriesForUser(uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'ERROR: ${snapshot.error}',
                          style:
                              const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    );
                  }

                  final entries = snapshot.data ?? [];

                  if (entries.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      return _JournalEntryCard(entry: entries[index]);
                    },
                  );
                },
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.book_outlined, size: 56, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No journal entries yet',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap "New Entry" below to write your first one.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// A single card showing one past journal entry in the list.
class _JournalEntryCard extends StatelessWidget {
  final JournalEntryModel entry;

  const _JournalEntryCard({required this.entry});

  String _formatDate(DateTime date) {
    // Simple readable date, no extra packages needed.
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final ampm = date.hour >= 12 ? 'PM' : 'AM';
    return '${months[date.month - 1]} ${date.day}, ${date.year} · $hour:$minute $ampm';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF9B8ECF).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (entry.prompt.isNotEmpty) ...[
            Text(
              entry.prompt,
              style: const TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: Color(0xFF9B8ECF),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
          ],
          Text(
            entry.content,
            style: const TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 10),
          Text(
            _formatDate(entry.date),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// The bottom sheet form used to write a new journal entry.
class _NewJournalEntrySheet extends StatefulWidget {
  const _NewJournalEntrySheet();

  @override
  State<_NewJournalEntrySheet> createState() => _NewJournalEntrySheetState();
}

class _NewJournalEntrySheetState extends State<_NewJournalEntrySheet> {
  final TextEditingController _contentController = TextEditingController();
  String _selectedPrompt = '';
  bool _isSaving = false;
  String? _errorText;

  final List<String> _prompts = const [
    'What made you smile today?',
    'What\'s something on your mind right now?',
    'What are you grateful for today?',
    'What was challenging about today?',
  ];

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  String _friendlyError(Object e) {
    return 'Something went wrong saving your entry. Please try again.';
  }

  Future<void> _saveEntry() async {
    setState(() => _errorText = null);

    if (_contentController.text.trim().isEmpty) {
      setState(() => _errorText = 'Write something before saving.');
      return;
    }

    final authService = context.read<AuthService>();
    final firestoreService = context.read<FirestoreService>();
    final uid = authService.currentUser?.uid;

    if (uid == null) {
      setState(() => _errorText = 'You need to be logged in to save this.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final entry = JournalEntryModel(
        id: '', // Firestore generates this automatically
        uid: uid,
        prompt: _selectedPrompt,
        content: _contentController.text.trim(),
        date: DateTime.now(),
      );

      await firestoreService.addJournalEntry(entry);

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      setState(() => _errorText = _friendlyError(e));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pushes the sheet up above the on-screen keyboard when typing.
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'New Journal Entry',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),

            // Optional prompt chips.
            const Text(
              'Need a prompt? (optional)',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _prompts.map((prompt) {
                final isSelected = _selectedPrompt == prompt;
                return ChoiceChip(
                  label: Text(prompt, style: const TextStyle(fontSize: 12)),
                  selected: isSelected,
                  selectedColor:
                      const Color(0xFF9B8ECF).withValues(alpha: 0.25),
                  onSelected: (selected) {
                    setState(() {
                      _selectedPrompt = selected ? prompt : '';
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 18),
            TextField(
              controller: _contentController,
              maxLines: 6,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Write here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            if (_errorText != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorText!,
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
            ],

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSaving ? null : _saveEntry,
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
                  : const Text('Save Entry', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
