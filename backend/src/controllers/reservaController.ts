import { Request, Response } from "express";
import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

// GET /reservas/me
export const getMinhasReservas = async (req: Request, res: Response) => {
  try {
    const usuario_id = (req as any).user?.id;

    if (!usuario_id) {
      return res.status(401).json({ erro: "Usuário não autenticado" });
    }

    const reservas = await prisma.reserva.findMany({
      where: { usuario_id },
      include: {
        quadra: {
          select: {
            id: true,
            identificacao: true,
            esporte: true,
            valor_hora: true,
            estabelecimento: {
              select: {
                nome_local: true,
                endereco: true,
              },
            },
          },
        },
      },
      orderBy: { data: "desc" },
    });

    return res.status(200).json(reservas);
  } catch (error) {
    console.error(error);
    return res.status(500).json({ erro: "Erro interno do servidor" });
  }
};

// DELETE /reservas/:id
export const cancelarReserva = async (req: Request, res: Response) => {
  try {
    const usuario_id = (req as any).user?.id;
    const id = parseInt(req.params.id);

    if (!usuario_id) {
      return res.status(401).json({ erro: "Usuário não autenticado" });
    }

    if (isNaN(id)) {
      return res.status(400).json({ erro: "ID inválido" });
    }

    const reserva = await prisma.reserva.findUnique({ where: { id } });

    if (!reserva) {
      return res.status(404).json({ erro: "Reserva não encontrada" });
    }

    if (reserva.usuario_id !== usuario_id) {
      return res
        .status(403)
        .json({ erro: "Sem permissão para cancelar esta reserva" });
    }

    if (reserva.status === "CANCELADA") {
      return res.status(400).json({ erro: "Reserva já está cancelada" });
    }

    const reservaAtualizada = await prisma.reserva.update({
      where: { id },
      data: { status: "CANCELADA" },
    });

    return res.status(200).json(reservaAtualizada);
  } catch (error) {
    console.error(error);
    return res.status(500).json({ erro: "Erro interno do servidor" });
  }
};