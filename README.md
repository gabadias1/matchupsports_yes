# Match Up Sports YES — Sprint 1

## Estrutura do Projeto

```
lib/
├── main.dart                    # Entry point
├── theme/
│   └── app_theme.dart           # Cores, tipografia e estilos globais
├── routes/
│   └── app_router.dart          # Configuração de navegação (go_router)
├── widgets/
│   └── app_widgets.dart         # Widgets reutilizáveis
└── screens/
    ├── splash_screen.dart       # Tela de abertura animada
    ├── login_screen.dart        # Login com validação
    ├── register_screen.dart     # Cadastro (Jogador / Dono de Quadra)
    └── home_screen.dart         # Home com listagem e filtros
```

## Como Rodar

```bash
# 1. Instalar dependências
flutter pub get

# 2. Rodar o app
flutter run
```

## Dependências

| Pacote | Versão | Uso |
|---|---|---|
| `google_fonts` | ^6.1.0 | Fontes Bebas Neue + DM Sans |
| `go_router` | ^13.0.0 | Navegação declarativa |

## Telas Implementadas

### Splash Screen
- Animação de fade + slide ao iniciar
- Redireciona automaticamente para Login após 2.5s

### Login
- Formulário com validação de e-mail e senha
- Botão de visibilidade da senha
- Acesso rápido por perfil (Jogador / Dono de Quadra)
- Link para tela de Cadastro

### Cadastro
- Seleção de perfil: Jogador ou Dono de Quadra
- Campos: nome, e-mail, telefone, senha e confirmação
- Validações em todos os campos

### Home
- Header escuro com saudação e busca
- Banner de destaque do Sistema Match
- Filtros por modalidade (Todos, Futebol, Vôlei, Basquete)
- Lista de quadras com card informativo (nome, local, preço, disponibilidade)
- Bottom navigation com 4 abas: Início, Match, Reservas, Perfil

## Navegação

```
Splash → Login ↔ Cadastro
                     ↓
                    Home (tabs: Início / Match / Reservas / Perfil)
```

## Critérios de Aceitação — Sprint 1

- [x] App rodando
- [x] Telas básicas criadas (Splash, Login, Cadastro, Home)
- [x] Navegação funcionando (go_router com rotas nomeadas)
