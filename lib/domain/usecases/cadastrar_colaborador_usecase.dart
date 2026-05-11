import '../entities/colaborador.dart';
import '../repositories/colaborador_repository.dart';

class CadastrarColaboradorUseCase {
  CadastrarColaboradorUseCase(this._colaboradorRepository);

  final ColaboradorRepository _colaboradorRepository;

  Future<Colaborador> execute({
    required String nome,
    required String email,
    required String senha,
  }) async {
    final normalizedNome = nome.trim();
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedSenha = senha.trim();

    if (normalizedNome.isEmpty || normalizedEmail.isEmpty || normalizedSenha.isEmpty) {
      throw const FormatException('Nome, email e senha sao obrigatorios.');
    }

    if (normalizedSenha.length < 6) {
      throw const FormatException('A senha deve ter pelo menos 6 caracteres.');
    }

    final existente = await _colaboradorRepository.buscarPorEmail(normalizedEmail);
    if (existente != null) {
      throw const FormatException('Ja existe usuario cadastrado com este email.');
    }

    final novo = Colaborador(
      nome: normalizedNome,
      email: normalizedEmail,
      login: normalizedEmail,
      senha: normalizedSenha,
      dataCadastro: DateTime.now(),
    );

    final id = await _colaboradorRepository.inserir(novo);
    return novo.copyWith(id: id);
  }
}
