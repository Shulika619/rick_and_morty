import 'dart:convert';

import 'package:rick_and_morty/data/models/character.dart';
import 'package:http/http.dart' as http;

class CharacterRepository {
  final url = 'https://rickandmortyapi.com/api/character';
  Future<Character> getCharacter(int page, String name) async {
    try {
      var response = await http.get(Uri.parse(url + '?page=$page&name=$name'));
      var jsonResult = json.decode(response.body);
      return Character.fromJson(jsonResult);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
