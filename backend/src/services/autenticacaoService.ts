import { prisma } from "../config/prisma";
import { Request } from "express";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";

export const cadastrar = async (req: Request) => {
  const { nome, email, celular, senha, tipo } = req.body;

  // 1. Verifica de verdade se o e-mail já existe no banco
  const usuarioExistente = await prisma.usuario.findUnique({
    where: { email },
  });

  if (usuarioExistente) {
    throw new Error("E-mail já está em uso.");
  }

  const hashedSenha = await bcrypt.hash(String(senha), 10);
  
  try {
    // 2. Como sabemos que o e-mail está livre, tentamos criar
    const usuario = await prisma.usuario.create({
      data: { nome, email, celular, senha: hashedSenha, tipo }
    });
    return usuario;
  } catch (error) {
    // 3. Se o Prisma estourar erro agora, é por outro motivo! (ex: tamanho do texto, campo obrigatório faltando)
    console.error("🚨 ERRO REAL DO PRISMA AO CRIAR CONTA:", error);
    throw new Error("Erro interno ao criar conta. Olhe o terminal do backend para ver o motivo exato.");
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
  
  return { usuario, token };
}