import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:rick_and_morty/data/models/character.dart';
import 'package:rick_and_morty/data/repositories/character_repository.dart';

part 'character_state.dart';
part 'character_event.dart';
part 'character_bloc.freezed.dart';
part 'character_bloc.g.dart';

//* Что бы расширить от hydrated_bloc: Нужно with HydratedMixin или вместо Bloc - HydratedBloc< , >
//* и написать fromJson для bloc и State
class CharacterBloc extends Bloc<CharacterEvent, CharacterState>
    with HydratedMixin {
  final CharacterRepository characterRepository;
  CharacterBloc({required this.characterRepository})
      : super(const CharacterState.loading()) {
    on<CharacterEventFetch>((event, emit) async {
      emit(const CharacterState.loading());
      try {
        Character _characterLoaded = await characterRepository
            .getCharacter(event.page, event.name)
            .timeout(const Duration(seconds: 5));
        emit(CharacterState.loaded(charracterLoaded: _characterLoaded));
      } catch (_) {
        emit(const CharacterState.error());
        rethrow; // пустить ошибку дальше
      }
    });
  }

// что бы можно было восстанавливать состояние блока нужно 2 метода для записи и извлечения
// в State тоже нужно написать методы fromJson toJson

  @override
  CharacterState? fromJson(Map<String, dynamic> json) => CharacterState.fromJson(json);

  @override
  Map<String, dynamic>? toJson(CharacterState state) => state.toJson();
}
