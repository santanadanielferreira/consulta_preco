import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/ui_messages.dart';
import '../controllers/app_providers.dart';
import '../navigation/route_args.dart';

class ScannerPage extends ConsumerStatefulWidget {
  const ScannerPage({super.key, required this.args});

  final ScannerArgs args;

  @override
  ConsumerState<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends ConsumerState<ScannerPage> {
  final MobileScannerController _controller = MobileScannerController();
  bool _processing = false;
  // Temporary bypass to jump directly to PriceInputPage for testing.
  static const bool _bypassToPriceInput = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (_bypassToPriceInput) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final colaborador = ref.read(colaboradorSessaoProvider);
        if (colaborador?.id == null) {
          if (!mounted) return;
          ref.read(feedbackServiceProvider).error(
            context: context,
            message: UiMessages.sessaoSemUsuario,
          );
          return;
        }

        final produtos = await ref
            .read(listarProdutosColaboradorUseCaseProvider)
            .execute(colaborador!.id!);
        if (!mounted) return;
        if (produtos.isEmpty) {
          ref.read(feedbackServiceProvider).error(
            context: context,
            message: 'Nenhum produto cadastrado para este usuário.',
          );
          return;
        }

        final produto = produtos.first;
        final saved = await Navigator.pushNamed(
          context,
          AppConstants.routePriceInput,
          arguments: PriceInputArgs(
            idColeta: widget.args.idColeta,
            idProduto: produto.id ?? 0,
            nomeProduto: produto.nome,
          ),
        );

        if (!mounted) return;
        if (saved == true) {
          Navigator.pop(context, true);
        }
      });
    }
  }

  Future<void> _handleDetection(BarcodeCapture capture) async {
    if (_processing) {
      return;
    }

    final raw = capture.barcodes.isNotEmpty
      ? capture.barcodes.first.rawValue?.trim()
      : null;
    if (raw == null || raw.isEmpty) {
      return;
    }

    _processing = true;

    try {
      final colaborador = ref.read(colaboradorSessaoProvider);
      if (colaborador?.id == null) {
        if (!mounted) {
          return;
        }
        ref.read(feedbackServiceProvider).error(
          context: context,
          message: UiMessages.sessaoSemUsuario,
        );
        return;
      }

      final buscarProduto = ref.read(buscarProdutoCodigoBarrasColaboradorUseCaseProvider);
      final produto = await buscarProduto.execute(raw, colaborador!.id!);

      if (!mounted) {
        return;
      }

      if (produto == null || produto.id == null) {
        ref.read(feedbackServiceProvider).error(
          context: context,
          message: UiMessages.produtoNaoEncontrado,
        );
        return;
      }

      final saved = await Navigator.pushNamed(
        context,
        AppConstants.routePriceInput,
        arguments: PriceInputArgs(
          idColeta: widget.args.idColeta,
          idProduto: produto.id!,
          nomeProduto: produto.nome,
        ),
      );

      if (!mounted) {
        return;
      }

      if (saved == true) {
        Navigator.pop(context, true);
      }
    } finally {
      _processing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scanner')),
      body: MobileScanner(
        controller: _controller,
        onDetect: _handleDetection,
      ),
    );
  }
}
