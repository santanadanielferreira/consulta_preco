import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/ui_messages.dart';
import '../controllers/app_providers.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final colaborador = await ref.read(autenticarColaboradorUseCaseProvider).execute(
            email: _emailController.text,
            senha: _passwordController.text,
          );
      final dispositivo =
          await ref.read(inicializarDispositivoSessaoUseCaseProvider).execute();

      ref.read(colaboradorSessaoProvider.notifier).state = colaborador;
      ref.read(dispositivoSessaoProvider.notifier).state = dispositivo;

      if (!mounted) {
        return;
      }

      Navigator.pushReplacementNamed(
        context,
        AppConstants.routeStoreSelection,
      );
    } on FormatException {
      if (!mounted) {
        return;
      }
      ref.read(feedbackServiceProvider).error(
            context: context,
            message: UiMessages.credenciaisInvalidas,
          );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ref.read(feedbackServiceProvider).error(
            context: context,
            message: '${UiMessages.falhaAutenticacao} $e',
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
    // Cores do novo design
    const primaryBlue = Color(0xFF4A84F6);
    const lightGray = Color(0xFFF0F0F0);
    const placeholderGray = Color(0xFFAAAAAA);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppConstants.appName,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                      letterSpacing: -1.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Acesse sua conta para gerenciar \niniciar suas coletas.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 40),

                  const Text(
                    'E-mail',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    key: const Key('emailField'),
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'seu@email.com',
                      hintStyle: const TextStyle(color: placeholderGray),
                      filled: true,
                      fillColor: lightGray,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Informe o email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Senha',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    key: const Key('passwordField'),
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: 'Sua senha',
                      hintStyle: const TextStyle(color: placeholderGray),
                      filled: true,
                      fillColor: lightGray,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: placeholderGray,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Informe a senha';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        // Ação esqueci a senha - manter para integração futura
                      },
                      child: Text(
                        'Esqueci a senha',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primaryBlue),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      key: const Key('loginButton'),
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Entrar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Center(
                    child: TextButton(
                      key: const Key('signupButton'),
                      onPressed: _isLoading
                          ? null
                          : () {
                              Navigator.pushNamed(context, AppConstants.routeSignup);
                            },
                      style: TextButton.styleFrom(foregroundColor: primaryBlue),
                      child: const Text('Criar novo cadastro'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
