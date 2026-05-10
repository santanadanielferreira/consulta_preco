import '../../domain/entities/colaborador.dart';

class ColaboradorModel extends Colaborador {
  const ColaboradorModel({
    super.id,
    required super.nome,
    required super.email,
    required super.login,
    required super.senha,
    required super.dataCadastro,
  });

  factory ColaboradorModel.fromMap(Map<String, dynamic> map) {
    return ColaboradorModel(
      id: map['id'] as int?,
      nome: map['nome'] as String,
      email: map['email'] as String,
      login: map['login'] as String,
      senha: map['senha'] as String,
      dataCadastro: DateTime.parse(map['data_cadastro'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'login': login,
      'senha': senha,
      'data_cadastro': dataCadastro.toIso8601String(),
    };
  }

  factory ColaboradorModel.fromEntity(Colaborador entity) {
    return ColaboradorModel(
      id: entity.id,
      nome: entity.nome,
      email: entity.email,
      login: entity.login,
      senha: entity.senha,
      dataCadastro: entity.dataCadastro,
    );
  }
}
