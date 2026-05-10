import '../../domain/entities/colaborador.dart';
import '../../domain/repositories/colaborador_repository.dart';
import '../datasources/local/local_data_source.dart';
import '../models/colaborador_model.dart';

class ColaboradorRepositoryImpl implements ColaboradorRepository {
  ColaboradorRepositoryImpl(this._localDataSource);

  final LocalDataSource _localDataSource;

  @override
  Future<Colaborador?> buscarPorEmail(String email) {
    return _localDataSource.buscarColaboradorPorEmail(email.trim().toLowerCase());
  }

  @override
  Future<int> inserir(Colaborador colaborador) {
    return _localDataSource.inserirColaborador(
      ColaboradorModel.fromEntity(colaborador),
    );
  }
}
