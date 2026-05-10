import '../entities/produto.dart';

abstract class ProdutoRepository {
  Future<void> importarProdutos(List<Produto> produtos, {int? idColaborador});
  Future<Produto?> buscarPorCodigoBarras(String codigoBarras);
  Future<Produto?> buscarPorCodigoBarrasColaborador(String codigoBarras, int idColaborador);
  Future<List<Produto>> buscarPorNome(String nome);
  Future<Produto?> buscarPorId(int id);
  Future<List<Produto>> listarProdutos();
  Future<List<Produto>> listarProdutosPorColaborador(int? idColaborador);
}
