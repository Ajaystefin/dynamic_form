# Sonar Exporter

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Next.js](https://img.shields.io/badge/Next.js-14+-black)](https://nextjs.org/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.0+-3178C6)](https://www.typescriptlang.org/)

> Uma solução poderosa, segura e amigável para exportar relatórios de issues do SonarQube com facilidade.

For the English version of this README, click [here](README_EN.md).

## 🎯 Visão Geral

O Sonar Exporter é uma aplicação Next.js projetada para suprir uma lacuna crítica na funcionalidade do SonarQube: a capacidade de exportar relatórios de issues de forma simples, segura e customizável. Ao utilizar as APIs oficiais do SonarQube, esta ferramenta capacita equipes de desenvolvimento a gerar relatórios detalhados sem processos manuais complexos ou preocupações de segurança.

## 🚀 Principais Funcionalidades

- **Exportação Simplificada**: Gera relatórios abrangentes de issues do SonarQube em múltiplos formatos
- **Interface Intuitiva**: UI limpa e responsiva projetada para produtividade do desenvolvedor
- **Integração Direta com API**: Comunicação em tempo real com as APIs do SonarQube
- **Arquitetura Privacy-First**: Zero armazenamento de dados - todo processamento ocorre no cliente
- **Suporte Multi-Projetos**: Gerencia múltiplos projetos SonarQube sem esforço
- **Pronto para Empresa**: Construído com segurança e escalabilidade em mente

## 💡 Por que o Sonar Exporter?

Embora o SonarQube seja excelente em análise de qualidade de código, carece de capacidades robustas de exportação para relatórios de issues. Equipes de desenvolvimento frequentemente enfrentam:

- Processos manuais de geração de relatórios
- Opções limitadas de formato de exportação
- Preocupações de segurança com ferramentas de terceiros
- Dificuldade em customizar saídas de relatórios

O Sonar Exporter resolve esses pontos de dor fornecendo uma solução simplificada e segura que se integra diretamente com sua infraestrutura SonarQube existente.

## 🔒 Segurança e Privacidade

A segurança é fundamental em nossa filosofia de design:

- **Zero Persistência de Dados**: Nenhuma credencial de usuário, token ou dados de relatório são armazenados
- **Processamento Client-Side**: Todas as operações ocorrem no navegador do usuário
- **Comunicação Direta com API**: Nenhum servidor intermediário manipula dados sensíveis
- **Arquitetura Transparente**: Código-fonte aberto para auditoria completa

## ⚡ Início Rápido

### Pré-requisitos

- Node.js 18+ 
- npm ou yarn
- Acesso a uma instância do SonarQube

### Instalação

```bash
# Clone o repositório
git clone https://github.com/fonteeboa/next-sonar-exporter.git

# Navegue para o diretório do projeto
cd sonar-exporter

# Instale as dependências
npm install

# Inicie o servidor de desenvolvimento
npm run dev
```

### Uso

1. Abra seu navegador e navegue até `http://localhost:3000`
2. Configure os detalhes de conexão do seu SonarQube
3. Selecione o projeto e filtros para seu relatório
4. Exporte seu relatório de issues customizado

## 🛠 Arquitetura Técnica

### Construído Com

- **Framework**: Next.js 14+ com App Router
- **Linguagem**: TypeScript para type safety
- **Estilização**: Tailwind CSS para desenvolvimento rápido de UI
- **Cliente de API**: Fetch nativo com tratamento adequado de erros
- **Segurança**: Gerenciamento de tokens client-side

### Estrutura do Projeto

```
sonar-exporter/
├── src/
│   ├── app/                 # Next.js App Router
│   │   ├── api/             # Routes da API Next.js
│   │   │   ├── sonar-issues/     # Endpoints para issues do SonarQube
│   │   │   └── sonar-projects/   # Endpoints para projetos do SonarQube
│   │   └── components/      # Componentes específicos de páginas
│   ├── assets/              # Assets estáticos e recursos
│   ├── context/             # Contextos React para estado global
│   ├── services/            # Serviços de API e integrações externas
│   ├── styles/              # Arquivos de estilo globais
│   └── types/               # Definições de tipos TypeScript
├── public/                  # Assets públicos
└── docs/                    # Documentação
```

## 📊 Limitações Atuais

As limitações atuais estão principalmente vinculadas às restrições da API do SonarQube:

- **Limites de Paginação**: Governados pelas regras de paginação da API do SonarQube
- **Disponibilidade de Filtros**: Limitado aos filtros expostos pelas APIs do SonarQube
- **Limites de Performance**: Sujeito às características de performance da instância SonarQube
- **Rate Limiting**: Aderência aos limites de taxa da API do SonarQube

## 🗺 Roadmap

### Fase 1: Funcionalidade Core ✅
- Funcionalidade básica de exportação de issues
- Suporte ao idioma português
- Implementação de UI responsiva
- Múltiplos formatos de exportação (PDF, Excel, CSV)

### Fase 2: Melhorias (Em Progresso)
- [ ] Tradução completa para inglês
- [ ] Opções avançadas de filtragem

## 📝 Licença

Este projeto está licenciado sob a Licença Apache 2.0 - consulte o arquivo [LICENSE](LICENSE) para detalhes.

## 🔧 Suporte

Se você encontrar problemas ou tiver dúvidas:

1. Consulte nossa [Documentação](docs/)
2. Busque por [Issues](https://github.com/fonteeboa/next-sonar-exporter/issues) existentes
3. Crie uma nova issue com informações detalhadas

## 🌟 Agradecimentos

- Equipe do SonarQube por fornecer APIs abrangentes
- Comunidade Next.js pela excelente documentação e suporte

---

**Construído com ❤️ pela equipe de desenvolvimento**

*Tornando relatórios do SonarQube acessíveis para todos*