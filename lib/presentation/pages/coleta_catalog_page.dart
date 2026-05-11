import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/ui_messages.dart';
import '../../domain/entities/item_coleta.dart';
import '../../domain/entities/produto.dart';
import '../controllers/app_providers.dart';
import 'coleta_export_modal.dart';
import '../navigation/route_args.dart';

class ColetaCatalogPage extends ConsumerStatefulWidget {
  const ColetaCatalogPage({super.key, required this.args});

  final ColetaCatalogArgs args;

  @override
  ConsumerState<ColetaCatalogPage> createState() => _ColetaCatalogPageState();
}

class _CatalogItemView {
  const _CatalogItemView({required this.item, required this.produto});

  final ItemColeta item;
  final Produto? produto;
}

class _ColetaCatalogPageState extends ConsumerState<ColetaCatalogPage> {
  final _searchController = TextEditingController();
  String _query = '';
  late Future<List<_CatalogItemView>> _futureItems;

  static const _primaryBlue = Color(0xFF4A89F3);
  static const _surfaceBg = Color(0xFFF7F9FC);
  static const _titleColor = Color(0xFF1F2937);
  static const _mutedColor = Color(0xFF6F7682);

  @override
  void initState() {
    super.initState();
    _futureItems = _loadItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<_CatalogItemView>> _loadItems() async {
    final coletaRepo = ref.read(coletaRepositoryProvider);
    final produtoRepo = ref.read(produtoRepositoryProvider);

    final items = await coletaRepo.listarItensDaColeta(widget.args.idColeta);
    final mapped = <_CatalogItemView>[];

    for (final item in items) {
      final produto = await produtoRepo.buscarPorId(item.idProduto);
      mapped.add(_CatalogItemView(item: item, produto: produto));
    }

    return mapped;
  }

  Future<void> _refresh() async {
    setState(() {
      _futureItems = _loadItems();
    });
  }


Future<void> _abrirScanner(bool isBusca) async {
  final result = await Navigator.pushNamed(
    context,
    AppConstants.routeScanner,
    arguments: ScannerArgs(
      idColeta: widget.args.idColeta,
        idLoja: widget.args.idLoja,
      isBusca: isBusca,
    ),
  );

  if (result == null) {
    return;
  }

  if (isBusca) {
    final codigo = result as String;

    setState(() {
      _searchController.text = codigo;
      _query = codigo;
    });
  }

  if (result == true) {
    await _refresh();
  }
}

  Future<void> _abrirExportacao() async {
    final exported = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ColetaExportModal(args: widget.args),
    );

    if (exported == true && mounted) {
      await _refresh();
    }
  }

