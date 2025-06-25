import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:stitchmate/features/ai_planner/services/conversation_handler.dart';
import 'package:stitchmate/features/ai_planner/services/gemini_api_config.dart';

class ChatService {
  // Use GeminiApiConfig to manage API key
  final GeminiApiConfig _apiConfig = GeminiApiConfig();

  // Google Gemini API base URL
  final String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  String _model =
      'gemini-2.0-flash'; // Default model, will be loaded from config

  final ConversationHandler _conversation = ConversationHandler();

  ChatService() {
    // Load the model preference when service is initialized
    _loadModelPreference();
    // Ensure we're using the correct model immediately
    _model = 'gemini-2.0-flash';
  }

  // Load saved model preference
  Future<void> _loadModelPreference() async {
    // Force using gemini-2.0-flash regardless of saved preference
    _model = 'gemini-2.0-flash';
    // Update the stored preference to match
    await _apiConfig.setModel(_model);
    debugPrint('Model set to: $_model');
  }

  // Update API key
  Future<bool> updateApiKey(String apiKey) async {
    return await _apiConfig.setApiKey(apiKey);
  }

  // Update model
  Future<bool> updateModel(String model) async {
    // Always enforce using gemini-2.0-flash
    if (model != 'gemini-2.0-flash') {
      debugPrint(
        'Attempted to change model to $model, enforcing gemini-2.0-flash',
      );
      model = 'gemini-2.0-flash';
    }
    _model = model;
    return await _apiConfig.setModel(model);
  }

  // Send a message to the Gemini model
  Future<String> sendMessage(String message) async {
    try {
      // Add the user message to our conversation history
      _conversation.addUserMessage(message);

      // Get messages from conversation handler
      final List<ChatMessageData> messagesList =
          _conversation.prepareMessagesForRequest();

      // Format the conversation for Gemini API
      final List<Map<String, dynamic>> formattedMessages =
          messagesList.map((msg) {
            // gemini-2.0-flash only supports "model" and "user" roles
            // Use "model" for both system and assistant messages
            String role = msg.role == MessageRole.user ? "user" : "model";

            return {
              'role': role,
              'parts': [
                {'text': msg.content},
              ],
            };
          }).toList();

      // Get API key from config
      final apiKey = await _apiConfig.getApiKey();
      debugPrint(
        'API Key loaded: ${apiKey.isNotEmpty ? "Valid key found" : "No valid key"}',
      );
      // Check if API key is available
      if (apiKey.isEmpty) {
        throw Exception(
          "API key not set. Please set your Google Gemini API key in settings.",
        );
      }

      // Force using gemini-2.0-flash model
      final String modelToUse = 'gemini-2.0-flash';
      // Create the Gemini API URL with the API key
      final Uri uri = Uri.parse(
        '$_baseUrl/models/$modelToUse:generateContent?key=$apiKey',
      );
      debugPrint('Using model for request: $modelToUse');

      final Map<String, dynamic> requestBody = {
        'contents': formattedMessages,
        'generationConfig': {
          'temperature': 0.7,
          'maxOutputTokens': 2048,
          'topP': 0.95,
          'topK': 40,
        },
      };

      // Print request for debugging
      debugPrint('Request URL: $uri');
      debugPrint('Request Headers: ${{'Content-Type': 'application/json'}}');
      debugPrint('Request Body: ${jsonEncode(requestBody)}');

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      // Print response for debugging
      debugPrint('Response Status: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // Extract response text from Gemini API
        String responseText = '';

        if (responseData.containsKey('candidates') &&
            responseData['candidates'].isNotEmpty &&
            responseData['candidates'][0].containsKey('content') &&
            responseData['candidates'][0]['content'].containsKey('parts') &&
            responseData['candidates'][0]['content']['parts'].isNotEmpty) {
          responseText =
              responseData['candidates'][0]['content']['parts'][0]['text'] ??
              '';
        }

        if (responseText.isEmpty) {
          responseText =
              "I'm ready to assist you. What would you like to know?";
          debugPrint('No content found in response, using fallback');
        }

        // Clean up any unusual formatting in the response
        responseText = cleanResponse(responseText);

        debugPrint('AI Response Text (cleaned): $responseText');

        // Add the assistant's response to our conversation history
        _conversation.addAssistantMessage(responseText);

        return responseText;
      } else {
        String errorDetails = '';
        try {
          final errorData = jsonDecode(response.body);
          errorDetails = errorData['error']?['message'] ?? 'Unknown error';
        } catch (e) {
          errorDetails = response.body;
        }

        debugPrint('API Error: ${response.statusCode} - $errorDetails');

        // More user-friendly error message
        final fallbackMessage =
            "I couldn't process your request. Please try again later.";
        _conversation.addAssistantMessage(fallbackMessage);
        return fallbackMessage;
      }
    } catch (e) {
      debugPrint('Error in ChatService: $e');
      final errorMessage =
          "Sorry, I'm having trouble connecting right now. Please check your internet connection and try again.";
      _conversation.addAssistantMessage(errorMessage);
      return errorMessage;
    }
  }

