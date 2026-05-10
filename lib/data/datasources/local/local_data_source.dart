import '../../models/coleta_model.dart';
import '../../models/colaborador_model.dart';
import '../../models/dispositivo_model.dart';
import '../../models/item_coleta_model.dart';
import '../../models/loja_model.dart';
import '../../models/produto_model.dart';

abstract class LocalDataSource {
  Future<void> upsertProdutos(List<ProdutoModel> produtos, {int? idColaborador});
  Future<ProdutoModel?> buscarProdutoPorCodigoBarras(String codigoBarras);
  Future<ProdutoModel?> buscarProdutoPorCodigoBarrasColaborador(String codigoBarras, int idColaborador);
  Future<ProdutoModel?> buscarProdutoPorId(int id);
  Future<List<ProdutoModel>> listarProdutos();
  Future<List<ProdutoModel>> buscarProdutosPorNome(String filtroNome);
  Future<List<ProdutoModel>> listarProdutosPorColaborador(int? idColaborador);

  Future<void> upsertLojas(List<LojaModel> lojas, {int? idColaborador});
  Future<List<LojaModel>> listarLojas({String? filtroNome});
  Future<List<LojaModel>> listarLojasPorColaborador(int idColaborador, {String? filtroNome});
  Future<LojaModel?> buscarLojaPorId(int id);

  Future<int> inserirColeta(ColetaModel coleta);
  Future<ColetaModel?> buscarColetaPorId(int id);
  Future<List<ColetaModel>> listarColetasPorDia(DateTime data);
  Future<ItemColetaModel?> buscarItemColeta(int idColeta, int idProduto);
  Future<void> inserirOuAtualizarItemColeta(ItemColetaModel item);
  Future<void> removerItemColeta(int idColeta, int idProduto);
  Future<List<ItemColetaModel>> listarItensColeta(int idColeta);

  Future<ColaboradorModel?> buscarColaboradorPorEmail(String email);
  Future<int> inserirColaborador(ColaboradorModel colaborador);

  Future<DispositivoModel?> buscarDispositivoPorMei(String mei);
  Future<int> inserirDispositivo(DispositivoModel dispositivo);
}