  Future<void> _confirmarReinicioColeta() async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reiniciar coleta'),
          content: const Text(
            'Isso vai limpar os itens ativos desta coleta e zerar o progresso. Deseja continuar?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: _primaryBlue),
              child: const Text('Reiniciar'),
            ),
          ],
        );
      },
    );

    if (confirmou != true) {
      return;
    }

    try {
      await ref.read(reiniciarColetaUseCaseProvider).execute(widget.args.idColeta);

      if (!mounted) {
        return;
      }

      await ref.read(feedbackServiceProvider).success(
        context: context,
        message: 'Coleta reiniciada com sucesso.',
        vibracaoAtiva: ref.read(vibracaoAtivaProvider),
      );

      await _refresh();
    } catch (e) {
      if (!mounted) {
        return;
      }

      ref.read(feedbackServiceProvider).error(
        context: context,
        message: 'Falha ao reiniciar coleta: $e',
      );
    }
  }

  Future<void> _confirmarRemocao(_CatalogItemView item) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(color: const Color.fromRGBO(74, 137, 243, 0.12), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.delete_outline, color: Color(0xFF4A89F3)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text('Confirmar exclusão', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: _primaryBlue, fontWeight: FontWeight.w800))),
                  ],
                ),
                const SizedBox(height: 12),
                Text(UiMessages.confirmarExclusaoItem, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: _mutedColor)),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(backgroundColor: _primaryBlue),
                      child: const Text('Excluir'),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );

    if (confirmou != true) {
      return;
    }

    try {
      await ref.read(removerItemColetaUseCaseProvider).execute(
            idColeta: widget.args.idColeta,
            idProduto: item.item.idProduto,
          );

      if (!mounted) {
        return;
      }

      ref.read(feedbackServiceProvider).success(
            context: context,
            message: UiMessages.itemRemovido,
            vibracaoAtiva: ref.read(vibracaoAtivaProvider),
          );
      await _refresh();
    } catch (e) {
      if (!mounted) {
        return;
      }
      ref.read(feedbackServiceProvider).error(
            context: context,
            message: '${UiMessages.falhaRemoverItem} $e',
          );
    }
  }

  Future<void> _confirmarLogout() async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(color: const Color.fromRGBO(74, 137, 243, 0.12), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.logout_outlined, color: Color(0xFF4A89F3)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text('Confirmar logout', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: _primaryBlue, fontWeight: FontWeight.w800))),
                  ],
                ),
                const SizedBox(height: 12),
                Text(UiMessages.confirmarLogout, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: _mutedColor)),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, AppConstants.routeLogin,),
                      style: ElevatedButton.styleFrom(backgroundColor: _primaryBlue),
                      child: const Text('Sair'),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );

    if (confirmou != true) {
      return;
    }


  }

  String? _resolveItemImageBase64(_CatalogItemView item) {
    final candidates = <String?>[
      item.item.fotoBase64,
      item.produto?.fotoBase64,
    ];

    for (final candidate in candidates) {
      if (candidate == null || candidate.trim().isEmpty) {
        continue;
      }

      try {
        base64Decode(candidate);
        return candidate;
      } catch (_) {
        continue;
      }
    }

    return null;
  }

  Widget _buildItemImage(_CatalogItemView item) {
    final imageBase64 = _resolveItemImageBase64(item);

    if (imageBase64 == null) {
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F4F9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.image_outlined,
          color: Color(0xFFB7C0CC),
          size: 30,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.memory(
        base64Decode(imageBase64),
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        gaplessPlayback: true,
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color.fromRGBO(74, 137, 243, 0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.shopping_bag_outlined,
            color: _primaryBlue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Catálogo de coletas",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: _primaryBlue,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.args.nomeLoja,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _mutedColor,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Nome ou código de barras',
        prefixIcon: const Icon(Icons.search, color: _mutedColor),
        suffixIcon: IconButton(
          onPressed: () =>_abrirScanner(true),
          icon: const Icon(Icons.qr_code_scanner, color: _primaryBlue),
          tooltip: 'Buscar por scan',
        ),
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
          borderSide: const BorderSide(color: _primaryBlue, width: 1.4),
        ),
      ),
      onChanged: (value) {
        setState(() {
          _query = value;
        });
      },
    );
  }

  Widget _buildCountCard(int totalCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color.fromRGBO(74, 137, 243, 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.playlist_add_check,
              color: _primaryBlue,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Itens coletados',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: _titleColor,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$totalCount itens nesta coleta',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _mutedColor,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            totalCount.toString(),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: _primaryBlue,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
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
                Icons.inventory_2_outlined,
                size: 36,
                color: _primaryBlue,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: _titleColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(_CatalogItemView item) {
    final nome = item.produto?.nome ?? 'Produto #${item.item.idProduto}';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () async {
          final updated = await Navigator.pushNamed(
            context,
            AppConstants.routeEditItem,
            arguments: EditItemArgs(
              idColeta: widget.args.idColeta,
              idProduto: item.item.idProduto,
              nomeProduto: nome,
              precoAtual: item.item.preco,
            ),
          );

          if (updated == true) {
            await _refresh();
          }
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildItemImage(item),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nome,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: _titleColor,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cod: ${item.produto?.codigoBarras ?? item.item.idProduto}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: _mutedColor,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Preco: R\$ ${item.item.preco.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: _primaryBlue,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: _mutedColor),
                    onPressed: () async {
                      final updated = await Navigator.pushNamed(
                        context,
                        AppConstants.routeEditItem,
                        arguments: EditItemArgs(
                          idColeta: widget.args.idColeta,
                          idProduto: item.item.idProduto,
                          nomeProduto: nome,
                          precoAtual: item.item.preco,
                        ),
                      );

                      if (updated == true) {
                        await _refresh();
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: const Color.fromRGBO(244, 67, 54, 0.6),
                    ),
                    onPressed: () => _confirmarRemocao(item),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton.extended(
          heroTag: 'scan_fab',
          onPressed: () => _abrirScanner(false),
          icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
          label: const Text('Escanear'),
          backgroundColor: _primaryBlue,
          foregroundColor: Colors.white,
        ),
        const SizedBox(width: 12),
        FloatingActionButton.small(
          heroTag: 'restart_fab',
          onPressed: _confirmarReinicioColeta,
          backgroundColor: const Color(0xFFFFF3E0),
          foregroundColor: const Color(0xFFE67E22),
          child: const Icon(Icons.restart_alt),
        ),
        const SizedBox(width: 12),
        FloatingActionButton.small(
          heroTag: 'export_fab',
          onPressed: _abrirExportacao,
          backgroundColor: Colors.white,
          foregroundColor: _primaryBlue,
          child: const Icon(Icons.file_download_outlined),
        ),
      ],
    );
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
        title: Text(
          AppConstants.appName,
          style: const TextStyle(
            color: _primaryBlue,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppConstants.routeSummary,
                arguments: ColetaSummaryArgs(
                  idColeta: widget.args.idColeta,
                  idLoja: widget.args.idLoja,
                  idColaborador: ref.read(colaboradorSessaoProvider)?.id ?? 0,
                ),
              );
            },
            icon: const Icon(Icons.assessment_outlined, color: _primaryBlue),
            tooltip: 'Ver progresso',
          ),
          IconButton(
            onPressed: _confirmarLogout,
            icon: const Icon(Icons.logout_outlined, color: Color.fromARGB(255, 253, 72, 0)),
            tooltip: 'Logout',
          ),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: _buildFloatingActions(),
      body: FutureBuilder<List<_CatalogItemView>>(
        future: _futureItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: _primaryBlue),
            );
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final items = snapshot.data ?? const <_CatalogItemView>[];
          final query = _query.trim().toLowerCase();
          final filteredItems = query.isEmpty
              ? items
              : items.where((entry) {
                  final nome = entry.produto?.nome ?? '';
                  final codigoBarras = entry.produto?.codigoBarras ?? '';
                  return nome.toLowerCase().contains(query) || codigoBarras.contains(query);
                }).toList(growable: false);

          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 24),
                _buildSearchField(),
                const SizedBox(height: 16),

                _buildCountCard(items.length),
                const SizedBox(height: 16),
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
                    child: filteredItems.isEmpty
                        ? _buildEmptyState(
                            query.isEmpty
                                ? 'Nenhum item coletado ainda.'
                                : 'Nenhum item encontrado para a busca informada.',
                          )
                        : ListView.separated(
                            itemCount: filteredItems.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final item = filteredItems[index];
                              return _buildItemCard(item);
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
