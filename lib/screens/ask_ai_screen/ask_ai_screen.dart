import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AskAIScreen extends StatefulWidget {
  static String routeName = 'AskAIScreen';

  const AskAIScreen({super.key});

  @override
  _AskAIScreenState createState() => _AskAIScreenState();
}

class _AskAIScreenState extends State<AskAIScreen> {
  final TextEditingController _questionController = TextEditingController();
  final List<Map<String, String>> _chatHistory = [];
  bool _isLoading = false;

  final model = GenerativeModel(
    model: 'gemini-pro',
    apiKey:
        'AIzaSyCtiWoChKx07E7xynztH3jWlWJHDPfnGog', // Replace with your actual Gemini AI API key
  );

  final String _initialPrompt = '''
You are Academia AI, an intelligent assistant designed to help students with their studies and academic queries. Your purpose is to provide helpful, accurate, and educational responses to students' questions across various subjects. Always introduce yourself as Academia AI, not as any other AI model. If asked about your capabilities, explain that you're here to assist with academic subjects, homework help, study techniques, and general knowledge related to education. Be friendly, patient, and encouraging in your responses to foster a positive learning environment.
''';

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  void _initializeChat() async {
    final content = [Content.text(_initialPrompt)];
    model.startChat(history: content);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ask Academia AI'),
        backgroundColor: Colors.black,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _chatHistory.length,
                itemBuilder: (context, index) {
                  final message = _chatHistory[index];
                  return _buildMessageBubble(
                    message['content']!,
                    message['role'] == 'user',
                  );
                },
              ),
            ),
            if (_isLoading) const LinearProgressIndicator(),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(String message, bool isUser) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) const CircleAvatar(child: Icon(Icons.school)),
          const SizedBox(width: 10),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: isUser ? Colors.blue : Colors.grey[300],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                message,
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          if (isUser) const CircleAvatar(child: Icon(Icons.person)),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _questionController,
              decoration: const InputDecoration(
                hintText: 'Ask Academia AI a question...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    if (_questionController.text.isEmpty) return;

    setState(() {
      _chatHistory.add({
        'role': 'user',
        'content': _questionController.text,
      });
      _isLoading = true;
    });

    final question = _questionController.text;
    _questionController.clear();

    try {
      final content = [Content.text(question)];
      final response = await model.generateContent(content);

      String aiResponse =
          response.text ?? 'Sorry, I couldn\'t generate a response.';
      aiResponse = aiResponse.replaceAll('Gemini', 'Academia AI');
      aiResponse = aiResponse.replaceAll('Google', 'Academia AI');

      setState(() {
        _chatHistory.add({
          'role': 'assistant',
          'content': aiResponse,
        });
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _chatHistory.add({
          'role': 'assistant',
          'content': 'Sorry, an error occurred. Please try again later.',
        });
        _isLoading = false;
      });
      print('Error: $e');
    }
  }
}
