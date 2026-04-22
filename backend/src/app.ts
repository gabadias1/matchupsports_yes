import express from "express";
import cors from "cors";
import usuarioRoutes from "./routes/usuarioRoutes";
import estabelecimentoRoutes from "./routes/estabelecimentoRoutes";
import quadraRoutes from "./routes/quadraRoutes";
import swaggerUi from "swagger-ui-express";
import { swaggerSpec } from "./config/swagger";

const app = express();

app.use(cors());
app.use(express.json());

// Swagger
app.use("/api-docs", swaggerUi.serve, swaggerUi.setup(swaggerSpec));

app.use("/usuarios", usuarioRoutes);
app.use("/estabelecimentos", estabelecimentoRoutes);
app.use("/quadras", quadraRoutes);

app.get("/", (req, res) => {
  res.send("Backend rodando! 🚀");
});

export default app;