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
  // manager
  //late final manager;

  // engine
  final engine = TypedGameEngine(
    onComplete: (result) {
      log('Correct: ${result.isCorrect}');
      log('Answer: ${result.userAnswer}');
    },
  );

  // boolean for conditional rendering hint under the input
  //bool isPracticeMode = true;
  String placeHolder = "Type the answer";
  bool _isSkipHighlighted = false;

  // question from provider
  String question = "Loading...";

  @override
  void initState() {
    super.initState();

    // Use level from widget parameter instead of hardcoded value
    engine.initialize(widget.level);
    question = engine.question.prompt;
  }

  void onSkip() {
    // Check if skip is allowed (only in practice mode)
    if (!widget.isPracticeMode) {
      // In test/exam mode, skip is not allowed
      return;
    }

    // Skip the question
    engine.skip();

    // Show highlight and correct answer
    setState(() {
      _isSkipHighlighted = true;
      placeHolder = engine.question.correctAnswer;
    });

    // Reset placeholder and highlight after 3 seconds
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
    // check the answer
    engine.submitAnswer(value);
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
                              fillColor: const Color(0xFFD9D9D9),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 24.0,
                                vertical: 16.0,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.0),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.0),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.0),
                                borderSide: const BorderSide(
                                  color: Color(0xFF7ED4DE),
                                  width: 3.0,
                                ),
                              ),
                            ),
                            onSubmitted: onComplete,
                            textInputAction: TextInputAction.done,
                            cursorColor: Colors.grey[600],
                          ),
                          SizedBox(height: 20.0),
                          // Don't know text - only show in practice mode, aligned to right
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
