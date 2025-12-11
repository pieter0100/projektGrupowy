# Services

This directory contains services responsible for generating questions and cards for educational games. These components are used by various game modules to deliver educational content based on the selected level.

## File Structure

### `question_provider.dart`

Question provider for all types of mini-games. The class contains static methods to generate multiplication table questions in three formats: questions for matching in pairs, multiple-choice questions, and questions requiring typed answers.

Generates questions with random multiplication combinations for a given level.

[Detailed description](../../code_documentation/question_provider_documentation.md)

### `card_generator.dart`

Card generator for the matching game. Based on a provided set of questions, it creates a deck of cards where each pair consists of an operation and its result. Cards are generated with unique identifiers and shuffled in random order.

Responsible for the physical representation of questions as a set of cards with pair identifiers, enabling the game mechanic of finding matching cards.