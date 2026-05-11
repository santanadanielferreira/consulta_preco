import '../repositories/coleta_repository.dart';

class RemoverItemColetaUseCase {
  RemoverItemColetaUseCase(this._coletaRepository);

  final ColetaRepository _coletaRepository;

  Future<void> execute({
    required int idColeta,
    required int idProduto,
  }) async {
    if (idColeta <= 0 || idProduto <= 0) {
      throw const FormatException('Identificadores de coleta/produto invalidos.');
    }

    await _coletaRepository.removerItemDaColeta(idColeta, idProduto);
  }
}
