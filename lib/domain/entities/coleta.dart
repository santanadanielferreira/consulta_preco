import 'package:equatable/equatable.dart';

class Coleta extends Equatable {
  const Coleta({
    this.id,
    required this.idLoja,
    required this.dataColeta,
    required this.idColaborador,
    required this.idDispositivo,
    this.dataExportacao,
    this.itensColetadosExportacao,
    this.totalEstimadoExportacao,
    this.percentualExportacao,
  });

  final int? id;
  final int idLoja;
  final DateTime dataColeta;
  final int idColaborador;
  final int idDispositivo;
  final DateTime? dataExportacao;
  final int? itensColetadosExportacao;
  final int? totalEstimadoExportacao;
  final double? percentualExportacao;

  Coleta copyWith({
    int? id,
    int? idLoja,
    DateTime? dataColeta,
    int? idColaborador,
    int? idDispositivo,
    DateTime? dataExportacao,
    int? itensColetadosExportacao,
    int? totalEstimadoExportacao,
    double? percentualExportacao,
  }) {
    return Coleta(
      id: id ?? this.id,
      idLoja: idLoja ?? this.idLoja,
      dataColeta: dataColeta ?? this.dataColeta,
      idColaborador: idColaborador ?? this.idColaborador,
      idDispositivo: idDispositivo ?? this.idDispositivo,
      dataExportacao: dataExportacao ?? this.dataExportacao,
      itensColetadosExportacao:
          itensColetadosExportacao ?? this.itensColetadosExportacao,
      totalEstimadoExportacao:
          totalEstimadoExportacao ?? this.totalEstimadoExportacao,
      percentualExportacao: percentualExportacao ?? this.percentualExportacao,
    );
  }

  @override
  List<Object?> get props => [
        id,
        idLoja,
        dataColeta,
        idColaborador,
        idDispositivo,
        dataExportacao,
        itensColetadosExportacao,
        totalEstimadoExportacao,
        percentualExportacao,
      ];
}
