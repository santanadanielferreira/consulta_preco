import '../entities/coleta.dart';
import '../repositories/coleta_repository.dart';

class IniciarColetaUseCase {
  IniciarColetaUseCase(this._coletaRepository);

  final ColetaRepository _coletaRepository;

  Future<int> execute({
    required int idLoja,
    required int idColaborador,
    required int idDispositivo,
  }) {
    final coleta = Coleta(
      idLoja: idLoja,
      dataColeta: DateTime.now(),
      idColaborador: idColaborador,
      idDispositivo: idDispositivo,
    );

    return _coletaRepository.iniciarColeta(coleta);
  }
}
