import '../entities/produto.dart';
import '../repositories/coleta_repository.dart';
import '../repositories/produto_repository.dart';

class BuscarProdutoPorCodigoBarrasNaLojaUseCase {
  BuscarProdutoPorCodigoBarrasNaLojaUseCase(this._produtoRepository, this._coletaRepository);

  final ProdutoRepository _produtoRepository;
  final ColetaRepository _coletaRepository;

  Future<Produto?> execute(String codigoBarras, int idColeta) async {
    final valor = codigoBarras.trim();
    if (valor.isEmpty) {
      throw const FormatException('Codigo de barras nao pode ser vazio.');
    }

    final coleta = await _coletaRepository.buscarPorId(idColeta);
    if (coleta == null) {
      return null;
    }

    return _produtoRepository.buscarPorCodigoBarrasNaLoja(valor, coleta.idLoja, coleta.idColaborador);
  }
}
