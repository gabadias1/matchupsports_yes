# 📱 Match Up Sports YES

## 📌 Sobre o Projeto

O **Match Up Sports YES** é um aplicativo móvel desenvolvido para facilitar o aluguel de quadras esportivas, como futebol, vôlei e basquete.

A plataforma conecta **donos de quadras** com **jogadores**, oferecendo uma forma simples, rápida e eficiente de reservar horários ou até mesmo encontrar novas pessoas para jogar.
 
---

## 🎯 Funcionalidades

### 👤 Para Usuários

* 🔍 Buscar quadras por:

  * Localização
  * Esporte (futebol, vôlei, basquete)
  * Data e horário
* 📅 Reservar quadras completas por horário
* 👥 Participar de listas públicas para jogar com outras pessoas
* 📲 Visualizar informações da quadra (local, preço, disponibilidade)

### 🏟️ Para Donos de Quadras

* ➕ Cadastrar quadras disponíveis
* 🕒 Definir horários e preços
* 📊 Gerenciar reservas
* ✏️ Editar informações das quadras

---

## 💡 Diferencial do Projeto

O grande diferencial do **Match Up Sports YES** é o sistema de **Match (listas online)**:

* Usuários podem entrar em listas de partidas disponíveis
* Pessoas desconhecidas podem se reunir para jogar juntas
* Ideal para quem quer jogar, mas não tem um time completo
* Possibilidade de escolher:

  * Esporte
  * Local
  * Horário
  * Tipo de quadra

---

## ⚙️ Tecnologias Utilizadas

* **Frontend Mobile:** Flutter
* **Backend:** Node.js / Express
* **Banco de Dados:** PostgreSQL


---

## 👨‍💻 Objetivo

Este projeto foi desenvolvido para:

* Facilitar o acesso a quadras esportivas
* Incentivar a prática de esportes
* Conectar pessoas através do esporte
* Aplicar conhecimentos em desenvolvimento de software

---

## 🚀 Backend - Instalação e Execução

### 📋 Pré-requisitos

Antes de começar, você precisa ter instalado:

* Node.js (versão 18+)
* Docker
* Docker Compose

---

### ⚙️ Configuração de ambiente

Crie um arquivo ```.env``` na raiz do backend:

```
DATABASE_URL=postgresql://postgres:postgres@postgres:5432/mydb
PORT=3000
```

---

### 🐳 Subindo o projeto com Docker

Dentro do diretório backend execute:

```
docker compose up --build
```

Após isso, o servidor backend estará disponível em:

```
http://localhost:3000
```

O swagger para documentação estará disponível em:

```
http://localhost:3000/api-docs
```
