import 'package:flutter_test/flutter_test.dart';

import 'package:consulta_preco/domain/entities/colaborador.dart';
import 'package:consulta_preco/domain/repositories/colaborador_repository.dart';
import 'package:consulta_preco/domain/usecases/cadastrar_colaborador_usecase.dart';

class MockColaboradorRepository implements ColaboradorRepository {
  final Map<String, Colaborador> _usuariosPorEmail = {};

  @override
  Future<Colaborador?> buscarPorEmail(String email) async {
    return _usuariosPorEmail[email.trim().toLowerCase()];
  }

  @override
  Future<int> inserir(Colaborador colaborador) async {
    final id = _usuariosPorEmail.length + 1;
    _usuariosPorEmail[colaborador.email.toLowerCase()] = colaborador.copyWith(id: id);
    return id;
  }

  void seed(Colaborador colaborador) {
    _usuariosPorEmail[colaborador.email.toLowerCase()] = colaborador;
  }
}

void main() {
  group('CadastrarColaboradorUseCase', () {
    late MockColaboradorRepository mockRepository;
    late CadastrarColaboradorUseCase useCase;

    setUp(() {
      mockRepository = MockColaboradorRepository();
      useCase = CadastrarColaboradorUseCase(mockRepository);
    });

    test('deve cadastrar colaborador com dados validos', () async {
      final colaborador = await useCase.execute(
        nome: 'Novo Usuario',
        email: 'novo@keeprice.app',
        senha: '123456',
      );

      expect(colaborador.id, 1);
      expect(colaborador.login, 'novo@keeprice.app');
    });

    test('deve impedir cadastro com email duplicado', () async {
      mockRepository.seed(
        Colaborador(
          id: 10,
          nome: 'Existente',
          email: 'dup@keeprice.app',
          login: 'dup@keeprice.app',
          senha: '123456',
          dataCadastro: DateTime(2026, 1, 1),
        ),
      );

      expect(
        () => useCase.execute(
          nome: 'Outro',
          email: 'dup@keeprice.app',
          senha: '123456',
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('deve rejeitar senha curta', () async {
      expect(
        () => useCase.execute(
          nome: 'Curta',
          email: 'curta@keeprice.app',
          senha: '123',
        ),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
