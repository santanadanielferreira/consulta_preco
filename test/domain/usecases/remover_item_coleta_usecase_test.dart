import 'package:flutter_test/flutter_test.dart';

import 'package:consulta_preco/domain/entities/coleta.dart';
import 'package:consulta_preco/domain/entities/item_coleta.dart';
import 'package:consulta_preco/domain/repositories/coleta_repository.dart';
import 'package:consulta_preco/domain/usecases/remover_item_coleta_usecase.dart';

class MockColetaRepository implements ColetaRepository {
  int? ultimoIdColetaRemovido;
  int? ultimoIdProdutoRemovido;

  @override
  Future<Coleta?> buscarPorId(int id) async => null;

  @override
  Future<ItemColeta?> buscarItemColeta(int idColeta, int idProduto) async => null;

  @override
  Future<int> iniciarColeta(Coleta coleta) async => 1;

  @override
  Future<List<ItemColeta>> listarItensDaColeta(int idColeta) async => [];

  @override
  Future<List<Coleta>> listarColetasDoDia(DateTime data) async => [];

  @override
  Future<void> registrarOuAtualizarItem(ItemColeta item) async {}

  @override
  Future<void> removerItemDaColeta(int idColeta, int idProduto) async {
    ultimoIdColetaRemovido = idColeta;
    ultimoIdProdutoRemovido = idProduto;
  }
}

void main() {
  group('RemoverItemColetaUseCase', () {
    late MockColetaRepository mockRepository;
    late RemoverItemColetaUseCase useCase;

    setUp(() {
      mockRepository = MockColetaRepository();
      useCase = RemoverItemColetaUseCase(mockRepository);
    });

    test('deve remover item com ids validos', () async {
      await useCase.execute(idColeta: 1, idProduto: 5);

      expect(mockRepository.ultimoIdColetaRemovido, 1);
      expect(mockRepository.ultimoIdProdutoRemovido, 5);
    });

    test('deve rejeitar ids invalidos', () async {
      expect(
        () => useCase.execute(idColeta: 0, idProduto: 5),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
