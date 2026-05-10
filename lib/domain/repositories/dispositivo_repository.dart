import '../entities/dispositivo.dart';

abstract class DispositivoRepository {
  Future<Dispositivo?> buscarPorFingerprint(String fingerprint);
  Future<int> inserir(Dispositivo dispositivo);
}
