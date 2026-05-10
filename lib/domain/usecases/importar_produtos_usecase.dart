import '../../core/utils/json_import_validators.dart';
import '../entities/produto.dart';
import '../repositories/produto_repository.dart';

class ImportarProdutosUseCase {
  ImportarProdutosUseCase(this._produtoRepository);

  final ProdutoRepository _produtoRepository;

  Future<void> execute(String jsonContent, {int? idColaborador}) async {
    final produtos = JsonImportValidators.parseProdutos(jsonContent);
    final semDuplicidade = _deduplicateByCodigoBarras(produtos);
    await _produtoRepository.importarProdutos(semDuplicidade, idColaborador: idColaborador);
  }

  List<Produto> _deduplicateByCodigoBarras(List<Produto> produtos) {
    final map = <String, Produto>{};
    for (final produto in produtos) {
      map[produto.codigoBarras] = produto;
    }
    return map.values.toList(growable: false);
  }
}
