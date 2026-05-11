import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:projekt_grupowy/utils/constants.dart';

class IntroScreen extends StatefulWidget {
  final String? level;

  const IntroScreen({super.key, this.level});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  int _currentStep = 1;
  final int _totalSteps = 2;

  String _getIntroText() {
    final intLevel = int.tryParse(widget.level ?? '1') ?? 1;
    
    if (_currentStep == 1) {
      switch (intLevel) {
        case 1: return "When you multiply any number by 1, the answer is always the same number.";
        case 2: return "Multiplying by 2 is just like doubling the number! 2 + 2 = 2 × 2.";
        case 3: return "Multiplying by 3 means adding the number to itself three times.";
        case 4: return "To multiply by 4, you can double the number and then double it again!";
        case 5: return "Multiples of 5 always end in 0 or 5. It's like counting nickels!";
        case 6: return "Multiply by 6 by multiplying by 5 and adding one more group.";
        case 7: return "7 is a lucky number! Let's see how many apples we get when we multiply by 7.";
        case 8: return "Multiply by 8 by doubling three times (double, double, double)!";
        case 9: return "A cool trick for 9: the digits of the answer always add up to 9!";
        case 10: return "Multiplying by 10 is the easiest! Just add a zero to the end of the number.";
        default: return "Let's learn how to multiply by $intLevel!";
      }
    } else {
      // Step 2 examples
      final result = intLevel * 7;
      switch (intLevel) {
        case 1: return "See? 1 group of 7 apples is just 7 apples!";
        case 2: return "2 groups of 7 apples makes 14 apples in total. Double 7 is 14!";
        case 3: return "3 groups of 7 apples is 21. That's 7 + 7 + 7!";
        case 4: return "4 groups of 7 apples is 28. That's 14 doubled!";
        case 5: return "5 groups of 7 apples is 35. It ends in a 5!";
        case 6: return "6 groups of 7 apples is 42. One more than 5 groups!";
        case 7: return "7 groups of 7 apples is 49. A perfect square!";
        case 8: return "8 groups of 7 apples is 56. Double of 28!";
        case 9: return "9 groups of 7 apples is 63. Note that 6 + 3 = 9!";
        case 10: return "10 groups of 7 apples is 70. Just 7 with a zero at the end!";
        default: return "So, $intLevel times 7 equals $result!";
      }
    }
  }

  Widget _buildEquation() {
    final intLevel = int.tryParse(widget.level ?? '1') ?? 1;
    
    // For step 1 use 1 apple, for step 2 use 7 apples as an example
    int applesCount = _currentStep == 1 ? 1 : 7;
    String leftApples = '🍎' * applesCount;
    String rightApples = '🍎' * (intLevel * applesCount);

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          '$intLevel × ',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(leftApples, style: const TextStyle(fontSize: 16)),
        const Text(
          ' = ',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(rightApples, style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            if (_currentStep > 1) {
              setState(() {
                _currentStep--;
              });
            } else {
              context.go('/level/learn?level=${widget.level ?? "1"}');
            }
          },
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.learnAppBarIcon),
        ),
        title: Text(
          'Intro to × ${widget.level}',
          style: AppTextStyles.learnTitle,
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFEDEDED),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // Chmurka z tekstem
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Text(
                  _getIntroText(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.4,
                    color: Colors.black87,
                  ),
                ),
              ),
              
              // Trójkąt z chmurki (wyśrodkowany)
              CustomPaint(
                size: const Size(20, 20),
                painter: TrianglePainter(),
              ),

              const SizedBox(height: 30),

              // Dinozaur i Równanie w jednym rzędzie
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/dragon1.png',
                    height: 120, // Trochę mniejszy, żeby jabłka się zmieściły
                  ),
                  const SizedBox(width: 20),
                  Flexible(
                    child: _buildEquation(),
                  ),
                ],
              ),

              const Spacer(),

              // Przycisk Next / Finish
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentStep < _totalSteps) {
                      setState(() {
                        _currentStep++;
                      });
                    } else {
                      context.go('/level/learn?level=${widget.level ?? "1"}');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8E8E8),
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentStep < _totalSteps ? 'Next' : 'Finish',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '$_currentStep/$_totalSteps',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// Prosty painter do narysowania ogonka chmurki
class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0) // Lewy górny róg
      ..lineTo(size.width, 0) // Prawy górny róg
      ..lineTo(size.width / 2, size.height) // Środek na dole
      ..close();

    // Dodanie lekkiego cienia
    canvas.drawShadow(path, Colors.black.withOpacity(0.1), 5, false);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
