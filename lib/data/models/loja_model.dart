import '../../domain/entities/loja.dart';

class LojaModel extends Loja {
  const LojaModel({
    super.id,
    required super.nome,
    required super.endereco,
    required super.cidade,
    required super.estado,
    required super.idColaborador,
    super.tempoMedioColeta = 300,
  });

  factory LojaModel.fromMap(Map<String, dynamic> map) {
    return LojaModel(
      id: map['id'] as int?,
      nome: map['nome'] as String,
      endereco: map['endereco'] as String,
      cidade: map['cidade'] as String,
      estado: map['estado'] as String,
      idColaborador: map['id_colaborador'] as int? ?? 1,
      tempoMedioColeta: map['tempo_medio_coleta'] as int? ?? 300,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'endereco': endereco,
      'cidade': cidade,
      'estado': estado,
      'id_colaborador': idColaborador,
      'tempo_medio_coleta': tempoMedioColeta,
    };
  }

  factory LojaModel.fromEntity(Loja entity) {
    return LojaModel(
      id: entity.id,
      nome: entity.nome,
      endereco: entity.endereco,
      cidade: entity.cidade,
      estado: entity.estado,
      idColaborador: entity.idColaborador,
      tempoMedioColeta: entity.tempoMedioColeta,
    );
  }
}
