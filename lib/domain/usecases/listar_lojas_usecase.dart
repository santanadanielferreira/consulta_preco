import '../entities/loja.dart';
import '../repositories/loja_repository.dart';

class ListarLojasUseCase {
  ListarLojasUseCase(this._lojaRepository);

  final LojaRepository _lojaRepository;

  Future<List<Loja>> execute({String? filtroNome}) {
    return _lojaRepository.listarLojas(filtroNome: filtroNome);
  }
}
