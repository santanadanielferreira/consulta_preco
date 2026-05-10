import '../entities/produto.dart';
import '../repositories/produto_repository.dart';

class BuscarProdutoPorCodigoBarrasColaboradorUseCase {
  BuscarProdutoPorCodigoBarrasColaboradorUseCase(this._produtoRepository);

  final ProdutoRepository _produtoRepository;

  Future<Produto?> execute(String codigoBarras, int idColaborador) {
    final valor = codigoBarras.trim();
    if (valor.isEmpty) {
      throw const FormatException('Codigo de barras nao pode ser vazio.');
    }
    return _produtoRepository.buscarPorCodigoBarrasColaborador(valor, idColaborador);
  }
}
