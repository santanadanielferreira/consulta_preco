import 'package:flutter_test/flutter_test.dart';

import 'package:consulta_preco/domain/entities/produto.dart';
import 'package:consulta_preco/domain/repositories/produto_repository.dart';
import 'package:consulta_preco/domain/usecases/buscar_produto_por_codigo_barras_usecase.dart';

// Mock simples para ProdutoRepository
class MockProdutoRepository implements ProdutoRepository {
  final Map<String, Produto> _produtosMap = {
    '7891000000011': const Produto(
      id: 1,
      codigoBarras: '7891000000011',
      nome: 'Arroz 1kg',
      fabricante: 'Marca A',
      idColaborador: 1,
    ),
  };

  @override
  Future<Produto?> buscarPorCodigoBarras(String codigoBarras) async {
    return _produtosMap[codigoBarras];
  }

  @override
  Future<Produto?> buscarPorCodigoBarrasColaborador(
    String codigoBarras,
    int idColaborador,
  ) async {
    return _produtosMap[codigoBarras];
  }

  @override
  Future<List<Produto>> buscarPorNome(String nome) async => [];

  @override
  Future<void> importarProdutos(List<Produto> produtos, {int? idColaborador}) async {}

  @override
  Future<Produto?> buscarPorId(int id) async => null;

  @override
  Future<List<Produto>> listarProdutos() async => _produtosMap.values.toList();

  @override
  Future<List<Produto>> listarProdutosPorColaborador(int idColaborador) async =>
      _produtosMap.values.toList();
}

void main() {
  group('BuscarProdutoPorCodigoBarrasUseCase', () {
    late MockProdutoRepository mockRepository;
    late BuscarProdutoPorCodigoBarrasUseCase useCase;

    setUp(() {
      mockRepository = MockProdutoRepository();
      useCase = BuscarProdutoPorCodigoBarrasUseCase(mockRepository);
    });

    test('deve buscar produto existente por codigo de barras', () async {
      final resultado = await useCase.execute('7891000000011');

      expect(resultado, isNotNull);
      expect(resultado?.nome, 'Arroz 1kg');
    });

    test('deve retornar null para produto nao encontrado', () async {
      final resultado = await useCase.execute('999');

      expect(resultado, isNull);
    });

    test('deve rejeitar codigo de barras vazio', () async {
      expect(
        () => useCase.execute(''),
        throwsA(isA<FormatException>()),
      );
    });

    test('deve fazer trim do codigo de barras antes de buscar', () async {
      const codigoComEspacos = '  7891000000011  ';

      final resultado = await useCase.execute(codigoComEspacos);

      expect(resultado, isNotNull);
      expect(resultado?.codigoBarras, '7891000000011');
    });
  });
}
