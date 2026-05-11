import 'package:flutter_test/flutter_test.dart';

import 'package:consulta_preco/domain/entities/coleta.dart';
import 'package:consulta_preco/domain/entities/item_coleta.dart';
import 'package:consulta_preco/domain/repositories/coleta_repository.dart';
import 'package:consulta_preco/domain/usecases/registrar_item_coleta_usecase.dart';

// Mock simples para ColetaRepository
class MockColetaRepository implements ColetaRepository {
  @override
  Future<Coleta?> buscarPorId(int id) async => null;

  @override
  Future<ItemColeta?> buscarItemColeta(int idColeta, int idProduto) async => null;

  @override
  Future<void> registrarOuAtualizarItem(ItemColeta item) async {}

  @override
  Future<int> iniciarColeta(Coleta coleta) async => 1;

  @override
  Future<List<ItemColeta>> listarItensDaColeta(int idColeta) async => [];

  @override
  Future<void> removerItemDaColeta(int idColeta, int idProduto) async {}

  @override
  Future<List<Coleta>> listarColetasDoDia(DateTime data) async => [];
}

void main() {
  group('RegistrarItemColetaUseCase', () {
    late MockColetaRepository mockRepository;
    late RegistrarItemColetaUseCase useCase;

    setUp(() {
      mockRepository = MockColetaRepository();
      useCase = RegistrarItemColetaUseCase(mockRepository);
    });

    test('deve registrar item com preco valido', () async {
      await useCase.execute(
        idColeta: 1,
        idProduto: 1,
        preco: 10.50,
      );

      // Teste passa se nao lanca excecao
      expect(true, isTrue);
    });

    test('deve rejeitar preco zero', () async {
      expect(
        () => useCase.execute(
          idColeta: 1,
          idProduto: 1,
          preco: 0,
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('deve rejeitar preco negativo', () async {
      expect(
        () => useCase.execute(
          idColeta: 1,
          idProduto: 1,
          preco: -5.0,
        ),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
