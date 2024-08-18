import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gitjournal/logger/logger.dart';

class GlobalBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    Log.d('${bloc.runtimeType} Event $event');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    Log.d('${bloc.runtimeType} Change $change');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    Log.d('${bloc.runtimeType} Transition $transition');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    Log.d('${bloc.runtimeType} Error', ex: error, stacktrace: stackTrace);
  }
}
