import '../../domain/entities/produto.dart';

class ProdutoModel extends Produto {
  const ProdutoModel({
    super.id,
    required super.codigoBarras,
    required super.nome,
    required super.fabricante,
    super.fotoBase64,
    required super.idColaborador,
  });

  factory ProdutoModel.fromMap(Map<String, dynamic> map) {
    return ProdutoModel(
      id: map['id'] as int?,
      codigoBarras: map['codigo_barras'] as String,
      nome: map['nome'] as String,
      fabricante: map['fabricante'] as String,
      fotoBase64: map['foto_base64'] as String?,
      idColaborador: map['id_colaborador'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'codigo_barras': codigoBarras,
      'nome': nome,
      'fabricante': fabricante,
      'foto_base64': fotoBase64,
      'id_colaborador': idColaborador,
    };
  }

  factory ProdutoModel.fromEntity(Produto entity) {
    return ProdutoModel(
      id: entity.id,
      codigoBarras: entity.codigoBarras,
      nome: entity.nome,
      fabricante: entity.fabricante,
      fotoBase64: entity.fotoBase64,
      idColaborador: entity.idColaborador,
    );
  }
}
