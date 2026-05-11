# Plano de Implementacao - KeePrice

## Objetivo
Executar o roadmap de forma incremental, com rastreabilidade de status em cada tarefa.

## Convencoes de Status
- [ ] Pendente
- [~] Em andamento
- [x] Concluida
- [!] Bloqueada

## Backlog Priorizado

### Fase 0 - Governanca e Baseline
- [x] Definir gerenciamento de estado (Riverpod)
- [x] Definir estrategia de acompanhamento em arquivo separado
- [x] Criar plano operacional de implementacao
- [x] Registrar baseline tecnica no repositorio

### Fase 1 - Setup Tecnico
- [x] Atualizar dependencias em pubspec.yaml
- [x] Configurar Android para scanner/permissoes
- [x] Estruturar pastas base de arquitetura
- [x] Substituir app contador por bootstrap real

### Fase 2 - Dominio e Dados
- [x] Criar entidades de dominio
- [x] Criar models com serializacao JSON
- [x] Criar schema SQLite inicial
- [x] Implementar datasources locais
- [x] Implementar repositories

### Fase 3 - Regras de Negocio
- [x] Importacao de produtos/lojas com validacao
- [x] Fluxo de coleta e regras de duplicidade/preco
- [x] Busca por codigo de barras
- [x] Exportacao JSON diaria
- [x] Calculo de progresso

### Fase 4 - UI (7 telas)
- [x] Login
- [x] Selecao de Loja
- [x] Catalogo de Coleta
- [x] Scanner
- [x] Insercao de Preco
- [x] Edicao de Coleta
- [x] Resumo Final

### Fase 5 - Refinamento UX
- [x] Feedback sonoro
- [x] Vibracao opcional
- [x] Mensagens de erro/sucesso padronizadas

### Fase 6 - Qualidade
- [x] Testes unitarios dos use cases criticos
- [x] Widget tests das telas principais
- [x] Analise estatica sem erros bloqueantes

### Fase 7 - Fechamento
- [ ] Checklist de criterios de aceite
- [ ] Registrar riscos residuais e backlog futuro

## Em andamento
- Fase 7 - Fechamento (validacao final contra roadmap, checklist de criterios de aceite)

## Concluidas
- Decisao de arquitetura de estado: Riverpod
- Definicao de acompanhamento em arquivo separado
- Setup tecnico inicial completo (dependencias, Android, estrutura de pastas, bootstrap)
- Testes e analise estatica passando apos bootstrap inicial
- Baseline tecnica registrada no plano operacional
- Fase 2 concluida (entidades, models, SQLite, datasources e repositories)
- Testes e analise estatica passando apos implementacao da Fase 2
- Fase 3 concluida (use cases de importacao, coleta, busca, exportacao e progresso)
- Testes e analise estatica passando apos implementacao da Fase 3
- Fase 4 concluida com fluxo navegavel completo integrado ao dominio/SQLite
- Testes e analise estatica passando apos implementacao da Fase 4
- Fase 5 concluida (feedback sonoro, vibracao opcional e mensagens padronizadas)
- Testes e analise estatica passando apos implementacao da Fase 5
- Fase 6 concluida com 28 testes passando (4 unit tests de use cases, 6 unit tests de validators, 4 widget tests, all passing, zero analyze issues)

## Bloqueios
- Nenhum

## Riscos Atuais
- Integracao real de scanner deve ser validada em dispositivo fisico Android.
- Definicao de schema SQLite precisa considerar migracoes desde a v1.

## Proxima Sprint (curta)
1. Integrar feedback sonoro no registro de coleta
2. Integrar vibracao opcional e padronizar mensagens de erro/sucesso
3. Preparar testes unitarios dos use cases criticos
