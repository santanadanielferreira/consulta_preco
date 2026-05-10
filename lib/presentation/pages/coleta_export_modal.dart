import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/app_providers.dart';
import '../navigation/route_args.dart';

class ColetaExportModal extends ConsumerStatefulWidget {
  const ColetaExportModal({
    super.key,
    required this.args,
  });

  final ColetaCatalogArgs args;

  @override
  ConsumerState<ColetaExportModal> createState() => _ColetaExportModalState();
}

class _ColetaExportModalState extends ConsumerState<ColetaExportModal> {
  static const _primaryBlue = Color(0xFF4A89F3);
  static const _surfaceBg = Color(0xFFF7F9FC);
  static const _titleColor = Color(0xFF1F2937);
  static const _mutedColor = Color(0xFF6F7682);

  late Future<_ExportResumoData> _futureResumo;
  bool _exportando = false;

  @override
  void initState() {
    super.initState();
    _futureResumo = _loadResumo();
  }

  Future<_ExportResumoData> _loadResumo() async {
    final colaborador = ref.read(colaboradorSessaoProvider);
    if (colaborador == null) {
      throw StateError('Colaborador da sessão indisponivel.');
    }

    final exportJson = await ref.read(exportarColetaIndividualUseCaseProvider).execute(
          idColeta: widget.args.idColeta,
          idLoja: widget.args.idLoja,
          nomeColaborador: colaborador.nome,
          emailColaborador: colaborador.email,
        );

    return _ExportResumoData.fromMap(exportJson);
  }

