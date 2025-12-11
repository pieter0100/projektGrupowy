import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:projekt_grupowy/widgets/progress_bar_widget.dart';

class TypedScreen extends StatefulWidget {
  @override
  _TypedScreenState createState() => _TypedScreenState();
}

class _TypedScreenState extends State<TypedScreen> {
  // boolean for conditional rendering hint under the input
  bool isPracticeMode = true;

  String placeHolder = "Type the answer";

  // pytanie pobrane z provider'a
  String question = "2 x 2 =";

  onSkip() {
    setState(() {
      // TODO pobierz odpowiedz z provider'a do pytania i wstaw ja do placeholder'a
      placeHolder = "podpowiedz";
    });

    // Uruchom licznik
    Future.delayed(const Duration(seconds: 2), () {
      // Sprawdzenie 'mounted' jest kluczowe!
      // Zapobiega błędowi, jeśli użytkownik wyjdzie z ekranu
      if (mounted) {
        setState(() {
          placeHolder = "Type the answer";
        });
      }
    });
  }

  void onComplete(String value) {
    // czy odpowiedz to liczba
    if (int.tryParse(value) == null) {
      print("nie wpisano liczby");
    } else {
      print("wpisano liczbe, mozna sprawdzic poprawnosc wyniku");

      // sprawdz poprawnosc odpowiedzi pobranej z provider'a
      print(value);

      // przejdzo do nastpenego pytania
      setState(() {
        question = "nastepne pytanie z dostepnych pobranych";
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
          onPressed: () => context.pop(), // akcja powrotu
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
                          color: Color(
                            0xFF7ED4DE,
                          ), // Błękitny kolor (np. Light Blue)
                          width: 3.0, // Grubość ramki (żeby była wyraźna)
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
