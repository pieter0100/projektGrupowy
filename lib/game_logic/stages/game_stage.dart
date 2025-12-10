import 'package:projekt_grupowy/game_logic/stages/stage_type.dart';
import 'package:projekt_grupowy/game_logic/stages/stage_data.dart';

/// Combines the stage type with its specific data.
class GameStage {
  final StageType type;
    final StageData data;
  
  GameStage({
    required this.type,
    required this.data,
  });
}
