import express from "express";
import cors from "cors";
import usuarioRoutes from "./routes/usuarioRoutes";
import estabelecimentoRoutes from "./routes/estabelecimentoRoutes";
import quadraRoutes from "./routes/quadraRoutes";
import autenticacaoRoutes from "./routes/autenticacaoRoutes";
import disponibilidadeRoutes from "./routes/disponibilidadeRoutes";
import swaggerUi from "swagger-ui-express";
import { setupSwagger, swaggerSpec } from "./config/swagger";

const app = express();

app.use(cors());
app.use(express.json());

// Swagger
app.use("/api-docs", swaggerUi.serve, swaggerUi.setup(swaggerSpec));


// Rotas
app.use("/usuarios", usuarioRoutes);
app.use("/estabelecimentos", estabelecimentoRoutes);
app.use("/quadras", quadraRoutes);
app.use("/autenticacao", autenticacaoRoutes);
app.use("/disponibilidades", disponibilidadeRoutes);

app.get("/", (req, res) => {
  res.send("Backend rodando! 🚀");
});

setupSwagger(app);

export default app;