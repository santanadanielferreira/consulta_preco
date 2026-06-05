import 'dart:convert';

import 'package:KeepPrice/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/produto.dart';
import '../../domain/usecases/calcular_progresso_coleta_usecase.dart';
import '../controllers/app_providers.dart';
import '../navigation/route_args.dart';

class ColetaSummaryPage extends ConsumerStatefulWidget {
  const ColetaSummaryPage({super.key, required this.args});

  final ColetaSummaryArgs args;

  @override
  ConsumerState<ColetaSummaryPage> createState() => _ColetaSummaryPageState();
}

class _ColetaSummaryPageState extends ConsumerState<ColetaSummaryPage> {
  late Future<_SummaryData> _future;
  static const _primaryBlue = Color(0xFF4A89F3);
  static const _surfaceBg = Color(0xFFF7F9FC);
  static const _titleColor = Color(0xFF1F2937);
  static const _mutedColor = Color(0xFF6F7682);

  Future<_SummaryData> _loadSummary() async {
    final coleta = await ref.read(coletaRepositoryProvider).buscarPorId(widget.args.idColeta);
    final progressoAtual = await ref.read(calcularProgressoUseCaseProvider).execute(
      idColeta: widget.args.idColeta,
        idLoja: widget.args.idLoja,
      idColaborador: widget.args.idColaborador,
    );
    final produtos = await ref.read(produtoRepositoryProvider).listarProdutosPorLojaEColaborador(
      widget.args.idLoja,
      widget.args.idColaborador,
    );
    final itens = await ref
        .read(coletaRepositoryProvider)
        .listarItensDaColeta(widget.args.idColeta);
    final idsColetados = itens.map((e) => e.idProduto).toSet();

    final coletados = produtos
        .where((produto) => produto.id != null && idsColetados.contains(produto.id))
        .toList(growable: false);
    final pendentes = produtos
        .where((produto) => produto.id != null && !idsColetados.contains(produto.id))
        .toList(growable: false);

    final usaSnapshotExportado =
        coleta?.dataExportacao != null &&
        coleta?.itensColetadosExportacao != null &&
        coleta?.totalEstimadoExportacao != null &&
        coleta?.percentualExportacao != null;

    final progresso = usaSnapshotExportado
        ? ProgressoColeta(
            itensColetados: coleta!.itensColetadosExportacao!,
            totalEstimado: coleta.totalEstimadoExportacao!,
            itensPendentes: (coleta.totalEstimadoExportacao! - coleta.itensColetadosExportacao!)
                .clamp(0, coleta.totalEstimadoExportacao!),
            percentual: coleta.percentualExportacao!,
          )
        : progressoAtual;

    return _SummaryData(
      progresso: progresso,
      produtosColetados: coletados,
      produtosPendentes: pendentes,
      usandoSnapshotExportado: usaSnapshotExportado,
      dataExportacao: coleta?.dataExportacao,
    );
  }

  @override
  void initState() {
    super.initState();
    _future = _loadSummary();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surfaceBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _titleColor),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(AppConstants.appName, style: TextStyle(color: _primaryBlue, fontWeight: FontWeight.w800, fontSize: 18)),
      ),
      body: FutureBuilder<_SummaryData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final summary = snapshot.data;
          if (summary == null) {
            return const Center(child: Text('Resumo indisponivel.'));
          }

          final progresso = summary.progresso;

          Widget buildThumb(Produto produto) {
            final foto = produto.fotoBase64;
            if (foto == null || foto.trim().isEmpty) {
              return Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(color: const Color(0xFFF1F4F9), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.image_outlined, color: Color(0xFFB7C0CC)),
              );
            }

            try {
              final bytes = base64Decode(foto);
              return ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.memory(bytes, width: 52, height: 52, fit: BoxFit.cover));
            } catch (_) {
              return Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(color: const Color(0xFFF1F4F9), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.broken_image, color: Color(0xFFB7C0CC)),
              );
            }
          }

          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200), boxShadow: [BoxShadow(color: const Color.fromRGBO(0, 0, 0, 0.04), blurRadius: 20, offset: const Offset(0, 10))]),
                  child: Row(children: [
                    Container(width: 48, height: 48, decoration: BoxDecoration(color: const Color.fromRGBO(74, 137, 243, 0.12), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.bar_chart, color: _primaryBlue)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Resumo da coleta', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: _primaryBlue, fontWeight: FontWeight.w800)), const SizedBox(height: 4), Text('Itens coletados: ${progresso.itensColetados} • Pendentes: ${progresso.itensPendentes}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: _mutedColor))])),
                    const SizedBox(width: 12),
                    Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.end, children: [Text('${progresso.percentual.toStringAsFixed(1)}%', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: _primaryBlue, fontWeight: FontWeight.w800)), const SizedBox(height: 4), Text('${progresso.itensColetados}/${progresso.totalEstimado}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: _mutedColor))])
                  ]),
                ),
                const SizedBox(height: 14),
                if (summary.usandoSnapshotExportado)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF7EC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFB9E3C0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Color(0xFF2E9E44), size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Exibindo o progresso no momento da exportação${summary.dataExportacao != null ? ' (${summary.dataExportacao!.day.toString().padLeft(2, '0')}/${summary.dataExportacao!.month.toString().padLeft(2, '0')})' : ''}.',
                            style: const TextStyle(
                              color: Color(0xFF236C34),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: ListView(
                    children: [
                      Text('Coletados (${summary.produtosColetados.length})', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: _titleColor, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      if (summary.produtosColetados.isEmpty) const Text('Nenhum produto coletado nesta loja/coleta.'),
                      ...summary.produtosColetados.map((produto) {
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: Material(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: () {},
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.grey.shade200)),
                                child: Row(children: [
                                  buildThumb(produto),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(produto.nome, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: _titleColor, fontWeight: FontWeight.w700)),
                                        const SizedBox(height: 6),
                                        Text('Cod: ${produto.codigoBarras}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: _mutedColor)),
                                        if ((produto.fabricante ?? '').trim().isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(produto.fabricante, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: _mutedColor)),
                                        ],
                                      ],
                                    ),
                                  ),
                                ]),
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 12),
                      Text('Pendentes (${summary.produtosPendentes.length})', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: _titleColor, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      if (summary.produtosPendentes.isEmpty) const Text('Nenhum pendente para esta coleta.'),
                      ...summary.produtosPendentes.map((produto) {
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: Material(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.grey.shade200)),
                              child: Row(children: [
                                buildThumb(produto),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(produto.nome, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: _titleColor, fontWeight: FontWeight.w700)),
                                      const SizedBox(height: 6),
                                      Text('Cod: ${produto.codigoBarras}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: _mutedColor)),
                                      if ((produto.fabricante ?? '').trim().isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(produto.fabricante, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: _mutedColor)),
                                      ],
                                    ],
                                  ),
                                ),
                              ]),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryData {
  const _SummaryData({
    required this.progresso,
    required this.produtosColetados,
    required this.produtosPendentes,
    required this.usandoSnapshotExportado,
    required this.dataExportacao,
  });

  final ProgressoColeta progresso;
  final List<Produto> produtosColetados;
  final List<Produto> produtosPendentes;
  final bool usandoSnapshotExportado;
  final DateTime? dataExportacao;
}
