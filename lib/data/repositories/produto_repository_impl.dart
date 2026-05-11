import '../../domain/entities/produto.dart';
import '../../domain/repositories/produto_repository.dart';
import '../datasources/local/local_data_source.dart';
import '../models/produto_model.dart';

class ProdutoRepositoryImpl implements ProdutoRepository {
  ProdutoRepositoryImpl(this._localDataSource);

  final LocalDataSource _localDataSource;

  @override
  Future<void> importarProdutos(List<Produto> produtos, {int? idColaborador}) async {
    final models = produtos
        .map(ProdutoModel.fromEntity)
        .toList(growable: false);
    await _localDataSource.upsertProdutos(models, idColaborador: idColaborador);
  }

  @override
  Future<Produto?> buscarPorCodigoBarras(String codigoBarras) {
    return _localDataSource.buscarProdutoPorCodigoBarras(codigoBarras);
  }

  @override
  Future<Produto?> buscarPorCodigoBarrasColaborador(
    String codigoBarras,
    int idColaborador,
  ) {
    return _localDataSource.buscarProdutoPorCodigoBarrasColaborador(
      codigoBarras,
      idColaborador,
    );
  }

  @override
  Future<List<Produto>> buscarPorNome(String nome) {
    return _localDataSource.buscarProdutosPorNome(nome);
  }

  @override
  Future<Produto?> buscarPorId(int id) {
    return _localDataSource.buscarProdutoPorId(id);
  }

  @override
  Future<Produto?> buscarPorCodigoBarrasNaLoja(String codigoBarras, int lojaId, int colaboradorId) {
    return _localDataSource.buscarProdutoPorCodigoBarrasNaLoja(codigoBarras, lojaId, colaboradorId);
  }

  @override
  Future<List<Produto>> listarProdutos() {
    return _localDataSource.listarProdutos();
  }

  @override
  Future<List<Produto>> listarProdutosPorColaborador(int? idColaborador) {
    return _localDataSource.listarProdutosPorColaborador(idColaborador);
  }

  @override
  Future<List<Produto>> listarProdutosPorLojaEColaborador(int lojaId, int colaboradorId) {
    return _localDataSource.listarProdutosPorLojaEColaborador(lojaId, colaboradorId);
  }
}
