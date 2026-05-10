import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/ui_messages.dart';
import '../../domain/entities/loja.dart';
import '../controllers/app_providers.dart';
import '../navigation/route_args.dart';

class StoreSelectionPage extends ConsumerStatefulWidget {
  const StoreSelectionPage({super.key});

  @override
  ConsumerState<StoreSelectionPage> createState() => _StoreSelectionPageState();
}

class _StoreSelectionPageState extends ConsumerState<StoreSelectionPage> {
  final _searchController = TextEditingController();
  late Future<List<Loja>> _futureStores;

  static const _importFolderName = 'keeprice_import';
  static const _lojasFileName = 'lojas.json';
  static const _produtosFileName = 'produtos.json';
  static const _defaultLojasAssetPath = 'assets/import/lojas.json';
  static const _defaultProdutosAssetPath = 'assets/import/produtos.json';

  Future<Directory> _resolveImportDirectory() async {
    final externalDir = await getExternalStorageDirectory();
    final baseDir = externalDir ?? await getApplicationDocumentsDirectory();
    final importDir = Directory(path.join(baseDir.path, _importFolderName));

    if (!await importDir.exists()) {
      await importDir.create(recursive: true);
    }

    return importDir;
  }

  Future<({File lojasFile, File produtosFile})> _ensureImportFiles() async {
    final importDir = await _resolveImportDirectory();
    final lojasFile = File(path.join(importDir.path, _lojasFileName));
    final produtosFile = File(path.join(importDir.path, _produtosFileName));

    if (!await lojasFile.exists()) {
      final lojasSeed = await rootBundle.loadString(_defaultLojasAssetPath);
      await lojasFile.writeAsString(lojasSeed);
    }

    if (!await produtosFile.exists()) {
      final produtosSeed = await rootBundle.loadString(_defaultProdutosAssetPath);
      await produtosFile.writeAsString(produtosSeed);
    }

    return (lojasFile: lojasFile, produtosFile: produtosFile);
  }

  Future<({String lojasJson, String produtosJson, String importPath})>
      _readImportJsonFromDevice() async {
    final files = await _ensureImportFiles();
    final lojasJson = await files.lojasFile.readAsString();
    final produtosJson = await files.produtosFile.readAsString();

    return (
      lojasJson: lojasJson,
      produtosJson: produtosJson,
      importPath: files.lojasFile.parent.path,
    );
  }

  @override
  void initState() {
    super.initState();
    _futureStores = _loadStores();
  }

  Future<List<Loja>> _loadStores() async {
    final listarLojasColaborador = ref.read(listarLojasColaboradorUseCaseProvider);
    final importarLojas = ref.read(importarLojasUseCaseProvider);
    final importarProdutos = ref.read(importarProdutosUseCaseProvider);
    final colaborador = ref.read(colaboradorSessaoProvider);

    if (colaborador?.id == null) {
      throw Exception(UiMessages.sessaoSemUsuario);
    }

    var lojas = await listarLojasColaborador.execute(colaborador!.id!);
    
    if (lojas.isEmpty) {
      final importData = await _readImportJsonFromDevice();

      try {
        await importarLojas.execute(importData.lojasJson, idColaborador: colaborador.id!);
        await importarProdutos.execute(importData.produtosJson, idColaborador: colaborador.id!);
      } catch (e) {
        throw Exception(
          'Falha ao importar JSONs em ${importData.importPath}: $e',
        );
      }

      lojas = await listarLojasColaborador.execute(colaborador.id!);
    }

    return lojas;
  }

  Future<void> _refresh() async {
    setState(() {
      _futureStores = _loadStores();
    });
  }

