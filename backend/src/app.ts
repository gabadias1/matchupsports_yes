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
import chatRoutes from "./routes/chatRoutes";
import { getMatchesDisponiveis } from "./controllers/partidaController";
import swaggerUi from "swagger-ui-express";
import { setupSwagger } from "./config/swagger";
const app = express();

app.use(cors());
app.use(express.json());

// Swagger

// Rotas
app.use("/usuarios", usuarioRoutes);
app.use("/estabelecimentos", estabelecimentoRoutes);
app.use("/quadras", quadraRoutes);
app.use("/autenticacao", autenticacaoRoutes);
app.use("/disponibilidades", disponibilidadeRoutes);
app.use("/reservas", reservaRoutes); // Apenas uma declaração para reservas
app.use("/partidas", partidaRoutes);
app.use("/convites", conviteRoutes);
app.use("/chat", chatRoutes);
app.get("/match", getMatchesDisponiveis);

app.get("/", (req, res) => {
  res.send("Backend rodando! 🚀");
});

setupSwagger(app);

export default app;