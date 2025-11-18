# BookNest

Plataforma web para gerenciamento de biblioteca pessoal e clube de leitura virtual.

## Tecnologias

- React 19.2.0
- TypeScript 5.6.3
- Vite 5.4.11
- TailwindCSS 3.4.14
- React Router 7.9.3
- TanStack Query 5.90.2
- Zustand 5.0.8
- React Hook Form 7.63.0
- Zod 4.1.11

## Instalação

```bash
npm install
```

## Configuração

1. Copie o arquivo `.env.example` para `.env`:
```bash
cp .env.example .env
```

2. Configure as variáveis de ambiente no arquivo `.env`

## Desenvolvimento

```bash
npm run dev
```

Acesse: http://localhost:5173

## Build

```bash
npm run build
```

## Preview

```bash
npm run preview
```

## Estrutura do Projeto

```
src/
├── app/              # Configuração da aplicação
├── assets/           # Recursos estáticos
├── core/             # Componentes e lógica compartilhada
├── domain/           # Módulos de domínio
└── pages/            # Páginas da aplicação
```

## Funcionalidades

- Gerenciamento de biblioteca pessoal
- Acompanhamento de leituras
- Sistema de avaliação e resenhas
- Dashboard com estatísticas
- Metas anuais de leitura
- Timeline de leituras
- Busca e filtros avançados