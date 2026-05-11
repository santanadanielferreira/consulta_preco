import '../entities/loja.dart';

abstract class LojaRepository {
  Future<void> importarLojas(List<Loja> lojas, {int? idColaborador});
  Future<List<Loja>> listarLojas({String? filtroNome});
  Future<List<Loja>> listarLojasPorColaborador(int idColaborador, {String? filtroNome});
  Future<Loja?> buscarPorId(int id);
  Future<void> vincularProduto(int lojaId, int produtoId, int colaboradorId);
}
