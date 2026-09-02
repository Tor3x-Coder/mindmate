import 'package:flutter/material.dart';

import '../../models/learn_article_model.dart';
import '../../services/chat_service.dart';
import '../../utils/app_theme.dart';

class _ChatMessage {
  final String role;
  final String content;
  final bool isError;

  const _ChatMessage({
    required this.role,
    required this.content,
    this.isError = false,
  });
}

class ChatTabScreen extends StatefulWidget {
  final LearnArticle? learnArticle;

  const ChatTabScreen({
    super.key,
    this.learnArticle,
  });

  @override
  State<ChatTabScreen> createState() => _ChatTabScreenState();
}

class _ChatTabScreenState extends State<ChatTabScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocusNode = FocusNode();

  final List<_ChatMessage> _messages = [];
  bool _isSending = false;
  String? _activeMode;
  LearnArticle? _activeLearnArticle;

  @override
  void initState() {
    super.initState();
    _activeLearnArticle = widget.learnArticle;
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  void _useStarter(String starter) {
    setState(() {
      _activeMode = null;
      _inputController.text = starter;
    });
    _inputController.selection = TextSelection.fromPosition(
      TextPosition(offset: _inputController.text.length),
    );
    _inputFocusNode.requestFocus();
  }

  void _useMode(String mode) {
    switch (mode) {
      case 'listen':
        _useStarter('I just need someone to listen. ');
        break;
      case 'calm':
        _useStarter('I need help calming down. ');
        break;
      case 'plan':
        _useStarter('Help me make a small plan for ');
        break;
    }
    // The starter helper clears the mode; re-apply it afterwards so the
    // chosen direction is actually sent with the first message.
    setState(() => _activeMode = mode);
  }

  void _showAiBoundary() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About the AI companion'),
        content: const Text(
          'MindMate can listen, help you reflect, and suggest small next steps. It is not a therapist, doctor, or emergency service. If you may be in immediate danger, use Emergency Support instead.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _isSending) return;

    // Keep the client request small while the backend history limit is still
    // being completed in the AI safety batch.
    final previousMessages = _messages
        .where((message) => !message.isError)
        .toList();
    final history = previousMessages
        .skip(previousMessages.length > 12 ? previousMessages.length - 12 : 0)
        .map((message) => {
              'role': message.role,
              'content': message.content,
            })
        .toList();

    final modeToSend = _activeMode;
    final learnContextToSend = _activeLearnArticle?.aiContext;
    setState(() {
      _messages.add(_ChatMessage(role: 'user', content: text));
      _isSending = true;
      _activeMode = null;
      _inputController.clear();
    });
    _scrollToBottom();

    try {
      final reply = await _chatService.sendMessage(
        userMessage: text,
        history: history,
        mode: modeToSend,
        learnContext: learnContextToSend,
      );

      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMessage(role: 'assistant', content: reply));
        _isSending = false;
      });
      _scrollToBottom();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _messages.add(
          const _ChatMessage(
            role: 'assistant',
            content:
                'I could not connect right now. You can try again or use one of the guided practices instead.',
            isError: true,
          ),
        );
        _isSending = false;
      });
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Talk with MindMate'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: _showAiBoundary,
            icon: const Icon(Icons.info_outline_rounded),
            tooltip: 'About the AI companion',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_activeLearnArticle != null)
              _buildLearnContextBanner(_activeLearnArticle!),
            Expanded(
              child: _messages.isEmpty
                  ? _buildGuidedStart(isDark)
                  : ListView.builder(
                      controller: _scrollController,
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                      itemCount: _messages.length + (_isSending ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _messages.length) {
                          return _buildTypingIndicator(isDark);
                        }
                        return _buildMessageBubble(_messages[index], isDark);
                      },
                    ),
            ),
            _buildInputBar(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildLearnContextBanner(LearnArticle article) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      decoration: BoxDecoration(
        color: AppTheme.secondary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.secondary.withValues(alpha: 0.38),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.menu_book_rounded,
            color: AppTheme.primary,
            size: 20,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              'Using this read: ${article.title}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppTheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
          ),
          TextButton(
            onPressed: () => setState(() => _activeLearnArticle = null),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidedStart(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppTheme.heroGradientFor(Theme.of(context).brightness),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.55),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chat_bubble_outline_rounded,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'I’m here to listen.',
                        style: TextStyle(
                          color: AppTheme.textDark,
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  'Choose a direction, or type whatever is on your mind.',
                  style: TextStyle(
                    color: Color(0xFF59646F),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'The AI companion supports reflection. It is not therapy or emergency care.',
                  style: TextStyle(
                    color: const Color(0xFF59646F).withValues(alpha: 0.85),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'What do you need?',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _ModeCard(
                  icon: Icons.favorite_border_rounded,
                  label: 'Listen',
                  color: AppTheme.primary,
                  onTap: () => _useMode('listen'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ModeCard(
                  icon: Icons.air_rounded,
                  label: 'Calm me',
                  color: AppTheme.secondary,
                  onTap: () => _useMode('calm'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ModeCard(
                  icon: Icons.checklist_rounded,
                  label: 'Make a plan',
                  color: AppTheme.accent,
                  onTap: () => _useMode('plan'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Try saying',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          _StarterTile(
            text: 'I keep overthinking what happened.',
            onTap: () => _useStarter('I keep overthinking what happened.'),
          ),
          _StarterTile(
            text: 'Help me take one small next step.',
            onTap: () => _useStarter('Help me take one small next step.'),
          ),
          _StarterTile(
            text: 'I just want to talk about what went well today.',
            onTap: () => _useStarter(
              'I just want to talk about what went well today.',
            ),
          ),
          const SizedBox(height: 18),
          if (!isDark)
            const Text(
              'You can change your mind at any time and use a guided practice instead.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textLight, fontSize: 12),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(_ChatMessage message, bool isDark) {
    final isUser = message.role == 'user';
    final bubbleColor = isUser
        ? AppTheme.primary
        : message.isError
            ? AppTheme.danger.withValues(alpha: isDark ? 0.18 : 0.10)
            : Theme.of(context).colorScheme.surface;
    final textColor = isUser
        ? Colors.white
        : message.isError
            ? AppTheme.danger
            : Theme.of(context).colorScheme.onSurface;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
          border: (!isUser && !message.isError)
              ? Border.all(color: Theme.of(context).dividerColor)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          message.content,
          style: TextStyle(color: textColor, fontSize: 14, height: 1.4),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator(bool isDark) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(18),
          ),
        ),
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _inputController,
                focusNode: _inputFocusNode,
                minLines: 1,
                maxLines: 4,
                maxLength: 800,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.send,
                enabled: !_isSending,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: 'Type what’s on your mind...',
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.03),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.accentGradient,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _isSending ? null : _sendMessage,
                icon: const Icon(Icons.arrow_upward_rounded),
                color: Colors.white,
                tooltip: 'Send message',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ModeCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppTheme.surfaceBorder.withValues(alpha: 0.78),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 23),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _StarterTile extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _StarterTile({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.surfaceBorder.withValues(alpha: 0.78),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '“$text”',
                  style: const TextStyle(
                    color: AppTheme.textLight,
                    fontSize: 13,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
