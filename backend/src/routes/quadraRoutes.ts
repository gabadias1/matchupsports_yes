import { Router } from "express";
import { createQuadra, deleteQuadra, getQuadra, getQuadras, updateQuadra } from "../controllers/quadraController";

const router = Router();

/**
 * @swagger
 * /quadras:
 *   post:
 *     summary: Cria uma nova quadra
 *     tags: [Quadras]
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
 *             properties:
 *               identificacao:
 *                 type: string
 *                 example: Quadra 1
 *               descricao:
 *                 type: string
 *                 example: Quadra de futebol society
 *               estabelecimento_id:
 *                 type: integer
 *                 example: 1
 *     responses:
 *       200:
 *         description: Quadra criada com sucesso
 *       404:
 *         description: Estabelecimento não encontrado
 */
router.post("/", createQuadra);

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
 *                 example: Quadra 2
 *               descricao:
 *                 type: string
 *                 example: Quadra reformada
 *               estabelecimento_id:
 *                 type: integer
 *                 example: 2
 *     responses:
 *       200:
 *         description: Quadra atualizada com sucesso
 *       404:
 *         description: Quadra ou estabelecimento não encontrado
 */
router.put("/:id", updateQuadra);

/**
 * @swagger
 * /quadras/{id}:
 *   delete:
 *     summary: Deleta uma quadra
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
 *       204:
 *         description: Quadra deletada com sucesso
 *       404:
 *         description: Quadra não encontrada
 */
router.delete("/:id", deleteQuadra);

export default router;