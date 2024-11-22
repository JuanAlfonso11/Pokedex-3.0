import 'package:flutter/material.dart';
import 'package:pokedex_final_final_final_vainita_rara_que_chequea/Paginas/ListaPag/Lista.Pag.dart';


void main() {
  runApp(PokedexApp());
}

class PokedexApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.red, // Cambia el color de la AppBar a rojo
      ),
      home: const ListPage(),
    );
  }
}