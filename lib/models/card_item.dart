class CardItem {
  String id;
  String pairId;
  String value;
  bool isMatched;
  bool isFailed;

  // constructor
  CardItem({
    required this.id,
    required this.pairId,
    required this.value,
    this.isMatched = false,
    this.isFailed = false,
  });

  @override
  String toString() {
    return "Card id: $id, pairId: $pairId, value: $value, isMatched: $isMatched";
  }
}
