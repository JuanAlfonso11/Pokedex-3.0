import 'package:postgres/postgres.dart';

class PostgreSQLHelper {
  static final PostgreSQLHelper _instance = PostgreSQLHelper._internal();
  late PostgreSQLConnection connection;
  bool _isInitialized = false;

  PostgreSQLHelper._internal();

  factory PostgreSQLHelper() => _instance;

  /// Inicializa la conexión a PostgreSQL
  Future<void> initConnection({
    required String host,
    required int port,
    required String databaseName,
    required String username,
    required String password,
  }) async {
    if (_isInitialized) {
      print("PostgreSQL connection is already initialized.");
      return;
    }

    try {
      connection = PostgreSQLConnection(
        host,
        port,
        databaseName,
        username: username,
        password: password,
      );

      print("Connecting to PostgreSQL...");
      await connection.open();
      _isInitialized = true;
      print("Connection to PostgreSQL successful!");
    } catch (e) {
      print("Error connecting to PostgreSQL: $e");
      rethrow;
    }
  }

  /// Verifica si la conexión está abierta
  Future<bool> isConnected() async {
    return !connection.isClosed;
  }

  /// Cierra la conexión a PostgreSQL
  Future<void> closeConnection() async {
    if (_isInitialized && !connection.isClosed) {
      await connection.close();
      _isInitialized = false;
      print("PostgreSQL connection closed.");
    }
  }

  /// Ejecuta una consulta en la base de datos
  Future<List<List<dynamic>>> executeQuery(String query,
      {Map<String, dynamic>? substitutionValues}) async {
    try {
      return await connection.query(query, substitutionValues: substitutionValues);
    } catch (e) {
      print("Error executing query: $e");
      rethrow;
    }
  }
}

void main() async {
  PostgreSQLHelper dbHelper = PostgreSQLHelper();

  await dbHelper.initConnection(
    host: '10.0.2.2',
    port: 5432,
    databaseName: 'pokedex',
    username: 'postgres',
    password: '1234',
  );

  // Verifica si la conexión está abierta
  if (await dbHelper.isConnected()) {
    print("Conexión exitosa.");

    // Ejemplo de consulta
    final results = await dbHelper.executeQuery('SELECT * FROM pokemons');
    for (var row in results) {
      print("Pokemon ID: ${row[0]}, Name: ${row[1]}");
    }
  }

  // Cierra la conexión cuando sea necesario
  await dbHelper.closeConnection();
}
