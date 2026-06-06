import { Request, Response } from "express";
import bcrypt from "bcryptjs";
import { prisma } from "../config/prisma";

// Configuração estendida para incluir os relacionamentos que o Flutter precisa carregar no perfil
const usuarioIncludeConfig = {
  include: {
    estabelecimentos: {
      include: {
        quadras: true,
      },
    },
    reservas: {
      include: {
        quadra: {
          include: {
            estabelecimento: true,
          },
        },
      },
    },
  },
};

// GET /usuarios/me - Retorna os dados do usuário logado (Injetado via Token no Middleware)
export const getMe = async (req: Request, res: Response) => {
  try {
    // O autenticacaoMiddleware injeta o id do usuário logado dentro de req.user.id
    const userId = (req as any).user?.id;

    if (!userId) {
      return res.status(401).json({ message: "Usuário não autenticado" });
    }

    const usuario = await prisma.usuario.findUnique({
      where: { id: Number(userId) },
      ...usuarioIncludeConfig, // Traz estabelecimentos, quadras e reservas juntos
    });

    if (!usuario) {
      return res.status(404).json({ message: "Usuário não encontrado" });
    }

    return res.json(usuario);
  } catch (error) {
    return res.status(500).json({ message: "Erro interno ao buscar perfil" });
  }
};

export const updateUsuario = async (req: Request, res: Response) => {
  const { nome, email, celular, senha, tipo } = req.body;

  try {
    await prisma.usuario.findUniqueOrThrow({
      where: { id: Number(req.params.id) }
    });
  } catch {
    return res.status(404).json({ message: "Usuário não encontrado" });
  }
  
  const hashedSenha = await bcrypt.hash(senha, 10);
  try {
    const usuario = await prisma.usuario.update({
      where: { id: Number(req.params.id) },
      data: { nome, email, celular, senha: hashedSenha, tipo }
    });
    return res.json(usuario);
  } catch {
    return res.status(400).json({ message: "E-mail em uso por outro usuário" });
  }
};

export const deleteUsuario = async (req: Request, res: Response) => {
  try {
    await prisma.usuario.delete({
      where: { id: Number(req.params.id) }
    });

    return res.status(204).send();
  } catch {
    return res.status(404).json({ message: "Usuário não encontrado" });
  }
};

export const getUsuario = async (req: Request, res: Response) => {
  const usuario = await prisma.usuario.findUnique({
    where: { id: Number(req.params.id) },
    ...usuarioIncludeConfig, // Atualizado para incluir as relações também por ID comum se precisar
  });
  
  if (!usuario) {
    return res.status(404).json({ message: "Usuário não encontrado" });
  }

  return res.json(usuario);
};

export const getUsuarios = async (req: Request, res: Response) => {
  const usuarios = await prisma.usuario.findMany();
  return res.json(usuarios);
};