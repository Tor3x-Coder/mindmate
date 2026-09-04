import 'package:flutter_test/flutter_test.dart';
import 'package:mindmate/services/chat_history_service.dart';
import 'package:mindmate/services/chat_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('saves bounded conversations locally and restores known actions', () async {
    final service = ChatHistoryService();
    final conversations = List.generate(
      14,
      (index) => ChatConversation(
        id: 'chat-$index',
        title: 'Conversation $index',
        updatedAt: DateTime(2026, 9, 1).add(Duration(minutes: index)),
        learnArticleId: index.isEven ? 'substances' : null,
        messages: [
          const ChatHistoryMessage(
            role: 'user',
            content: 'I need one small next step.',
          ),
          if (index == 13)
            const ChatHistoryMessage(
              role: 'assistant',
              content: 'Please open Emergency Support.',
              actionType: ChatAction.openEmergencySupportWireValue,
            ),
        ],
      ),
    );

    await service.save('user/a', conversations);
    final restored = await service.load('user/a');

    expect(restored, hasLength(ChatHistoryService.maxConversations));
    expect(restored.first.id, 'chat-13');
    expect(restored.first.messages.last.actionType,
        ChatAction.openEmergencySupportWireValue);

    final otherUser = await service.load('user/b');
    expect(otherUser, isEmpty);
  });

  test('keeps only the most recent messages and ignores unknown actions', () async {
    final service = ChatHistoryService();
    final messages = List.generate(
      30,
      (index) => ChatHistoryMessage(
        role: index.isEven ? 'user' : 'assistant',
        content: 'Message $index',
        actionType: index == 29 ? 'open_unknown_screen' : null,
      ),
    );

    await service.save(
      'bounded-user',
      [
        ChatConversation(
          id: 'bounded',
          title: 'A long conversation',
          updatedAt: DateTime(2026, 9, 1),
          messages: messages,
        ),
      ],
    );

    final restored = await service.load('bounded-user');
    expect(restored.single.messages, hasLength(24));
    expect(restored.single.messages.first.content, 'Message 6');
    expect(restored.single.messages.last.actionType, isNull);
  });

  test('clear removes only the selected account history', () async {
    final service = ChatHistoryService();
    final chat = ChatConversation(
      id: 'chat',
      title: 'A chat',
      updatedAt: DateTime(2026, 9, 1),
      messages: const [
        ChatHistoryMessage(role: 'user', content: 'Hello'),
      ],
    );

    await service.save('first-user', [chat]);
    await service.save('second-user', [chat]);
    await service.clear('first-user');

    expect(await service.load('first-user'), isEmpty);
    expect(await service.load('second-user'), hasLength(1));
  });
}
