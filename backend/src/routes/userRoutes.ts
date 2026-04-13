import { Router } from "express";
import { createUser } from "../controllers/userController";

const router = Router();

/**
 * @swagger
 * /users:
 *   post:
 *     summary: Cria um novo usuário
 *     tags: [Users]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - name
 *               - email
 *             properties:
 *               name:
 *                 type: string
 *                 example: João Silva
 *               email:
 *                 type: string
 *                 example: joao@email.com
 *     responses:
 *       200:
 *         description: Usuário criado com sucesso
 *       500:
 *         description: Erro interno
 */
router.post("/", createUser);

export default router;