import '../entities/loja.dart';
import '../repositories/loja_repository.dart';

class ListarLojasColaboradorUseCase {
  ListarLojasColaboradorUseCase(this._lojaRepository);

  final LojaRepository _lojaRepository;

  Future<List<Loja>> execute(int idColaborador, {String? filtroNome}) {
    return _lojaRepository.listarLojasPorColaborador(
      idColaborador,
      filtroNome: filtroNome,
    );
  }
}
