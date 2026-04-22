# Match Up Sports YES

## 📌 Sobre

Aplicativo para aluguel de quadras esportivas com sistema de match entre jogadores.

---

## 🚀 Como rodar

### 🔹 Backend (Node + Docker)

```bash
cd backend
docker compose up -d --build
```

API: http://localhost:4000

---

### 🔹 Banco de Dados

Configurado via Docker (PostgreSQL)

---

### 🔹 Frontend (Flutter)

```bash
cd frontend
flutter run
```

---

## 📡 Teste da API

GET usuários:

```bash
curl http://localhost:4000/usuarios
```

---

## 🛠️ Tecnologias

* Flutter
* Node.js / Express
* PostgreSQL
* Docker
* Prisma
