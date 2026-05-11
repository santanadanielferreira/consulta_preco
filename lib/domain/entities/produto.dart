import 'package:equatable/equatable.dart';

class Produto extends Equatable {
  const Produto({
    this.id,
    required this.codigoBarras,
    required this.nome,
    required this.fabricante,
    this.fotoBase64,
    required this.idColaborador,
  });

  final int? id;
  final String codigoBarras;
  final String nome;
  final String fabricante;
  final String? fotoBase64;
  final int idColaborador;

  Produto copyWith({
    int? id,
    String? codigoBarras,
    String? nome,
    String? fabricante,
    String? fotoBase64,
    int? idColaborador,
  }) {
    return Produto(
      id: id ?? this.id,
      codigoBarras: codigoBarras ?? this.codigoBarras,
      nome: nome ?? this.nome,
      fabricante: fabricante ?? this.fabricante,
      fotoBase64: fotoBase64 ?? this.fotoBase64,
      idColaborador: idColaborador ?? this.idColaborador,
    );
  }

  @override
  List<Object?> get props => [id, codigoBarras, nome, fabricante, fotoBase64, idColaborador];
}
