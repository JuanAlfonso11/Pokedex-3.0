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
  late DatabaseHelper db;
  final PostgreSQLHelper dbHelper = PostgreSQLHelper();
  bool loading = true;
  List<Pokemon> pokemons = [];
  int favoriteFilter = 0;
  String searchString = '';
  String? selectedGeneration;
  List<String> selectedTypes = [];
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
      await dbHelper.initConnection(
        host: '10.0.2.2',
        port: 5432,
        databaseName: 'pokedex',
        username: 'postgres',
        password: '1234',
      );
      db = DatabaseHelper();
      await db.initDatabase(
        host: '10.0.2.2',
        port: 5432,
        databaseName: 'pokedex',
        username: 'postgres',
        password: '1234',
      );
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
        if (result.exception?.linkException != null) {
          print("Link Exception: ${result.exception!.linkException}");
        }
        if (result.exception?.graphqlErrors.isNotEmpty == true) {
          print("GraphQL Errors: ${result.exception!.graphqlErrors}");
        }
        return;
      }

      if (result.data != null) {
        print("Raw data received: ${result.data}");
        PokemonGraphQL pokemonGraphQL = PokemonGraphQL.fromJson(result.data!);
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

  Widget _buildHeader() {
    return Container(
      color: const Color.fromARGB(255, 202, 0, 16),
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Vainita Rara Que Chequea',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
                  color: Colors.white,
                ),
              ),
            ],
          ),
          _buildSearchBar(),
        ],
      ),
    );
  }

  Widget _buildFiltersButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton.icon(
        onPressed: _showFiltersDialog,
        icon: const Icon(Icons.filter_list),
        label: const Text('Filtros'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 202, 0, 16),
        ),
      ),
    );
  }

  void _showFiltersDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filtros'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                hint: const Text('Generación'),
                value: selectedGeneration,
                items: [
                  const DropdownMenuItem(value: 'all', child: Text('Todas')),
                  const DropdownMenuItem(value: '1', child: Text('Generación 1')),
                  const DropdownMenuItem(value: '2', child: Text('Generación 2')),
                  const DropdownMenuItem(value: '3', child: Text('Generación 3')),
                  const DropdownMenuItem(value: '4', child: Text('Generación 4')),
                  const DropdownMenuItem(value: '5', child: Text('Generación 5')),
                  const DropdownMenuItem(value: '6', child: Text('Generación 6')),
                  const DropdownMenuItem(value: '7', child: Text('Generación 7')),
                  const DropdownMenuItem(value: '8', child: Text('Generación 8')),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedGeneration = value;
                  });
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8.0,
                children: [
                  FilterChip(
                    label: const Text('Todos'),
                    selected: selectedTypes.isEmpty,
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          selectedTypes.clear();
                        }
                      });
                    },
                  ),
                  FilterChip(
                    label: const Text('Fuego'),
                    selected: selectedTypes.contains('fire'),
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          selectedTypes.add('fire');
                        } else {
                          selectedTypes.remove('fire');
                        }
                      });
                    },
                  ),
                  FilterChip(
                    label: const Text('Agua'),
                    selected: selectedTypes.contains('water'),
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          selectedTypes.add('water');
                        } else {
                          selectedTypes.remove('water');
                        }
                      });
                    },
                  ),
                  FilterChip(
                    label: const Text('Planta'),
                    selected: selectedTypes.contains('grass'),
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          selectedTypes.add('grass');
                        } else {
                          selectedTypes.remove('grass');
                        }
                      });
                    },
                  ),
                  FilterChip(
                    label: const Text('Eléctrico'),
                    selected: selectedTypes.contains('electric'),
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          selectedTypes.add('electric');
                        } else {
                          selectedTypes.remove('electric');
                        }
                      });
                    },
                  ),
                  FilterChip(
                    label: const Text('Psíquico'),
                    selected: selectedTypes.contains('psychic'),
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          selectedTypes.add('psychic');
                        } else {
                          selectedTypes.remove('psychic');
                        }
                      });
                    },
                  ),
                  FilterChip(
                    label: const Text('Roca'),
                    selected: selectedTypes.contains('rock'),
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          selectedTypes.add('rock');
                        } else {
                          selectedTypes.remove('rock');
                        }
                      });
                    },
                  ),
                  FilterChip(
                    label: const Text('Hielo'),
                    selected: selectedTypes.contains('ice'),
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          selectedTypes.add('ice');
                        } else {
                          selectedTypes.remove('ice');
                        }
                      });
                    },
                  ),
                  FilterChip(
                    label: const Text('Fantasma'),
                    selected: selectedTypes.contains('ghost'),
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          selectedTypes.add('ghost');
                        } else {
                          selectedTypes.remove('ghost');
                        }
                      });
                    },
                  ),
                  FilterChip(
                    label: const Text('Lucha'),
                    selected: selectedTypes.contains('fighting'),
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          selectedTypes.add('fighting');
                        } else {
                          selectedTypes.remove('fighting');
                        }
                      });
                    },
                  ),
                  FilterChip(
                    label: const Text('Veneno'),
                    selected: selectedTypes.contains('poison'),
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          selectedTypes.add('poison');
                        } else {
                          selectedTypes.remove('poison');
                        }
                      });
                    },
                  ),
                  FilterChip(
                    label: const Text('Bicho'),
                    selected: selectedTypes.contains('bug'),
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          selectedTypes.add('bug');
                        } else {
                          selectedTypes.remove('bug');
                        }
                      });
                    },
                  ),
                  FilterChip(
                    label: const Text('Normal'),
                    selected: selectedTypes.contains('normal'),
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          selectedTypes.add('normal');
                        } else {
                          selectedTypes.remove('normal');
                        }
                      });
                    },
                  ),
                  FilterChip(
                    label: const Text('Volador'),
                    selected: selectedTypes.contains('flying'),
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          selectedTypes.add('flying');
                        } else {
                          selectedTypes.remove('flying');
                        }
                      });
                    },
                  ),
                  FilterChip(
                    label: const Text('Tierra'),
                    selected: selectedTypes.contains('ground'),
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          selectedTypes.add('ground');
                        } else {
                          selectedTypes.remove('ground');
                        }
                      });
                    },
                  ),
                  FilterChip(
                    label: const Text('Siniestro'),
                    selected: selectedTypes.contains('dark'),
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          selectedTypes.add('dark');
                        } else {
                          selectedTypes.remove('dark');
                        }
                      });
                    },
                  ),
                  FilterChip(
                    label: const Text('Hada'),
                    selected: selectedTypes.contains('fairy'),
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          selectedTypes.add('fairy');
                        } else {
                          selectedTypes.remove('fairy');
                        }
                      });
                    },
                  ),
                  FilterChip(
                    label: const Text('Dragón'),
                    selected: selectedTypes.contains('dragon'),
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          selectedTypes.add('dragon');
                        } else {
                          selectedTypes.remove('dragon');
                        }
                      });
                    },
                  ),
                  FilterChip(
                    label: const Text('Acero'),
                    selected: selectedTypes.contains('steel'),
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          selectedTypes.add('steel');
                        } else {
                          selectedTypes.remove('steel');
                        }
                      });
                    },
                  ),

                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  List<Pokemon> _filterPokemons() {
    return pokemons.where((p) {
      // Filtrar por favoritos
      bool matchesFavorites = favoriteFilter == 0 ||
          (favoriteFilter == 1 && p.favoriteBool()) ||
          (favoriteFilter == -1 && !p.favoriteBool());

      // Filtrar por búsqueda
      bool matchesSearch = searchString.isEmpty ||
          p.name.toLowerCase().contains(searchString.toLowerCase());

      // Filtrar por generación
      bool matchesGeneration = selectedGeneration == null ||
          selectedGeneration == 'all' || // Mostrar todas las generaciones
          p.generation.toString() == selectedGeneration;

      // Filtrar por tipo
      bool matchesType = selectedTypes.isEmpty ||
          selectedTypes.any((type) =>
          p.type1 == type || p.type2 == type); // Comprobar ambos tipos

      // Combinar todos los filtros
      return matchesFavorites && matchesSearch && matchesGeneration && matchesType;
    }).toList();
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
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 202, 0, 16),
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildFiltersButton(),
          Expanded(
            child: _buildPokemonGrid(displayedPokemons),
          ),
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
    return GridView.builder(
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
}
