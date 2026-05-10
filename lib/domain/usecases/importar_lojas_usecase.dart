import '../../core/utils/json_import_validators.dart';
import '../entities/loja.dart';
import '../repositories/loja_repository.dart';

class ImportarLojasUseCase {
  ImportarLojasUseCase(this._lojaRepository);

  final LojaRepository _lojaRepository;

  Future<void> execute(String jsonContent, {int? idColaborador}) async {
    final lojas = JsonImportValidators.parseLojas(jsonContent);
    final semDuplicidade = _deduplicateByNomeCidade(lojas);
    await _lojaRepository.importarLojas(semDuplicidade, idColaborador: idColaborador);
  }

  List<Loja> _deduplicateByNomeCidade(List<Loja> lojas) {
    final map = <String, Loja>{};
    for (final loja in lojas) {
      final chave = '${loja.nome.toLowerCase()}|${loja.cidade.toLowerCase()}';
      map[chave] = loja;
    }
    return map.values.toList(growable: false);
  }
}
