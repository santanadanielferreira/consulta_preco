import '../../domain/entities/coleta.dart';

class ColetaModel extends Coleta {
  const ColetaModel({
    super.id,
    required super.idLoja,
    required super.dataColeta,
    required super.idColaborador,
    required super.idDispositivo,
    super.dataExportacao,
    super.itensColetadosExportacao,
    super.totalEstimadoExportacao,
    super.percentualExportacao,
  });

  factory ColetaModel.fromMap(Map<String, dynamic> map) {
    return ColetaModel(
      id: map['id'] as int?,
      idLoja: map['id_loja'] as int,
      dataColeta: DateTime.parse(map['data_coleta'] as String),
      idColaborador: map['id_colaborador'] as int,
      idDispositivo: map['id_dispositivo'] as int,
      dataExportacao: (map['data_exportacao'] as String?) != null
          ? DateTime.parse(map['data_exportacao'] as String)
          : null,
      itensColetadosExportacao: map['itens_coletados_exportacao'] as int?,
      totalEstimadoExportacao: map['total_estimado_exportacao'] as int?,
      percentualExportacao: (map['percentual_exportacao'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_loja': idLoja,
      'data_coleta': dataColeta.toIso8601String(),
      'id_colaborador': idColaborador,
      'id_dispositivo': idDispositivo,
      'data_exportacao': dataExportacao?.toIso8601String(),
      'itens_coletados_exportacao': itensColetadosExportacao,
      'total_estimado_exportacao': totalEstimadoExportacao,
      'percentual_exportacao': percentualExportacao,
    };
  }

  factory ColetaModel.fromEntity(Coleta entity) {
    return ColetaModel(
      id: entity.id,
      idLoja: entity.idLoja,
      dataColeta: entity.dataColeta,
      idColaborador: entity.idColaborador,
      idDispositivo: entity.idDispositivo,
      dataExportacao: entity.dataExportacao,
      itensColetadosExportacao: entity.itensColetadosExportacao,
      totalEstimadoExportacao: entity.totalEstimadoExportacao,
      percentualExportacao: entity.percentualExportacao,
    );
  }
}