  Future<String> getInitialGreeting() async {
    try {
      // Get API key from config
      final apiKey = await _apiConfig.getApiKey();

      // Check if API key is available
      if (apiKey.isEmpty) {
        throw Exception(
          "API key not set. Please set your Google Gemini API key in settings.",
        );
      }

      // Force using gemini-2.0-flash model
      final String modelToUse = 'gemini-2.0-flash';
      // Create the Gemini API URL with the API key
      final Uri uri = Uri.parse(
        '$_baseUrl/models/$modelToUse:generateContent?key=$apiKey',
      );

      final Map<String, dynamic> requestBody = {
        'contents': [
          {
            'role': 'user',
            'parts': [
              {'text': 'Say "Hello! How can I help you today?"'},
            ],
          },
        ],
        'generationConfig': {
          'temperature': 0.1, // Lower temperature for more consistent response
          'maxOutputTokens': 20, // Very short response
          'topP': 0.95,
          'topK': 40,
        },
      };

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // Extract greeting text from Gemini API
        String greeting = '';

        if (responseData.containsKey('candidates') &&
            responseData['candidates'].isNotEmpty &&
            responseData['candidates'][0].containsKey('content') &&
            responseData['candidates'][0]['content'].containsKey('parts') &&
            responseData['candidates'][0]['content']['parts'].isNotEmpty) {
          greeting =
              responseData['candidates'][0]['content']['parts'][0]['text'] ??
              '';
        }

        if (greeting.isEmpty) {
          greeting = "Hello! How can I help you today?";
        }

        // Clean up any unusual formatting in the greeting
        greeting = cleanResponse(greeting);

        // Important: Store this initial greeting in the conversation history
        _conversation.addAssistantMessage(greeting);
        return greeting;
      } else {
        // Fallback greeting if API fails
        const fallbackGreeting = "Hello! How can I help you today?";
        _conversation.addAssistantMessage(fallbackGreeting);
        return fallbackGreeting;
      }
    } catch (e) {
      debugPrint('Error getting initial greeting: $e');
      const fallbackGreeting = "Hello! How can I help you today?";
      _conversation.addAssistantMessage(fallbackGreeting);
      return fallbackGreeting;
    }
  }

  // Update the system prompt to change how the assistant behaves
  void updateSystemPrompt(String systemPrompt) {
    _conversation.updateSystemMessage(systemPrompt);
  }

  // Clear conversation history
  void clearConversation() {
    _conversation.clearConversation();
  }

  void dispose() {
    // Nothing to dispose for now
  }

  // Test API connection with more debug information
  Future<bool> testApiConnection() async {
    try {
      // Get API key from config
      final apiKey = await _apiConfig.getApiKey();

      // Check if API key is available
      if (apiKey.isEmpty) {
        throw Exception(
          "API key not set. Please set your Google Gemini API key in settings.",
        );
      }

      // Force using gemini-2.0-flash model
      final String modelToUse = 'gemini-2.0-flash';
      // Create the Gemini API URL with the API key
      final Uri uri = Uri.parse(
        '$_baseUrl/models/$modelToUse:generateContent?key=$apiKey',
      );
      debugPrint('Using model for API test: $modelToUse');

      final Map<String, dynamic> requestBody = {
        'contents': [
          {
            'role': 'user',
            'parts': [
              {'text': 'Hello'},
            ],
          },
        ],
        'generationConfig': {
          'temperature': 0.7,
          'maxOutputTokens': 5,
          'topP': 0.95,
          'topK': 40,
        },
      };

      debugPrint('Testing API connection to: $uri');

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      debugPrint('API test response status: ${response.statusCode}');
      debugPrint('API test response body: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('API connection test failed: $e');
      return false;
    }
  }

  // Get available Gemini models
  Future<List<String>> getAvailableModels() async {
    try {
      // Get API key from config
      final apiKey = await _apiConfig.getApiKey();

      // Check if API key is available
      if (apiKey.isEmpty) {
        throw Exception(
          "API key not set. Please set your Google Gemini API key in settings.",
        );
      }

      final Uri uri = Uri.parse('$_baseUrl/models?key=$apiKey');

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        final List<dynamic> models = responseData['models'] ?? [];
        return models.map((model) => model['name'].toString()).toList();
      } else {
        debugPrint(
          'Failed to get available models: ${response.statusCode} - ${response.body}',
        );
        return [];
      }
    } catch (e) {
      debugPrint('Error getting available models: $e');
      return [];
    }
  }

  String cleanResponse(String text) {
    // If text is empty or null, return a default response
    if (text.isEmpty) {
      return "I'm here to help you. What would you like to know?";
    }

    // Remove flutter log prefixes
    text = text.replaceAll(RegExp(r'I/flutter \(\d+\):', multiLine: true), '');

    // Remove JSON code blocks
    text = text.replaceAll(RegExp(r'```json[\s\S]*?```', multiLine: true), '');

    // Remove LaTeX-style \boxed{} content wrappers
    text = text.replaceAll('\\boxed{', '');
    text = text.replaceAll('}', '');

    // Remove any "thoughts:" or "reasoning:" prefixes
    text = text.replaceAll(
      RegExp(r'(thoughts|reasoning):\s*', caseSensitive: false),
      '',
    );

    // Clean up any excessive whitespace
    text = text.trim().replaceAll(RegExp(r'\s+'), ' ');

    // If after all cleaning we have an empty string, return a default
    if (text.trim().isEmpty) {
      return "I'm here to help you. What would you like to know?";
    }

    return text;
  }
}
