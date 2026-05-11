import '../../core/utils/json_import_validators.dart';
import '../entities/produto.dart';
import '../repositories/produto_repository.dart';
import '../repositories/loja_repository.dart';

class ImportarProdutosUseCase {
  ImportarProdutosUseCase(this._produtoRepository, this._lojaRepository);

  final ProdutoRepository _produtoRepository;
  final LojaRepository _lojaRepository;

  Future<void> execute(String jsonContent, {int? idColaborador}) async {
    final produtos = JsonImportValidators.parseProdutos(jsonContent);
    final semDuplicidade = _deduplicateByCodigoBarras(produtos);
    await _produtoRepository.importarProdutos(semDuplicidade, idColaborador: idColaborador);

    // If collaborator provided, link each imported product to all lojas of that collaborator
    if (idColaborador != null) {
      final lojas = await _lojaRepository.listarLojasPorColaborador(idColaborador);
      for (final produto in semDuplicidade) {
        final inserted = await _produtoRepository.buscarPorCodigoBarras(produto.codigoBarras);
        if (inserted == null || inserted.id == null) continue;
        for (final loja in lojas) {
          if (loja.id == null) continue;
          await _lojaRepository.vincularProduto(loja.id!, inserted.id!, idColaborador);
        }
      }
    }
  }

  List<Produto> _deduplicateByCodigoBarras(List<Produto> produtos) {
    final map = <String, Produto>{};
    for (final produto in produtos) {
      map[produto.codigoBarras] = produto;
    }
    return map.values.toList(growable: false);
  }
}
