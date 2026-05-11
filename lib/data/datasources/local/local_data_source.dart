import '../../models/coleta_model.dart';
import '../../models/colaborador_model.dart';
import '../../models/dispositivo_model.dart';
import '../../models/item_coleta_model.dart';
import '../../models/loja_model.dart';
import '../../models/loja_produto_model.dart';
import '../../models/produto_model.dart';

abstract class LocalDataSource {
  Future<void> upsertProdutos(List<ProdutoModel> produtos, {int? idColaborador});
  Future<ProdutoModel?> buscarProdutoPorCodigoBarras(String codigoBarras);
  Future<ProdutoModel?> buscarProdutoPorCodigoBarrasColaborador(String codigoBarras, int idColaborador);
  Future<ProdutoModel?> buscarProdutoPorId(int id);
  Future<ProdutoModel?> buscarProdutoPorCodigoBarrasNaLoja(String codigoBarras, int lojaId, int colaboradorId);
  Future<List<ProdutoModel>> listarProdutos();
  Future<List<ProdutoModel>> buscarProdutosPorNome(String filtroNome);
  Future<List<ProdutoModel>> listarProdutosPorColaborador(int? idColaborador);

  Future<void> upsertLojas(List<LojaModel> lojas, {int? idColaborador});
  Future<List<LojaModel>> listarLojas({String? filtroNome});
  Future<List<LojaModel>> listarLojasPorColaborador(int idColaborador, {String? filtroNome});
  Future<LojaModel?> buscarLojaPorId(int id);

  // Relations between stores and products
  Future<void> upsertLojaProduto(int lojaId, int produtoId, int colaboradorId);
  Future<void> upsertLojaProdutos(List<LojaProdutoModel> lojaProdutos, {int? idColaborador});
  Future<List<ProdutoModel>> listarProdutosPorLojaEColaborador(int lojaId, int colaboradorId);

  Future<int> inserirColeta(ColetaModel coleta);
  Future<ColetaModel?> buscarColetaPorId(int id);
  Future<List<ColetaModel>> listarColetasPorDia(DateTime data);
  Future<List<ColetaModel>> listarColetasPorColaborador(int idColaborador);
  Future<ItemColetaModel?> buscarItemColeta(int idColeta, int idProduto);
  Future<void> inserirOuAtualizarItemColeta(ItemColetaModel item);
  Future<void> removerItemColeta(int idColeta, int idProduto);
  Future<List<ItemColetaModel>> listarItensColeta(int idColeta);

  Future<void> marcarColetaComoExportada(
    int idColeta, {
    required DateTime dataExportacao,
    required int itensColetados,
    required int totalEstimado,
    required double percentual,
  });
  Future<void> reiniciarColeta(int idColeta);

  Future<void> removerColeta(int idColeta);

  Future<ColaboradorModel?> buscarColaboradorPorEmail(String email);
  Future<int> inserirColaborador(ColaboradorModel colaborador);

  Future<DispositivoModel?> buscarDispositivoPorMei(String mei);
  Future<int> inserirDispositivo(DispositivoModel dispositivo);
}
