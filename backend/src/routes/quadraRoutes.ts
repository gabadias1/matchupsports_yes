import { Router } from "express";

import { autenticacaoMiddleware } from "../middleware/autenticacaoMiddleware";
import { cargoMiddleware } from "../middleware/cargoMiddleware";
import { createQuadra, deleteQuadra, getQuadra, getQuadras, getQuadrasByDono, getQuadrasByEstabelecimento, updateQuadra } from "../controllers/quadraController";

const router = Router();

/**
 * @swagger
 * components:
 *   schemas:
 *     Quadra:
 *       type: object
 *       properties:
 *         id:
 *           type: integer
 *           example: 1
 *         identificacao:
 *           type: string
 *           example: Quadra Society 1
 *         descricao:
 *           type: string
 *           example: Quadra coberta com grama sintética
 *         estabelecimento_id:
 *           type: integer
 *           example: 1
 *         dono_id:
 *           type: integer
 *           example: 2
 *         esporte:
 *           type: string
 *           enum:
 *             - Futebol
 *             - Vôlei
 *             - Basquete
 *             - Tênis
 *             - Futsal
 *           example: Futebol
 *         valor_hora:
 *           type: number
 *           example: 80
 */

/**
 * @swagger
 * /quadras:
 *   post:
 *     summary: Cria uma nova quadra
 *     tags: [Quadras]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - identificacao
 *               - descricao
 *               - estabelecimento_id
 *               - esporte
 *             properties:
 *               identificacao:
 *                 type: string
 *                 example: Quadra Society 1
 *               descricao:
 *                 type: string
 *                 example: Quadra coberta com grama sintética
 *               estabelecimento_id:
 *                 type: integer
 *                 example: 1
 *               esporte:
 *                 type: string
 *                 enum:
 *                   - Futebol
 *                   - Vôlei
 *                   - Basquete
 *                   - Tênis
 *                   - Futsal
 *                 example: Futebol
 *               valor_hora:
 *                 type: number
 *                 example: 80
 *     responses:
 *       201:
 *         description: Quadra criada com sucesso
 *       404:
 *         description: Estabelecimento não encontrado
 *       500:
 *         description: Erro interno ao criar quadra
 */
router.post(
  "/",
  autenticacaoMiddleware,
  cargoMiddleware(1),
  createQuadra
);

/**
 * @swagger
 * /quadras:
 *   get:
 *     summary: Retorna todas as quadras
 *     tags: [Quadras]
 *     responses:
 *       200:
 *         description: Lista de quadras retornada com sucesso
 */
router.get("/", getQuadras);

/**
 * @swagger
 * /quadras/estabelecimento/{estabelecimentoId}:
 *   get:
 *     summary: Lista todas as quadras de um estabelecimento
 *     tags: [Quadras]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: estabelecimentoId
 *         required: true
 *         schema:
 *           type: integer
 *         example: 1
 *     responses:
 *       200:
 *         description: Lista de quadras do estabelecimento
 *       404:
 *         description: Estabelecimento não encontrado
 */
router.get("/estabelecimento/:estabelecimentoId", 
            getQuadrasByEstabelecimento);

/**
 * @swagger
 * /quadras/minhas:
 *   get:
 *     summary: Lista as quadras do usuário autenticado
 *     tags: [Quadras]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Lista de quadras do dono autenticado
 *       401:
 *         description: Usuário não autenticado
 */
router.get("/minhas", 
  autenticacaoMiddleware,
  cargoMiddleware(1),
  getQuadrasByDono
);

/**
 * @swagger
 * /quadras/{id}:
 *   get:
 *     summary: Retorna uma quadra pelo ID
 *     tags: [Quadras]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         description: ID da quadra
 *         schema:
 *           type: integer
 *           example: 1
 *     responses:
 *       200:
 *         description: Quadra encontrada
 *       404:
 *         description: Quadra não encontrada
 */
router.get("/:id", getQuadra);

/**
 * @swagger
 * /quadras/{id}:
 *   put:
 *     summary: Atualiza uma quadra
 *     tags: [Quadras]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         description: ID da quadra
 *         schema:
 *           type: integer
 *           example: 1
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               identificacao:
 *                 type: string
 *                 example: Quadra Reformada
 *               descricao:
 *                 type: string
 *                 example: Quadra com iluminação LED
 *               estabelecimento_id:
 *                 type: integer
 *                 example: 2
 *               esporte:
 *                 type: string
 *                 enum:
 *                   - Futebol
 *                   - Vôlei
 *                   - Basquete
 *                   - Tênis
 *                   - Futsal
 *                 example: Futebol
 *               valor_hora:
 *                 type: number
 *                 example: 120
 *     responses:
 *       200:
 *         description: Quadra atualizada com sucesso
 *       404:
 *         description: Quadra ou estabelecimento não encontrado
 */
router.put("/:id", 
  autenticacaoMiddleware, 
  cargoMiddleware(1), 
  updateQuadra
);

/**
 * @swagger
 * /quadras/{id}:
 *   delete:
 *     summary: Deleta uma quadra
 *     tags: [Quadras]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         description: ID da quadra
 *         schema:
 *           type: integer
 *           example: 1
 *     responses:
 *       204:
 *         description: Quadra deletada com sucesso
 *       404:
 *         description: Quadra não encontrada
 */
router.delete("/:id", 
  autenticacaoMiddleware, 
  cargoMiddleware(1), 
  deleteQuadra
);

export default router;