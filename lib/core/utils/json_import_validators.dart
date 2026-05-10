import 'dart:convert';

import '../../domain/entities/loja.dart';
import '../../domain/entities/produto.dart';

class JsonImportValidators {
  static List<Produto> parseProdutos(String jsonContent) {
    final decoded = json.decode(jsonContent);
    final dynamic rawList = decoded is Map<String, dynamic>
        ? decoded['produtos']
        : decoded;

    if (rawList is! List) {
      throw const FormatException(
        'JSON de produtos invalido: esperado array ou chave "produtos".',
      );
    }

    final produtos = <Produto>[];
    for (final item in rawList) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('Produto invalido no JSON.');
      }

      final codigoBarras = (item['codigo_barras'] ?? item['codigoBarras']) as String?;
      final nome = item['nome'] as String?;
      final fabricante = item['fabricante'] as String?;
      final fotoBase64 = item['foto_base64'] as String?;

      if (_isBlank(codigoBarras) || _isBlank(nome) || _isBlank(fabricante)) {
        throw const FormatException(
          'Produto invalido: campos obrigatorios ausentes (codigo_barras, nome, fabricante).',
        );
      }

      produtos.add(
        Produto(
          codigoBarras: codigoBarras!.trim(),
          nome: nome!.trim(),
          fabricante: fabricante!.trim(),
          fotoBase64: fotoBase64,
          idColaborador: 1, // Default to user 1 for backward compatibility
        ),
      );
    }

    return produtos;
  }

  static List<Loja> parseLojas(String jsonContent) {
    final decoded = json.decode(jsonContent);
    final dynamic rawList = decoded is Map<String, dynamic>
        ? decoded['lojas']
        : decoded;

    if (rawList is! List) {
      throw const FormatException(
        'JSON de lojas invalido: esperado array ou chave "lojas".',
      );
    }

    final lojas = <Loja>[];
    for (final item in rawList) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('Loja invalida no JSON.');
      }

      final nome = item['nome'] as String?;
      final endereco = item['endereco'] as String?;
      final cidade = item['cidade'] as String?;
      final estado = item['estado'] as String?;
      final tempoMedioColeta = item['tempo_medio_coleta'] as int? ?? 300;

      if (_isBlank(nome) || _isBlank(endereco) || _isBlank(cidade) || _isBlank(estado)) {
        throw const FormatException(
          'Loja invalida: campos obrigatorios ausentes (nome, endereco, cidade, estado).',
        );
      }

      lojas.add(
        Loja(
          nome: nome!.trim(),
          endereco: endereco!.trim(),
          cidade: cidade!.trim(),
          estado: estado!.trim(),
          idColaborador: 1, // Default to user 1 for backward compatibility
          tempoMedioColeta: tempoMedioColeta,
        ),
      );
    }

    return lojas;
  }

  static bool _isBlank(String? value) => value == null || value.trim().isEmpty;
}
