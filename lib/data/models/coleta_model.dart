import '../../domain/entities/coleta.dart';

class ColetaModel extends Coleta {
  const ColetaModel({
    super.id,
    required super.idLoja,
    required super.dataColeta,
    required super.idColaborador,
    required super.idDispositivo,
  });

  factory ColetaModel.fromMap(Map<String, dynamic> map) {
    return ColetaModel(
      id: map['id'] as int?,
      idLoja: map['id_loja'] as int,
      dataColeta: DateTime.parse(map['data_coleta'] as String),
      idColaborador: map['id_colaborador'] as int,
      idDispositivo: map['id_dispositivo'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_loja': idLoja,
      'data_coleta': dataColeta.toIso8601String(),
      'id_colaborador': idColaborador,
      'id_dispositivo': idDispositivo,
    };
  }

  factory ColetaModel.fromEntity(Coleta entity) {
    return ColetaModel(
      id: entity.id,
      idLoja: entity.idLoja,
      dataColeta: entity.dataColeta,
      idColaborador: entity.idColaborador,
      idDispositivo: entity.idDispositivo,
    );
  }
}
