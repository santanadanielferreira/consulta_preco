import '../../domain/entities/dispositivo.dart';
import '../../domain/repositories/dispositivo_repository.dart';
import '../datasources/local/local_data_source.dart';
import '../models/dispositivo_model.dart';

class DispositivoRepositoryImpl implements DispositivoRepository {
  DispositivoRepositoryImpl(this._localDataSource);

  final LocalDataSource _localDataSource;

  @override
  Future<Dispositivo?> buscarPorFingerprint(String fingerprint) {
    return _localDataSource.buscarDispositivoPorMei(fingerprint);
  }

  @override
  Future<int> inserir(Dispositivo dispositivo) {
    return _localDataSource.inserirDispositivo(
      DispositivoModel.fromEntity(dispositivo),
    );
  }
}
