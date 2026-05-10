import 'package:equatable/equatable.dart';

class Colaborador extends Equatable {
  const Colaborador({
    this.id,
    required this.nome,
    required this.email,
    required this.login,
    required this.senha,
    required this.dataCadastro,
  });

  final int? id;
  final String nome;
  final String email;
  final String login;
  final String senha;
  final DateTime dataCadastro;

  Colaborador copyWith({
    int? id,
    String? nome,
    String? email,
    String? login,
    String? senha,
    DateTime? dataCadastro,
  }) {
    return Colaborador(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      login: login ?? this.login,
      senha: senha ?? this.senha,
      dataCadastro: dataCadastro ?? this.dataCadastro,
    );
  }

  @override
  List<Object?> get props => [id, nome, email, login, senha, dataCadastro];
}
