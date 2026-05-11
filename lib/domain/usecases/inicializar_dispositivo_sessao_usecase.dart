import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

import '../entities/dispositivo.dart';
import '../repositories/dispositivo_repository.dart';

class InicializarDispositivoSessaoUseCase {
  InicializarDispositivoSessaoUseCase(this._dispositivoRepository);

  final DispositivoRepository _dispositivoRepository;

  Future<Dispositivo> execute() async {
    final infoPlugin = DeviceInfoPlugin();

    String modelo = 'Dispositivo';
    String versao = 'Desconhecida';
    String fingerprint = 'fallback-device';

    try {
      if (Platform.isAndroid) {
        final info = await infoPlugin.androidInfo;
        modelo = '${info.manufacturer} ${info.model}'.trim();
        versao = info.version.release;
        fingerprint =
            '${info.manufacturer}-${info.model}-${info.device}'.toLowerCase();
      }
    } catch (_) {
      // Mantem fallback para nao bloquear autenticacao em ambiente sem dados de device.
    }

    final existente = await _dispositivoRepository.buscarPorFingerprint(fingerprint);
    if (existente != null) {
      return existente;
    }

    final novo = Dispositivo(
      modelo: modelo,
      mei: fingerprint,
      versaoAndroid: versao,
      dataCadastro: DateTime.now(),
    );

    final id = await _dispositivoRepository.inserir(novo);
    return novo.copyWith(id: id);
  }
}
