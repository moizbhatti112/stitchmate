import 'package:shared_preferences/shared_preferences.dart';

class GeminiApiConfig {
  // Keys for SharedPreferences
  static const String _apiKeyPrefKey = 'gemini_api_key';
  static const String _modelPrefKey = 'gemini_model';
  
  // Default model
  static const String _defaultModel = 'gemini-2.0-flash';

  // Default API key (for testing purposes only)
  static const String _defaultApiKey = 'AIzaSyAaDdLQ7vvT30Y6c0q-je340jybUCIxVvU';
  
  // Get the stored API key
  Future<String> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    // Return the stored API key or the default key if none is stored
    return prefs.getString(_apiKeyPrefKey) ?? _defaultApiKey;
  }
  
  // Set a new API key
  Future<bool> setApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_apiKeyPrefKey, apiKey);
  }
  
  // Get the selected model
  Future<String> getModel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_modelPrefKey) ?? _defaultModel;
  }
  
  // Set a new model
  Future<bool> setModel(String model) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_modelPrefKey, model);
  }
}