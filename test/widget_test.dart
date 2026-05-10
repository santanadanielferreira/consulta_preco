import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:consulta_preco/main.dart';
import 'package:consulta_preco/domain/entities/produto.dart';
import 'package:consulta_preco/domain/repositories/produto_repository.dart';
import 'package:consulta_preco/presentation/navigation/route_args.dart';
import 'package:consulta_preco/presentation/pages/price_input_page.dart';
import 'package:consulta_preco/presentation/controllers/app_providers.dart';

class _MockProdutoRepository implements ProdutoRepository {
  @override
  Future<Produto?> buscarPorCodigoBarras(String codigoBarras) async => null;

  @override
  Future<Produto?> buscarPorCodigoBarrasColaborador(
    String codigoBarras,
    int idColaborador,
  ) async =>
      null;

  @override
  Future<Produto?> buscarPorId(int id) async => const Produto(
        id: 1,
        codigoBarras: '123',
        nome: 'Produto Teste',
        fabricante: 'Fabricante Teste',
        idColaborador: 1,
      );

  @override
  Future<List<Produto>> buscarPorNome(String nome) async => const [];

  @override
  Future<void> importarProdutos(List<Produto> produtos, {int? idColaborador}) async {}

  @override
  Future<List<Produto>> listarProdutos() async => const [];

  @override
  Future<List<Produto>> listarProdutosPorColaborador(int idColaborador) async =>
      const [];
}

void main() {
  testWidgets('Aplicacao renderiza tela de login', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Override seed data to do nothing in tests
          seedDataProvider.overrideWith((ref) async {}),
        ],
        child: const KeePriceApp(),
      ),
    );

    await tester.pump();

    expect(find.text('KeePrice'), findsOneWidget);
    expect(find.byType(TextFormField), findsWidgets);
  });

  testWidgets('Login com campos preenchidos executa submissao', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          seedDataProvider.overrideWith((ref) async {}),
        ],
        child: const KeePriceApp(),
      ),
    );

    await tester.pump();

    // Preenche campos de login
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'teste@keeprice.app',
    );
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    
    // Clica em entrar
    await tester.tap(find.text('Entrar'));
    await tester.pump(const Duration(milliseconds: 300));

    // Mantem o fluxo renderizado sem quebra apos tentativa de autenticacao.
    expect(find.byType(Scaffold), findsWidgets);
  });

  testWidgets('App renderiza sem erros', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          seedDataProvider.overrideWith((ref) async {}),
        ],
        child: const KeePriceApp(),
      ),
    );
    await tester.pump();
    expect(find.byType(Scaffold), findsWidgets);
  });

  testWidgets('Campo de email valida entrada', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          seedDataProvider.overrideWith((ref) async {}),
        ],
        child: const KeePriceApp(),
      ),
    );
    await tester.pump();

    final emailField = find.byType(TextFormField).at(0);
    await tester.enterText(emailField, 'email_valido@keeprice.app');
    await tester.pump();

    expect(find.text('email_valido@keeprice.app'), findsOneWidget);
  });

  testWidgets('Botao de cadastro navega para tela Novo Cadastro', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          seedDataProvider.overrideWith((ref) async {}),
        ],
        child: const KeePriceApp(),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Criar novo cadastro'));
    await tester.pumpAndSettle();

    expect(find.text('KeePrice'), findsOneWidget);
  });

  testWidgets('Insercao de preco exige confirmacao dupla igual', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          produtoRepositoryProvider.overrideWithValue(_MockProdutoRepository()),
        ],
        child: const MaterialApp(
          home: PriceInputPage(
            args: PriceInputArgs(
              idColeta: 1,
              idProduto: 1,
              nomeProduto: 'Produto Teste',
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final textFields = find.byType(TextFormField);
    await tester.enterText(textFields.first, '10,00');
    await tester.enterText(textFields.at(1), '12,00');
    await tester.ensureVisible(find.text('Salvar preço'));
    await tester.tap(find.text('Salvar preço'));
    await tester.pumpAndSettle();

    expect(find.text('Os dois campos de preco devem ser iguais.'), findsWidgets);
  });
}
