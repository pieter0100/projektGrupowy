class CardItem {
  String id;
  String pairId;
  String value;
  bool isMatched = false;

  // constructor
  CardItem({
    required this.id,
    required this.pairId,
    required this.value
  });

  @override
  String toString() {
    return "Card id: $id, pairId: $pairId, value: $value, isMatched: $isMatched";
  }
}
