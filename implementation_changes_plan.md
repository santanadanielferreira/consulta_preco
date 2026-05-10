# Plano de Mudancas - Autenticacao e Coleta

## Convencoes
- [ ] Pendente
- [~] Em andamento
- [x] Concluida
- [!] Bloqueada

## Fase 1 - Autenticacao e Cadastro
- [x] Criar repositorios e use cases de colaborador/dispositivo
- [x] Validar login por email e senha no banco
- [x] Criar fluxo de cadastro na tela de login

## Fase 2 - Sessao e Dispositivo
- [x] Inicializar dispositivo automaticamente ao autenticar
- [x] Persistir usuario/dispositivo autenticados em providers
- [x] Remover ids fixos ao iniciar coleta

## Fase 3 - Catalogo
- [x] Busca por nome no catalogo de itens coletados
- [x] Busca por scan no contexto do catalogo
- [x] Excluir item com confirmacao

## Fase 4 - Preco com dupla digitacao
- [x] Insercao de preco com confirmacao dupla
- [x] Edicao de preco com confirmacao dupla

## Fase 5 - Progresso por loja/coleta
- [x] Ajustar progresso por coleta usando catalogo global
- [x] Exibir pendentes por coleta

## Fase 6 - Testes
- [x] Testes unitarios dos novos casos de uso
- [x] Widget tests dos novos fluxos
- [x] Validar analyze/test sem regressao

## Atualizacoes
- 2026-04-12: plano criado e implementacao iniciada.
- 2026-04-12: fase 1 e fase 2 concluidas (auth por banco, cadastro, sessao com dispositivo e coleta sem ids fixos).
- 2026-04-12: validacao concluida com flutter analyze sem issues e flutter test com 28 testes passando.
- 2026-04-12: corrigido erro Android de plugin registrant (arquivo gerado removido de android/app/src/main/java e build debug recompilado com sucesso).
- 2026-04-12: fase 3 a fase 5 concluidas (busca no catalogo por nome/scan, exclusao com confirmacao, dupla digitacao de preco e progresso com pendentes por coleta).
- 2026-04-12: fase 6 concluida com novos testes unitarios/widget tests e validacao final (flutter analyze limpo e flutter test com 39 testes passando).
