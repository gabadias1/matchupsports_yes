import { prisma } from "../config/prisma";
import { Request, Response } from "express";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";

export const cadastrar = async (req: Request) => {
  const { nome, email, celular, senha, tipo } = req.body;
  const hashedSenha = await bcrypt.hash(String(senha), 10);
  try {
    const usuario = await prisma.usuario.create({
      data: { nome, email, celular, senha: hashedSenha, tipo }
    });
    return usuario;
  } catch {
    throw new Error("E-mail já está em uso.");
  }
};

export async function login(email: string, senha: string) {
  const usuario = await prisma.usuario.findUnique({
    where: { email },
  });

  if (!usuario) {
    throw new Error("Usuário não encontrado. Tente novamente.");
  }

  const passwordMatch = await bcrypt.compare(senha, usuario.senha);

  if (!passwordMatch) {
    throw new Error("Senha incorreta. Tente novamente.");
  }

  const token = jwt.sign(
    {
      id: usuario.id,
      email: usuario.email,
      tipo: usuario.tipo,
    },
    process.env.JWT_SECRET as string,
    {
      expiresIn: "7d",
    }
  );
  return { usuario, token, };
}