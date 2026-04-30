import { Router } from "express";
import { updateUsuario, deleteUsuario, getUsuario, getUsuarios } from "../controllers/usuarioController";

const router = Router();

// post /usuarios foi para autenticacaoRoutes.ts

/**
 * @swagger
 * /usuarios/{id}:
 *   get:
 *     summary: Retorna um usuário pelo ID
 *     tags: [Usuarios]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         description: ID do usuário
 *         schema:
 *           type: integer
 *           example: 1
 *     responses:
 *       200:
 *         description: Usuário encontrado
 *       404:
 *         description: Usuário não encontrado
 *       500:
 *         description: Erro interno
 */
router.get("/:id", getUsuario);

/**
 * @swagger
 * /usuarios:
 *   get:
 *     summary: Lista todos os usuários
 *     tags: [Usuarios]
 *     responses:
 *       200:
 *         description: Lista de usuários retornada com sucesso
 *       500:
 *         description: Erro interno
 */
router.get("/", getUsuarios);

/**
 * @swagger
 * /usuarios/{id}:
 *   put:
 *     summary: Atualiza um usuário pelo ID
 *     tags: [Usuarios]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         description: ID do usuário
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
 *               nome:
 *                 type: string
 *                 example: João Silva
 *               email:
 *                 type: string
 *                 example: joao@email.com
 *               celular:
 *                 type: string
 *                 example: 11999999999
 *               senha:
 *                  type: string
 *                  example: senha123
 *               tipo:
 *                  type: integer
 *                  example: 0
 *     responses:
 *       200:
 *         description: Usuário atualizado com sucesso
 *       400:
 *         description: E-mail em uso por outro usuário
 *       404:
 *         description: Usuário não encontrado
 *       500:
 *         description: Erro interno
 */
router.put("/:id", updateUsuario);

/**
 * @swagger
 * /usuarios/{id}:
 *   delete:
 *     summary: Deleta um usuário pelo ID
 *     tags: [Usuarios]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         description: ID do usuário
 *         schema:
 *           type: integer
 *           example: 1
 *     responses:
 *       204:
 *         description: Usuário deletado com sucesso
 *       404:
 *         description: Usuário não encontrado
 *       500:
 *         description: Erro interno
 */
router.delete("/:id", deleteUsuario);

export default router;