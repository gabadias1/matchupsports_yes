import "dotenv/config";
import app from "./app";

const PORT = process.env.PORT || 3000;

if (!process.env.JWT_SECRET) {
  console.error("Erro: variável JWT_SECRET não definida.");
  process.exit(1);
}

app.listen(PORT, () => {
  console.log(`🚀 Servidor rodando na porta ${PORT}`);
  console.log(`📄 Documentação modular disponível em http://localhost:${PORT}/api-docs`);
});