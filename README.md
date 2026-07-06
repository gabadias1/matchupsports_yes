# 🏆 Match Up Sports YES

> Conectando jogadores, facilitando o esporte. Não tem time? A gente resolve.

O **Match Up Sports YES** é uma plataforma móvel completa que revoluciona o aluguel de espaços esportivos. Mais do que um simples aplicativo de reservas de quadras, nós atuamos como uma rede de conexão entre **donos de estabelecimentos** e **atletas amadores**.

---

## 🔥 O Grande Diferencial: Sistema "Match"

Esqueça a frustração de querer jogar futebol, vôlei ou basquete e não ter pessoas suficientes para fechar um time. O coração do Match Up Sports YES é o nosso **Sistema de Listas Online (Match)**.

* **Listas Públicas:** Usuários podem abrir suas reservas para que outras pessoas da comunidade entrem na partida.
* **Sem panelinhas:** Pessoas que não se conhecem podem se reunir com base na proximidade e interesse pelo esporte.
* **Filtros Inteligentes:** Encontre partidas disponíveis escolhendo o esporte, o horário ideal e o tipo de quadra.

---

## ✨ Principais Funcionalidades

### 🏃‍♂️ Para os Jogadores (Usuários)
* **Busca Otimizada:** Encontre quadras por localização, modalidade esportiva e disponibilidade de horário.
* **Gestão de Reservas:** Alugue quadras completas de forma rápida, com histórico detalhado e integração direta com o estabelecimento.
* **Sistema Match:** Junte-se a partidas abertas ou crie as suas próprias listas para encontrar parceiros de jogo.
* **Transparência:** Acesso rápido aos preços, infraestrutura do local e vagas disponíveis nas partidas.

### 🏟️ Para Donos de Quadras (Gestores)
* **Controle Total:** Cadastro e edição de quadras, modalidades e infraestrutura do estabelecimento.
* **Precificação Flexível:** Definição de preços e horários de funcionamento.
* **Dashboard de Reservas:** Gerenciamento centralizado de todas as reservas confirmadas, pendentes ou canceladas.

---

## 🛠️ Tecnologias Utilizadas

O ecossistema do projeto foi construído separando as responsabilidades de Frontend e Backend, garantindo escalabilidade e facilidade de manutenção.

**📱 Frontend (Mobile)**
* **Flutter & Dart:** Desenvolvimento multiplataforma e interface fluida.
* **Dio:** Cliente HTTP para comunicação eficiente com a API e tratamento de rotas.

**⚙️ Backend (API)**
* **Node.js & Express:** Servidor robusto para lidar com as requisições.
* **TypeScript:** Tipagem estática para maior segurança no código.
* **Prisma ORM:** Modelagem estruturada do banco de dados e execução de *migrations*.

**🗄️ Infraestrutura e Dados**
* **PostgreSQL:** Banco de dados relacional escolhido pela sua confiabilidade.
* **Docker & Docker Compose:** Containerização do banco de dados para padronização do ambiente de desenvolvimento.

---

## 🚀 Como Executar o Projeto Localmente

### 📋 Pré-requisitos
* Node.js (versão 18+)
* Flutter SDK configurado
* Docker e Docker Compose instalados

### 1️⃣ Configuração do Backend
Clone o repositório e acesse a pasta `backend`. Crie um arquivo `.env` na raiz da pasta com as credenciais do banco:

```env
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/mydb
PORT=3000
```

---


### Instale as dependências:



##BACK

**npm install
**sudo docker compose up -d
**npx prisma db push

##FRONT

*flutter pub get

##Executar Back

*npm run dev


##Executar Front
*flutter run -d chrome

