import { Router } from "express";
import { autenticacaoMiddleware } from "../middleware/autenticacaoMiddleware";
import { 
  createReserva, 
  getMinhasReservas, 
  getAvailableSlots, 
  getReservasDonoQuadras,
  cancelarReserva // Adicionado o seu controller da Sprint 3
} from "../controllers/reservaController";

const router = Router();

/**
 * @swagger
 * components:
 * schemas:
 * Reserva:
 * type: object
 * properties:
 * id:
 * type: integer
 * example: 1
 * usuario_id:
 * type: integer
 * example: 3
 * quadra_id:
 * type: integer
 * example: 2
 * data:
 * type: string
 * format: date-time
 * example: "2025-06-24T00:00:00.000Z"
 * hora_inicio:
 * type: integer
 * example: 1800
 * hora_fim:
 * type: integer
 * example: 2000
 * status:
 * type: string
 * enum: [PENDENTE, CONFIRMADA, CANCELADA]
 * example: PENDENTE
 * created_at:
 * type: string
 * format: date-time
 */

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
 * 200:
 * description: Lista de reservas do usuário
 * 401:
 * description: Não autenticado
 */
router.get("/me", autenticacaoMiddleware, getMinhasReservas);

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
 * 200:
 * description: Reserva cancelada com sucesso
 * 403:
 * description: Sem permissão para cancelar esta reserva
 * 404:
 * description: Reserva não encontrada
 */
router.delete("/:id", autenticacaoMiddleware, cancelarReserva);

export default router;