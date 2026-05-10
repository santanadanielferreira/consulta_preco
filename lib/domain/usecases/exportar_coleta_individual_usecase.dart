import '../entities/produto.dart';
import '../repositories/coleta_repository.dart';
import '../repositories/loja_repository.dart';
import '../repositories/produto_repository.dart';

class ExportarColetaIndividualUseCase {
  ExportarColetaIndividualUseCase({
    required ColetaRepository coletaRepository,
    required LojaRepository lojaRepository,
    required ProdutoRepository produtoRepository,
  })  : _coletaRepository = coletaRepository,
        _lojaRepository = lojaRepository,
        _produtoRepository = produtoRepository;

  final ColetaRepository _coletaRepository;
  final LojaRepository _lojaRepository;
  final ProdutoRepository _produtoRepository;

  Future<Map<String, dynamic>> execute({
    required int idColeta,
    required int idLoja,
    required String nomeColaborador,
    required String emailColaborador,
  }) async {
    final coleta = await _coletaRepository.buscarPorId(idColeta);
    if (coleta == null) {
      throw StateError('Coleta nao encontrada.');
    }

    final loja = await _lojaRepository.buscarPorId(idLoja);
    if (loja == null) {
      throw StateError('Loja nao encontrada para exportacao.');
    }

    final itens = await _coletaRepository.listarItensDaColeta(idColeta);
    final produtos = await _produtoRepository.listarProdutos();
    final produtosPorId = <int, Produto>{
      for (final produto in produtos)
        if (produto.id != null) produto.id!: produto,
    };

    final itensExportacao = <Map<String, dynamic>>[];
    for (final item in itens) {
      final produto = produtosPorId[item.idProduto];
      itensExportacao.add({
        'id': item.id,
        'id_produto': item.idProduto,
        'preco': item.preco,
        'data_coleta': item.dataColeta.toIso8601String(),
        'foto_base64': item.fotoBase64 ?? produto?.fotoBase64,
        'produto': {
          'id': produto?.id,
          'codigo_barras': produto?.codigoBarras,
          'nome': produto?.nome,
          'fabricante': produto?.fabricante,
        },
      });
    }

    final duration = DateTime.now().difference(coleta.dataColeta);
    final totalEsperado = produtos.length;
    final itensColetados = itens.length;

    return {
      'id_coleta': coleta.id,
      'data_inicio_coleta': coleta.dataColeta.toIso8601String(),
      'tempo_decorrido_segundos': duration.inSeconds,
      'tempo_decorrido_formatado': _formatDuration(duration),
      'loja': {
        'id': loja.id,
        'nome': loja.nome,
        'endereco': loja.endereco,
        'cidade': loja.cidade,
        'estado': loja.estado,
      },
      'colaborador': {
        'nome': nomeColaborador,
        'email': emailColaborador,
      },
      'estatisticas': {
        'itens_coletados': itensColetados,
        'itens_esperados': totalEsperado,
        'itens_pendentes': (totalEsperado - itensColetados).clamp(0, totalEsperado),
        'percentual': totalEsperado <= 0 ? 0 : ((itensColetados / totalEsperado) * 100).clamp(0, 100),
      },
      'itens': itensExportacao,
    };
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours <= 0) {
      return '${duration.inMinutes}min';
    }

    if (minutes <= 0) {
      return '${hours}h';
    }

    return '${hours}h ${minutes}min';
  }
}
