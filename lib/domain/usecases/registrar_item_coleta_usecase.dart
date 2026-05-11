import '../../core/utils/price_validator.dart';
import '../entities/item_coleta.dart';
import '../repositories/coleta_repository.dart';

class RegistrarItemColetaUseCase {
  RegistrarItemColetaUseCase(this._coletaRepository);

  final ColetaRepository _coletaRepository;

  Future<void> execute({
    required int idColeta,
    required int idProduto,
    required double preco,
    String? fotoBase64,
  }) async {
    PriceValidator.ensureValid(preco);

    final item = ItemColeta(
      idColeta: idColeta,
      idProduto: idProduto,
      preco: preco,
      dataColeta: DateTime.now(),
      fotoBase64: fotoBase64,
    );

    await _coletaRepository.registrarOuAtualizarItem(item);
  }
}
