import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/ui_messages.dart';
import '../../domain/entities/produto.dart';
import '../controllers/app_providers.dart';
import '../navigation/route_args.dart';

class ColetaEditPage extends ConsumerStatefulWidget {
  const ColetaEditPage({super.key, required this.args});

  final EditItemArgs args;

  @override
  ConsumerState<ColetaEditPage> createState() => _ColetaEditPageState();
}

class _ColetaEditPageState extends ConsumerState<ColetaEditPage> {
  static const _brandBlue = Color(0xFF4285F4);
  static const _textGrey = Color(0xFF757575);

  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _confirmPriceController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  Future<Map<String, Object?>>? _futureData;
  String? _capturedImageBase64;

  double? _parsePrice(String value) => double.tryParse(value.trim().replaceAll(',', '.'));

  @override
  void initState() {
    super.initState();
    _futureData = _loadInitial();
  }

  Future<Map<String, Object?>> _loadInitial() async {
    final coletaRepo = ref.read(coletaRepositoryProvider);
    final produtoRepo = ref.read(produtoRepositoryProvider);

    final item = await coletaRepo.buscarItemColeta(widget.args.idColeta, widget.args.idProduto);
    final produto = await produtoRepo.buscarPorId(widget.args.idProduto);

    final precoInicial = item?.preco ?? widget.args.precoAtual;
    _priceController.text = precoInicial.toStringAsFixed(2);
    _confirmPriceController.text = precoInicial.toStringAsFixed(2);
    _capturedImageBase64 = item?.fotoBase64;

    return {
      'item': item,
      'produto': produto,
    };
  }

  @override
  void dispose() {
    _priceController.dispose();
    _confirmPriceController.dispose();
    super.dispose();
  }

  bool _isValidBase64(String? s) {
    if (s == null || s.trim().isEmpty) return false;
    try {
      base64Decode(s);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _captureImage() async {
    try {
      final picked = await _picker.pickImage(source: ImageSource.camera, maxWidth: 1200, imageQuality: 80);
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      setState(() => _capturedImageBase64 = base64Encode(bytes));
    } catch (e) {
      if (!mounted) return;
      ref.read(feedbackServiceProvider).error(context: context, message: 'Falha ao capturar imagem: $e');
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final preco = _parsePrice(_priceController.text);
    final confirmacao = _parsePrice(_confirmPriceController.text);
    if (preco == null || confirmacao == null) {
      ref.read(feedbackServiceProvider).error(context: context, message: UiMessages.precoInvalido);
      return;
    }

    if (preco != confirmacao) {
      ref.read(feedbackServiceProvider).error(context: context, message: UiMessages.precoConfirmacaoInvalida);
      return;
    }

    try {
      await ref.read(registrarItemColetaUseCaseProvider).execute(
        idColeta: widget.args.idColeta,
        idProduto: widget.args.idProduto,
        preco: preco,
        fotoBase64: _capturedImageBase64,
      );

      if (!mounted) return;
      await ref.read(feedbackServiceProvider).success(
        context: context,
        message: UiMessages.precoAtualizado,
        vibracaoAtiva: ref.read(vibracaoAtivaProvider),
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ref.read(feedbackServiceProvider).error(context: context, message: '${UiMessages.falhaAtualizarPreco} $e');
    }
  }

  Widget _buildImageSection(Produto? produto) {
    final produtoHas = _isValidBase64(produto?.fotoBase64);
    final display = _capturedImageBase64 ?? (produtoHas ? produto?.fotoBase64 : null);
    final isReadonly = _capturedImageBase64 == null && produtoHas;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: 160,
          decoration: BoxDecoration(color: const Color(0xFFECEFF3), borderRadius: BorderRadius.circular(12)),
          child: display == null
              ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.camera_alt_outlined, size: 44, color: _textGrey),
                  const SizedBox(height: 8),
                  Text('ADICIONAR FOTO DO PRODUTO', style: TextStyle(color: _textGrey, fontWeight: FontWeight.w600)),
                ])
              : ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.memory(base64Decode(display), fit: BoxFit.cover)),
        ),
        const SizedBox(height: 10),
        if (!isReadonly)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _captureImage,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Tirar foto'),
              style: ElevatedButton.styleFrom(backgroundColor: _brandBlue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
            ),
          )
        else
          Text('Foto do produto', style: TextStyle(color: _textGrey, fontStyle: FontStyle.italic)),
      ],
    );
  }

  Widget _buildInputField({required String label, required TextEditingController controller, String? hint, String? Function(String?)? validator}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      TextFormField(controller: controller, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(hintText: hint, filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)), validator: validator),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(backgroundColor: const Color(0xFFF0F2F5), elevation: 0, leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black87), onPressed: () => Navigator.maybePop(context)), centerTitle: true, title: const Text('Editar item', style: TextStyle(color: _brandBlue, fontWeight: FontWeight.bold))),
      body: FutureBuilder<Map<String, Object?>>(
        future: _futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final produto = snapshot.data?['produto'] as Produto?;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.args.nomeProduto, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              _buildImageSection(produto),
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(children: [
                  _buildInputField(label: 'Preço', controller: _priceController, hint: 'Ex: 10,50', validator: (v) => v == null || v.trim().isEmpty ? 'Informe o preço' : null),
                  const SizedBox(height: 12),
                  _buildInputField(label: 'Confirmar preço', controller: _confirmPriceController, hint: 'Ex: 10,50', validator: (v) => v == null || v.trim().isEmpty ? 'Confirme o preço' : (_parsePrice(v) != _parsePrice(_priceController.text) ? UiMessages.precoConfirmacaoInvalida : null)),
                  const SizedBox(height: 18),
                  SizedBox(width: double.infinity, height: 48, child: ElevatedButton.icon(onPressed: _submit, icon: const Icon(Icons.check_circle_outline), label: const Text('Atualizar preço'), style: ElevatedButton.styleFrom(backgroundColor: _brandBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))))),
                ]),
              ),
            ]),
          );
        },
      ),
    );
  }
}
