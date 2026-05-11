import 'package:equatable/equatable.dart';

class Loja extends Equatable {
  const Loja({
    this.id,
    required this.nome,
    required this.endereco,
    required this.cidade,
    required this.estado,
    required this.idColaborador,
    this.tempoMedioColeta = 300,
    this.ultimoExport,
  });

  final int? id;
  final String nome;
  final String endereco;
  final String cidade;
  final String estado;
  final int idColaborador;
  final int tempoMedioColeta;
  final DateTime? ultimoExport;

  Loja copyWith({
    int? id,
    String? nome,
    String? endereco,
    String? cidade,
    String? estado,
    int? idColaborador,
    int? tempoMedioColeta,
    DateTime? ultimoExport,
  }) {
    return Loja(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      endereco: endereco ?? this.endereco,
      cidade: cidade ?? this.cidade,
      estado: estado ?? this.estado,
      idColaborador: idColaborador ?? this.idColaborador,
      tempoMedioColeta: tempoMedioColeta ?? this.tempoMedioColeta,
      ultimoExport: ultimoExport ?? this.ultimoExport,
    );
  }

  @override
  List<Object?> get props => [
        id,
        nome,
        endereco,
        cidade,
        estado,
        idColaborador,
        tempoMedioColeta,
        ultimoExport,
      ];
}
