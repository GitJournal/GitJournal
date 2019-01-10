import 'package:journal/note.dart';

class AppState {
  bool onBoardingCompleted;
  bool isLoadingFromDisk;
  List<Note> notes;

  AppState({
    this.onBoardingCompleted = false,
    this.isLoadingFromDisk = false,
    this.notes = const [],
  });
}