  String _formatTempoColeta(int segundos) {
    if (segundos < 60) {
      return '${segundos}s';
    } else if (segundos < 3600) {
      final minutos = segundos ~/ 60;
      return '${minutos}min';
    } else {
      final horas = segundos ~/ 3600;
      final minutosRestantes = (segundos % 3600) ~/ 60;
      if (minutosRestantes == 0) {
        return '${horas}h';
      }
      return '${horas}h ${minutosRestantes}min';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildHeader(BuildContext context, String? colaboradorNome) {
    final theme = Theme.of(context);
    final greetingName = colaboradorNome == null || colaboradorNome.trim().isEmpty
        ? 'colaborador'
        : colaboradorNome.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(74, 137, 243, 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.storefront_outlined,
                color: Color(0xFF4A89F3),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Olá, $greetingName!',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: const Color(0xFF4A89F3),
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Seleção de loja',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF6F7682),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Escolha uma unidade para iniciar a coleta de produtos.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF6F7682),
            height: 1.35,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return TextField(
      controller: _searchController,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: 'Buscar loja por nome',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF4A89F3), width: 1.4),
        ),
      ),
    );
  }

  Widget _buildStoreCard(BuildContext context, Loja store) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.white,
      elevation: 0,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () async {
          try {
            final colaborador = ref.read(colaboradorSessaoProvider);
            final dispositivo = ref.read(dispositivoSessaoProvider);

            if (colaborador?.id == null) {
              throw const FormatException(UiMessages.sessaoSemUsuario);
            }

            if (dispositivo?.id == null) {
              throw const FormatException(UiMessages.sessaoSemDispositivo);
            }

            final idColeta = await ref
                .read(iniciarColetaUseCaseProvider)
                .execute(
                  idLoja: store.id!,
                  idColaborador: colaborador!.id!,
                  idDispositivo: dispositivo!.id!,
                );

            if (!context.mounted) {
              return;
            }

            await Navigator.pushNamed(
              context,
              AppConstants.routeColetaCatalog,
              arguments: ColetaCatalogArgs(
                idColeta: idColeta,
                idLoja: store.id!,
                nomeLoja: store.nome,
              ),
            );

            await _refresh();
          } catch (e) {
            if (!context.mounted) {
              return;
            }
            ref.read(feedbackServiceProvider).error(
              context: context,
              message: '${UiMessages.falhaSelecionarLoja} $e',
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: const Color.fromRGBO(0, 0, 0, 0.03),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F4F9),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  Icons.store_mall_directory_outlined,
                  size: 28,
                  color: Colors.blueGrey.shade400,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.nome,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF1F2937),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${store.cidade} - ${store.estado}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF8A93A1),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tempo estimado: ${_formatTempoColeta(store.tempoMedioColeta)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFFA1A8B0),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: Colors.blueGrey.shade300,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(74, 137, 243, 0.12),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.storefront_outlined,
                size: 36,
                color: Color(0xFF4A89F3),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: const Color(0xFF1F2937),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colaborador = ref.watch(colaboradorSessaoProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppConstants.appName,
          style: const TextStyle(
            color: Color(0xFF4A89F3),
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
      ),
      body: FutureBuilder<List<Loja>>(
        future: _futureStores,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF4A89F3)),
            );
          }

          if (snapshot.hasError) {
            return _buildEmptyState(
              context,
              'Erro ao carregar lojas\n${snapshot.error}',
            );
          }

          final stores = snapshot.data ?? const <Loja>[];
          final query = _searchController.text.trim().toLowerCase();
          final filteredStores = stores
              .where((store) => store.nome.toLowerCase().contains(query))
              .toList(growable: false);

          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, colaborador?.nome),
                const SizedBox(height: 24),
                _buildSearchField(context),
                const SizedBox(height: 18),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromRGBO(0, 0, 0, 0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: filteredStores.isEmpty
                        ? _buildEmptyState(
                            context,
                            query.isEmpty
                                ? 'Nenhuma loja disponível no momento.'
                                : 'Nenhuma loja encontrada para a busca informada.',
                          )
                        : ListView.separated(
                            itemCount: filteredStores.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final store = filteredStores[index];
                              return _buildStoreCard(context, store);
                            },
                          ),
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





