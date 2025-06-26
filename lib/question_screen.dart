import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class QuestionScreen extends StatefulWidget {
  final String category;
  final String difficulty;
  final VoidCallback onCorrect;
  final VoidCallback onSnooze;

  const QuestionScreen({
    super.key,
    required this.category,
    required this.difficulty,
    required this.onCorrect,
    required this.onSnooze,
  });

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  String? _question;
  List<String> _options = [];
  String? _correctAnswer;
  bool _loading = true;
  int _attempts = 0;

  @override
  void initState() {
    super.initState();
    _fetchQuestion();
  }

  Future<void> _fetchQuestion() async {
    setState(() => _loading = true);
    final url = Uri.parse(
        'https://opentdb.com/api.php?amount=1&category=${widget.category}&difficulty=${widget.difficulty}&type=multiple');
    final res = await http.get(url);
    final data = json.decode(res.body);
    final result = data['results'][0];

    final question = Uri.decodeComponent(result['question']);
    final correct = Uri.decodeComponent(result['correct_answer']);
    final incorrect = (result['incorrect_answers'] as List)
        .map((e) => Uri.decodeComponent(e))
        .toList();

    final options = [...incorrect, correct]..shuffle();

    setState(() {
      _question = question;
      _correctAnswer = correct;
      _options = options;
      _loading = false;
    });
  }

  void _checkAnswer(String selected) {
    setState(() => _attempts++);
    if (selected == _correctAnswer) {
      widget.onCorrect();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wrong answer. Snoozing...')),
      );
      Future.delayed(const Duration(seconds: 2), widget.onSnooze);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_question!, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 30),
            ..._options.map(
              (opt) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ElevatedButton(
                  onPressed: () => _checkAnswer(opt),
                  child: Text(opt),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
