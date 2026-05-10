import 'package:flutter_test/flutter_test.dart';

import 'package:consulta_preco/domain/entities/produto.dart';
import 'package:consulta_preco/domain/repositories/produto_repository.dart';
import 'package:consulta_preco/domain/usecases/importar_produtos_usecase.dart';

// Mock simples para ProdutoRepository
class MockProdutoRepository implements ProdutoRepository {
  List<Produto> _produtosImportados = [];

  @override
  Future<void> importarProdutos(List<Produto> produtos, {int? idColaborador}) async {
    _produtosImportados = produtos;
  }

  @override
  Future<Produto?> buscarPorCodigoBarras(String codigoBarras) async => null;

  @override
  Future<Produto?> buscarPorCodigoBarrasColaborador(
    String codigoBarras,
    int idColaborador,
  ) async =>
      null;

  @override
  Future<List<Produto>> buscarPorNome(String nome) async => [];

  @override
  Future<Produto?> buscarPorId(int id) async => null;

  @override
  Future<List<Produto>> listarProdutos() async => _produtosImportados;

  @override
  Future<List<Produto>> listarProdutosPorColaborador(int idColaborador) async =>
      _produtosImportados;

  List<Produto> get produtosImportados => _produtosImportados;
}

void main() {
  group('ImportarProdutosUseCase', () {
    late MockProdutoRepository mockRepository;
    late ImportarProdutosUseCase useCase;

    setUp(() {
      mockRepository = MockProdutoRepository();
      useCase = ImportarProdutosUseCase(mockRepository);
    });

    test('deve importar lista de produtos valida', () async {
      const json = '''
[
  {"codigo_barras":"111","nome":"Produto A","fabricante":"Fab A"},
  {"codigo_barras":"222","nome":"Produto B","fabricante":"Fab B"}
]
''';

      await useCase.execute(json);

      expect(mockRepository.produtosImportados, hasLength(2));
    });

    test('deve remover duplicatas por codigo de barras', () async {
      const json = '''
[
  {"codigo_barras":"111","nome":"Produto A","fabricante":"Fab A"},
  {"codigo_barras":"111","nome":"Produto A Atualizado","fabricante":"Fab A"}
]
''';

      await useCase.execute(json);

      expect(mockRepository.produtosImportados, hasLength(1));
      expect(mockRepository.produtosImportados.first.codigoBarras, '111');
    });

    test('deve lancar erro para JSON invalido', () async {
      const json = 'invalid json';

      expect(
        () => useCase.execute(json),
        throwsA(isA<FormatException>()),
      );
    });

    test('deve lancar erro para campos obrigatorios faltando', () async {
      const json = '[{"codigo_barras":"111"}]';

      expect(
        () => useCase.execute(json),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
