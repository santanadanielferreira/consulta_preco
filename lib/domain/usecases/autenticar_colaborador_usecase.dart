import '../entities/colaborador.dart';
import '../repositories/colaborador_repository.dart';

class AutenticarColaboradorUseCase {
  AutenticarColaboradorUseCase(this._colaboradorRepository);

  final ColaboradorRepository _colaboradorRepository;

  Future<Colaborador> execute({
    required String email,
    required String senha,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedSenha = senha.trim();

    if (normalizedEmail.isEmpty || normalizedSenha.isEmpty) {
      throw const FormatException('Email e senha sao obrigatorios.');
    }

    final colaborador = await _colaboradorRepository.buscarPorEmail(normalizedEmail);
    if (colaborador == null || colaborador.senha != normalizedSenha) {
      throw const FormatException('Credenciais invalidas.');
    }

    return colaborador;
  }
}
