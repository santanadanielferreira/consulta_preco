import '../entities/colaborador.dart';

abstract class ColaboradorRepository {
  Future<Colaborador?> buscarPorEmail(String email);
  Future<int> inserir(Colaborador colaborador);
}
