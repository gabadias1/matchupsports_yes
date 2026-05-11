import { Router } from "express";
import {
  createDisponibilidade,
  getDisponibilidades,
  getDisponibilidadesPorQuadra,
  getDisponibilidade,
  updateDisponibilidade,
  deleteDisponibilidade,
} from "../controllers/disponibilidadeController";
import { autenticacaoMiddleware } from "../middleware/autenticacaoMiddleware";
import { cargoMiddleware } from "../middleware/cargoMiddleware";

const router = Router();

/**
 * @swagger
 * tags:
 *   name: Disponibilidades
 *   description: Gerenciamento de disponibilidades das quadras
 */

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
 *           example: 1800
 *         hora_fim:
 *           type: integer
 *           example: 2200
 *         quadra_id:
 *           type: integer
 *           example: 1
 *
 *     DisponibilidadeInput:
 *       type: object
 *       required:
 *         - dia_semana
 *         - hora_inicio
 *         - hora_fim
 *         - quadra_id
 *       properties:
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
 *         hora_inicio:
 *           type: integer
 *           example: 1800
 *         hora_fim:
 *           type: integer
 *           example: 2200
 *         quadra_id:
 *           type: integer
 *           example: 1
 */

/**
 * @swagger
 * /disponibilidades:
 *   post:
 *     summary: Cria uma disponibilidade
 *     tags: [Disponibilidades]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/DisponibilidadeInput'
 *     responses:
 *       201:
 *         description: Disponibilidade criada com sucesso
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Disponibilidade'
 *       404:
 *         description: Quadra não encontrada
 */
router.post("/", autenticacaoMiddleware, cargoMiddleware(1), createDisponibilidade);

/**
 * @swagger
 * /disponibilidades:
 *   get:
 *     summary: Lista todas as disponibilidades
 *     tags: [Disponibilidades]
 *     responses:
 *       200:
 *         description: Lista de disponibilidades
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Disponibilidade'
 */
router.get("/", autenticacaoMiddleware, getDisponibilidades);

/**
 * @swagger
 * /disponibilidades/quadra/{quadra_id}:
 *   get:
 *     summary: Lista disponibilidades de uma quadra
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
 *         description: Lista de disponibilidades da quadra
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Disponibilidade'
 *       404:
 *         description: Quadra não encontrada
 */
router.get("/quadra/:quadra_id", autenticacaoMiddleware, getDisponibilidadesPorQuadra);

/**
 * @swagger
 * /disponibilidades/{id}:
 *   get:
 *     summary: Busca uma disponibilidade por ID
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
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Disponibilidade'
 *       404:
 *         description: Disponibilidade não encontrada
 */
router.get("/:id", autenticacaoMiddleware, getDisponibilidade);

/**
 * @swagger
 * /disponibilidades/{id}:
 *   put:
 *     summary: Atualiza uma disponibilidade
 *     tags: [Disponibilidades]
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
 *             $ref: '#/components/schemas/DisponibilidadeInput'
 *     responses:
 *       200:
 *         description: Disponibilidade atualizada
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Disponibilidade'
 *       404:
 *         description: Disponibilidade ou quadra não encontrada
 */
router.put("/:id", autenticacaoMiddleware, cargoMiddleware(1), updateDisponibilidade);

/**
 * @swagger
 * /disponibilidades/{id}:
 *   delete:
 *     summary: Remove uma disponibilidade
 *     tags: [Disponibilidades]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         example: 1
 *     responses:
 *       204:
 *         description: Disponibilidade removida
 *       404:
 *         description: Disponibilidade não encontrada
 */
router.delete("/:id", autenticacaoMiddleware, cargoMiddleware(1), deleteDisponibilidade);

export default router;