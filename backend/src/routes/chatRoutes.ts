import { Router } from "express";
import { autenticacaoMiddleware } from "../middleware/autenticacaoMiddleware";
import { enviarMensagem, recuperarMensagens } from "../controllers/chatController";

const router = Router();

/**
 * @swagger
 * tags:
 *   name: Chat
 *   description: Chat das reservas
 */

/**
 * @swagger
 * /chat/mensagens:
 *   post:
 *     summary: Recupera mensagens de um chat de reserva com paginação
 *     tags: [Chat]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - reserva_id
 *             properties:
 *               reserva_id:
 *                 type: integer
 *                 example: 5
 *                 description: ID da reserva associada ao chat
 *               page:
 *                 type: integer
 *                 example: 0
 *                 description: Página da paginação. A página 0 retorna as 50 mensagens mais recentes.
 *     responses:
 *       200:
 *         description: Mensagens recuperadas com sucesso
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 page:
 *                   type: integer
 *                   example: 0
 *                 limit:
 *                   type: integer
 *                   example: 50
 *                 total:
 *                   type: integer
 *                   example: 132
 *                 hasMore:
 *                   type: boolean
 *                   example: true
 *                 mensagens:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       id:
 *                         type: integer
 *                         example: 120
 *                       mensagem:
 *                         type: string
 *                         example: "Nos encontramos às 20h!"
 *                       created_at:
 *                         type: string
 *                         format: date-time
 *                         example: "2026-06-23T18:30:00.000Z"
 *                       usuario:
 *                         type: object
 *                         properties:
 *                           id:
 *                             type: integer
 *                             example: 2
 *                           first_name:
 *                             type: string
 *                             example: "Matheus"
 *       401:
 *         description: Usuário não autenticado
 *       404:
 *         description: Chat da reserva não encontrado
 *       400:
 *         description: Erro ao recuperar mensagens
 */
router.get(
    "/mensagens",
    autenticacaoMiddleware,
    recuperarMensagens
);

/**
 * @swagger
 * /chat/reservas/{reservaId}/mensagens:
 *   post:
 *     summary: Envia mensagem no chat de uma reserva
 *     tags:
 *       - Chat
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: reservaId
 *         required: true
 *         schema:
 *           type: integer
 *         example: 3
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               mensagem:
 *                 type: string
 *                 example: "Olá, tudo certo?"
 *     responses:
 *       201:
 *         description: Mensagem enviada
 */
router.post(
    "/:reservaId/mensagens",
    autenticacaoMiddleware,
    enviarMensagem
);

export default router;