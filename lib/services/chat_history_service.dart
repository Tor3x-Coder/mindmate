import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'chat_service.dart';

/// Local-only Chat history. Conversations are keyed by the signed-in user so
/// a shared device does not show one person's chats to another account.
class ChatHistoryService {
  static const int maxConversations = 12;
  static const int maxMessagesPerConversation = 24;
  static const int maxStoredContentChars = 4000;
  static const String _keyPrefix = 'mindmate_chat_history_v1_';

  Future<List<ChatConversation>> load(String userKey) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey(userKey));
    if (raw == null || raw.trim().isEmpty) return [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      final conversations = <ChatConversation>[];
      for (final item in decoded) {
        if (item is! Map<String, dynamic>) continue;
        try {
          conversations.add(ChatConversation.fromMap(item));
        } on FormatException {
          // Ignore one damaged item without losing all other saved chats.
        }
      }
      conversations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return conversations.take(maxConversations).toList(growable: false);
    } on FormatException {
      return [];
    } on TypeError {
      return [];
    }
  }

  Future<void> save(
    String userKey,
    List<ChatConversation> conversations,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final bounded = conversations
        .map(_boundConversation)
        .where((conversation) => conversation.messages.isNotEmpty)
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    await prefs.setString(
      _storageKey(userKey),
      jsonEncode(bounded.take(maxConversations).map((item) => item.toMap()).toList()),
    );
  }

  Future<void> clear(String userKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey(userKey));
  }

  String _storageKey(String userKey) {
    final clean = userKey.trim();
    if (clean.isEmpty) return '${_keyPrefix}guest';
    // UIDs/emails normally contain safe characters, but keeping the key
    // predictable avoids unexpected preference-key characters on web.
    final safe = clean.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    return '$_keyPrefix$safe';
  }

  ChatConversation _boundConversation(ChatConversation conversation) {
    final boundedMessages = conversation.messages
        .map(_boundMessage)
        .toList();
    final start = boundedMessages.length > maxMessagesPerConversation
        ? boundedMessages.length - maxMessagesPerConversation
        : 0;
    return conversation.copyWith(
      messages: boundedMessages.sublist(start),
      title: _boundText(conversation.title, 80),
    );
  }

  ChatHistoryMessage _boundMessage(ChatHistoryMessage message) {
    return ChatHistoryMessage(
      role: message.role,
      content: _boundText(message.content, maxStoredContentChars),
      actionType: message.actionType == ChatAction.openEmergencySupportWireValue
          ? message.actionType
          : null,
    );
  }

  String _boundText(String value, int maxChars) {
    final clean = value.trim();
    return clean.length > maxChars ? clean.substring(0, maxChars) : clean;
  }
}

class ChatHistoryMessage {
  final String role;
  final String content;
  final String? actionType;

  const ChatHistoryMessage({
    required this.role,
    required this.content,
    this.actionType,
  });

  factory ChatHistoryMessage.fromMap(Map<String, dynamic> map) {
    final role = map['role'];
    final content = map['content'];
    if ((role != 'user' && role != 'assistant') ||
        content is! String ||
        content.trim().isEmpty) {
      throw const FormatException('Invalid saved Chat message.');
    }

    final actionType = map['actionType'];
    return ChatHistoryMessage(
      role: role,
      content: content.trim(),
      actionType: actionType == ChatAction.openEmergencySupportWireValue
          ? actionType
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'role': role,
        'content': content,
        if (actionType != null) 'actionType': actionType,
      };
}

class ChatConversation {
  final String id;
  final String title;
  final DateTime updatedAt;
  final String? learnArticleId;
  final List<ChatHistoryMessage> messages;

  const ChatConversation({
    required this.id,
    required this.title,
    required this.updatedAt,
    required this.messages,
    this.learnArticleId,
  });

  factory ChatConversation.fromMap(Map<String, dynamic> map) {
    final id = map['id'];
    final title = map['title'];
    final updatedAtRaw = map['updatedAt'];
    final rawMessages = map['messages'];
    if (id is! String ||
        id.trim().isEmpty ||
        title is! String ||
        updatedAtRaw is! String ||
        rawMessages is! List) {
      throw const FormatException('Invalid saved Chat conversation.');
    }

    final updatedAt = DateTime.tryParse(updatedAtRaw);
    if (updatedAt == null) {
      throw const FormatException('Invalid saved Chat date.');
    }

    final messages = rawMessages
        .whereType<Map<String, dynamic>>()
        .map(ChatHistoryMessage.fromMap)
        .toList(growable: false);
    if (messages.isEmpty) {
      throw const FormatException('Saved Chat has no messages.');
    }

    final articleId = map['learnArticleId'];
    return ChatConversation(
      id: id.trim(),
      title: title.trim().isEmpty ? 'Conversation' : title.trim(),
      updatedAt: updatedAt,
      learnArticleId: articleId is String && articleId.trim().isNotEmpty
          ? articleId.trim()
          : null,
      messages: messages,
    );
  }

  ChatConversation copyWith({
    String? title,
    DateTime? updatedAt,
    String? learnArticleId,
    List<ChatHistoryMessage>? messages,
  }) {
    return ChatConversation(
      id: id,
      title: title ?? this.title,
      updatedAt: updatedAt ?? this.updatedAt,
      learnArticleId: learnArticleId ?? this.learnArticleId,
      messages: messages ?? this.messages,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'updatedAt': updatedAt.toIso8601String(),
        if (learnArticleId != null) 'learnArticleId': learnArticleId,
        'messages': messages.map((message) => message.toMap()).toList(),
      };
}
