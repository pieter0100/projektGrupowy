class CardItem {
  int id;
  int pairId;
  String value;
  bool isMatched;

  // constructor
  CardItem(this.id, this.pairId, this.value, this.isMatched);

  @override
  String toString() {
    return "Card id: $id, pairdId: $pairId, value: $value, isMatched: $isMatched";
  }
}
