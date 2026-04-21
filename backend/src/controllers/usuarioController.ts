import { Request, Response } from "express";
import { prisma } from "../config/prisma";

export const createUsuario = async (req: Request, res: Response) => {
  const { nome, email, senha, tipo } = req.body;

  const usuario = await prisma.usuario.create({
    data: { nome, email, senha, tipo }
  });

  res.json(usuario);
};

export const updateUsuario = async (req: Request, res: Response) => {
  const { nome, email, senha, tipo } = req.body;

  try {
    await prisma.usuario.findUniqueOrThrow({
      where: { id: Number(req.params.id) }
    });
  } catch {
    return res.status(404).json({ message: "Usuário não encontrado" });
  }
  
  const usuario = await prisma.usuario.update({
    where: { id: Number(req.params.id) },
    data: { nome, email, senha, tipo }
  });

  res.json(usuario);
};

export const deleteUsuario = async (req: Request, res: Response) => {

  try {
    const usuario = await prisma.usuario.delete({
      where: { id: Number(req.params.id) }
    });

    return res.status(204).send();
  } catch {
    return res.status(404).json({ message: "Usuário não encontrado" });
  }
};

export const getUsuario = async (req: Request, res: Response) => {
  const usuario = await prisma.usuario.findUnique({
    where: { id: Number(req.params.id) }
  });
  
  if (!usuario) {
    return res.status(404).json({ message: "Usuário não encontrado" });
  }

  res.json(usuario);
};

export const getUsuarios = async (req: Request, res: Response) => {
  const usuarios = await prisma.usuario.findMany();
  
  res.json(usuarios);
};