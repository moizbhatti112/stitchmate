import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stitchmate/core/constants/colors.dart';
import 'package:stitchmate/features/ai_planner/viewmodels/chat_viewmodel.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _customPromptController = TextEditingController();
  final TextEditingController _apiKeyController =
      TextEditingController(); // Controller for API key
  String _selectedModel = 'gemini-pro'; // Default model

  @override
  void initState() {
    super.initState();
    // Load initial greeting when the screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Ensure we're calling loadInitialGreeting
      debugPrint('Loading initial greeting...');
      context.read<ChatViewModel>().loadInitialGreeting();
    });
  }

  @override
  void dispose() {
    _customPromptController.dispose();
    _apiKeyController.dispose(); // Dispose the API key controller
    super.dispose();
  }

  // Share chat history as text
  void _shareChat(List<ChatMessage> messages) {
    // Create shareable text from messages
    final String chatText = messages.reversed
        .map((message) {
          final sender =
              message.user.id == '1' ? 'You' : 'Gemini'; // Updated to Gemini
          return '$sender: ${message.text}\n';
        })
        .join('\n');

    if (chatText.isNotEmpty) {
      Share.share(
        chatText,
        subject: 'My Gemini Chat Conversation',
      ); // Updated subject
    }
  }

  // Show dialog to customize assistant behavior
  void _showCustomizeAssistantDialog(
    BuildContext context,
    ChatViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Customize Gemini Assistant'), // Updated title
          content: TextField(
            controller: _customPromptController,
            decoration: const InputDecoration(
              hintText:
                  'Enter system prompt (e.g., "You are a helpful assistant who...")',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_customPromptController.text.isNotEmpty) {
                  viewModel.updateAssistantBehavior(
                    _customPromptController.text,
                  );
                  _customPromptController.clear();
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  // Method to select a Gemini model
  void _showModelSelectionDialog(
    BuildContext context,
    ChatViewModel viewModel,
  ) {
    // List of available Gemini models
    final List<String> availableModels = [
      'gemini-pro',
      'gemini-pro-vision',
      'gemini-ultra', // Note: Ultra may require special access
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final sm=ScaffoldMessenger.of(context);
        return AlertDialog(
          title: const Text('Select Gemini Model'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: availableModels.length,
              itemBuilder: (context, index) {
                return RadioListTile<String>(
                  title: Text(availableModels[index]),
                  value: availableModels[index],
                  groupValue: _selectedModel,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedModel = value!;
                    });
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Here we would update the model in the service
                bool result = await viewModel.updateModel(_selectedModel);
                if (result) {
                  sm.showSnackBar(
                    SnackBar(content: Text('Model updated to $_selectedModel')),
                  );
                }
               if(context.mounted)
               {
                 Navigator.of(context).pop();
               }
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  // Method to set the Gemini API key
  void _showApiKeyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Set Gemini API Key'),
          content: TextField(
            controller: _apiKeyController,
            decoration: const InputDecoration(
              hintText: 'Enter your Google Gemini API key',
              border: OutlineInputBorder(),
            ),
            obscureText: true, // Hide the API key for security
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final sm=ScaffoldMessenger.of(context);
                if (_apiKeyController.text.isNotEmpty) {
                  // Update the API key in the service
                  final result = await context
                      .read<ChatViewModel>()
                      .updateApiKey(_apiKeyController.text);

                  if (result) {
                    sm.showSnackBar(
                      const SnackBar(
                        content: Text('API key updated successfully'),
                      ),
                    );
                  } else {
                    sm.showSnackBar(
                      const SnackBar(
                        content: Text('Failed to update API key'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }

                  _apiKeyController.clear();
                if(context.mounted)
                {
                    Navigator.of(context).pop();
                }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Show confirmation dialog before clearing chat
  void _showClearChatConfirmation(
    BuildContext context,
    ChatViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear Chat'),
          content: const Text(
            'Are you sure you want to clear this conversation? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                viewModel.clearChat();
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant'), // Updated title
        backgroundColor: primaryColor,
        elevation: 2,
        foregroundColor: white,
        actions: [
          // Add a debug button for testing
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () {
              // Test sending a hardcoded message
              final testMessage = ChatMessage(
                user: context.read<ChatViewModel>().currentUser,
                createdAt: DateTime.now(),
                text: "Test message from debug button",
              );
              context.read<ChatViewModel>().sendMessage(testMessage);
            },
          ),
          Consumer<ChatViewModel>(
            builder: (context, viewModel, child) {
              return PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (String value) {
                  switch (value) {
                    case 'clear':
                      _showClearChatConfirmation(context, viewModel);
                      break;
                    case 'share':
                      _shareChat(viewModel.messages);
                      break;
                    case 'customize':
                      _showCustomizeAssistantDialog(context, viewModel);
                      break;
                    case 'diagnose':
                      viewModel.runDiagnostics();
                      break;
                    case 'apikey': // Option for setting API key
                      _showApiKeyDialog(context);
                      break;
                    case 'model': // Option for selecting model
                      _showModelSelectionDialog(context, viewModel);
                      break;
                  }
                },
                itemBuilder:
                    (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'clear',
                        child: ListTile(
                          leading: Icon(Icons.delete_outline),
                          title: Text('Clear Chat'),
                        ),
                      ),
                    ],
              );
            },
          ),
        ],
      ),
      body: Consumer<ChatViewModel>(
        builder: (context, chatViewModel, child) {
          // Debug print to check if messages are available
          debugPrint('Messages count in UI: ${chatViewModel.messages.length}');

          return Container(
            decoration: BoxDecoration(color: bgColor),
            child: Column(
              children: [
                Expanded(
                  child: DashChat(
                    currentUser: chatViewModel.currentUser,
                    messages: chatViewModel.messages,
                    onSend: (ChatMessage message) {
                      // Debug to ensure onSend is being called
                      debugPrint('Message being sent: ${message.text}');
                      chatViewModel.sendMessage(message);
                    },
                    inputOptions: InputOptions(
                      inputDecoration: InputDecoration(
                        hintText: 'Ask something...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: nextbg,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      sendButtonBuilder: (onSend) {
                        return Container(
                          margin: const EdgeInsets.only(left: 8),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.send, color: white),
                            onPressed: onSend,
                          ),
                        );
                      },
                    ),
                    messageOptions: MessageOptions(
                      showTime: true,
                      currentUserContainerColor: primaryColor,
                      containerColor: nextbg,
                      messagePadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      showOtherUsersAvatar: true, // Show assistant avatar
                      showCurrentUserAvatar: true, // Show user avatar
                    ),
                    typingUsers:
                        chatViewModel.isTyping
                            ? [chatViewModel.assistantUser]
                            : [],
                    scrollToBottomOptions: ScrollToBottomOptions(
                      scrollToBottomBuilder: (scrollController) {
                        return Positioned(
                          bottom: 10,
                          right: 10,
                          child: FloatingActionButton.small(
                            backgroundColor: primaryColor,
                            child: const Icon(
                              Icons.arrow_downward,
                              color: white,
                            ),
                            onPressed: () {
                              scrollController.animateTo(
                                0,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if (chatViewModel.isTyping)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    color: white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Assistant is thinking...',
                          style: TextStyle(
                            color: primaryColor,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
