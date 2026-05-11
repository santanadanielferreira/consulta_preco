class ColetaCatalogArgs {
  const ColetaCatalogArgs({
    required this.idColeta,
    required this.idLoja,
    required this.nomeLoja,
  });

  final int idColeta;
  final int idLoja;
  final String nomeLoja;
}

class ScannerArgs {
  const ScannerArgs({required this.idColeta, required this.idLoja, required this.isBusca});

  final int idColeta;
  final int idLoja;
  final bool isBusca;
}

class PriceInputArgs {
  const PriceInputArgs({
    required this.idColeta,
    required this.idProduto,
    required this.nomeProduto,
  });

  final int idColeta;
  final int idProduto;
  final String nomeProduto;
}

class EditItemArgs {
  const EditItemArgs({
    required this.idColeta,
    required this.idProduto,
    required this.nomeProduto,
    required this.precoAtual,
  });

  final int idColeta;
  final int idProduto;
  final String nomeProduto;
  final double precoAtual;
}

class ColetaSummaryArgs {
  const ColetaSummaryArgs({
    required this.idColeta,
    required this.idLoja,
    required this.idColaborador,
  });

  final int idColeta;
  final int idLoja;
  final int idColaborador;
}
