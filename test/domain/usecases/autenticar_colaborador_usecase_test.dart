import 'package:flutter_test/flutter_test.dart';

import 'package:consulta_preco/domain/entities/colaborador.dart';
import 'package:consulta_preco/domain/repositories/colaborador_repository.dart';
import 'package:consulta_preco/domain/usecases/autenticar_colaborador_usecase.dart';

class MockColaboradorRepository implements ColaboradorRepository {
  final Map<String, Colaborador> _usuariosPorEmail = {};

  @override
  Future<Colaborador?> buscarPorEmail(String email) async {
    return _usuariosPorEmail[email.trim().toLowerCase()];
  }

  @override
  Future<int> inserir(Colaborador colaborador) async {
    final id = (_usuariosPorEmail.length + 1);
    _usuariosPorEmail[colaborador.email.toLowerCase()] = colaborador.copyWith(id: id);
    return id;
  }

  void seed(Colaborador colaborador) {
    _usuariosPorEmail[colaborador.email.toLowerCase()] = colaborador;
  }
}

void main() {
  group('AutenticarColaboradorUseCase', () {
    late MockColaboradorRepository mockRepository;
    late AutenticarColaboradorUseCase useCase;

    setUp(() {
      mockRepository = MockColaboradorRepository();
      useCase = AutenticarColaboradorUseCase(mockRepository);
      mockRepository.seed(
        Colaborador(
          id: 1,
          nome: 'Usuario Teste',
          email: 'teste@keeprice.app',
          login: 'teste@keeprice.app',
          senha: '123456',
          dataCadastro: DateTime(2026, 1, 1),
        ),
      );
    });

    test('deve autenticar quando email e senha forem validos', () async {
      final usuario = await useCase.execute(
        email: 'teste@keeprice.app',
        senha: '123456',
      );

      expect(usuario.id, 1);
      expect(usuario.email, 'teste@keeprice.app');
    });

    test('deve normalizar email com espacos e caixa alta', () async {
      final usuario = await useCase.execute(
        email: '  TESTE@KEEPRICE.APP ',
        senha: '123456',
      );

      expect(usuario.email, 'teste@keeprice.app');
    });

    test('deve falhar com credenciais invalidas', () async {
      expect(
        () => useCase.execute(email: 'teste@keeprice.app', senha: 'senha_errada'),
        throwsA(isA<FormatException>()),
      );
    });

    test('deve falhar com campos vazios', () async {
      expect(
        () => useCase.execute(email: '', senha: ''),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
