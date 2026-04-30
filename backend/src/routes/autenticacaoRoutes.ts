import { Router } from "express";
import * as autenticacaoController from "../controllers/autenticacaoController";

const router = Router();

/**
 * @swagger
 * tags:
 *   name: Autenticacao
 *   description: Autenticação de usuários
 */

/**
 * @swagger
 * /autenticacao/cadastrar:
 *   post:
 *     summary: Registrar novo usuário
 *     tags: [Autenticacao]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - nome
 *               - email
 *               - senha
 *               - tipo
 *             properties:
 *               nome:
 *                 type: string
 *                 example: João Silva
 *               email:
 *                 type: string
 *                 example: joao@email.com
 *               celular:
 *                 type: string
 *                 example: 11987654321
 *               senha:
 *                 type: string
 *                 example: 123456
 *               tipo:
 *                 type: integer
 *                 example: 1
 *     responses:
 *       201:
 *         description: Usuário criado com sucesso
 *       400:
 *         description: Usuário já existe ou erro de validação
 */
router.post("/cadastrar", autenticacaoController.cadastrar);

/**
 * @swagger
 * /autenticacao/login:
 *   post:
 *     summary: Login do usuário
 *     tags: [Autenticacao]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *               - senha
 *             properties:
 *               email:
 *                 type: string
 *                 example: joao@email.com
 *               senha:
 *                 type: string
 *                 example: 123456
 *     responses:
 *       200:
 *         description: Login realizado com sucesso
 *       401:
 *         description: Credenciais inválidas
 */
router.post("/login", autenticacaoController.login);

export default router;