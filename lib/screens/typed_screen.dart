import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:projekt_grupowy/services/typed_game_engine.dart';
import 'package:projekt_grupowy/widgets/progress_bar_widget.dart';

class TypedScreen extends StatefulWidget {
  final int level;
  final bool isPracticeMode;

  const TypedScreen({
    super.key,
    required this.level,
    required this.isPracticeMode,
  });

  @override
  TypedScreenState createState() => TypedScreenState();
}

class TypedScreenState extends State<TypedScreen> {
  final engine = TypedGameEngine(
    onComplete: (result) {
      log('Correct: ${result.isCorrect}');
      log('Answer: ${result.userAnswer}');
    },
  );
  String placeHolder = "Type the answer";
  bool _isSkipHighlighted = false;
  String question = "Loading...";

  // Feedback states
  bool _showFeedback = false;
  bool _isCorrect = false;
  final TextEditingController _textController = TextEditingController();
  @override
  void initState() {
    super.initState();
    engine.initialize(widget.level);
    question = engine.question.prompt;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void onSkip() {
    if (!widget.isPracticeMode) {
      return;
    }

    engine.skip();

    setState(() {
      _isSkipHighlighted = true;
      placeHolder = engine.question.correctAnswer;
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isSkipHighlighted = false;
          placeHolder = "Type the answer";
        });
      }
    });
  }

  void onComplete(String value) {
    if (value.trim().isEmpty) return;

    // Get the result before submitting to engine
    final userAnswer = int.tryParse(value.trim()) ?? 0;
    final correctAnswer = int.parse(engine.question.correctAnswer);
    final isCorrect = userAnswer == correctAnswer;

    // Show visual feedback only in practice mode
    if (widget.isPracticeMode) {
      setState(() {
        _showFeedback = true;
        _isCorrect = isCorrect;
      });
    }

    // Submit to engine
    engine.submitAnswer(value);

    // Hide feedback after 1 second and move to next question
    final delayDuration = widget.isPracticeMode
        ? const Duration(seconds: 1)
        : const Duration(milliseconds: 100); // Minimal delay for exam mode

    Future.delayed(delayDuration, () {
      if (mounted) {
        setState(() {
          _showFeedback = false;
          _textController.clear();
          // Update question for next round
          question = engine.question.prompt;
        });

        // TEMPORARY: Navigate back to learn screen after answering
        // TODO: Remove this and implement proper session flow
        context.go('/level/learn?level=${widget.level}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("(np Multiply x 2) dane pobrane"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
        backgroundColor: Color(0xFFE5E5E5),
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 20.0),
            child: ProgressBarWidget(),
          ),
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Text('Type your answer', style: TextStyle(fontSize: 30.0)),
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      question,
                      style: TextStyle(fontSize: 48.0),
                      textAlign: TextAlign.center,
                    ),
                    Padding(
                      padding: EdgeInsetsGeometry.directional(
                        start: 35.0,
                        end: 35.0,
                        top: 35.0,
                        bottom: 40.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            controller: _textController,
                            enabled: !_showFeedback, // Disable during feedback
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 25.0,
                            ),
                            decoration: InputDecoration(
                              hintText: placeHolder,
                              hintStyle: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 25.0,
                              ),
                              filled: true,
                              fillColor: _showFeedback
                                  ? (_isCorrect
                                        ? Colors.green[100]
                                        : Colors.red[100])
                                  : const Color(0xFFD9D9D9),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 24.0,
                                vertical: 16.0,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.0),
                                borderSide: _showFeedback
                                    ? BorderSide(
                                        color: _isCorrect
                                            ? Colors.green
                                            : Colors.red,
                                        width: 3.0,
                                      )
                                    : BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.0),
                                borderSide: _showFeedback
                                    ? BorderSide(
                                        color: _isCorrect
                                            ? Colors.green
                                            : Colors.red,
                                        width: 3.0,
                                      )
                                    : BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.0),
                                borderSide: BorderSide(
                                  color: _showFeedback
                                      ? (_isCorrect ? Colors.green : Colors.red)
                                      : const Color(0xFF7ED4DE),
                                  width: 3.0,
                                ),
                              ),
                            ),
                            onSubmitted: _showFeedback ? null : onComplete,
                            textInputAction: TextInputAction.done,
                            cursorColor: Colors.grey[600],
                          ),
                          SizedBox(height: 20.0),
                          if (widget.isPracticeMode)
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: onSkip,
                                child: Text(
                                  "Don't know?",
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.grey[600],
                                    decoration: _isSkipHighlighted
                                        ? TextDecoration.underline
                                        : TextDecoration.none,
                                    decorationColor: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ),
                          SizedBox(height: 180.0),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
