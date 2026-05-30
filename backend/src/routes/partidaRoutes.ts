import { Router } from "express";
import {
  createPartida,
  entrarPartida,
  sairPartida,
  getMinhasPartidas,
  getPartidasAbertas,
} from "../controllers/partidaController";

import { autenticacaoMiddleware } from "../middleware/autenticacaoMiddleware";

const router = Router();

/**
 * @swagger
 * tags:
 *   name: Partidas
 *   description: Gerenciamento de partidas
 */

/**
 * @swagger
 * /partidas:
 *   post:
 *     summary: Criar uma partida
 *     tags: [Partidas]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - vagas
 *               - reserva_id
 *             properties:
 *               vagas:
 *                 type: integer
 *               status:
 *                 type: string
 *                 example: ABERTA
 *               reserva_id:
 *                 type: integer
 *     responses:
 *       201:
 *         description: Partida criada com sucesso
 */
router.post("/", autenticacaoMiddleware, createPartida);

/**
 * @swagger
 * /partidas/minhas:
 *   get:
 *     summary: Buscar minhas partidas
 *     tags: [Partidas]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Lista de partidas
 */
router.get("/minhas", autenticacaoMiddleware, getMinhasPartidas);

/**
 * @swagger
 * /partidas/abertas:
 *   get:
 *     summary: Buscar partidas abertas
 *     tags: [Partidas]
 *     responses:
 *       200:
 *         description: Lista de partidas abertas
 */
router.get("/abertas", autenticacaoMiddleware, getPartidasAbertas);

/**
 * @swagger
 * /partidas/{partidaId}/entrar:
 *   post:
 *     summary: Entrar em uma partida
 *     tags: [Partidas]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: partidaId
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: Entrou na partida
 */
router.post("/:partidaId/entrar", autenticacaoMiddleware, entrarPartida);

/**
 * @swagger
 * /partidas/{partidaId}/sair:
 *   delete:
 *     summary: Sair de uma partida
 *     tags: [Partidas]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: partidaId
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: Saiu da partida
 */
router.delete("/:partidaId/sair", autenticacaoMiddleware, sairPartida);

export default router;