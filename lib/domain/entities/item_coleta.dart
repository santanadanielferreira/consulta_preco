import 'package:equatable/equatable.dart';

class ItemColeta extends Equatable {
  const ItemColeta({
    this.id,
    required this.idColeta,
    required this.idProduto,
    required this.preco,
    required this.dataColeta,
    this.fotoBase64,
  });

  final int? id;
  final int idColeta;
  final int idProduto;
  final double preco;
  final DateTime dataColeta;
  final String? fotoBase64;

  ItemColeta copyWith({
    int? id,
    int? idColeta,
    int? idProduto,
    double? preco,
    DateTime? dataColeta,
    String? fotoBase64,
  }) {
    return ItemColeta(
      id: id ?? this.id,
      idColeta: idColeta ?? this.idColeta,
      idProduto: idProduto ?? this.idProduto,
      preco: preco ?? this.preco,
      dataColeta: dataColeta ?? this.dataColeta,
      fotoBase64: fotoBase64 ?? this.fotoBase64,
    );
  }

  @override
  List<Object?> get props => [id, idColeta, idProduto, preco, dataColeta, fotoBase64];
}
