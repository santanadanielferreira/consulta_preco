import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/ui_messages.dart';
import '../controllers/app_providers.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  bool _isLoading = false;
  bool _obscureSenha = true;
  bool _obscureConfirmacao = true;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final colaborador = await ref.read(cadastrarColaboradorUseCaseProvider).execute(
            nome: _nomeController.text,
            email: _emailController.text,
            senha: _senhaController.text,
          );

      final dispositivo = await ref.read(inicializarDispositivoSessaoUseCaseProvider).execute();

      ref.read(colaboradorSessaoProvider.notifier).state = colaborador;
      ref.read(dispositivoSessaoProvider.notifier).state = dispositivo;

      if (!mounted) {
        return;
      }

      ref.read(feedbackServiceProvider).success(
            context: context,
            message: UiMessages.cadastroSucesso,
            vibracaoAtiva: ref.read(vibracaoAtivaProvider),
          );

      Navigator.pushReplacementNamed(context, AppConstants.routeStoreSelection);
    } on FormatException catch (e) {
      if (!mounted) {
        return;
      }
      ref.read(feedbackServiceProvider).error(
            context: context,
            message: '${UiMessages.falhaCadastro} ${e.message}',
          );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ref.read(feedbackServiceProvider).error(
            context: context,
            message: '${UiMessages.falhaCadastro} $e',
          );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF4A84F6);
    const lightGray = Color(0xFFF0F0F0);
    const textDark = Color(0xFF222222);
    const textGray = Color(0xFF666666);
    const placeholderGray = Color(0xFFAAAAAA);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Text(
                        'KeePrice',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: primaryBlue,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Crie sua conta de colab.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Preencha os dados abaixo para começar a utilizar a plataforma.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: textGray,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _buildLabeledInputField(
                  controller: _nomeController,
                  label: 'Nome de colaborador',
                  hintText: 'Ex: José da Silva',
                  keyboardType: TextInputType.text,
                  obscureText: false,
                  onToggleVisibility: null,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe o nome';
                    }
                    return null;
                  },
                  textColor: textDark,
                  labelColor: textGray,
                  placeholderColor: placeholderGray,
                  backgroundColor: lightGray,
                ),
                const SizedBox(height: 10),
                _buildLabeledInputField(
                  controller: _emailController,
                  label: 'E-mail',
                  hintText: 'contato@sualoja.com.br',
                  keyboardType: TextInputType.emailAddress,
                  obscureText: false,
                  onToggleVisibility: null,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe o email';
                    }
                    return null;
                  },
                  textColor: textDark,
                  labelColor: textGray,
                  placeholderColor: placeholderGray,
                  backgroundColor: lightGray,
                ),
                const SizedBox(height: 10),
                _buildLabeledInputField(
                  controller: _senhaController,
                  label: 'Senha',
                  hintText: 'Mínimo 8 caracteres',
                  keyboardType: TextInputType.text,
                  obscureText: _obscureSenha,
                  onToggleVisibility: () {
                    setState(() {
                      _obscureSenha = !_obscureSenha;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe a senha';
                    }
                    if (value.trim().length < 6) {
                      return 'Senha minima de 6 caracteres';
                    }
                    return null;
                  },
                  textColor: textDark,
                  labelColor: textGray,
                  placeholderColor: placeholderGray,
                  backgroundColor: lightGray,
                ),
                const SizedBox(height: 10),
                _buildLabeledInputField(
                  controller: _confirmarSenhaController,
                  label: 'Confirme sua senha',
                  hintText: 'Mínimo 8 caracteres',
                  keyboardType: TextInputType.text,
                  obscureText: _obscureConfirmacao,
                  onToggleVisibility: () {
                    setState(() {
                      _obscureConfirmacao = !_obscureConfirmacao;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Confirme a senha';
                    }
                    if (value.trim() != _senhaController.text.trim()) {
                      return 'As senhas nao conferem';
                    }
                    return null;
                  },
                  textColor: textDark,
                  labelColor: textGray,
                  placeholderColor: placeholderGray,
                  backgroundColor: lightGray,
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _agreedToTerms,
                      activeColor: primaryBlue,
                      onChanged: (bool? value) {
                        setState(() {
                          _agreedToTerms = value ?? false;
                        });
                      },
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              color: textDark,
                              fontSize: 12,
                              height: 1.25,
                            ),
                            children: [
                              const TextSpan(text: 'Ao criar uma conta, você concorda com nossos '),
                              TextSpan(
                                text: 'Termos de Uso',
                                style: TextStyle(color: primaryBlue),
                              ),
                              const TextSpan(text: ' e '),
                              TextSpan(
                                text: 'Política de Privacidade',
                                style: TextStyle(color: primaryBlue),
                              ),
                              const TextSpan(text: '.'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _cadastrar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Criar conta',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            Navigator.pushReplacementNamed(
                              context,
                              AppConstants.routeLogin,
                            );
                          },
                    style: TextButton.styleFrom(foregroundColor: primaryBlue),
                    child: const Text('Já possui cadastro? Fazer Login'),
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabeledInputField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required String? Function(String?) validator,
    required Color textColor,
    required Color labelColor,
    required Color placeholderColor,
    required Color backgroundColor,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: labelColor,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          key: Key('signup_${label.toLowerCase().replaceAll(' ', '_')}'),
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: placeholderColor),
            filled: true,
            fillColor: backgroundColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            suffixIcon: onToggleVisibility != null
                ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: placeholderColor,
                    ),
                    onPressed: onToggleVisibility,
                  )
                : null,
          ),
          validator: validator,
        ),
      ],
    );
  }
}
