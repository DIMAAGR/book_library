abstract class UndoCommand {
  bool get undone;
  bool get committed;
  Future<void> commit();
  void undo();
}
