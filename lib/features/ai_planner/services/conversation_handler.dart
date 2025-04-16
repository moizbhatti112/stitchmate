// lib/features/ai_planner/services/conversation_handler.dart
import 'package:flutter/foundation.dart';

// Role enum for message participants - keep the same for API compatibility
enum MessageRole { system, user, assistant }

// Message class with role and content
class ChatMessageData {
  final MessageRole role;
  final String content;

  ChatMessageData({required this.role, required this.content});

  // Convert to map for API requests
  Map<String, String> toMap() {
    return {'role': role.name, 'content': content};
  }
}

class ConversationHandler {
  // Track conversation history
  final List<ChatMessageData> _conversationHistory = [
    // Start with a system message to set the assistant's behavior
    ChatMessageData(
      role: MessageRole.system,
      content: "You are a helpful AI assistant.Don't use your name",
    ),
  ];

  List<ChatMessageData> get conversationHistory =>
      List.unmodifiable(_conversationHistory);

  // Add a user message to the conversation
  void addUserMessage(String message) {
    _conversationHistory.add(
      ChatMessageData(role: MessageRole.user, content: message),
    );
  }

  // Add an assistant message to the conversation
  void addAssistantMessage(String message) {
    _conversationHistory.add(
      ChatMessageData(role: MessageRole.assistant, content: message),
    );
  }

  // Prepare messages for API request with conversation context
  // Includes a sliding window to maintain context within token limits
  List<ChatMessageData> prepareMessagesForRequest({
    int maxContextMessages = 10,
  }) {
    // Always keep the system message at the beginning
    final systemMessage = _conversationHistory.first;

    // Get the most recent messages for context
    final recentMessages =
        _conversationHistory.length <= maxContextMessages + 1
            ? _conversationHistory.sublist(1) // Skip system message
            : _conversationHistory.sublist(
              _conversationHistory.length - maxContextMessages,
            );

    // Combine system message with recent context
    return [systemMessage, ...recentMessages];
  }

  // Clear conversation history but keep system message
  void clearConversation() {
    final systemMessage = _conversationHistory.first;
    _conversationHistory.clear();
    _conversationHistory.add(systemMessage);
  }

  // Update system message to change assistant behavior
  void updateSystemMessage(String systemPrompt) {
    if (_conversationHistory.isNotEmpty &&
        _conversationHistory.first.role == MessageRole.system) {
      _conversationHistory[0] = ChatMessageData(
        role: MessageRole.system,
        content: systemPrompt,
      );
    } else {
      // If no system message exists, add one at the beginning
      _conversationHistory.insert(
        0,
        ChatMessageData(role: MessageRole.system, content: systemPrompt),
      );
    }
  }

  // Debug method to print conversation history
  void debugPrintConversation() {
    debugPrint('--- Conversation History ---');
    for (var message in _conversationHistory) {
      debugPrint('${message.role.name}: ${message.content}');
    }
    debugPrint('---------------------------');
  }
}
