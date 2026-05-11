import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local/database_service.dart';
import '../../data/datasources/local/local_data_source.dart';
import '../../data/datasources/local/local_data_source_impl.dart';
import '../../data/datasources/seed_data.dart';
import '../../data/repositories/colaborador_repository_impl.dart';
import '../../data/repositories/coleta_repository_impl.dart';
import '../../data/repositories/dispositivo_repository_impl.dart';
import '../../data/repositories/loja_repository_impl.dart';
import '../../data/repositories/produto_repository_impl.dart';
import '../../domain/entities/colaborador.dart';
import '../../domain/entities/dispositivo.dart';
import '../../domain/repositories/colaborador_repository.dart';
import '../../domain/repositories/coleta_repository.dart';
import '../../domain/repositories/dispositivo_repository.dart';
import '../../domain/repositories/loja_repository.dart';
import '../../domain/repositories/produto_repository.dart';
import '../../domain/usecases/autenticar_colaborador_usecase.dart';
import '../../domain/usecases/buscar_produto_por_codigo_barras_usecase.dart';
import '../../domain/usecases/cadastrar_colaborador_usecase.dart';
import '../../domain/usecases/calcular_progresso_coleta_usecase.dart';
import '../../domain/usecases/exportar_coleta_individual_usecase.dart';
import '../../domain/usecases/exportar_coletas_diarias_usecase.dart';
import '../../domain/usecases/importar_lojas_usecase.dart';
import '../../domain/usecases/importar_produtos_usecase.dart';
import '../../domain/usecases/inicializar_dispositivo_sessao_usecase.dart';
import '../../domain/usecases/iniciar_coleta_usecase.dart';
import '../../domain/usecases/listar_lojas_usecase.dart';
import '../../domain/usecases/listar_lojas_colaborador_usecase.dart';
import '../../domain/usecases/buscar_produto_codigo_barras_colaborador_usecase.dart';
import '../../domain/usecases/buscar_produto_codigo_barras_na_loja_usecase.dart';
import '../../domain/usecases/listar_produtos_colaborador_usecase.dart';
import '../../domain/usecases/remover_item_coleta_usecase.dart';
import '../../domain/usecases/reiniciar_coleta_usecase.dart';
import '../../domain/usecases/registrar_item_coleta_usecase.dart';
import '../../core/utils/export_file_service.dart';
import 'feedback_service.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService.instance;
});

final localDataSourceProvider = Provider<LocalDataSource>((ref) {
  return LocalDataSourceImpl(ref.watch(databaseServiceProvider));
});

final produtoRepositoryProvider = Provider<ProdutoRepository>((ref) {
  return ProdutoRepositoryImpl(ref.watch(localDataSourceProvider));
});

final lojaRepositoryProvider = Provider<LojaRepository>((ref) {
  return LojaRepositoryImpl(ref.watch(localDataSourceProvider));
});

final coletaRepositoryProvider = Provider<ColetaRepository>((ref) {
  return ColetaRepositoryImpl(ref.watch(localDataSourceProvider));
});

final colaboradorRepositoryProvider = Provider<ColaboradorRepository>((ref) {
  return ColaboradorRepositoryImpl(ref.watch(localDataSourceProvider));
});

final dispositivoRepositoryProvider = Provider<DispositivoRepository>((ref) {
  return DispositivoRepositoryImpl(ref.watch(localDataSourceProvider));
});

final importarProdutosUseCaseProvider = Provider<ImportarProdutosUseCase>((ref) {
  return ImportarProdutosUseCase(
    ref.watch(produtoRepositoryProvider),
    ref.watch(lojaRepositoryProvider),
  );
});

final importarLojasUseCaseProvider = Provider<ImportarLojasUseCase>((ref) {
  return ImportarLojasUseCase(ref.watch(lojaRepositoryProvider));
});

final listarLojasUseCaseProvider = Provider<ListarLojasUseCase>((ref) {
  return ListarLojasUseCase(ref.watch(lojaRepositoryProvider));
});

final listarLojasColaboradorUseCaseProvider = Provider<ListarLojasColaboradorUseCase>((ref) {
  return ListarLojasColaboradorUseCase(ref.watch(lojaRepositoryProvider));
});

