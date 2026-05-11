import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/ui_messages.dart';
import '../../domain/entities/produto.dart';
import '../controllers/app_providers.dart';
import '../navigation/route_args.dart';

class PriceInputPage extends ConsumerStatefulWidget {
  const PriceInputPage({super.key, required this.args});

  final PriceInputArgs args;

  @override
  ConsumerState<PriceInputPage> createState() => _PriceInputPageState();
}

class _PriceInputPageState extends ConsumerState<PriceInputPage> {
  // Colors from mock design
  final Color _brandBlue = const Color(0xFF4285F4);
  final Color _textGrey = const Color(0xFF757575);
  final Color _backgroundGrey = const Color(0xFFF0F2F5);
  final Color _imagePlaceholderGrey = const Color(0xFFE0E0E0);
  final Color _errorRed = const Color(0xFFE53935);

  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _confirmPriceController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  
  Future<Produto?>? _futureProduto;
  String? _capturedImageBase64;

  double? _parsePrice(String value) {
    return double.tryParse(value.trim().replaceAll(',', '.'));
  }

  Future<Produto?> _getFutureProduto() {
    return _futureProduto ??= ref.read(produtoRepositoryProvider).buscarPorId(widget.args.idProduto);
  }

  @override
  void initState() {
    super.initState();
    _getFutureProduto();
  }

  @override
  void dispose() {
    _priceController.dispose();
    _confirmPriceController.dispose();
    super.dispose();
  }

  bool _isValidBase64(String? base64String) {
    if (base64String == null || base64String.isEmpty) return false;
    try {
      base64Decode(base64String);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final preco = _parsePrice(_priceController.text);
    final confirmacao = _parsePrice(_confirmPriceController.text);
    if (preco == null || confirmacao == null) {
      ref.read(feedbackServiceProvider).error(
        context: context,
        message: UiMessages.precoInvalido,
      );
      return;
    }

    if (preco != confirmacao) {
      ref.read(feedbackServiceProvider).error(
        context: context,
        message: UiMessages.precoConfirmacaoInvalida,
      );
      return;
    }

    try {
      await ref.read(registrarItemColetaUseCaseProvider).execute(
            idColeta: widget.args.idColeta,
            idProduto: widget.args.idProduto,
            preco: preco,
            fotoBase64: _capturedImageBase64,
          );

      if (!mounted) {
        return;
      }

      await ref.read(feedbackServiceProvider).success(
        context: context,
        message: UiMessages.precoRegistrado,
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
        message: '${UiMessages.falhaRegistrarPreco} $e',
      );
    }
  }

  Future<void> _captureImage() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        imageQuality: 80,
      );
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      setState(() {
        _capturedImageBase64 = base64Encode(bytes);
      });
    } catch (e) {
      if (!mounted) return;
      ref.read(feedbackServiceProvider).error(
        context: context,
        message: 'Falha ao capturar imagem: $e',
      );
    }
  }

  Widget _buildImageSection(Produto produto) {
    final productPhotoValid = _isValidBase64(produto.fotoBase64);
    final displayImage = _capturedImageBase64 ?? (productPhotoValid ? produto.fotoBase64 : null);
    final isImageReadonly = _capturedImageBase64 == null && productPhotoValid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: 180,
          decoration: BoxDecoration(
            color: _imagePlaceholderGrey,
            borderRadius: BorderRadius.circular(12),
          ),
          child: displayImage == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt_outlined,
                      size: 48,
                      color: _textGrey,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'ADICIONAR FOTO DO PRODUTO',
                      style: TextStyle(
                        fontSize: 14,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w600,
                        color: _textGrey,
                      ),
                    ),
                  ],
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    base64Decode(displayImage),
                    fit: BoxFit.cover,
                  ),
                ),
        ),
        const SizedBox(height: 12),
        if (!isImageReadonly)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _captureImage,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Tirar foto'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _brandBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          )
        else
          Text(
            'Foto do produto',
            style: TextStyle(
              fontSize: 12,
              color: _textGrey,
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    required String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _textGrey,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: _textGrey.withValues(alpha: 0.5)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          style: TextStyle(color: _textGrey, fontSize: 16),
          validator: validator,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundGrey,
      appBar: AppBar(
        backgroundColor: _backgroundGrey,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _textGrey),
          onPressed: () => Navigator.maybePop(context),
        ),
        centerTitle: true,
        title: Text(
          'KeePrice',
          style: TextStyle(
            color: _brandBlue,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: FutureBuilder<Produto?>(
        future: _getFutureProduto(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: _brandBlue),
            );
          }
          if (snapshot.hasError || snapshot.data == null) {
            return Center(
              child: Text(
                'Erro ao carregar produto',
                style: TextStyle(color: _errorRed),
              ),
            );
          }

          final produto = snapshot.data!;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Adicionar preço',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _textGrey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Preencha os dados abaixo para registrar o preço do produto',
                    style: TextStyle(
                      fontSize: 14,
                      color: _textGrey,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Product image section
                  _buildImageSection(produto),
                  const SizedBox(height: 20),
                  // Product info
                  Text(
                    'Produto',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _textGrey,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white, width: 0),
                    ),
                    child: Text(
                      produto.nome,
                      style: TextStyle(color: _textGrey, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Price fields
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildInputField(
                          label: 'Preço',
                          hintText: 'Ex: 10,50',
                          controller: _priceController,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe o preço';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),
                        _buildInputField(
                          label: 'Confirmar preço',
                          hintText: 'Ex: 10,50',
                          controller: _confirmPriceController,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Confirme o preço';
                            }
                            if (_parsePrice(value) != _parsePrice(_priceController.text)) {
                              return UiMessages.precoConfirmacaoInvalida;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        // Save button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: _submit,
                            icon: const Icon(
                              Icons.check_circle_outline,
                              color: Colors.white,
                              size: 24,
                            ),
                            label: const Text(
                              'Salvar preço',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _brandBlue,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
