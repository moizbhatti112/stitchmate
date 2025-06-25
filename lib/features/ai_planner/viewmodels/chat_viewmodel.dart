// lib/features/ai_planner/viewmodels/chat_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:stitchmate/features/ai_planner/services/chat_service.dart';

class ChatViewModel extends ChangeNotifier {
  final ChatService _chatService = ChatService();

  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => _messages;

  bool _isTyping = false;
  bool get isTyping => _isTyping;

  final ChatUser _currentUser = ChatUser(
    id: '1',
    firstName: 'User',
    lastName: '',
  );
  ChatUser get currentUser => _currentUser;

  final ChatUser _assistantUser = ChatUser(
    id: '2',
    firstName: 'Gemini', // Updated to reflect Google Gemini
    lastName: '',
  );
  ChatUser get assistantUser => _assistantUser;

  Future<void> loadInitialGreeting() async {
    setTyping(true);

    try {
      final response = await _chatService.getInitialGreeting();

      // Debug the response
      debugPrint('Initial greeting received: $response');

      // Make sure we explicitly add the bot message to the UI
      addBotMessage(response);
    } catch (e) {
      debugPrint('Error loading initial greeting: $e');
      // More user-friendly fallback message
      addBotMessage("Hello! I'm your AI assistant . How can I help you today?");
    } finally {
      setTyping(false);
    }
  }

  Future<void> sendMessage(ChatMessage message) async {
    // Add user message to list
    _messages.insert(0, message);
    notifyListeners();

    setTyping(true);

    try {
      // Extract just the text content from the user message
      final String userText = message.text;

      // Send to API and get response
      final response = await _chatService.sendMessage(userText);

      // Debug the response
      debugPrint('Gemini response received: $response');

      // Always add the bot message to the UI, even if it's the fallback response
      // from the service which should never be empty now
      addBotMessage(response);
    } catch (e) {
      // Get more details about the error
      debugPrint('Error sending message: $e');

      // Check for specific error types
      String errorMessage =
          "Sorry, there was an error processing your request.";

      if (e.toString().contains('token') || e.toString().contains('api key')) {
        errorMessage =
            "There seems to be an issue with the API key. Please check your configuration.";
      } else if (e.toString().contains('timeout')) {
        errorMessage = "The request timed out. Please try again.";
      } else if (e.toString().contains('network')) {
        errorMessage = "Please check your internet connection and try again.";
      }

      addBotMessage(errorMessage);
    } finally {
      setTyping(false);
    }
  }

  void addBotMessage(String text) {
    // Debug statement to verify the text content
    debugPrint('Adding bot message to UI: $text');

    final botMessage = ChatMessage(
      user: _assistantUser,
      createdAt: DateTime.now(),
      text: text,
    );

    // Ensure we're adding the message correctly
    _messages.insert(0, botMessage);

    // Make sure to call notifyListeners() to update the UI
    notifyListeners();

    // Double-check that the message was added
    debugPrint('Current message count: ${_messages.length}');
  }

  void setTyping(bool isTyping) {
    _isTyping = isTyping;
    notifyListeners();
  }

  // Clear chat history (UI and backend)
  void clearChat() {
    _messages.clear();
    _chatService.clearConversation();
    notifyListeners();
  }

  // Change assistant behavior with a new system prompt
  void updateAssistantBehavior(String systemPrompt) {
    _chatService.updateSystemPrompt(systemPrompt);
    // Optionally add a system message to inform the user
    addBotMessage("Assistant behavior updated. How can I help you now?");
  }

  // Update the Gemini API key
  Future<bool> updateApiKey(String apiKey) async {
    try {
      bool result = await _chatService.updateApiKey(apiKey);
      if (result) {
        addBotMessage(
          "API key updated successfully. You can now use Google Gemini.",
        );
      } else {
        addBotMessage(
          "There was a problem saving your API key. Please try again.",
        );
      }
      return result;
    } catch (e) {
      debugPrint('Error updating API key: $e');
      addBotMessage("Error updating API key: ${e.toString()}");
      return false;
    }
  }

  // Update the Gemini model
  Future<bool> updateModel(String model) async {
    try {
      bool result = await _chatService.updateModel(model);
      if (result) {
        addBotMessage("Model updated to $model. How can I help you now?");
      } else {
        addBotMessage(
          "There was a problem updating the model. Please try again.",
        );
      }
      return result;
    } catch (e) {
      debugPrint('Error updating model: $e');
      addBotMessage("Error updating model: ${e.toString()}");
      return false;
    }
  }

  // Save chat history to local storage
  Future<void> saveChatHistory() async {
    // Implement saving chat to local storage
    // This would require a storage service implementation
    debugPrint('Saving chat history...');
    // Example implementation would go here
  }

  // Load chat history from local storage
  Future<void> loadChatHistory() async {
    // Implement loading chat from local storage
    // This would require a storage service implementation
    debugPrint('Loading chat history...');
    // Example implementation would go here
  }

  // Check API connection
  Future<bool> testApiConnection() async {
    setTyping(true);
    try {
      bool result = await _chatService.testApiConnection();
      setTyping(false);
      return result;
    } catch (e) {
      debugPrint('API connection test failed: $e');
      addBotMessage(
        "Diagnostic: API connection failed. Error: ${e.toString()}",
      );
      setTyping(false);
      return false;
    }
  }

  // Run diagnostics to check system functionality
  void runDiagnostics() async {
    addBotMessage("Running diagnostics...");

    // Test 1: API Connection
    bool apiConnectionOk = await testApiConnection();
    addBotMessage(
      "Google Gemini API Connection: ${apiConnectionOk ? '✅ Good' : '❌ Failed'}",
    );

    // Test 2: Check http package version
    try {
      addBotMessage("Please check pubspec.yaml for http package version");

      // Test 3: Check available models
      try {
        final models = await _chatService.getAvailableModels();
        if (models.isNotEmpty) {
          addBotMessage("Available Gemini models: ${models.join(', ')}");
        } else {
          addBotMessage("Could not retrieve available models.");
        }
      } catch (e) {
        addBotMessage("Error checking available models: $e");
      }
    } catch (e) {
      addBotMessage("Diagnostic error: $e");
    }

    addBotMessage(
      "Diagnostics complete. If you're seeing errors, please check your API key and internet connection.",
    );
  }

  @override
  void dispose() {
    _chatService.dispose();
    super.dispose();
  }
}
