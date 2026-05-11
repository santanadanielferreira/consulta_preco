import '../../domain/entities/dispositivo.dart';

class DispositivoModel extends Dispositivo {
  const DispositivoModel({
    super.id,
    required super.modelo,
    required super.mei,
    required super.versaoAndroid,
    required super.dataCadastro,
  });

  factory DispositivoModel.fromMap(Map<String, dynamic> map) {
    return DispositivoModel(
      id: map['id'] as int?,
      modelo: map['modelo'] as String,
      mei: map['mei'] as String,
      versaoAndroid: map['versao_android'] as String,
      dataCadastro: DateTime.parse(map['data_cadastro'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'modelo': modelo,
      'mei': mei,
      'versao_android': versaoAndroid,
      'data_cadastro': dataCadastro.toIso8601String(),
    };
  }

  factory DispositivoModel.fromEntity(Dispositivo entity) {
    return DispositivoModel(
      id: entity.id,
      modelo: entity.modelo,
      mei: entity.mei,
      versaoAndroid: entity.versaoAndroid,
      dataCadastro: entity.dataCadastro,
    );
  }
}
