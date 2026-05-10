import '../../domain/entities/coleta.dart';
import '../../domain/entities/item_coleta.dart';
import '../../domain/repositories/coleta_repository.dart';
import '../datasources/local/local_data_source.dart';
import '../models/coleta_model.dart';
import '../models/item_coleta_model.dart';

class ColetaRepositoryImpl implements ColetaRepository {
  ColetaRepositoryImpl(this._localDataSource);

  final LocalDataSource _localDataSource;

  @override
  Future<int> iniciarColeta(Coleta coleta) {
    return _localDataSource.inserirColeta(ColetaModel.fromEntity(coleta));
  }

  @override
  Future<Coleta?> buscarPorId(int id) {
    return _localDataSource.buscarColetaPorId(id);
  }

  @override
  Future<ItemColeta?> buscarItemColeta(int idColeta, int idProduto) {
    return _localDataSource.buscarItemColeta(idColeta, idProduto);
  }

  @override
  Future<void> registrarOuAtualizarItem(ItemColeta item) {
    return _localDataSource.inserirOuAtualizarItemColeta(
      ItemColetaModel.fromEntity(item),
    );
  }

  @override
  Future<void> removerItemDaColeta(int idColeta, int idProduto) {
    return _localDataSource.removerItemColeta(idColeta, idProduto);
  }

  @override
  Future<List<ItemColeta>> listarItensDaColeta(int idColeta) {
    return _localDataSource.listarItensColeta(idColeta);
  }

  @override
  Future<List<Coleta>> listarColetasDoDia(DateTime data) {
    return _localDataSource.listarColetasPorDia(data);
  }
}
