import 'dart:async';
import 'package:flutter/material.dart';
import 'package:graphql/client.dart';
import 'package:pokedex_final_final_final_vainita_rara_que_chequea/DTO/DTO.PokemonGraphQL.dart';
import 'package:pokedex_final_final_final_vainita_rara_que_chequea/BasedeDatos/DB.dart';
import 'package:pokedex_final_final_final_vainita_rara_que_chequea/BasedeDatos/PostgresSQLHelper.dart';
import 'package:pokedex_final_final_final_vainita_rara_que_chequea/Modelos/Pokemon.dart';
import 'Lista.Carta.dart' as pc;
import 'package:pokedex_final_final_final_vainita_rara_que_chequea/Paginas/DetallePag/Detalle.Pag.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  late DatabaseHelper db; // DatabaseHelper for operations
  final PostgreSQLHelper dbHelper = PostgreSQLHelper(); // PostgreSQL connection
  bool loading = true; // If the page is loading information
  List<Pokemon> pokemons = []; // All Pokemons loaded in memory
  int favoriteFilter = 0; // 0 all, 1 only favorite, -1 only not favorite Pokemons
  String searchString = '';
  final GraphQLClient client = GraphQLClient(
    link: HttpLink('https://beta.pokeapi.co/graphql/v1beta'),
    cache: GraphQLCache(),
  );

  @override
  void initState() {
    super.initState();
    _initializeDatabaseAndLoadData();
  }

  Future<void> _initializeDatabaseAndLoadData() async {
    try {
      // Initialize PostgreSQL connection
      print("Connecting to PostgreSQL...");
      await dbHelper.initConnection(
        host: '10.0.2.2', // Emulator's localhost
        port: 5432,
        databaseName: 'pokedex',
        username: 'postgres',
        password: '1234',
      );
      print("PostgreSQL connection initialized.");

      // Initialize DatabaseHelper with the established connection
      db = DatabaseHelper();
      await db.initDatabase(
        host: '10.0.2.2',
        port: 5432,
        databaseName: 'pokedex',
        username: 'postgres',
        password: '1234',
      );
      print("DatabaseHelper initialized successfully.");

      // Load Pokémon data
      await _loadPokemon();
    } catch (e) {
      print("Initialization error: $e");
    }
  }


  Future<void> _loadPokemon() async {
    try {
      const String queryPokemons = r'''
      query samplePokeAPIquery {
        pokemon_v2_pokemon {
          id
          name
          pokemon_v2_pokemontypes {
            pokemon_v2_type {
              id
              name
            }
          }
          pokemon_v2_pokemonsprites {
            sprites
          }
        }
      }
    ''';

      QueryOptions options = QueryOptions(document: gql(queryPokemons));
      var result = await client.query(options);

      if (result.hasException) {
        print("GraphQL Exception: ${result.exception}");
        return;
      }

      if (result.data != null) {
        PokemonGraphQL pokemonGraphQL = PokemonGraphQL.fromJson(result.data!);

        // Update database using DatabaseHelper
        pokemons = await db.updateDatabase(pokemonGraphQL);

        for (var p in pokemons) {
          if (p.sprites.isEmpty) {
            p.sprites.add(
                'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${p.id}.png');
          }
        }

        setState(() {
          loading = false;
        });
      } else {
        print("No data received from GraphQL.");
      }
    } catch (e) {
      print("Error loading Pokémon data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Pokemon> displayedPokemons = _filterPokemons();

    return loading
        ? Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Image(
              image: AssetImage("assets/gif/mew-spinning.gif"),
              height: 75,
            ),
            const SizedBox(height: 10),
            const Text("Cargando..."),
          ],
        ),
      ),
    )
        : Scaffold(
      appBar: _appBarList(),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildPokemonGrid(displayedPokemons),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 50,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: Colors.grey[200],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Buscar Pokémon',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {
                    searchString = value;
                  });
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                FocusScope.of(context).unfocus();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPokemonGrid(List<Pokemon> displayedPokemons) {
    return Expanded(
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: displayedPokemons.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(4),
            child: GestureDetector(
              onTap: () {
                _openPokemonDetails(context, displayedPokemons[index].id);
              },
              child: pc.PokemonCard(
                onSonChanged: updatePokemonFromChild,
                pokemon: displayedPokemons[index],
              ),
            ),
          );
        },
      ),
    );
  }

  AppBar _appBarList() {
    return AppBar(
      title: const Text('Vainita Rara Que Chequea'),
      backgroundColor: const Color.fromARGB(255, 202, 0, 16),
      actions: [
        IconButton(
          onPressed: () {
            setState(() {
              favoriteFilter = favoriteFilter == 1 ? 0 : 1;
            });
          },
          icon: Icon(
            favoriteFilter == 1
                ? Icons.favorite_outlined
                : Icons.favorite_border,
          ),
        ),
      ],
    );
  }

  void _openPokemonDetails(BuildContext context, int id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PokemonDetallePag(
          id: id,
          onSonChanged: updatePokemonFromChild,
        ),
      ),
    );
  }

  void updatePokemonFromChild(int id, int favorite) {
    for (var p in pokemons) {
      if (p.id == id) {
        setState(() {
          p.favorite = favorite;
        });
        db.insertOrUpdatePokemon(p);
        return;
      }
    }
  }

  List<Pokemon> _filterPokemons() {
    return pokemons.where((p) {
      bool favorite = favoriteFilter == 0 ||
          (favoriteFilter == 1 && p.favoriteBool()) ||
          (favoriteFilter == -1 && !p.favoriteBool());
      bool search = searchString.isEmpty ||
          p.name.toLowerCase().contains(searchString.toLowerCase());
      return favorite && search;
    }).toList();
  }
}