final buscarProdutoCodigoBarrasColaboradorUseCaseProvider =
    Provider<BuscarProdutoPorCodigoBarrasColaboradorUseCase>((ref) {
      return BuscarProdutoPorCodigoBarrasColaboradorUseCase(
        ref.watch(produtoRepositoryProvider),
      );
    });

final listarProdutosColaboradorUseCaseProvider =
    Provider<ListarProdutosColaboradorUseCase>((ref) {
      return ListarProdutosColaboradorUseCase(
        ref.watch(produtoRepositoryProvider),
      );
    });

final iniciarColetaUseCaseProvider = Provider<IniciarColetaUseCase>((ref) {
  return IniciarColetaUseCase(ref.watch(coletaRepositoryProvider));
});

final registrarItemColetaUseCaseProvider = Provider<RegistrarItemColetaUseCase>((ref) {
  return RegistrarItemColetaUseCase(ref.watch(coletaRepositoryProvider));
});

final buscarProdutoCodigoBarrasNaLojaUseCaseProvider =
    Provider<BuscarProdutoPorCodigoBarrasNaLojaUseCase>((ref) {
  return BuscarProdutoPorCodigoBarrasNaLojaUseCase(
    ref.watch(produtoRepositoryProvider),
    ref.watch(coletaRepositoryProvider),
  );
});

final buscarProdutoPorCodigoUseCaseProvider =
    Provider<BuscarProdutoPorCodigoBarrasUseCase>((ref) {
      return BuscarProdutoPorCodigoBarrasUseCase(
        ref.watch(produtoRepositoryProvider),
      );
    });

final calcularProgressoUseCaseProvider =
    Provider<CalcularProgressoColetaUseCase>((ref) {
      return CalcularProgressoColetaUseCase(
        coletaRepository: ref.watch(coletaRepositoryProvider),
        produtoRepository: ref.watch(produtoRepositoryProvider),
      );
    });

final removerItemColetaUseCaseProvider = Provider<RemoverItemColetaUseCase>((ref) {
  return RemoverItemColetaUseCase(ref.watch(coletaRepositoryProvider));
});

final reiniciarColetaUseCaseProvider = Provider<ReiniciarColetaUseCase>((ref) {
  return ReiniciarColetaUseCase(ref.watch(coletaRepositoryProvider));
});

final exportarColetasDiariasUseCaseProvider =
    Provider<ExportarColetasDiariasUseCase>((ref) {
      return ExportarColetasDiariasUseCase(
        coletaRepository: ref.watch(coletaRepositoryProvider),
        lojaRepository: ref.watch(lojaRepositoryProvider),
        produtoRepository: ref.watch(produtoRepositoryProvider),
      );
    });

final exportarColetaIndividualUseCaseProvider =
    Provider<ExportarColetaIndividualUseCase>((ref) {
      return ExportarColetaIndividualUseCase(
        coletaRepository: ref.watch(coletaRepositoryProvider),
        lojaRepository: ref.watch(lojaRepositoryProvider),
        produtoRepository: ref.watch(produtoRepositoryProvider),
      );
    });

final autenticarColaboradorUseCaseProvider =
    Provider<AutenticarColaboradorUseCase>((ref) {
      return AutenticarColaboradorUseCase(
        ref.watch(colaboradorRepositoryProvider),
      );
    });

final cadastrarColaboradorUseCaseProvider =
    Provider<CadastrarColaboradorUseCase>((ref) {
      return CadastrarColaboradorUseCase(
        ref.watch(colaboradorRepositoryProvider),
      );
    });

final inicializarDispositivoSessaoUseCaseProvider =
    Provider<InicializarDispositivoSessaoUseCase>((ref) {
      return InicializarDispositivoSessaoUseCase(
        ref.watch(dispositivoRepositoryProvider),
      );
    });

final feedbackServiceProvider = Provider<FeedbackService>((ref) {
  return FeedbackService();
});

final exportFileServiceProvider = Provider<ExportFileService>((ref) {
  return ExportFileService();
});

final vibracaoAtivaProvider = StateProvider<bool>((ref) => true);

final colaboradorSessaoProvider = StateProvider<Colaborador?>((ref) => null);
final dispositivoSessaoProvider = StateProvider<Dispositivo?>((ref) => null);

// Seed data initialization
final seedDataProvider = FutureProvider<void>((ref) async {
  final localDataSource = ref.watch(localDataSourceProvider);
  await SeedData.seedInitialData(localDataSource);
});
