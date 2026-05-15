import { Router } from "express";

import {
  createDisponibilidade,
  getDisponibilidades,
  getDisponibilidadesPorQuadra,
  getDisponibilidade,
  updateDisponibilidade,
  deleteDisponibilidade,
  ativarDisponibilidade,
  desativarDisponibilidade,
} from "../controllers/disponibilidadeController";

import { autenticacaoMiddleware } from "../middleware/autenticacaoMiddleware";
import { cargoMiddleware } from "../middleware/cargoMiddleware";

const router = Router();

/**
 * @swagger
 * components:
 *   schemas:
 *     Disponibilidade:
 *       type: object
 *       properties:
 *         id:
 *           type: integer
 *           example: 1
 *         quadra_id:
 *           type: integer
 *           example: 1
 *         dia_semana:
 *           type: string
 *           enum:
 *             - SEGUNDA
 *             - TERCA
 *             - QUARTA
 *             - QUINTA
 *             - SEXTA
 *             - SABADO
 *             - DOMINGO
 *           example: SEGUNDA
 *         hora_inicio:
 *           type: integer
 *           description: Horário no formato HHMM
 *           example: 1800
 *         hora_fim:
 *           type: integer
 *           description: Horário no formato HHMM
 *           example: 2200
 *         ativo:
 *           type: boolean
 *           example: true
 */

/**
 * @swagger
 * /disponibilidades:
 *   post:
 *     summary: Cria uma nova disponibilidade
 *     tags: [Disponibilidades]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - dia_semana
 *               - hora_inicio
 *               - hora_fim
 *               - quadra_id
 *             properties:
 *               dia_semana:
 *                 type: string
 *                 enum:
 *                   - SEGUNDA
 *                   - TERCA
 *                   - QUARTA
 *                   - QUINTA
 *                   - SEXTA
 *                   - SABADO
 *                   - DOMINGO
 *                 example: SEGUNDA
 *               hora_inicio:
 *                 type: integer
 *                 description: Horário no formato HHMM
 *                 example: 1800
 *               hora_fim:
 *                 type: integer
 *                 description: Horário no formato HHMM
 *                 example: 2200
 *               quadra_id:
 *                 type: integer
 *                 example: 1
 *     responses:
 *       201:
 *         description: Disponibilidade criada com sucesso
 *       400:
 *         description: Dados inválidos ou horário final menor que o inicial
 *       404:
 *         description: Quadra não encontrada
 *       409:
 *         description: Já existe disponibilidade nesse intervalo
 */
router.post(
  "/",
  autenticacaoMiddleware,
  cargoMiddleware(1),
  createDisponibilidade
);

/**
 * @swagger
 * /disponibilidades:
 *   get:
 *     summary: Lista todas as disponibilidades
 *     tags: [Disponibilidades]
 *     responses:
 *       200:
 *         description: Lista de disponibilidades retornada com sucesso
 */
router.get("/", getDisponibilidades);

/**
 * @swagger
 * /disponibilidades/quadra/{quadra_id}:
 *   get:
 *     summary: Lista disponibilidades de uma quadra ordenadas por dia e horário
 *     tags: [Disponibilidades]
 *     parameters:
 *       - in: path
 *         name: quadra_id
 *         required: true
 *         schema:
 *           type: integer
 *         example: 1
 *     responses:
 *       200:
 *         description: Disponibilidades da quadra
 *       404:
 *         description: Quadra não encontrada
 */
router.get(
  "/quadra/:quadra_id",
  autenticacaoMiddleware,
  cargoMiddleware(1),
  getDisponibilidadesPorQuadra
);

/**
 * @swagger
 * /disponibilidades/{id}:
 *   get:
 *     summary: Retorna uma disponibilidade pelo ID
 *     tags: [Disponibilidades]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         example: 1
 *     responses:
 *       200:
 *         description: Disponibilidade encontrada
 *       404:
 *         description: Disponibilidade não encontrada
 */
router.get("/:id", getDisponibilidade);

/**
 * @swagger
 * /disponibilidades/{id}:
 *   put:
 *     summary: Atualiza uma disponibilidade
 *     tags: [Disponibilidades]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         example: 1
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               dia_semana:
 *                 type: string
 *                 enum:
 *                   - SEGUNDA
 *                   - TERCA
 *                   - QUARTA
 *                   - QUINTA
 *                   - SEXTA
 *                   - SABADO
 *                   - DOMINGO
 *                 example: TERCA
 *               hora_inicio:
 *                 type: integer
 *                 description: Horário no formato HHMM
 *                 example: 1400
 *               hora_fim:
 *                 type: integer
 *                 description: Horário no formato HHMM
 *                 example: 1800
 *               quadra_id:
 *                 type: integer
 *                 example: 1
 *     responses:
 *       200:
 *         description: Disponibilidade atualizada com sucesso
 *       400:
 *         description: Horário inválido
 *       404:
 *         description: Disponibilidade ou quadra não encontrada
 *       409:
 *         description: Já existe disponibilidade nesse intervalo
 */
router.put(
  "/:id",
  autenticacaoMiddleware,
  cargoMiddleware(1),
  updateDisponibilidade
);

/**
 * @swagger
 * /disponibilidades/{id}:
 *   delete:
 *     summary: Remove uma disponibilidade
 *     tags: [Disponibilidades]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         example: 1
 *     responses:
 *       204:
 *         description: Disponibilidade removida com sucesso
 *       404:
 *         description: Disponibilidade não encontrada
 */
router.delete(
  "/:id",
  autenticacaoMiddleware,
  cargoMiddleware(1),
  deleteDisponibilidade
);

/**
 * @swagger
 * /disponibilidades/{id}/desativar:
 *   patch:
 *     summary: Desativa uma disponibilidade
 *     tags: [Disponibilidades]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         example: 1
 *     responses:
 *       200:
 *         description: Disponibilidade desativada com sucesso
 *       400:
 *         description: Disponibilidade já está desativada
 *       404:
 *         description: Disponibilidade não encontrada
 */
router.patch(
  "/:id/desativar",
  autenticacaoMiddleware,
  cargoMiddleware(1),
  desativarDisponibilidade
);

/**
 * @swagger
 * /disponibilidades/{id}/ativar:
 *   patch:
 *     summary: Ativa uma disponibilidade
 *     tags: [Disponibilidades]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         example: 1
 *     responses:
 *       200:
 *         description: Disponibilidade ativada com sucesso
 *       400:
 *         description: Disponibilidade já está ativa
 *       404:
 *         description: Disponibilidade não encontrada
 */
router.patch(
  "/:id/ativar",
  autenticacaoMiddleware,
  cargoMiddleware(1),
  ativarDisponibilidade
);

export default router;