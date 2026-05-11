import '../entities/coleta.dart';
import '../entities/item_coleta.dart';

abstract class ColetaRepository {
  Future<int> iniciarColeta(Coleta coleta);
  Future<Coleta?> buscarPorId(int id);
  Future<ItemColeta?> buscarItemColeta(int idColeta, int idProduto);
  Future<void> registrarOuAtualizarItem(ItemColeta item);
  Future<void> removerItemDaColeta(int idColeta, int idProduto);
  Future<List<ItemColeta>> listarItensDaColeta(int idColeta);
  Future<List<Coleta>> listarColetasDoDia(DateTime data);
  Future<List<Coleta>> listarColetasPorColaborador(int idColaborador);
  Future<void> marcarColetaComoExportada(
    int idColeta, {
    required DateTime dataExportacao,
    required int itensColetados,
    required int totalEstimado,
    required double percentual,
  });
  Future<void> reiniciarColeta(int idColeta);
  Future<void> removerColeta(int idColeta);
}
