
/// This [enum] is a representation of the difficulty levels defined in the `question_catalog_schema.json`.

enum DifficultyLevel {
  easy, standard, hard
}


/// Returns true if this [DifficultyLevel] is immanent in the given [DifficultyLevel].

extension DifficultyCheck on DifficultyLevel {
  bool isSubLevelOf(DifficultyLevel difficultyLevel) {
    return index <= difficultyLevel.index;
  }
}
