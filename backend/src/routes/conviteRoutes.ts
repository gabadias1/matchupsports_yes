import { Router } from "express";
import {
  criarConvite,
  aceitarConvite,
} from "../controllers/conviteController";

import { autenticacaoMiddleware } from "../middleware/autenticacaoMiddleware";

const router = Router();

/**
 * @swagger
 * /convites:
 *   post:
 *     summary: Criar convite para uma partida
 *     tags:
 *       - Convites
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - partida_id
 *             properties:
 *               partida_id:
 *                 type: integer
 *                 example: 1
 *     responses:
 *       201:
 *         description: Convite criado com sucesso
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 link:
 *                   type: string
 *                   example: http://localhost:3000/convite/abc123
 *       400:
 *         description: Erro ao criar convite
 */
router.post("/convites", autenticacaoMiddleware, criarConvite);

/**
 * @swagger
 * /convites/{token}/aceitar:
 *   post:
 *     summary: Aceitar convite de uma partida
 *     tags:
 *       - Convites
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: token
 *         required: true
 *         schema:
 *           type: string
 *         example: abc123
 *     responses:
 *       200:
 *         description: Convite aceito com sucesso
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: Convite aceito com sucesso.
 *
 *       400:
 *         description: Erro ao aceitar convite
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   examples:
 *                     expirado:
 *                       value: Convite expirado.
 *                     usado:
 *                       value: Convite já utilizado.
 *                     cheia:
 *                       value: Partida cheia. Não é possível aceitar o convite.
 *                     invalido:
 *                       value: Erro ao aceitar convite. Verifique o token e tente novamente.
 */
router.post(
  "/convites/:token/aceitar",
  autenticacaoMiddleware,
  aceitarConvite
);

export default router;