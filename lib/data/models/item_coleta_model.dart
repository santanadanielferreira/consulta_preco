import '../../domain/entities/item_coleta.dart';

class ItemColetaModel extends ItemColeta {
  const ItemColetaModel({
    super.id,
    required super.idColeta,
    required super.idProduto,
    required super.preco,
    required super.dataColeta,
    super.fotoBase64,
  });

  factory ItemColetaModel.fromMap(Map<String, dynamic> map) {
    return ItemColetaModel(
      id: map['id'] as int?,
      idColeta: map['id_coleta'] as int,
      idProduto: map['id_produto'] as int,
      preco: (map['preco'] as num).toDouble(),
      dataColeta: DateTime.parse(map['data_coleta'] as String),
      fotoBase64: map['foto_base64'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_coleta': idColeta,
      'id_produto': idProduto,
      'preco': preco,
      'data_coleta': dataColeta.toIso8601String(),
      'foto_base64': fotoBase64,
    };
  }

  factory ItemColetaModel.fromEntity(ItemColeta entity) {
    return ItemColetaModel(
      id: entity.id,
      idColeta: entity.idColeta,
      idProduto: entity.idProduto,
      preco: entity.preco,
      dataColeta: entity.dataColeta,
      fotoBase64: entity.fotoBase64,
    );
  }
}
