import 'package:flutter_test/flutter_test.dart';

import 'package:consulta_preco/core/utils/json_import_validators.dart';

void main() {
  group('JsonImportValidators', () {
    group('parseProdutos', () {
      test('deve parsear JSON valido com array direto', () {
        const json = '''
[
  {"codigo_barras":"7891000000011","nome":"Arroz 1kg","fabricante":"Marca A"},
  {"codigo_barras":"7891000000028","nome":"Feijao 1kg","fabricante":"Marca B"}
]
''';
        final produtos = JsonImportValidators.parseProdutos(json);

        expect(produtos, hasLength(2));
        expect(produtos[0].codigoBarras, '7891000000011');
        expect(produtos[0].nome, 'Arroz 1kg');
        expect(produtos[1].codigoBarras, '7891000000028');
      });

      test('deve parsear JSON valido com chave "produtos"', () {
        const json = '''
{
  "produtos": [
    {"codigo_barras":"123","nome":"Produto A","fabricante":"Fab A"}
  ]
}
''';
        final produtos = JsonImportValidators.parseProdutos(json);

        expect(produtos, hasLength(1));
        expect(produtos[0].nome, 'Produto A');
      });

      test('deve lancar erro quando JSON invalido', () {
        const json = '{"invalid": "structure"}';

        expect(
          () => JsonImportValidators.parseProdutos(json),
          throwsA(isA<FormatException>()),
        );
      });

      test('deve lancar erro quando campos obrigatorios faltam', () {
        const json = '''
[
  {"codigo_barras":"123","nome":"Produto A"}
]
''';

        expect(
          () => JsonImportValidators.parseProdutos(json),
          throwsA(isA<FormatException>()),
        );
      });
    });

    group('parseLojas', () {
      test('deve parsear JSON valido com array direto', () {
        const json = '''
[
  {"nome":"Loja A","endereco":"Rua 1","cidade":"Fortaleza","estado":"CE"},
  {"nome":"Loja B","endereco":"Rua 2","cidade":"Caucaia","estado":"CE"}
]
''';
        final lojas = JsonImportValidators.parseLojas(json);

        expect(lojas, hasLength(2));
        expect(lojas[0].nome, 'Loja A');
        expect(lojas[0].cidade, 'Fortaleza');
      });

      test('deve lancar erro quando campos obrigatorios faltam', () {
        const json = '''
[
  {"nome":"Loja A","endereco":"Rua 1"}
]
''';

        expect(
          () => JsonImportValidators.parseLojas(json),
          throwsA(isA<FormatException>()),
        );
      });
    });
  });
}
