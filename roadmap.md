# 📱 KeePrice - Roadmap de Desenvolvimento (Flutter)

## 🎯 Objetivo
Desenvolver um aplicativo Android em Flutter para coleta de preços de produtos em lojas físicas, com funcionamento offline, leitura de código de barras e exportação de dados em JSON.

---

## 🧱 Arquitetura Geral

### Abordagem
- Arquitetura: Clean Architecture (simplificada)
- Gerenciamento de estado: Riverpod ou Bloc
- Persistência local: SQLite
- Leitura de código de barras: mobile_scanner
- Manipulação de JSON: dart:convert
- Armazenamento de arquivos: path_provider

---

## 📦 Estrutura de Pastas

lib/
│
├── core/
│   ├── utils/
│   ├── constants/
│
├── data/
│   ├── models/
│   ├── datasources/
│   ├── repositories/
│
├── domain/
│   ├── entities/
│   ├── usecases/
│
├── presentation/
│   ├── pages/
│   ├── widgets/
│   ├── controllers/
│
└── main.dart

---

## 🧩 Modelagem de Dados

### Entidades principais

- Produto
  - id
  - codigo_barras
  - nome
  - fabricante

- Loja
  - id
  - nome
  - endereco
  - cidade
  - estado

- Coleta
  - id
  - id_loja
  - data_coleta
  - id_colaborador
  - id_dispositivo

- ItemColeta
  - id
  - id_coleta
  - id_produto
  - preco
  - data_coleta

- Colaborador
  - id
  - nome
  - email
  - login
  - senha
  - data_cadastro

- Dispositivo
  - id
  - modelo
  - mei
  - versao_android
  - data_cadastro

---

## 📥 Importação de Dados

### Fonte
- Arquivos JSON locais no dispositivo

### Funcionalidades
- Importar lista de produtos
- Importar lista de lojas

### Regras
- Validar estrutura do JSON
- Evitar duplicidade
- Exibir feedback ao usuário

---

## 📤 Exportação de Dados

### Objetivo
Gerar arquivo JSON com todas as coletas do dia

### Estrutura esperada

{
  "data": "2026-04-12",
  "loja": {...},
  "itens": [
    {
      "produto": {...},
      "preco": 10.50,
      "data_coleta": "timestamp"
    }
  ]
}

### Funcionalidades
- Exportar por dia
- Salvar no armazenamento local
- Compartilhar arquivo (opcional)

---

## 📷 Leitura de Código de Barras

### Fluxo
1. Abrir câmera
2. Ler código
3. Buscar produto localmente
4. Exibir produto encontrado

### Tratamento de erro
- Produto não encontrado → alertar usuário

---

## 🔄 Fluxo Principal do App

1. Login (local simples)
2. Seleção de loja
3. Início da coleta
4. Scan de produto
5. Inserção de preço
6. Feedback (som + visual)
7. Armazenamento local
8. Exibição de progresso

---

## 📱 Telas

### 1. Login
- Validação simples
- Persistência local

### 2. Seleção de Loja
- Lista simples
- Busca por nome

### 3. Catálogo de Coleta
- Lista de produtos já coletados
- Indicador de progresso

### 4. Scanner
- Leitura rápida
- Feedback visual

### 5. Inserção de Preço
- Campo numérico
- Validação obrigatória

### 6. Edição de Coleta
- Permitir alterar preço

### 7. Resumo Final
- Total de itens coletados
- Botão de exportação

---

## ⚙️ Regras de Negócio

- Não permitir preço vazio
- Evitar duplicidade de coleta (mesmo produto)
- Permitir edição
- Indicar itens já coletados
- Exibir progresso (% ou quantidade)

---

## 🔊 Feedback ao Usuário

- Som ao registrar coleta
- Vibração opcional
- Mensagens claras

---

## 🧪 Testes

### Unitários
- UseCases
- Validação de JSON

### Widget Tests
- Telas principais

---

## 🚀 Etapas de Desenvolvimento

### Fase 1 - Setup
- Criar projeto Flutter
- Configurar dependências

### Fase 2 - Modelos e Banco Local
- Criar entidades
- Implementar SQLite

### Fase 3 - Importação JSON
- Parser de produtos e lojas

### Fase 4 - Scanner
- Integração com câmera

### Fase 5 - Fluxo de Coleta
- CRUD de coletas

### Fase 6 - UI/UX
- Telas e navegação

### Fase 7 - Exportação JSON
- Gerar e salvar arquivo

### Fase 8 - Refinamento
- Feedback sonoro
- Correções UX

---

## 📌 Melhorias Futuras

- Sincronização com backend
- Geolocalização
- Dashboard web
- Multiusuário online

---

## ⚠️ Pontos Críticos

- Performance da busca por código de barras
- Consistência dos dados offline
- UX simples e rápida (campo de operação)

---

## ✅ Critérios de Aceite

- App funciona 100% offline
- Importa JSON corretamente
- Lê código de barras
- Permite coleta e edição
- Exporta JSON válido
- UX simples e clara