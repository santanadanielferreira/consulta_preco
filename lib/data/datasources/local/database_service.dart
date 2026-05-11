import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  DatabaseService._();

  static final DatabaseService instance = DatabaseService._();
  static const _databaseName = 'keeprice.db';
  static const _databaseVersion = 5;

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
      onUpgrade: _onUpgrade,
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
        ultimo_export TEXT,
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
        data_exportacao TEXT,
        itens_coletados_exportacao INTEGER,
        total_estimado_exportacao INTEGER,
        percentual_exportacao REAL,
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

    await db.execute('''
      CREATE TABLE loja_produto (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        loja_id INTEGER NOT NULL,
        produto_id INTEGER NOT NULL,
        colaborador_id INTEGER NOT NULL,
        UNIQUE(loja_id, produto_id),
        FOREIGN KEY(loja_id) REFERENCES loja(id),
        FOREIGN KEY(produto_id) REFERENCES produto(id),
        FOREIGN KEY(colaborador_id) REFERENCES colaborador(id)
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

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
      await db.transaction((txn) async {
        await txn.execute('''
          CREATE TABLE IF NOT EXISTS loja_produto (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            loja_id INTEGER NOT NULL,
            produto_id INTEGER NOT NULL,
            colaborador_id INTEGER NOT NULL,
            UNIQUE(loja_id, produto_id),
            FOREIGN KEY(loja_id) REFERENCES loja(id),
            FOREIGN KEY(produto_id) REFERENCES produto(id),
            FOREIGN KEY(colaborador_id) REFERENCES colaborador(id)
          )
        ''');

        // Migrate existing products to be related to stores of the same collaborator.
        // This will create one relation per (loja, produto) where both belong to same colaborador.
        await txn.execute('''
          INSERT OR IGNORE INTO loja_produto (loja_id, produto_id, colaborador_id)
          SELECT l.id AS loja_id, p.id AS produto_id, p.id_colaborador AS colaborador_id
          FROM loja l
          JOIN produto p ON l.id_colaborador = p.id_colaborador
        ''');
      });
    }

    if (oldVersion < 5) {
      await db.transaction((txn) async {
        await txn.execute('ALTER TABLE coleta ADD COLUMN data_exportacao TEXT');
        await txn.execute(
          'ALTER TABLE coleta ADD COLUMN itens_coletados_exportacao INTEGER',
        );
        await txn.execute(
          'ALTER TABLE coleta ADD COLUMN total_estimado_exportacao INTEGER',
        );
        await txn.execute(
          'ALTER TABLE coleta ADD COLUMN percentual_exportacao REAL',
        );
        await txn.execute('ALTER TABLE loja ADD COLUMN ultimo_export TEXT');
      });
    }
  }
}
