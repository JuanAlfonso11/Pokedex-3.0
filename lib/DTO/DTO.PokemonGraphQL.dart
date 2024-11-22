import 'dart:convert';

PokemonGraphQL pokemonGraphQLFromJson(String str) => PokemonGraphQL.fromJson(json.decode(str));

String pokemonGraphQLToJson(PokemonGraphQL data) => json.encode(data.toJson());

class PokemonGraphQL {
  List<PokemonV2Pokemon> pokemonList;

  PokemonGraphQL({
    required this.pokemonList,
  });

  factory PokemonGraphQL.fromJson(Map<String, dynamic> json) => PokemonGraphQL(
    pokemonList: json["pokemon_v2_pokemon"] != null
        ? List<PokemonV2Pokemon>.from(
        json["pokemon_v2_pokemon"].map((x) => PokemonV2Pokemon.fromJson(x)))
        : [],
  );

  Map<String, dynamic> toJson() => {
    "pokemon_v2_pokemon": List<dynamic>.from(pokemonList.map((x) => x.toJson())),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is PokemonGraphQL &&
              runtimeType == other.runtimeType &&
              pokemonList == other.pokemonList;

  @override
  int get hashCode {
    int hash = 0;

    pokemonList.forEach((p) {
      hash = hash ^ p.id.hashCode ^ p.name.hashCode;
      p.pokemonV2PokemonTypes.forEach((t) {
        hash = hash ^ t.pokemonV2Type.name.hashCode;
      });
    });
    return hash;
  }
}

class PokemonV2Type {
  int id;
  String name;

  PokemonV2Type({required this.id, required this.name});

  factory PokemonV2Type.fromJson(Map<String, dynamic> json) => PokemonV2Type(
    id: json['id'],
    name: json['name'],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}

class PokemonV2PokemonTypes {
  PokemonV2Type pokemonV2Type;

  PokemonV2PokemonTypes({required this.pokemonV2Type});

  factory PokemonV2PokemonTypes.fromJson(Map<String, dynamic> json) =>
      PokemonV2PokemonTypes(
        pokemonV2Type: PokemonV2Type.fromJson(json["pokemon_v2_type"]),
      );

  Map<String, dynamic> toJson() => {
    "pokemon_v2_type": pokemonV2Type.toJson(),
  };
}

class Sprites {
  String? frontDefault;
  Other other;

  Sprites({required this.frontDefault, required this.other});

  factory Sprites.fromJson(Map<String, dynamic> json) => Sprites(
    frontDefault: json["front_default"],
    other: Other.fromJson(json["other"]),
  );

  Map<String, dynamic> toJson() => {
    "front_default": frontDefault,
    "other": other.toJson(),
  };
}

class Other {
  DreamWorld dreamWorld;
  Home home;
  OfficialArtwork officialArtwork;

  Other({
    required this.dreamWorld,
    required this.home,
    required this.officialArtwork,
  });

  factory Other.fromJson(Map<String, dynamic> json) => Other(
    dreamWorld: DreamWorld.fromJson(json["dream_world"]),
    home: Home.fromJson(json["home"]),
    officialArtwork: OfficialArtwork.fromJson(json["official-artwork"]),
  );

  Map<String, dynamic> toJson() => {
    "dream_world": dreamWorld.toJson(),
    "home": home.toJson(),
    "official-artwork": officialArtwork.toJson(),
  };
}

class PokemonV2PokemonSprites {
  Sprites sprites;

  PokemonV2PokemonSprites({required this.sprites});

  factory PokemonV2PokemonSprites.fromJson(Map<String, dynamic> json) =>
      PokemonV2PokemonSprites(
        sprites: Sprites.fromJson(json["sprites"]),
      );

  Map<String, dynamic> toJson() => {
    "sprites": sprites.toJson(),
  };
}

class DreamWorld {
  String? frontDefault;

  DreamWorld({required this.frontDefault});

  factory DreamWorld.fromJson(Map<String, dynamic> json) => DreamWorld(
    frontDefault: json["front_default"],
  );

  Map<String, dynamic> toJson() => {
    "front_default": frontDefault,
  };
}

class Home {
  String? frontDefault;

  Home({required this.frontDefault});

  factory Home.fromJson(Map<String, dynamic> json) => Home(
    frontDefault: json["front_default"],
  );

  Map<String, dynamic> toJson() => {
    "front_default": frontDefault,
  };
}

class OfficialArtwork {
  String? frontDefault;

  OfficialArtwork({required this.frontDefault});

  factory OfficialArtwork.fromJson(Map<String, dynamic> json) => OfficialArtwork(
    frontDefault: json["front_default"],
  );

  Map<String, dynamic> toJson() => {
    "front_default": frontDefault,
  };
}

class PokemonV2Pokemon {
  int id;
  String name;
  List<PokemonV2PokemonTypes> pokemonV2PokemonTypes;
  List<PokemonV2PokemonSprites> pokemonV2PokemonSprites;

  PokemonV2Pokemon({
    required this.id,
    required this.name,
    required this.pokemonV2PokemonTypes,
    required this.pokemonV2PokemonSprites,
  });

  factory PokemonV2Pokemon.fromJson(Map<String, dynamic> json) => PokemonV2Pokemon(
    id: json['id'],
    name: json['name'],
    pokemonV2PokemonTypes: json["pokemon_v2_pokemontypes"] != null
        ? List<PokemonV2PokemonTypes>.from(
        json["pokemon_v2_pokemontypes"].map((x) => PokemonV2PokemonTypes.fromJson(x)))
        : [],
    pokemonV2PokemonSprites: json["pokemon_v2_pokemonsprites"] != null
        ? List<PokemonV2PokemonSprites>.from(
        json["pokemon_v2_pokemonsprites"].map((x) => PokemonV2PokemonSprites.fromJson(x)))
        : [],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "pokemon_v2_pokemontypes":
    List<dynamic>.from(pokemonV2PokemonTypes.map((x) => x.toJson())),
    "pokemon_v2_pokemonsprites":
    List<dynamic>.from(pokemonV2PokemonSprites.map((x) => x.toJson())),
  };
}
