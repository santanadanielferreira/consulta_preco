import 'package:flutter_test/flutter_test.dart';

import 'package:consulta_preco/domain/entities/coleta.dart';
import 'package:consulta_preco/domain/entities/item_coleta.dart';
import 'package:consulta_preco/domain/entities/produto.dart';
import 'package:consulta_preco/domain/repositories/coleta_repository.dart';
import 'package:consulta_preco/domain/repositories/produto_repository.dart';
import 'package:consulta_preco/domain/usecases/calcular_progresso_coleta_usecase.dart';

// Mock simples para ColetaRepository
class MockColetaRepository implements ColetaRepository {
  final List<ItemColeta> _itens = [];

  @override
  Future<Coleta?> buscarPorId(int id) async => null;

  @override
  Future<ItemColeta?> buscarItemColeta(int idColeta, int idProduto) async => null;

  @override
  Future<List<ItemColeta>> listarItensDaColeta(int idColeta) async => _itens;

  @override
  Future<int> iniciarColeta(Coleta coleta) async => 1;

  @override
  Future<void> registrarOuAtualizarItem(ItemColeta item) async {}

  @override
  Future<void> removerItemDaColeta(int idColeta, int idProduto) async {}

  @override
  Future<List<Coleta>> listarColetasDoDia(DateTime data) async => [];

  void adicionarItens(List<ItemColeta> itens) {
    _itens.clear();
    _itens.addAll(itens);
  }
}

class MockProdutoRepository implements ProdutoRepository {
  final List<Produto> _produtos = [];

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
  Future<void> importarProdutos(List<Produto> produtos, {int? idColaborador}) async {
    _produtos
      ..clear()
      ..addAll(produtos);
  }

  @override
  Future<List<Produto>> listarProdutos() async => _produtos;

  @override
  Future<List<Produto>> listarProdutosPorColaborador(int idColaborador) async =>
      _produtos;

  void definirProdutos(List<Produto> produtos) {
    _produtos
      ..clear()
      ..addAll(produtos);
  }
}

void main() {
  group('CalcularProgressoColetaUseCase', () {
    late MockColetaRepository mockRepository;
    late MockProdutoRepository mockProdutoRepository;
    late CalcularProgressoColetaUseCase useCase;

    setUp(() {
      mockRepository = MockColetaRepository();
      mockProdutoRepository = MockProdutoRepository();
      useCase = CalcularProgressoColetaUseCase(
        coletaRepository: mockRepository,
        produtoRepository: mockProdutoRepository,
      );
    });

    void definirCatalogoGlobal(int total) {
      mockProdutoRepository.definirProdutos(
        List.generate(
          total,
          (i) => Produto(
            id: i + 1,
            codigoBarras: '789$i',
            nome: 'Produto $i',
            fabricante: 'Marca $i',
            idColaborador: 1,
          ),
        ),
      );
    }

    test('deve calcular progresso correto com itens coletados', () async {
      final itens = List.generate(
        2,
        (i) => ItemColeta(
          id: i,
          idColeta: 1,
          idProduto: i,
          preco: 10.0,
          dataColeta: DateTime.now(),
        ),
      );

      mockRepository.adicionarItens(itens);
      definirCatalogoGlobal(10);

      final progresso = await useCase.execute(
        idColeta: 1,
      );

      expect(progresso.itensColetados, 2);
      expect(progresso.totalEstimado, 10);
      expect(progresso.itensPendentes, 8);
      expect(progresso.percentual, 20.0);
    });

    test('deve retornar 100% quando todos itens coletados', () async {
      final itens = List.generate(
        5,
        (i) => ItemColeta(
          id: i,
          idColeta: 1,
          idProduto: i,
          preco: 10.0,
          dataColeta: DateTime.now(),
        ),
      );

      mockRepository.adicionarItens(itens);
      definirCatalogoGlobal(5);

      final progresso = await useCase.execute(
        idColeta: 1,
      );

      expect(progresso.percentual, 100.0);
      expect(progresso.itensPendentes, 0);
    });

    test('deve lidar com total estimado zero', () async {
      mockRepository.adicionarItens([]);
      definirCatalogoGlobal(0);

      final progresso = await useCase.execute(
        idColeta: 1,
      );

      expect(progresso.totalEstimado, 0);
      expect(progresso.itensColetados, 0);
      expect(progresso.itensPendentes, 0);
      expect(progresso.percentual, 0.0);
    });

    test('deve limitar percentual a 100%', () async {
      final itens = [
        ItemColeta(
          id: 1,
          idColeta: 1,
          idProduto: 1,
          preco: 10.0,
          dataColeta: DateTime.now(),
        ),
      ];

      mockRepository.adicionarItens(itens);
      definirCatalogoGlobal(0);

      final progresso = await useCase.execute(
        idColeta: 1,
      );

      expect(progresso.percentual, lessThanOrEqualTo(100.0));
    });
  });
}
