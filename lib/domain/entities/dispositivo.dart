import 'package:equatable/equatable.dart';

class Dispositivo extends Equatable {
  const Dispositivo({
    this.id,
    required this.modelo,
    required this.mei,
    required this.versaoAndroid,
    required this.dataCadastro,
  });

  final int? id;
  final String modelo;
  final String mei;
  final String versaoAndroid;
  final DateTime dataCadastro;

  Dispositivo copyWith({
    int? id,
    String? modelo,
    String? mei,
    String? versaoAndroid,
    DateTime? dataCadastro,
  }) {
    return Dispositivo(
      id: id ?? this.id,
      modelo: modelo ?? this.modelo,
      mei: mei ?? this.mei,
      versaoAndroid: versaoAndroid ?? this.versaoAndroid,
      dataCadastro: dataCadastro ?? this.dataCadastro,
    );
  }

  @override
  List<Object?> get props => [id, modelo, mei, versaoAndroid, dataCadastro];
}
