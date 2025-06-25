import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:share_plus/share_plus.dart';
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
 // Default model

  @override
  void initState() {
    super.initState();
    // Load initial greeting when the screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Clear existing chat history first
      context.read<ChatViewModel>().clearChat();
      // Wait a brief moment to ensure clearing is complete
      await Future.delayed(const Duration(milliseconds: 100));
      // Then load the initial greeting
      if (mounted) {
        debugPrint('Loading initial greeting...');
        context.read<ChatViewModel>().loadInitialGreeting();
      }
    });
  }

  @override
  void dispose() {
    _customPromptController.dispose();
    _apiKeyController.dispose(); // Dispose the API key controller
    super.dispose();
  }

  // Share chat history as text

  // Show dialog to customize assistant behavior
  // void _showCustomizeAssistantDialog(
  //   BuildContext context,
  //   ChatViewModel viewModel,
  // ) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Customize Gemini Assistant'), // Updated title
  //         content: TextField(
  //           controller: _customPromptController,
  //           decoration: const InputDecoration(
  //             hintText:
  //                 'Enter system prompt (e.g., "You are a helpful assistant who...")',
  //             border: OutlineInputBorder(),
  //           ),
  //           maxLines: 3,
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.of(context).pop(),
  //             child: const Text('Cancel'),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               if (_customPromptController.text.isNotEmpty) {
  //                 viewModel.updateAssistantBehavior(
  //                   _customPromptController.text,
  //                 );
  //                 _customPromptController.clear();
  //                 Navigator.of(context).pop();
  //               }
  //             },
  //             child: const Text('Apply'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }



  // Method to set the Gemini API key
 

  // Show confirmation dialog before clearing chat
  // void _showClearChatConfirmation(
  //   BuildContext context,
  //   ChatViewModel viewModel,
  // ) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Clear Chat'),
  //         content: const Text(
  //           'Are you sure you want to clear this conversation? This action cannot be undone.',
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.of(context).pop(),
  //             child: const Text('Cancel'),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               viewModel.clearChat();
  //               Navigator.of(context).pop();
  //             },
  //             style: TextButton.styleFrom(foregroundColor: Colors.red),
  //             child: const Text('Clear'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI assistant'), // Updated title
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
          // Consumer<ChatViewModel>(
          //   builder: (context, viewModel, child) {
          //     return PopupMenuButton<String>(
          //       icon: const Icon(Icons.more_vert),
          //       onSelected: (String value) {
          //         switch (value) {
          //           case 'clear':
          //             _showClearChatConfirmation(context, viewModel);
          //             break;
          //           case 'share':
          //             _shareChat(viewModel.messages);
          //             break;
          //           case 'customize':
          //             _showCustomizeAssistantDialog(context, viewModel);
          //             break;
          //           case 'diagnose':
          //             viewModel.runDiagnostics();
          //             break;
          //           case 'apikey': // Option for setting API key
                 
          //             break;
          //           case 'model': // Option for selecting model
                      
          //             break;
          //         }
          //       },
          //       itemBuilder:
          //           (BuildContext context) => <PopupMenuEntry<String>>[
          //             const PopupMenuItem<String>(
          //               value: 'clear',
          //               child: ListTile(
          //                 leading: Icon(Icons.delete_outline),
          //                 title: Text('Clear Chat'),
          //               ),
          //             ),
          //           ],
          //     );
          //   },
          // ),
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
