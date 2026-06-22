import { Router } from "express";
import { autenticacaoMiddleware } from "../middleware/autenticacaoMiddleware";
import { 
  createReserva, 
  getMinhasReservas, 
  getAvailableSlots, 
  getReservasDonoQuadras,
  cancelarReserva, // Adicionado o seu controller da Sprint 3
  confirmarReserva,
  recusarReserva
} from "../controllers/reservaController";
import { cargoMiddleware } from "../middleware/cargoMiddleware";

const router = Router();

/**
 * POST /reservas
 * body: { quadra_id, data, hora_inicio, hora_fim }
 */
router.post("/", autenticacaoMiddleware, createReserva);

/**
 * GET /reservas/available?quadra_id=1&date=YYYY-MM-DD
 * Retorna intervalos livres para a quadra na data
 */
router.get("/available", getAvailableSlots);

/**
 * GET /reservas/dono
 * Retorna reservas das quadras do dono autenticado
 */
router.get("/dono", autenticacaoMiddleware, getReservasDonoQuadras);

/**
 * GET /reservas/minhas
 * Retorna reservas do usuário autenticado (Rota da equipe)
 */
router.get("/minhas", autenticacaoMiddleware, getMinhasReservas);

/**
 * @swagger
 * /reservas/me:
 * get:
 * summary: Lista as reservas do usuário logado (Sua rota mantida para compatibilidade)
 * tags: [Reservas]
 * security:
 * - bearerAuth: []
 * responses:
 *  200:
 *    description: Lista de reservas do usuário
 *  401:
 *    description: Não autenticado
 */
router.get("/me", autenticacaoMiddleware, getMinhasReservas);

/**
 * @swagger
 * /reservas/{id}/recusar:
 *   put:
 *     summary: Recusa uma reserva
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
 *         description: Reserva recusada com sucesso
 *       403:
 *         description: Sem permissão para recusar esta reserva
 *       404:
 *         description: Reserva não encontrada
 */
router.put(
  "/:id/recusar",
  autenticacaoMiddleware,
  cargoMiddleware(1),
  recusarReserva
);

/**
 * @swagger
 * /reservas/{id}/confirmar:
 *   put:
 *     summary: Confirma uma reserva
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
 *         description: Reserva confirmada com sucesso
 *       403:
 *         description: Sem permissão para confirmar esta reserva
 *       404:
 *         description: Reserva não encontrada
 */
router.put(
  "/:id/confirmar",
  autenticacaoMiddleware,
  cargoMiddleware(1),
  confirmarReserva
);

/**
 * @swagger
 * /reservas/{id}:
 * delete:
 * summary: Cancela uma reserva do usuário logado
 * tags: [Reservas]
 * security:
 * - bearerAuth: []
 * parameters:
 * - in: path
 * name: id
 * required: true
 * schema:
 * type: integer
 * example: 1
 * responses:
 *  200:
 *    description: Reserva cancelada com sucesso
 *  403:
 *    description: Sem permissão para cancelar esta reserva
 *  404:
 *     description: Reserva não encontrada
 */
router.delete("/:id", autenticacaoMiddleware, cancelarReserva);

export default router;