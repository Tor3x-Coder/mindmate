import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/journal_entry_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../utils/app_theme.dart';

const List<String> _journalPrompts = [
  'What made you smile today?',
  'What\'s something on your mind right now?',
  'What are you grateful for today?',
  'What was challenging about today?',
];

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  void _openNewEntrySheet({String? prompt}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _JournalEntrySheet(initialPrompt: prompt),
    );
  }

  void _openEditSheet(JournalEntryModel entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _JournalEntrySheet(existingEntry: entry),
    );
  }

  Future<void> _confirmDelete(JournalEntryModel entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Delete this entry?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await context.read<FirestoreService>().deleteJournalEntry(entry.id);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not delete that entry. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final firestoreService = context.watch<FirestoreService>();
    final uid = authService.currentUser?.uid;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal'),
        automaticallyImplyLeading: true,
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
                    return _buildErrorState();
                  }

                  final entries = snapshot.data ?? <JournalEntryModel>[];

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildDiaryHero(),
                        const SizedBox(height: 24),
                        Text(
                          'Gentle prompts',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 10),
                        _buildPromptRow(),
                        const SizedBox(height: 26),
                        Text(
                          entries.isEmpty ? 'Start your diary' : 'Recent entries',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 10),
                        if (entries.isEmpty)
                          _buildEmptyState()
                        else
                          ...entries.map(
                            (entry) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _JournalEntryCard(
                                entry: entry,
                                accentColor: entries.indexOf(entry).isEven
                                    ? AppTheme.primary
                                    : AppTheme.secondary,
                                onEdit: () => _openEditSheet(entry),
                                onDelete: () => _confirmDelete(entry),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildDiaryHero() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradientFor(Theme.of(context).brightness),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'A MOMENT FOR YOU',
                  style: TextStyle(
                    color: Color(0xFF806B59),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'What’s on your mind?',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Write as much or as little as you want.',
                  style: TextStyle(
                    color: Color(0xFF806B59),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _openNewEntrySheet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('New entry'),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Text('✎', style: TextStyle(fontSize: 48, color: Color(0xFFC78D61))),
        ],
      ),
    );
  }

  Widget _buildPromptRow() {
    return SizedBox(
      height: 54,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _journalPrompts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final prompt = _journalPrompts[index];
          return InkWell(
            onTap: () => _openNewEntrySheet(prompt: prompt),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppTheme.surfaceBorder.withValues(alpha: 0.78),
                ),
              ),
              child: Text(
                prompt,
                style: const TextStyle(
                  color: AppTheme.textLight,
                  fontSize: 12,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppTheme.surfaceBorder.withValues(alpha: 0.78),
        ),
      ),
      child: const Column(
        children: [
          Icon(Icons.book_outlined, size: 48, color: AppTheme.textLight),
          SizedBox(height: 14),
          Text(
            'Your first entry can start small.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 7),
          Text(
            'You do not need the perfect words. Just begin wherever you are.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textLight, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Your journal could not load right now. Check your connection and try again.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.danger),
        ),
      ),
    );
  }
}

class _JournalEntryCard extends StatelessWidget {
  final JournalEntryModel entry;
  final Color accentColor;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _JournalEntryCard({
    required this.entry,
    required this.accentColor,
    required this.onEdit,
    required this.onDelete,
  });

  String _formatDate(DateTime date) {
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
    return '${months[date.month - 1]} ${date.day} · $hour:$minute $ampm';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: AppTheme.surfaceBorder.withValues(alpha: 0.78),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 7, color: accentColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            entry.prompt.isEmpty
                                ? _formatDate(entry.date)
                                : entry.prompt,
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 12,
                              fontStyle: entry.prompt.isNotEmpty
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.more_vert,
                            size: 20,
                            color: AppTheme.textLight,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          onSelected: (value) {
                            if (value == 'edit') onEdit();
                            if (value == 'delete') onDelete();
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(value: 'edit', child: Text('Edit')),
                            PopupMenuItem(value: 'delete', child: Text('Delete')),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      entry.content,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 15, height: 1.4),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _formatDate(entry.date),
                      style: const TextStyle(
                        color: AppTheme.textLight,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JournalEntrySheet extends StatefulWidget {
  final JournalEntryModel? existingEntry;
  final String? initialPrompt;

  const _JournalEntrySheet({
    this.existingEntry,
    this.initialPrompt,
  });

  @override
  State<_JournalEntrySheet> createState() => _JournalEntrySheetState();
}

class _JournalEntrySheetState extends State<_JournalEntrySheet> {
  late final TextEditingController _contentController;
  late String _selectedPrompt;
  bool _isSaving = false;
  String? _errorText;

  bool get _isEditing => widget.existingEntry != null;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(
      text: widget.existingEntry?.content ?? '',
    );
    _selectedPrompt =
        widget.existingEntry?.prompt ?? widget.initialPrompt ?? '';
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
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
      if (_isEditing) {
        final updated = JournalEntryModel(
          id: widget.existingEntry!.id,
          uid: uid,
          prompt: _selectedPrompt,
          content: _contentController.text.trim(),
          date: widget.existingEntry!.date,
        );
        await firestoreService.updateJournalEntry(updated);
      } else {
        final entry = JournalEntryModel(
          id: '',
          uid: uid,
          prompt: _selectedPrompt,
          content: _contentController.text.trim(),
          date: DateTime.now(),
        );
        await firestoreService.addJournalEntry(entry);
      }

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorText = 'Something went wrong saving your entry. Please try again.';
      });
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final surface = Theme.of(context).colorScheme.surface;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(26),
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                _isEditing ? 'Edit entry' : 'New journal entry',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Your entry is private. Use a prompt or start wherever you are.',
                style: TextStyle(
                  color: AppTheme.textLight,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Choose a prompt (optional)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 9),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _journalPrompts.map((prompt) {
                  final isSelected = _selectedPrompt == prompt;
                  return ChoiceChip(
                    label: Text(
                      prompt,
                      style: const TextStyle(fontSize: 12),
                    ),
                    selected: isSelected,
                    selectedColor: AppTheme.secondary.withValues(alpha: 0.25),
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
                maxLines: 7,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Write here...',
                  filled: true,
                  fillColor: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withValues(alpha: 0.45),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              if (_errorText != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorText!,
                  style: const TextStyle(
                    color: AppTheme.danger,
                    fontSize: 14,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(_isEditing ? 'Save changes' : 'Save entry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
