import 'dart:async';
import 'package:postgres/postgres.dart';
import '../Modelos/Pokemon.dart';
import 'package:pokedex_final_final_final_vainita_rara_que_chequea/DTO/DTO.PokemonGraphQL.dart' as PQ;

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  late PostgreSQLConnection _connection;
  bool _isInitialized = false;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  /// Initializes the PostgreSQL database connection
  Future<void> initDatabase({
    required String host,
    required int port,
    required String databaseName,
    required String username,
    required String password,
  }) async {
    try {
      _connection = PostgreSQLConnection(
        host,
        port,
        databaseName,
        username: username,
        password: password,
      );

      print("Connecting to PostgreSQL...");
      await _connection.open();
      _isInitialized = true;
      print("Connection to PostgreSQL successful!");

      // Create tables if they don't exist
      await _createTables();
    } catch (e) {
      print("Error initializing database: $e");
      rethrow;
    }
  }

  /// Ensures the connection is initialized and open
  Future<void> _validateConnection() async {
    if (!_isInitialized || _connection.isClosed) {
      throw Exception("Database connection is not initialized or closed.");
    }
  }

  /// Creates the necessary tables if they don't exist
  Future<void> _createTables() async {
    await _validateConnection();
    try {
      await _connection.transaction((ctx) async {
        await ctx.query('''
  CREATE TABLE IF NOT EXISTS pokemons (
    id SERIAL PRIMARY KEY,
    favorite INTEGER,
    name TEXT,
    type1 TEXT,
    type2 TEXT,
    generation INTEGER
  )
''');

        await ctx.query('''
          CREATE TABLE IF NOT EXISTS hash (
            id SERIAL PRIMARY KEY,
            hash INTEGER
          )
        ''');
      });
      print("Tables created successfully.");
    } catch (e) {
      print("Error creating tables: $e");
      rethrow;
    }
  }

  /// Retrieves the hash list from the database
  Future<List<int>> hashList() async {
    await _validateConnection();
    try {
      final result = await _connection.query('SELECT hash FROM hash');
      return result.map((row) => row[0] as int).toList();
    } catch (e) {
      print("Error fetching hash list: $e");
      return [];
    }
  }

  /// Inserts or updates the hash value in the database
  Future<void> insertOrUpdateHash(int hash) async {
    await _validateConnection();
    try {
      final existingHashes = await hashList();
      if (existingHashes.isEmpty) {
        await _connection.query('''
          INSERT INTO hash (id, hash)
          VALUES (1, @hash)
        ''', substitutionValues: {'hash': hash});
      } else {
        await _connection.query('''
          UPDATE hash
          SET hash = @hash
          WHERE id = 1
        ''', substitutionValues: {'hash': hash});
      }
    } catch (e) {
      print("Error updating hash: $e");
      rethrow;
    }
  }

  /// Inserts or updates a Pokémon in the database
  Future<void> insertOrUpdatePokemon(Pokemon pokemon) async {
    await _validateConnection();
    try {
      await _connection.query('''
        INSERT INTO pokemons (id, favorite, name, type1, type2)
        VALUES (@id, @favorite, @name, @type1, @type2)
        ON CONFLICT (id) DO UPDATE SET
          favorite = EXCLUDED.favorite,
          name = EXCLUDED.name,
          type1 = EXCLUDED.type1,
          type2 = EXCLUDED.type2
      ''', substitutionValues: pokemon.toMap());
    } catch (e) {
      print("Error inserting/updating Pokémon: $e");
      rethrow;
    }
  }

  /// Retrieves all Pokémon from the database
  Future<List<Pokemon>> getAllPokemons() async {
    await _validateConnection();
    try {
      final result = await _connection.query('SELECT * FROM pokemons');
      return result.map((row) {
        return Pokemon(
          id: row[0] as int,
          favorite: row[1] as int,
          name: row[2] as String,
          type1: row[3] as String,
          type2: row[4] as String,
          sprites: [],
        );
      }).toList();
    } catch (e) {
      print("Error fetching Pokémon list: $e");
      return [];
    }
  }

  /// Retrieves a Pokémon by its ID
  Future<List<Pokemon>> pokemonId(int id) async {
    await _validateConnection();
    try {
      final result = await _connection.query('''
        SELECT * FROM pokemons WHERE id = @id
      ''', substitutionValues: {'id': id});
      return result.map((row) {
        return Pokemon(
          id: row[0] as int,
          favorite: row[1] as int,
          name: row[2] as String,
          type1: row[3] as String,
          type2: row[4] as String,
          sprites: [],
        );
      }).toList();
    } catch (e) {
      print("Error fetching Pokémon by ID: $e");
      return [];
    }
  }

  /// Deletes a Pokémon by its ID
  Future<void> deletePokemon(int id) async {
    await _validateConnection();
    try {
      await _connection.query('''
        DELETE FROM pokemons WHERE id = @id
      ''', substitutionValues: {'id': id});
    } catch (e) {
      print("Error deleting Pokémon: $e");
      rethrow;
    }
  }

  /// Toggles the favorite status of a Pokémon
  Future<List<Pokemon>> changeFavorite(int id) async {
    List<Pokemon> pokemons = await pokemonId(id);
    if (pokemons.isNotEmpty) {
      pokemons[0].favorite = pokemons[0].favorite == 1 ? 0 : 1;

      // Actualiza el estado de favorito en la base de datos
      await insertOrUpdatePokemon(pokemons[0]);
    }
    return pokemons;
  }


  /// Updates the database with new Pokémon data
  /// Updates the database with new Pokémon data
  Future<List<Pokemon>> updateDatabase(PQ.PokemonGraphQL pokemonGraphQL) async {
    await _validateConnection();
    try {
      // Retrieve existing Pokémon and hashes from the database
      List<Pokemon> existingPokemons = await getAllPokemons();
      List<int> existingHashes = await hashList();

      // Calculate the hash of the new Pokémon data
      int newHash = pokemonGraphQL.hashCode;

      // If the hash matches the existing one, no update is needed
      if (existingHashes.isNotEmpty && existingHashes[0] == newHash) {
        print("No changes needed in the database.");
        return existingPokemons;
      }

      // Map new Pokémon data to a list of Pokémon objects
      List<Pokemon> newPokemons = pokemonGraphQL.pokemonList.map((p) {
        // Check if this Pokémon already exists in the database
        Pokemon? existingPokemon = existingPokemons.firstWhere(
              (existing) => existing.id == p.id,
          orElse: () => Pokemon(
            id: p.id,
            favorite: 0, // Default to not favorite if not in the database
            name: "",
            type1: "",
            type2: "",
            sprites: [],
          ),
        );

        // Retain the favorite state of the existing Pokémon
        int favoriteState = existingPokemon.favorite;

        return Pokemon(
          id: p.id,
          favorite: favoriteState, // Retain the existing favorite state
          name: p.name,
          type1: p.pokemonV2PokemonTypes.isNotEmpty
              ? p.pokemonV2PokemonTypes[0].pokemonV2Type.name
              : "",
          type2: p.pokemonV2PokemonTypes.length > 1
              ? p.pokemonV2PokemonTypes[1].pokemonV2Type.name
              : "",
          sprites: _mapGraphQLSprites(p.pokemonV2PokemonSprites, p.id),
        );
      }).toList();

      // Insert or update Pokémon in the database
      await Future.wait(newPokemons.map(insertOrUpdatePokemon));

      // Update the hash in the database
      await insertOrUpdateHash(newHash);

      print("Database successfully updated.");
      return newPokemons;
    } catch (e) {
      print("Error updating database: $e");
      return [];
    }
  }


  List<String> _mapGraphQLSprites(
      List<PQ.PokemonV2PokemonSprites> sprites, int id) {
    List<String> mappedSprites = [];
    if (sprites[0].sprites.other.home.frontDefault != null) {
      mappedSprites.add(sprites[0].sprites.other.home.frontDefault!);
    }
    if (sprites[0].sprites.other.officialArtwork.frontDefault != null) {
      mappedSprites.add(sprites[0].sprites.other.officialArtwork.frontDefault!);
    }
    if (sprites[0].sprites.frontDefault != null) {
      mappedSprites.add(sprites[0].sprites.frontDefault!);
    }
    if (mappedSprites.isEmpty) {
      mappedSprites.add(
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png');
    }
    return mappedSprites;
  }
}
