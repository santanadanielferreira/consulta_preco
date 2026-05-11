import '../repositories/coleta_repository.dart';

class ReiniciarColetaUseCase {
  ReiniciarColetaUseCase(this._coletaRepository);

  final ColetaRepository _coletaRepository;

  Future<void> execute(int idColeta) {
    return _coletaRepository.reiniciarColeta(idColeta);
  }
}
