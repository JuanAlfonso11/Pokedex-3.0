import 'package:flutter/material.dart';

class Pokemon {
  int id;
  int favorite;
  String name;
  String type1;
  String type2;
  List<String> sprites;

  Pokemon({
    required this.id,
    required this.favorite,
    required this.name,
    required this.type1,
    required this.type2,
    required this.sprites,
  });

  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'favorite': favorite,
      'name': name,
      'type1': type1,
      'type2': type2,
    };
  }

  bool favoriteBool() {
    return favorite == 1 ? true : false;
  }

  // Calculate generation based on the Pokémon ID
  int get generation {
    if (id >= 1 && id <= 151) {
      return 1; // Generation I
    } else if (id >= 152 && id <= 251) {
      return 2; // Generation II
    } else if (id >= 252 && id <= 386) {
      return 3; // Generation III
    } else if (id >= 387 && id <= 493) {
      return 4; // Generation IV
    } else if (id >= 494 && id <= 649) {
      return 5; // Generation V
    } else if (id >= 650 && id <= 721) {
      return 6; // Generation VI
    } else if (id >= 722 && id <= 809) {
      return 7; // Generation VII
    } else if (id >= 810 && id <= 898) {
      return 8; // Generation VIII
    } else {
      return 0; // Unknown Generation
    }
  }
}

Pokemon getPokemonId(List<Pokemon> pokemons, int id) {
  Pokemon ret = pokemons[0];
  for (var element in pokemons) {
    if (element.id == id) {
      return element;
    }
  }
  return ret;
}

Color getColorForElement(String element) {
  switch (element) {
    case 'fire':
      return Colors.red;
    case 'water':
      return Colors.blue;
    case 'grass':
      return Colors.green;
    case 'ice':
      return const Color.fromARGB(255, 102, 204, 255);
    case 'fairy':
      return const Color.fromARGB(255, 238, 153, 238);
    case 'electric':
      return const Color.fromARGB(255, 255, 204, 51);
    case 'fighting':
      return const Color.fromARGB(255, 187, 85, 68);
    case 'poison':
      return const Color.fromARGB(255, 146, 63, 204);
    case 'ground':
      return const Color.fromARGB(255, 100, 50, 25);
    case 'flying':
      return const Color.fromARGB(255, 136, 153, 255);
    case 'psychic':
      return const Color.fromARGB(255, 255, 85, 153);
    case 'bug':
      return const Color.fromARGB(255, 170, 187, 34);
    case 'rock':
      return const Color.fromARGB(255, 170, 170, 153);
    case 'ghost':
      return const Color.fromARGB(255, 113, 63, 113);
    case 'dragon':
      return const Color.fromARGB(255, 79, 96, 226);
    case 'dark':
      return const Color.fromARGB(255, 79, 63, 61);
    case 'steel':
      return const Color.fromARGB(255, 96, 162, 185);
    case 'normal':
      return const Color.fromARGB(255, 170, 170, 153);
    default:
      return Colors.white;
  }
}

Color textColorForBackground(Color backgroundColor) {
  final luminance = backgroundColor.computeLuminance();
  return luminance > 0.5 ? Colors.black : Colors.white;
}
