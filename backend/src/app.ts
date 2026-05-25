import express from "express";
import cors from "cors";
import usuarioRoutes from "./routes/usuarioRoutes";
import estabelecimentoRoutes from "./routes/estabelecimentoRoutes";
import quadraRoutes from "./routes/quadraRoutes";
import autenticacaoRoutes from "./routes/autenticacaoRoutes";
import disponibilidadeRoutes from "./routes/disponibilidadeRoutes";
import reservaRoutes from "./routes/reservaRoutes";
import partidaRoutes from "./routes/partidaRoutes";
import conviteRoutes from "./routes/conviteRoutes";
import swaggerUi from "swagger-ui-express";
import { setupSwagger, swaggerSpec } from "./config/swagger";
import reservaRouter from "./routes/reservaRoute";

const app = express();

app.use(cors());
app.use(express.json());
app.use("/reservas", reservaRouter);

// Swagger
app.use("/api-docs", swaggerUi.serve, swaggerUi.setup(swaggerSpec));


// Rotas
app.use("/usuarios", usuarioRoutes);
app.use("/estabelecimentos", estabelecimentoRoutes);
app.use("/quadras", quadraRoutes);
app.use("/autenticacao", autenticacaoRoutes);
app.use("/disponibilidades", disponibilidadeRoutes);
app.use("/reservas", reservaRoutes);
app.use("/partidas", partidaRoutes);
app.use("/convites", conviteRoutes);

app.get("/", (req, res) => {
  res.send("Backend rodando! 🚀");
});

setupSwagger(app);

export default app;