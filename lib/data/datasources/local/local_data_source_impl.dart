import 'package:sqflite/sqflite.dart';

import '../../models/coleta_model.dart';
import '../../models/colaborador_model.dart';
import '../../models/dispositivo_model.dart';
import '../../models/item_coleta_model.dart';
import '../../models/loja_model.dart';
import '../../models/produto_model.dart';
import 'database_service.dart';
import 'local_data_source.dart';

class LocalDataSourceImpl implements LocalDataSource {
  LocalDataSourceImpl(this._databaseService);

  final DatabaseService _databaseService;

  Future<Database> get _db async => _databaseService.database;

  @override
  Future<void> upsertProdutos(List<ProdutoModel> produtos, {int? idColaborador}) async {
    final db = await _db;

    await db.transaction((txn) async {
      for (final produto in produtos) {
        final map = produto.toMap()..remove('id');
        // If idColaborador is provided, override the product's idColaborador
        if (idColaborador != null) {
          map['id_colaborador'] = idColaborador;
        }
        await txn.insert(
          'produto',
          map,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  @override
  Future<ProdutoModel?> buscarProdutoPorCodigoBarras(String codigoBarras) async {
    final db = await _db;
    final result = await db.query(
      'produto',
      where: 'codigo_barras = ?',
      whereArgs: [codigoBarras],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return ProdutoModel.fromMap(result.first);
  }

  @override
  Future<ProdutoModel?> buscarProdutoPorCodigoBarrasColaborador(
    String codigoBarras,
    int idColaborador,
  ) async {
    final db = await _db;
    final result = await db.query(
      'produto',
      where: 'codigo_barras = ? AND id_colaborador = ?',
      whereArgs: [codigoBarras, idColaborador],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return ProdutoModel.fromMap(result.first);
  }

  @override
  Future<ProdutoModel?> buscarProdutoPorId(int id) async {
    final db = await _db;
    final result = await db.query(
      'produto',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return ProdutoModel.fromMap(result.first);
  }

  @override
  Future<List<ProdutoModel>> listarProdutos() async {
    final db = await _db;
    final result = await db.query('produto', orderBy: 'nome ASC');
    return result.map(ProdutoModel.fromMap).toList(growable: false);
  }

  @override
  Future<List<ProdutoModel>> buscarProdutosPorNome(String filtroNome) async {
    final db = await _db;
    final query = filtroNome.trim().toLowerCase();

    final result = await db.query(
      'produto',
      where: query.isEmpty ? null : 'LOWER(nome) LIKE ?',
      whereArgs: query.isEmpty ? null : ['%$query%'],
      orderBy: 'nome ASC',
      limit: 30,
    );

    return result.map(ProdutoModel.fromMap).toList(growable: false);
  }

  @override
  Future<List<ProdutoModel>> listarProdutosPorColaborador(int? idColaborador) async {
    final db = await _db;
    final result = await db.query(
      'produto',
      where: 'id_colaborador = ?',
      whereArgs: [idColaborador],
      orderBy: 'nome ASC',
    );
    return result.map(ProdutoModel.fromMap).toList(growable: false);
  }

  @override
  Future<void> upsertLojas(List<LojaModel> lojas, {int? idColaborador}) async {
    final db = await _db;

    await db.transaction((txn) async {
      for (final loja in lojas) {
        final map = loja.toMap()..remove('id');
        // If idColaborador is provided, override the loja's idColaborador
        if (idColaborador != null) {
          map['id_colaborador'] = idColaborador;
        }
        await txn.insert(
          'loja',
          map,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  @override
  Future<List<LojaModel>> listarLojas({String? filtroNome}) async {
    final db = await _db;

    final result = await db.query(
      'loja',
      where: filtroNome == null || filtroNome.trim().isEmpty
          ? null
          : 'LOWER(nome) LIKE ?',
      whereArgs: filtroNome == null || filtroNome.trim().isEmpty
          ? null
          : ['%${filtroNome.toLowerCase()}%'],
      orderBy: 'nome ASC',
    );

    return result.map(LojaModel.fromMap).toList(growable: false);
  }

  @override
  Future<List<LojaModel>> listarLojasPorColaborador(
    int idColaborador, {
    String? filtroNome,
  }) async {
    final db = await _db;

    final result = await db.query(
      'loja',
      where: filtroNome == null || filtroNome.trim().isEmpty
          ? 'id_colaborador = ?'
          : 'id_colaborador = ? AND LOWER(nome) LIKE ?',
      whereArgs: filtroNome == null || filtroNome.trim().isEmpty
          ? [idColaborador]
          : [idColaborador, '%${filtroNome.toLowerCase()}%'],
      orderBy: 'nome ASC',
    );

    return result.map(LojaModel.fromMap).toList(growable: false);
  }

  @override
  Future<LojaModel?> buscarLojaPorId(int id) async {
    final db = await _db;
    final result = await db.query(
      'loja',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return LojaModel.fromMap(result.first);
  }

  @override
  Future<int> inserirColeta(ColetaModel coleta) async {
    final db = await _db;
    return db.insert('coleta', coleta.toMap()..remove('id'));
  }

  @override
  Future<ColetaModel?> buscarColetaPorId(int id) async {
    final db = await _db;
    final result = await db.query(
      'coleta',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return ColetaModel.fromMap(result.first);
  }

  @override
  Future<List<ColetaModel>> listarColetasPorDia(DateTime data) async {
    final db = await _db;
    final day = data.toIso8601String().substring(0, 10);

    final result = await db.query(
      'coleta',
      where: 'substr(data_coleta, 1, 10) = ?',
      whereArgs: [day],
      orderBy: 'data_coleta ASC',
    );

    return result.map(ColetaModel.fromMap).toList(growable: false);
  }

  @override
  Future<void> inserirOuAtualizarItemColeta(ItemColetaModel item) async {
    final db = await _db;

    await db.insert(
      'item_coleta',
      item.toMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> removerItemColeta(int idColeta, int idProduto) async {
    final db = await _db;
    await db.delete(
      'item_coleta',
      where: 'id_coleta = ? AND id_produto = ?',
      whereArgs: [idColeta, idProduto],
    );
  }

  @override
  Future<List<ItemColetaModel>> listarItensColeta(int idColeta) async {
    final db = await _db;
    final result = await db.query(
      'item_coleta',
      where: 'id_coleta = ?',
      whereArgs: [idColeta],
      orderBy: 'data_coleta DESC',
    );

    return result.map(ItemColetaModel.fromMap).toList(growable: false);
  }

  @override
  Future<ItemColetaModel?> buscarItemColeta(int idColeta, int idProduto) async {
    final db = await _db;
    final result = await db.query(
      'item_coleta',
      where: 'id_coleta = ? AND id_produto = ?',
      whereArgs: [idColeta, idProduto],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return ItemColetaModel.fromMap(result.first);
  }

  @override
  Future<ColaboradorModel?> buscarColaboradorPorEmail(String email) async {
    final db = await _db;
    final result = await db.query(
      'colaborador',
      where: 'LOWER(email) = ?',
      whereArgs: [email.trim().toLowerCase()],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return ColaboradorModel.fromMap(result.first);
  }

  @override
  Future<int> inserirColaborador(ColaboradorModel colaborador) async {
    final db = await _db;
    return db.insert('colaborador', colaborador.toMap()..remove('id'));
  }

  @override
  Future<DispositivoModel?> buscarDispositivoPorMei(String mei) async {
    final db = await _db;
    final result = await db.query(
      'dispositivo',
      where: 'mei = ?',
      whereArgs: [mei],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return DispositivoModel.fromMap(result.first);
  }

  @override
  Future<int> inserirDispositivo(DispositivoModel dispositivo) async {
    final db = await _db;
    return db.insert('dispositivo', dispositivo.toMap()..remove('id'));
  }
}
