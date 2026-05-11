import 'dart:convert';

import 'package:intl/intl.dart';

import '../repositories/coleta_repository.dart';
import '../repositories/loja_repository.dart';
import '../repositories/produto_repository.dart';

class ExportarColetasDiariasUseCase {
  ExportarColetasDiariasUseCase({
    required ColetaRepository coletaRepository,
    required LojaRepository lojaRepository,
    required ProdutoRepository produtoRepository,
  }) : _coletaRepository = coletaRepository,
       _lojaRepository = lojaRepository,
       _produtoRepository = produtoRepository;

  final ColetaRepository _coletaRepository;
  final LojaRepository _lojaRepository;
  final ProdutoRepository _produtoRepository;

  Future<Map<String, dynamic>> execute({
    required DateTime data,
    required int idLoja,
  }) async {
    final dia = DateFormat('yyyy-MM-dd').format(data);
    final loja = await _lojaRepository.buscarPorId(idLoja);

    if (loja == null) {
      throw StateError('Loja nao encontrada para exportacao.');
    }

    final coletasDoDia = await _coletaRepository.listarColetasDoDia(data);
    final coletasDaLoja = coletasDoDia
        .where((coleta) => coleta.idLoja == idLoja)
        .toList(growable: false);

    final itensExportacao = <Map<String, dynamic>>[];
    for (final coleta in coletasDaLoja) {
      final itens = await _coletaRepository.listarItensDaColeta(coleta.id!);
      for (final item in itens) {
        final produto = await _produtoRepository.buscarPorId(item.idProduto);
        if (produto == null) {
          continue;
        }

        itensExportacao.add({
          'produto': {
            'id': produto.id,
            'codigo_barras': produto.codigoBarras,
            'nome': produto.nome,
            'fabricante': produto.fabricante,
          },
          'preco': item.preco,
          'data_coleta': item.dataColeta.toIso8601String(),
          'foto_base64': item.fotoBase64,
        });
      }
    }

    return {
      'data': dia,
      'loja': {
        'id': loja.id,
        'nome': loja.nome,
        'endereco': loja.endereco,
        'cidade': loja.cidade,
        'estado': loja.estado,
      },
      'itens': itensExportacao,
    };
  }

  Future<String> executeAsJson({
    required DateTime data,
    required int idLoja,
  }) async {
    final map = await execute(data: data, idLoja: idLoja);
    return const JsonEncoder.withIndent('  ').convert(map);
  }
}
