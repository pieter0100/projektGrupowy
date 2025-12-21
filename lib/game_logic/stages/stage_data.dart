import 'package:projekt_grupowy/models/cards/card_item.dart';

/// Abstract base class for stage-specific data.
abstract class StageData {}

class MultipleChoiceData extends StageData {
  final String question;
  final int correctAnswer;
  final List<int> options;
  
  MultipleChoiceData({
    required this.question,
    required this.correctAnswer,
    required this.options,
  });
}

class TypedData extends StageData {
  final String question;  
  final int correctAnswer;
  
  TypedData({
    required this.question,
    required this.correctAnswer,
  });
}

class PairsData extends StageData {
  final List<CardItem> cards;
  final int pairsCount;
  final int typeOfMultiplication;
  
  PairsData({
    required this.cards,
    required this.pairsCount,
    required this.typeOfMultiplication,
  });
}
