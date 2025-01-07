import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import '../../DTO/DTO.EvolutionChain.dart' as EC;
import '../../DTO/DTO.PokemonOnly.dart' as PO;
import '../../DTO/DTO.PokemonSpecies.dart' as PS;
import '../../BasedeDatos/DB.dart';
import '../../Modelos/Pokemon.dart';
import '../../Modelos/PokemonDetails.dart';
import 'package:pokedex_final_final_final_vainita_rara_que_chequea/Paginas/DetallePag/Tabs/Estadisticas/Estadisticas.dart';
import 'package:pokedex_final_final_final_vainita_rara_que_chequea/Paginas/DetallePag/Tabs/Evoluciones/Evoluciones.dart';
import 'package:pokedex_final_final_final_vainita_rara_que_chequea/Paginas/DetallePag/Tabs/Informacion/Informacion.dart';
import 'package:pokedex_final_final_final_vainita_rara_que_chequea/Paginas/DetallePag/Tabs/Movimientos/Movimientos.dart';
import 'package:pokedex_final_final_final_vainita_rara_que_chequea/utils/PokemonCardWidget.dart';
typedef PokemonCallBack = void Function(int id, int favorite);

class PokemonDetallePag extends StatefulWidget{
  final PokemonCallBack onSonChanged;
  final int id;




  PokemonDetallePag({ required this.id, required this.onSonChanged});

  @override
  _PokemonDetallePagState createState() => _PokemonDetallePagState(pokemonId: id, onSonChanged: onSonChanged);
}

class _PokemonDetallePagState extends State<PokemonDetallePag> {
  _PokemonDetallePagState(
      {required this.pokemonId, required this.onSonChanged});

  final int pokemonId;
  final PokemonCallBack onSonChanged;
  DatabaseHelper db = DatabaseHelper();
  late PokemonDetails pokemonDetails;
  late bool loading = true;
  late bool loadingError = false;
  bool favorite = false;


  List<String> sprites = [];
  static const double _statsVerticalLength = 12.0;

  late PageController _paginaController;
  int _paginaActual = 0;

  @override
  void initState() {
    super.initState();
    loadingPokemonDetails();
    _paginaController = PageController(initialPage: _paginaActual);
  }

