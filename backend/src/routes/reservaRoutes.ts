import { Router } from "express";
import { autenticacaoMiddleware } from "../middleware/autenticacaoMiddleware";
import { 
  createReserva, 
  getMinhasReservas, 
  getAvailableSlots, 
  getReservasDonoQuadras,
  cancelarReserva 
} from "../controllers/reservaController";

const router = Router();

/**
 * @swagger
 * components:
 *   schemas:
 *     Reserva:
 *       type: object
 *       properties:
 *         id:
 *           type: integer
 *           example: 1
 *         usuario_id:
 *           type: integer
 *           example: 3
 *         quadra_id:
 *           type: integer
 *           example: 2
 *         data:
 *           type: string
 *           format: date-time
 *           example: "2025-06-24T00:00:00.000Z"
 *         hora_inicio:
 *           type: integer
 *           example: 1800
 *         hora_fim:
 *           type: integer
 *           example: 2000
 *         status:
 *           type: string
 *           enum: [PENDENTE, CONFIRMADA, CANCELADA]
 *           example: PENDENTE
 *         created_at:
 *           type: string
 *           format: date-time
 */

/**
 * @swagger
 * /reservas:
 *   post:
 *     summary: Cria uma nova reserva
 *     tags: [Reservas]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               quadra_id:
 *                 type: integer
 *               data:
 *                 type: string
 *               hora_inicio:
 *                 type: integer
 *               hora_fim:
 *                 type: integer
 *     responses:
 *       201:
 *         description: Reserva criada
 *       400:
 *         description: Erro na requisição
 */
router.post("/", autenticacaoMiddleware, createReserva);

/**
 * @swagger
 * /reservas/available:
 *   get:
 *     summary: Retorna intervalos livres para a quadra na data
 *     tags: [Reservas]
 *     parameters:
 *       - in: query
 *         name: quadra_id
 *         required: true
 *         schema:
 *           type: integer
 *       - in: query
 *         name: date
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Lista de horários disponíveis
 */
router.get("/available", getAvailableSlots);

/**
 * @swagger
 * /reservas/dono:
 *   get:
 *     summary: Retorna reservas das quadras do dono autenticado
 *     tags: [Reservas]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Lista de reservas
 */
router.get("/dono", autenticacaoMiddleware, getReservasDonoQuadras);

/**
 * @swagger
 * /reservas/minhas:
 *   get:
 *     summary: Lista as reservas do usuário logado
 *     tags: [Reservas]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Lista de reservas do usuário
 *       401:
 *         description: Não autenticado
 */
router.get("/minhas", autenticacaoMiddleware, getMinhasReservas);

/**
 * @swagger
 * /reservas/me:
 *   get:
 *     summary: Lista as reservas do usuário logado (compatibilidade)
 *     tags: [Reservas]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Lista de reservas do usuário
 *       401:
 *         description: Não autenticado
 */
router.get("/me", autenticacaoMiddleware, getMinhasReservas);

/**
 * @swagger
 * /reservas/{id}:
 *   delete:
 *     summary: Cancela uma reserva do usuário logado
 *     tags: [Reservas]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *           example: 1
 *     responses:
 *       200:
 *         description: Reserva cancelada com sucesso
 *       403:
 *         description: Sem permissão para cancelar esta reserva
 *       404:
 *         description: Reserva não encontrada
 */
router.delete("/:id", autenticacaoMiddleware, cancelarReserva);

export default router;