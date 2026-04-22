import { Router } from "express";
import { createEstabelecimento, deleteEstabelecimento, getEstabelecimento, getEstabelecimentos, updateEstabelecimento } from "../controllers/estabelecimentoController";

const router = Router();

/**
 * @swagger
 * /estabelecimentos:
 *   post:
 *     summary: Cria um novo estabelecimento
 *     tags: [Estabelecimentos]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - nome_local
 *               - endereco
 *               - proprietario_id
 *             properties:
 *               nome_local:
 *                 type: string
 *                 example: Arena Futebol
 *               endereco:
 *                 type: string
 *                 example: Rua B, 456
 *               proprietario_id:
 *                 type: integer
 *                 example: 1
 *     responses:
 *       201:
 *         description: Estabelecimento criado com sucesso
 *       404:
 *         description: Usuário não encontrado
 */
router.post("/", createEstabelecimento);

/**
 * @swagger
 * /estabelecimentos:
 *   get:
 *     summary: Retorna todos os estabelecimentos
 *     tags: [Estabelecimentos]
 *     responses:
 *       200:
 *         description: Lista de estabelecimentos retornada com sucesso
 */
router.get("/", getEstabelecimentos);

/**
 * @swagger
 * /estabelecimentos/{id}:
 *   get:
 *     summary: Retorna um estabelecimento pelo ID
 *     tags: [Estabelecimentos]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         description: ID do estabelecimento
 *         schema:
 *           type: integer
 *           example: 1
 *     responses:
 *       200:
 *         description: Estabelecimento encontrado
 *       404:
 *         description: Estabelecimento não encontrado
 */
router.get("/:id", getEstabelecimento);

/**
 * @swagger
 * /estabelecimentos/{id}:
 *   put:
 *     summary: Atualiza um estabelecimento
 *     tags: [Estabelecimentos]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         description: ID do estabelecimento
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
 *               nome_local:
 *                 type: string
 *                 example: Arena Atualizada
 *               endereco:
 *                 type: string
 *                 example: Rua C, 789
 *               proprietario_id:
 *                 type: integer
 *                 example: 2
 *     responses:
 *       200:
 *         description: Estabelecimento atualizado com sucesso
 *       404:
 *         description: Estabelecimento ou usuário não encontrado
 */
router.put("/:id", updateEstabelecimento);

/**
 * @swagger
 * /estabelecimentos/{id}:
 *   delete:
 *     summary: Deleta um estabelecimento
 *     tags: [Estabelecimentos]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         description: ID do estabelecimento
 *         schema:
 *           type: integer
 *           example: 1
 *     responses:
 *       204:
 *         description: Estabelecimento deletado com sucesso
 *       404:
 *         description: Estabelecimento não encontrado
 */
router.delete("/:id", deleteEstabelecimento);

export default router;