  @override
  @override
  Widget build(BuildContext context) {
    return loading
        ? Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Center(
              child: Image(
                image: AssetImage('assets/gif/mew-spinning.gif'),
                height: 75,
              ),
            ),
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.all(10.0),
              child: const Text("Cargando..."),
            ),
          ],
        ),
      ),
    )
        : Scaffold(
      appBar: DetailsAppBar(),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Imagen del Pokémon y la Pokébola
              SizedBox(
                height: 250,
                child: Stack(
                  children: [
                    // Fondo Pokébola
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(5.0),
                      child: const Image(
                        image: AssetImage('assets/iconos/pokeball.png'),
                        opacity: AlwaysStoppedAnimation(0.2),
                      ),
                    ),
                    // Imagen del Pokémon
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(10.0),
                      child: pokemonDetails.sprites.isNotEmpty
                          ? CachedNetworkImage(
                        imageUrl: pokemonDetails.sprites[0],
                        placeholder: (context, url) =>
                        const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.red),
                          ),
                        ),
                        errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                        fit: BoxFit.cover,
                      )
                          : const Icon(Icons.error),
                    ),
                  ],
                ),
              ),
              // Navegación interna entre Pokémon
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: pokemonId > 1
                          ? () {
                        _navigateToPokemon(context, pokemonId - 1);
                      }
                          : null,
                      child: const Text('Anterior'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _navigateToPokemon(context, pokemonId + 1);
                      },
                      child: const Text('Siguiente'),
                    ),
                  ],
                ),
              ),
              // Navegación entre pestañas
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavigationItem(0, 'Información'),
                    _buildNavigationItem(1, 'Estadísticas'),
                    _buildNavigationItem(2, 'Evoluciones'),
                    _buildNavigationItem(3, 'Movimientos'),
                  ],
                ),
              ),
              // Contenido de la página
              Expanded(
                child: PageView(
                  controller: _paginaController,
                  onPageChanged: (int pagina) {
                    setState(() {
                      _paginaActual = pagina;
                    });
                  },
                  children: [
                    _buildSelectionInformacion(),
                    _buildSelectionEstaditica(),
                    _buildSelectionEvoluciones(),
                    _buildSelectionMovimientos(),
                  ],
                ),
              ),
            ],
          ),
          // RepaintBoundary para la tarjeta oculta
          Positioned(
            top: -9999,
            left: -9999,
            child: RepaintBoundary(
              key: _cardKey,
              child: PokemonCardWidget(
                pokemonName: pokemonDetails.name,
                id: pokemonDetails.id,
                types: pokemonDetails.types,
                imageUrl: pokemonDetails.sprites.isNotEmpty
                    ? pokemonDetails.sprites[0]
                    : 'https://via.placeholder.com/150',
              ),
            ),
          ),
        ],
      ),
    );
  }




  Widget _buildNavigationItem(int index, String title) {
    String asset = 'placeholder';
    switch (index) {
      case 0:
        {
          asset = 'assets/iconos/info.png';
        }
        break;
      case 1:
        {
          asset = 'assets/iconos/estadisticas.png';
        }
        break;
      case 2:
        {
          asset = 'assets/iconos/evoluciones.png';
        }
        break;
      case 3:
        {
          asset = 'assets/iconos/movimientos.png';
        }
        break;
    }

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3.0),
        child: TextButton(
          style: ButtonStyle(
            side: MaterialStateProperty.all(
                BorderSide(width: 1, color: Colors.black)),
          ),
          onPressed: () {
            setState(() {
              _paginaActual = index;
              _paginaController.animateToPage(
                  index, duration: Duration(milliseconds: 300),
                  curve: Curves.ease);
            });
          },
          child: Container(
            height: 25,
            alignment: Alignment.center,
            child: Image(
              image: AssetImage(asset),
            ),
          ),
        ),
      ),
    );
  }

  //pag informacion
  Widget _buildSelectionInformacion() {
    return loading
        ? ListView()
        : TabInformacion(pokemonDetails: pokemonDetails);
  }

  //pag estadisticas
  Widget _buildSelectionEstaditica() {
    return loading
        ? ListView()
        : TabEstadisticas(pokemonDetails: pokemonDetails);
  }

  //pag evoluciones

  Widget _buildSelectionEvoluciones() {
    return loading
        ? ListView()
        : TabEvoluciones(
        pokemonDetails: pokemonDetails, onSonChanged: updatePokemonFromChild);
  }

  //pag movimientos

  Widget _buildSelectionMovimientos() {
    return loading
        ? ListView()
        : TabMovimientos(pokemonDetails: pokemonDetails);
  }

  void updatePokemonFromChild(int id, int favorite) {
    onSonChanged(id, favorite);
  }
  AppBar DetailsAppBar() {
    pokemonDetails.name.replaceAll('-', '');

    return AppBar(
      title: Text(
        pokemonDetails.name.substring(0, 1).toUpperCase() +
            pokemonDetails.name.substring(1).replaceAll('-', ''),
      ),
      backgroundColor: loading
          ? const Color.fromARGB(255, 202, 0, 16)
          : getColorForElement(pokemonDetails.types[0]),
      actions: [
        // Mostrar ID del Pokémon
        Container(
          alignment: Alignment.centerRight,
          child: Text(
            '${pokemonDetails.id}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24),
          ),
        ),
        // Botón de favoritos
        IconButton(
          icon: favorite
              ? const Icon(
            Icons.favorite_outlined,
            color: Colors.red,
          )
              : const Icon(Icons.favorite_border_outlined),
          onPressed: () async {
            List<Pokemon> poke = await db.changeFavorite(pokemonDetails.id);
            setState(() {
              favorite = poke[0].favoriteBool();
              onSonChanged(pokemonId, poke[0].favorite);
            });
          },
        ),
        // Botón de compartir
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: _sharePokemonCard,
        ),
      ],
    );
  }
  final GlobalKey _cardKey = GlobalKey();


  Widget _buildPokemonCard() {
    return RepaintBoundary(
      key: _cardKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CachedNetworkImage(
            imageUrl: pokemonDetails.sprites[0],
            placeholder: (context, url) =>
            const CircularProgressIndicator(),
            errorWidget: (context, url, error) =>
            const Icon(Icons.error),
          ),
          Text(
            pokemonDetails.name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text('ID: ${pokemonDetails.id}'),
          Text('Tipos: ${pokemonDetails.types.join(", ")}'),
        ],
      ),
    );
  }



  Future<void> _sharePokemonCard() async {
    try {
      final RenderRepaintBoundary boundary =
      _cardKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final ByteData? byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        final Uint8List pngBytes = byteData.buffer.asUint8List();

        await Share.shareXFiles(
          [XFile.fromData(pngBytes, name: '${pokemonDetails.name}.png')],
          text: 'Mira mi Pokémon favorito: ${pokemonDetails.name}!',
        );
      }
    } catch (e) {
      print('Error al compartir la tarjeta: $e');
    }
  }





  // Cargar detalle pokemons
  void loadingPokemonDetails() async {
    PO.PokemonOnly? pokemonOnly;
    PS.PokemonSpecies? pokemonSpecies;
    EC.EvolutionChain? evolutionChain;

    print("\nCargando detalles del pokemon\n");
    await http.get(
        Uri.parse('https://pokeapi.co/api/v2/pokemon/$pokemonId/')).then((
        response) async {
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        pokemonOnly = PO.PokemonOnly.fromJson(data);
        print("Success\n");
      } else {
        print("Failure\n");
        setState(() {
          loadingError = true;
        });
        throw Exception('Failed to load details for pokemon $pokemonId}');
      }
    });

    print("\nCargando detalles de la especie del pokemon\n");
    await http.get(Uri.parse(pokemonOnly!.species.url)).then((response) async {
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        pokemonSpecies = PS.PokemonSpecies.fromJson(data);
        print("Success\n");
      } else {
        print("Failure\n");
        setState(() {
          loadingError = true;
        });
        throw Exception('Failed to load details for pokemon $pokemonId}');
      }
    });

    print("\nCargando cadena de evolucion del pokemon\n");
    await http.get(Uri.parse(pokemonSpecies!.evolutionChain.url)).then((
        response) {
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        evolutionChain = EC.EvolutionChain.fromJson(data);
        print("Success\n");
      } else {
        print("Failure\n");
        setState(() {
          loadingError = true;
        });
        throw Exception(
            'Failed to load evolution chain for pokemon $pokemonId}');
      }
    });

    print("\nConvirtiendo DTOs a clases\n");
    pokemonDetails =
        injectDetails(pokemonOnly!, pokemonSpecies!, evolutionChain!);

    List<Pokemon> poke = await db.pokemonId(pokemonDetails.id);
    favorite = poke[0].favoriteBool();

    setState(() {
      loading = false;
    });
  }

  void _openPokemonDetails(BuildContext context, int id) {
    setState(() {});
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>
          PokemonDetallePag(id: id, onSonChanged: updatePokemonFromChild)),
    );
  }

  void _navigateToPokemon(BuildContext context, int newId) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PokemonDetallePag(
          id: newId,
          onSonChanged: onSonChanged,
        ),
      ),
    );
  }
}