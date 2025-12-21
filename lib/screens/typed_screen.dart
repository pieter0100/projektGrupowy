import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:projekt_grupowy/services/typed_game_engine.dart';
import 'package:projekt_grupowy/widgets/progress_bar_widget.dart';

class TypedScreen extends StatefulWidget {
  @override
  _TypedScreenState createState() => _TypedScreenState();
}

class _TypedScreenState extends State<TypedScreen> {
  // manager
  late final manager;

  // engine
  final engine = TypedGameEngine(
    onComplete: (result) {
      print('Correct: ${result.isCorrect}');
      print('Answer: ${result.userAnswer}');
    },
  );

  // boolean for conditional rendering hint under the input
  bool isPracticeMode = true;

  String placeHolder = "Type the answer";

  // question from provider
  String question = "Loading...";

  @override
  void initState() {
    super.initState();

    // TODO change value
    engine.initialize(3);

    question = engine.question.prompt;
  }

  onSkip() {
    setState(() {
      // TODO get the hint from provider and set placeholder with its value
      placeHolder = "hint";
    });

    // Timer
    Future.delayed(const Duration(seconds: 2), () {
      // Mounted
      if (mounted) {
        setState(() {
          placeHolder = "Type the answer";
        });
      }
    });
  }

  void onComplete(String value) {
    // is answer an integer
    if (int.tryParse(value) == null) {
      log("answer is not a number");
    } else {
      log("answer is a number you can check if it is a correct answer");

      // check the answer
      engine.submitAnswer(value);

      // set the next question
      setState(() {
        question = engine.question.prompt;
        placeHolder = "Type the answer";
      });
    }
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
      body: Center(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 20.0),
              child: ProgressBarWidget(),
            ),
            Text(
              question,
              style: TextStyle(fontSize: 48.0),
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: EdgeInsetsGeometry.directional(
                start: 100.0,
                end: 100.0,
                top: 20.0,
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
                        vertical: 26.0,
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
                  ),
                  if (isPracticeMode)
                    Padding(
                      padding: EdgeInsets.only(top: 10.0, right: 20.0),
                      child: GestureDetector(
                        onTap: onSkip,

                        child: Text(
                          "Don’t Know?  ",
                          style: TextStyle(
                            fontSize: 25.0,
                            color: Color(0x88000000),
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0x88000000),
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
