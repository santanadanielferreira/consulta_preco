import '../../domain/entities/loja.dart';
import '../../domain/repositories/loja_repository.dart';
import '../datasources/local/local_data_source.dart';
import '../models/loja_model.dart';

class LojaRepositoryImpl implements LojaRepository {
  LojaRepositoryImpl(this._localDataSource);

  final LocalDataSource _localDataSource;

  @override
  Future<void> importarLojas(List<Loja> lojas, {int? idColaborador}) async {
    final models = lojas.map(LojaModel.fromEntity).toList(growable: false);
    await _localDataSource.upsertLojas(models, idColaborador: idColaborador);
  }

  @override
  Future<List<Loja>> listarLojas({String? filtroNome}) {
    return _localDataSource.listarLojas(filtroNome: filtroNome);
  }

  @override
  Future<List<Loja>> listarLojasPorColaborador(
    int idColaborador, {
    String? filtroNome,
  }) {
    return _localDataSource.listarLojasPorColaborador(
      idColaborador,
      filtroNome: filtroNome,
    );
  }

  @override
  Future<Loja?> buscarPorId(int id) {
    return _localDataSource.buscarLojaPorId(id);
  }

  @override
  Future<void> vincularProduto(int lojaId, int produtoId, int colaboradorId) async {
    await _localDataSource.upsertLojaProduto(lojaId, produtoId, colaboradorId);
  }
}
