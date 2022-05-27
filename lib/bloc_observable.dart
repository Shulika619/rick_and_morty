import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

// отслеживание событий и ошибок
class CharacterBlocObservable extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);

    //* выводим в лог название блока у которого призошел Event и сам Event
    log('onEvent  -- bloc: ${bloc.runtimeType}, event: $event');
  }

  //* Реализуем отслеживание ошибок
  //*1. что бы отслеживать сам BlocObservable нужно добавить в main.dart { BlocOverrides.runZoned(() => runApp(const MyApp()),blocObserver: CharacterBlocObservable()); }
  //*2. добавляем к запросу в bloc try {  await characterRepository.getCharacter(event.page, event.name).timeout(const Duration(seconds:5));
  //*3. добавим в bloc catch{... rethrow;  // пустить ошибку дальше
  // прекрасное место для отлавливания ошибок, когда получим ошибку, будем выводить ее в консоль
  // здесь можно подключить КрашЛитикс или FireBaseАналитикс куда буду собиратся все ошибки с приложения
  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    log('onError  -- bloc: ${bloc.runtimeType}, error: $error');
  }
}
