import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  DatabaseService._();

  static final DatabaseService instance = DatabaseService._();
  static const _databaseName = 'keeprice.db';
  static const _databaseVersion = 3;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _openDatabase();
    return _database!;
  }

  Future<Database> _openDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final dbPath = path.join(directory.path, _databaseName);

    return openDatabase(
      dbPath,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE produto (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        codigo_barras TEXT NOT NULL UNIQUE,
        nome TEXT NOT NULL,
        fabricante TEXT NOT NULL,
        foto_base64 TEXT,
        id_colaborador INTEGER NOT NULL,
        FOREIGN KEY(id_colaborador) REFERENCES colaborador(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE loja (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        endereco TEXT NOT NULL,
        cidade TEXT NOT NULL,
        estado TEXT NOT NULL,
        id_colaborador INTEGER NOT NULL,
        tempo_medio_coleta INTEGER DEFAULT 300,
        FOREIGN KEY(id_colaborador) REFERENCES colaborador(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE colaborador (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        email TEXT NOT NULL,
        login TEXT NOT NULL UNIQUE,
        senha TEXT NOT NULL,
        data_cadastro TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE dispositivo (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        modelo TEXT NOT NULL,
        mei TEXT NOT NULL,
        versao_android TEXT NOT NULL,
        data_cadastro TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE coleta (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_loja INTEGER NOT NULL,
        data_coleta TEXT NOT NULL,
        id_colaborador INTEGER NOT NULL,
        id_dispositivo INTEGER NOT NULL,
        FOREIGN KEY(id_loja) REFERENCES loja(id),
        FOREIGN KEY(id_colaborador) REFERENCES colaborador(id),
        FOREIGN KEY(id_dispositivo) REFERENCES dispositivo(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE item_coleta (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_coleta INTEGER NOT NULL,
        id_produto INTEGER NOT NULL,
        preco REAL NOT NULL,
        data_coleta TEXT NOT NULL,
        foto_base64 TEXT,
        UNIQUE(id_coleta, id_produto),
        FOREIGN KEY(id_coleta) REFERENCES coleta(id),
        FOREIGN KEY(id_produto) REFERENCES produto(id)
      )
    ''');

    await db.insert('colaborador', {
      'id': 1,
      'nome': 'Operador Local',
      'email': 'teste@keeprice.app',
      'login': 'teste@keeprice.app',
      'senha': '123456',
      'data_cadastro': DateTime.now().toIso8601String(),
    });

    await db.insert('dispositivo', {
      'id': 1,
      'modelo': 'Android',
      'mei': '000000000000000',
      'versao_android': '14',
      'data_cadastro': DateTime.now().toIso8601String(),
    });
  }
}