  Future<void> _confirmarExportacao(_ExportResumoData resumo) async {
    setState(() {
      _exportando = true;
    });

    try {
      final jsonContent = const JsonEncoder.withIndent('  ').convert(resumo.exportData);
      await ref.read(exportFileServiceProvider).saveCollectionJson(
            idColeta: widget.args.idColeta,
            jsonContent: jsonContent,
          );

      if (!mounted) {
        return;
      }

      await ref.read(feedbackServiceProvider).success(
            context: context,
            message: 'Coleta exportada com sucesso!',
            vibracaoAtiva: ref.read(vibracaoAtivaProvider),
          );

      if (!mounted) {
        return;
      }

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) {
        return;
      }
      ref.read(feedbackServiceProvider).error(
            context: context,
            message: 'Falha ao exportar coleta: $e',
          );
    } finally {
      if (mounted) {
        setState(() {
          _exportando = false;
        });
      }
    }
  }

  bool _isValidBase64(String? value) {
    if (value == null || value.isEmpty) {
      return false;
    }

    try {
      base64Decode(value);
      return true;
    } catch (_) {
      return false;
    }
  }

  Widget _buildImage(String? value, {double size = 48}) {
    if (!_isValidBase64(value)) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F4F9),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.image_outlined, color: Color(0xFFB7C0CC)),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.memory(
        base64Decode(value!),
        width: size,
        height: size,
        fit: BoxFit.cover,
        gaplessPlayback: true,
      ),
    );
  }

  Widget _buildSummaryChip(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: _mutedColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                color: _titleColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemTile(_ExportResumoItem item) {
    final imageValue = item.fotoBase64;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImage(imageValue, size: 52),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.nomeProduto,
                  style: const TextStyle(
                    color: _titleColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Cod: ${item.codigoBarras}',
                  style: const TextStyle(
                    color: _mutedColor,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'R\$ ${item.preco.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: _primaryBlue,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor: Colors.transparent,
      child: FutureBuilder<_ExportResumoData>(
        future: _futureResumo,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: _surfaceBg,
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Center(
                child: CircularProgressIndicator(color: _primaryBlue),
              ),
            );
          }

          if (snapshot.hasError || snapshot.data == null) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _surfaceBg,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Nao foi possivel montar o resumo da coleta.',
                    style: TextStyle(
                      color: _titleColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${snapshot.error}',
                    style: const TextStyle(color: _mutedColor),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Fechar'),
                  ),
                ],
              ),
            );
          }

          final resumo = snapshot.data!;

          return Container(
            height: MediaQuery.of(context).size.height * 0.86,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _surfaceBg,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(74, 137, 243, 0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.file_download_outlined, color: _primaryBlue),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Resumo da coleta',
                            style: TextStyle(
                              color: _titleColor,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Revise os dados antes de exportar',
                            style: TextStyle(
                              color: _mutedColor,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _exportando ? null : () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: _mutedColor),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.args.nomeLoja,
                        style: const TextStyle(
                          color: _titleColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Colaborador: ${resumo.colaboradorNome}',
                        style: const TextStyle(color: _mutedColor),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tempo de coleta: ${resumo.tempoFormatado}',
                        style: const TextStyle(color: _mutedColor),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildSummaryChip('Coletados', '${resumo.itensColetados}'),
                          const SizedBox(width: 10),
                          _buildSummaryChip('Esperados', '${resumo.itensEsperados}'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${resumo.itensColetados} de ${resumo.itensEsperados} itens coletados',
                        style: const TextStyle(
                          color: _titleColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: resumo.percentual,
                          minHeight: 10,
                          backgroundColor: const Color(0xFFE8EEF8),
                          valueColor: const AlwaysStoppedAnimation<Color>(_primaryBlue),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Itens da coleta',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: _titleColor,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.separated(
                    itemCount: resumo.itens.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) => _buildItemTile(resumo.itens[index]),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _exportando ? null : () => _confirmarExportacao(resumo),
                  icon: _exportando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.check_circle_outline, color: Colors.white),
                  label: Text(
                    _exportando ? 'Exportando...' : 'Confirmar exportação',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _exportando ? null : () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ExportResumoData {
  const _ExportResumoData({
    required this.exportData,
    required this.colaboradorNome,
    required this.tempoFormatado,
    required this.itensColetados,
    required this.itensEsperados,
    required this.percentual,
    required this.itens,
  });

  final Map<String, dynamic> exportData;
  final String colaboradorNome;
  final String tempoFormatado;
  final int itensColetados;
  final int itensEsperados;
  final double percentual;
  final List<_ExportResumoItem> itens;

  factory _ExportResumoData.fromMap(Map<String, dynamic> map) {
    final estatisticas = (map['estatisticas'] as Map<String, dynamic>? ?? const {});
    final colaborador = (map['colaborador'] as Map<String, dynamic>?) ?? const <String, dynamic>{};
    final itens = (map['itens'] as List<dynamic>? ?? const [])
        .map((item) => _ExportResumoItem.fromMap(item as Map<String, dynamic>))
        .toList(growable: false);

    return _ExportResumoData(
      exportData: map,
      colaboradorNome: colaborador['nome'] as String? ?? 'Colaborador',
      tempoFormatado: map['tempo_decorrido_formatado'] as String? ?? '0min',
      itensColetados: estatisticas['itens_coletados'] as int? ?? itens.length,
      itensEsperados: estatisticas['itens_esperados'] as int? ?? itens.length,
      percentual: ((estatisticas['percentual'] as num?) ?? 0).toDouble() / 100,
      itens: itens,
    );
  }
}

class _ExportResumoItem {
  const _ExportResumoItem({
    required this.nomeProduto,
    required this.codigoBarras,
    required this.preco,
    required this.fotoBase64,
  });

  final String nomeProduto;
  final String codigoBarras;
  final double preco;
  final String? fotoBase64;

  factory _ExportResumoItem.fromMap(Map<String, dynamic> map) {
    final produto = map['produto'] as Map<String, dynamic>? ?? const {};
    return _ExportResumoItem(
      nomeProduto: produto['nome'] as String? ?? 'Produto sem nome',
      codigoBarras: produto['codigo_barras'] as String? ?? '-',
      preco: (map['preco'] as num?)?.toDouble() ?? 0,
      fotoBase64: map['foto_base64'] as String?,
    );
  }
}
