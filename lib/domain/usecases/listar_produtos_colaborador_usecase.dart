import '../entities/produto.dart';
import '../repositories/produto_repository.dart';

class ListarProdutosColaboradorUseCase {
  ListarProdutosColaboradorUseCase(this._produtoRepository);

  final ProdutoRepository _produtoRepository;

  Future<List<Produto>> execute(int idColaborador) {
    return _produtoRepository.listarProdutosPorColaborador(idColaborador);
  }
}
