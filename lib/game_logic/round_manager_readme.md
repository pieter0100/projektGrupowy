# Round Manager and Card Generation


## Card Generation Logic
The `CardGenerator` class is responsible for generating a deck of cards for the game. Each card has a unique identifier, a pair identifier, a value, and a matched status.
```
  CardGenerator cardGenerator = CardGenerator(pairsAmount: 8,typeOfMultiplication: 2);

  cardGenerator.printCardDeck();
```

### Example output
```
Card id: 80a92f74-2f75-4b6f-9082-5dac7be436af, pairId: e8675a9a-d085-4756-9989-dae0f53a9c5f, value: 2 x 8, isMatched: false

Card id: e8675a9a-d085-4756-9989-dae0f53a9c5f, pairId: 80a92f74-2f75-4b6f-9082-5dac7be436af, value: 16, isMatched: false
```

## Round Manager Logic
The `RoundManager` class manages the game rounds and utilizes the `CardGenerator` to create the card deck.

Both cards have corresponding pairIds, indicating they are a matching pair

To check if player selected correct pairs:
- When a player selects two cards, compare pairIds of both cards
  - Card 1 id == Card 2 pairId
  - Card 2 id == Card 1 pairId
- If the pairIds match, the player has found a correct pair
- When a correct pair is found, set isMatched to true for both cards