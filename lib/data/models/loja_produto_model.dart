class LojaProdutoModel {
  final int? lojaId;
  final int? produtoId;
  final int? colaboradorId;

  const LojaProdutoModel({this.lojaId, this.produtoId, this.colaboradorId});

  factory LojaProdutoModel.fromMap(Map<String, dynamic> map) {
    return LojaProdutoModel(
      lojaId: map['loja_id'] as int?,
      produtoId: map['produto_id'] as int?,
      colaboradorId: map['colaborador_id'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'loja_id': lojaId,
      'produto_id': produtoId,
      'colaborador_id': colaboradorId,
    };
  }
}
