import 'package:flutter_bloc/flutter_bloc.dart';
import 'logger.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    AppLogger.d('Bloc Event: ${bloc.runtimeType}', event);
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    AppLogger.e('Bloc Error: ${bloc.runtimeType}', error, stackTrace);
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    if (change.currentState.runtimeType != change.nextState.runtimeType) {
       AppLogger.i('Bloc State Change: ${bloc.runtimeType}\nFrom: ${change.currentState}\nTo: ${change.nextState}');
    }
  }
  
  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    // Optional: Log transitions if you need detailed event->state mapping
    // AppLogger.d('Bloc Transition: ${bloc.runtimeType}', transition);
  }
}
