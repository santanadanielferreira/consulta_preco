import 'package:equatable/equatable.dart';

class Coleta extends Equatable {
  const Coleta({
    this.id,
    required this.idLoja,
    required this.dataColeta,
    required this.idColaborador,
    required this.idDispositivo,
  });

  final int? id;
  final int idLoja;
  final DateTime dataColeta;
  final int idColaborador;
  final int idDispositivo;

  Coleta copyWith({
    int? id,
    int? idLoja,
    DateTime? dataColeta,
    int? idColaborador,
    int? idDispositivo,
  }) {
    return Coleta(
      id: id ?? this.id,
      idLoja: idLoja ?? this.idLoja,
      dataColeta: dataColeta ?? this.dataColeta,
      idColaborador: idColaborador ?? this.idColaborador,
      idDispositivo: idDispositivo ?? this.idDispositivo,
    );
  }

  @override
  List<Object?> get props => [id, idLoja, dataColeta, idColaborador, idDispositivo];
}
