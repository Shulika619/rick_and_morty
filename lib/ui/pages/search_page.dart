import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:rick_and_morty/bloc/character/character_bloc.dart';
import 'package:rick_and_morty/data/models/character.dart';
import 'package:rick_and_morty/ui/widgets/custom_list_tile.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // Создаем 4 перем для удобной работы
  // _currentCharacter хранит об общей инфо о персонажах и страницах
  // _currentResults будет хранится массив персонажей
  // _currentPage текущая страница, так же понадобится для пагинации, подзагрузки персонажей
  // _currentSearchStrчто ввел пользователь
  late Character _currentCharacter;
  List<Results> _currentResults = [];
  int _currentPage = 1;
  String _currentSearchStr = '';

// Для работы с pull_to_refresh нужно 2 перем
  final refreshController = RefreshController();
  bool _isPagination = false;

// перем для паузы при вводе поиска
  Timer? searchDebounce;

// для работы с hydrated и path_provider (сохраняем состояние на устройство)
  final _storage = HydratedBlocOverrides.current?.storage;

  @override
  void initState() {
    if (_storage.runtimeType.toString().isEmpty) {
      // если нет сохран состояния, то запускаем
      if (_currentResults.isEmpty) {
        context.read<CharacterBloc>().add(const CharacterEvent.fetch(
            name: '', page: 1)); // при инициализ вызыв Event событие
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final state =
        context.watch<CharacterBloc>().state; // перем отслежи изменения в блоке
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding:
              const EdgeInsets.only(top: 15, bottom: 2, left: 12, right: 12),
          child: TextField(
              // ввод для поиска
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color.fromRGBO(86, 86, 86, 0.8),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none),
                  prefix: const Icon(Icons.search, color: Colors.white),
                  hintText: 'Search name',
                  hintStyle: const TextStyle(color: Colors.white)),
              onChanged: (value) {
                // при изменен текстПоля вызываем Event и передаем name знач value из поля
                _currentPage = 1;
                _currentResults = [];
                _currentSearchStr = value;

                // добавляем задержку при вводе, но сначала выключ таймеры если есть
                searchDebounce?.cancel();
                searchDebounce = Timer(const Duration(microseconds: 1000), () {
                  context.read<CharacterBloc>().add(
                      CharacterEvent.fetch(name: value, page: _currentPage));
                });
              }),
        ),
        Expanded(
          child: state.when(
              // патерн Maching (4 метода .when, .whenOrNull, map, mapOrNull)
              loading: () {
                // состояние loading
                if (!_isPagination) {
                  return Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        CircularProgressIndicator(strokeWidth: 2),
                        SizedBox(width: 10),
                        Text('Loading...')
                      ],
                    ),
                  );
                } else {
                  return _customListView(
                      _currentResults); // если произошла пагинация, то добавл список к существующему
                }
              },
              loaded: (characterLoaded) {
                _currentCharacter =
                    characterLoaded; // присв знач из characterLoaded
                if (_isPagination) {
                  // _currentResults.addAll(_currentCharacter.results); // добавляем персонажей, если пагинация
                  _currentResults += _currentCharacter.results;
                  refreshController.loadComplete(); // загрузка выполнена
                  _isPagination = false;
                } else {
                  _currentResults = _currentCharacter.results;
                }

                return _currentResults.isNotEmpty
                    ? _customListView(_currentResults)
                    : const SizedBox(); // если не пустой, то отображ рез, если пустой, то ничего
              },
              error: () => const Text('Ничего не найдено...')),
        ),
      ],
    ); // состояние error
  }

  Widget _customListView(List<Results> currentResults) {
    // оборачиваем в SmartRefresher и указ контроллер
    return SmartRefresher(
      controller: refreshController,
      enablePullUp:
          true, // когда доходим до конца списка и дергаем пальцем вверх (появляется загрузка)
      enablePullDown:
          false, // когда в самом верху списка и дергаем пальцем вниз ( не появляется загрузка)
      onLoading: () {
        // нужно реализовать метод, что будет при загрузке
        _isPagination = true;
        _currentPage++;
        if (_currentPage <= _currentCharacter.info.pages) {
          context.read<CharacterBloc>().add(CharacterEvent.fetch(
              name: _currentSearchStr, page: _currentPage));
        } else {
          refreshController
              .loadNoData(); // если страницы закончились, то указ контроллеру .loadNoData()
        }
      },
      child: ListView.separated(
          itemCount: currentResults.length,
          separatorBuilder: (_, index) => const SizedBox(height: 5),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            final result = currentResults[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              child:
                  CustomListTile(result: result), // выносим в отдельный виджет
            );
          }),
    );
  }
}
