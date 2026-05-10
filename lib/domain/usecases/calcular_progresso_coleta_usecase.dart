import '../repositories/produto_repository.dart';
import '../repositories/coleta_repository.dart';

class ProgressoColeta {
  const ProgressoColeta({
    required this.itensColetados,
    required this.totalEstimado,
    required this.itensPendentes,
    required this.percentual,
  });

  final int itensColetados;
  final int totalEstimado;
  final int itensPendentes;
  final double percentual;
}

class CalcularProgressoColetaUseCase {
  CalcularProgressoColetaUseCase({
    required ColetaRepository coletaRepository,
    required ProdutoRepository produtoRepository,
  })  : _coletaRepository = coletaRepository,
        _produtoRepository = produtoRepository;

  final ColetaRepository _coletaRepository;
  final ProdutoRepository _produtoRepository;

  Future<ProgressoColeta> execute({
    required int idColeta,
    required int idColaborador,
  }) async {
    final itens = await _coletaRepository.listarItensDaColeta(idColeta);
    final produtos = await _produtoRepository.listarProdutosPorColaborador(idColaborador);
    final coletados = itens.length;
    final totalProdutosEstimado = produtos.length;
    final totalSeguro = totalProdutosEstimado <= 0 ? 1 : totalProdutosEstimado;
    final pendentes = (totalProdutosEstimado - coletados).clamp(0, totalProdutosEstimado);
    final percentual = (coletados / totalSeguro) * 100;

    return ProgressoColeta(
      itensColetados: coletados,
      totalEstimado: totalProdutosEstimado,
      itensPendentes: pendentes,
      percentual: percentual.clamp(0, 100),
    );
  }
}
