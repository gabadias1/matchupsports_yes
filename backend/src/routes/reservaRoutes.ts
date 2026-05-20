import { Router } from "express";
import { autenticacaoMiddleware } from "../middleware/autenticacaoMiddleware";
import { createReserva, getMinhasReservas, getAvailableSlots, getReservasDonoQuadras } from "../controllers/reservaController";

const router = Router();

/**
 * POST /reservas
 * body: { quadra_id, data, hora_inicio, hora_fim }
 */
router.post("/", autenticacaoMiddleware, createReserva);

/**
 * GET /reservas/minhas
 * Retorna reservas do usuário autenticado
 */
router.get("/minhas", autenticacaoMiddleware, getMinhasReservas);

/**
 * GET /reservas/dono
 * Retorna reservas das quadras do dono autenticado
 */
router.get("/dono", autenticacaoMiddleware, getReservasDonoQuadras);

/**
 * GET /reservas/available?quadra_id=1&date=YYYY-MM-DD
 * Retorna intervalos livres para a quadra na data
 */
router.get("/available", getAvailableSlots);

export default router;
