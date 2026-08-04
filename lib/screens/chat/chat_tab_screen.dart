import 'package:flutter/material.dart';
import '../../services/chat_service.dart';
import '../../utils/app_theme.dart';

// A single message in the conversation, kept simple on purpose —
// this is just what's needed to draw a chat bubble and to send history
// back to the AI. Nothing here is saved to Firestore yet (that's the
// next phase); it only lives in memory while this screen is open.
class _ChatMessage {
  final String role; // 'user' or 'assistant'
  final String content;
  final bool isError; // true if this bubble represents a failed send

  _ChatMessage({
    required this.role,
    required this.content,
    this.isError = false,
  });
}

class ChatTabScreen extends StatefulWidget {
  const ChatTabScreen({super.key});

  @override
  State<ChatTabScreen> createState() => _ChatTabScreenState();
}

class _ChatTabScreenState extends State<ChatTabScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<_ChatMessage> _messages = [];

  // True while we're waiting on a reply from the AI — used to disable
  // the send button and show a "typing" indicator, so the user can't
  // fire off five messages before the first one even lands.
  bool _isSending = false;

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Scrolls the message list down to the newest message. Called after
  // adding any new bubble so the user always sees the latest one.
  void _scrollToBottom() {
    // Wait a frame so the new bubble has actually been laid out before
    // we try to scroll to it — otherwise maxScrollExtent is stale.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _isSending) return;

    // Build the history list the AI needs for context, BEFORE adding
    // the new user message to it — this should only contain turns that
    // already happened, not the one we're sending right now.
    final history = _messages
        .where((m) => !m.isError) // don't send failed turns back to the AI
        .map((m) => {'role': m.role, 'content': m.content})
        .toList();

    setState(() {
      _messages.add(_ChatMessage(role: 'user', content: text));
      _isSending = true;
      _inputController.clear();
    });
    _scrollToBottom();

    try {
      final reply = await _chatService.sendMessage(
        userMessage: text,
        history: history,
      );

      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMessage(role: 'assistant', content: reply));
        _isSending = false;
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      // Strip the "Exception: " prefix Dart adds automatically so the
      // user sees a clean message instead of raw error formatting.
      final message = e.toString().replaceFirst('Exception: ', '');
      setState(() {
        _messages.add(
          _ChatMessage(role: 'assistant', content: message, isError: true),
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
        title: const Text('Chat'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _messages.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length + (_isSending ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _messages.length) {
                          // Extra item at the end while waiting for a reply.
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

  // Shown before the user has sent anything yet.
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                gradient: AppTheme.accentGradient,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                color: Colors.white,
                size: 36,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Your AI companion is here',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            const Text(
              'A place to talk through what\'s on your mind, anytime '
              'someone else isn\'t available.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textLight, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(_ChatMessage message, bool isDark) {
    final isUser = message.role == 'user';

    // User bubbles use the app's accent gradient to match the rest of
    // the app. AI bubbles use a plain surface color so they read as
    // calm/neutral, and error bubbles get a soft red tint so a failed
    // send is obviously different from a normal reply.
    Color bubbleColor;
    Gradient? bubbleGradient;
    Color textColor;

    if (isUser) {
      bubbleGradient = AppTheme.accentGradient;
      bubbleColor = Colors.transparent;
      textColor = Colors.white;
    } else if (message.isError) {
      // AppTheme.danger is the app's single source of truth for "error"
      // red — using it here (instead of a raw Colors.red) keeps this
      // bubble in sync if the theme's danger color ever changes.
      bubbleColor = AppTheme.danger.withValues(alpha: isDark ? 0.18 : 0.12);
      textColor = isDark ? AppTheme.textOnDark : AppTheme.danger;
    } else {
      bubbleColor = Theme.of(context).colorScheme.surface;
      textColor = Theme.of(context).colorScheme.onSurface;
    }

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: bubbleColor,
          gradient: bubbleGradient,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
          // AI bubbles get a subtle border so they're visible against a
          // light-mode background that's very close to the same color.
          // User bubbles (gradient) and error bubbles (tinted red) don't
          // need this since they already stand out on their own.
          border: (!isUser && !message.isError)
              ? Border.all(color: Theme.of(context).dividerColor, width: 1)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
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

  // A simple "..." bubble shown on the AI's side while a reply is loading.
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
          width: 20,
          height: 12,
          child: Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
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
                minLines: 1,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                enabled: !_isSending,
                decoration: InputDecoration(
                  hintText: 'Type what\'s on your mind...',
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
                onSubmitted: (_) => _sendMessage(),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}