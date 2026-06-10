import { Request, Response } from "express";
import { prisma } from "../config/prisma";
import crypto from "crypto";

export const criarConvite = async (req: Request, res: Response) => {
    const { partida_id } = req.body;
    const token =  crypto.randomBytes(32).toString("hex");

    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 7);
    try {
        const convite = await prisma.convitePartida.create({
            data: {
                partida: {
                    connect: {
                        id: Number(partida_id),
                    },
                },
                token: token,
                expiresAt: expiresAt,
                criador: {
                    connect: {
                        id: Number(req.user.id),
                    },
                },
            },
        });
        return res.status(201).json(token);
    } catch (error) {
        return res.status(400).json({
            message: "Erro ao criar convite. Verifique os dados e tente novamente.",
        });
    }
};

export const aceitarConvite = async (req: Request, res: Response) => {
    const { token } = req.params;
    try {
        const convite = await prisma.convitePartida.findUniqueOrThrow({
            where: { token },
        });
        if (convite.expiresAt < new Date()) {
            return res.status(400).json({ message: "Convite expirado." });
        }
        if (convite.usado) {
            return res.status(400).json({ message: "Convite já utilizado." });
        }
        try {
            const partida = await prisma.partida.findUniqueOrThrow({
                where: { id: convite.partida_id },
            });
            if (partida.quantidade_atual >= partida.vagas) {
                return res.status(400).json({ message: "Partida cheia. Não é possível aceitar o convite." });
            }
            await prisma.usuariosPartida.create({
                data: {
                    usuario: {
                        connect: {
                            id: Number(req.user.id),
                        },
                    },
                    partida: {
                        connect: {
                            id: convite.partida_id,
                        },
                    },
                },
            });
            await prisma.partida.update({
                where: { id: convite.partida_id },
                data: { quantidade_atual: { increment: 1 } },
            });
            await prisma.convitePartida.update({
                where: { id: convite.id },
                data: { usado: true },
            });
            return res.status(200).json({ message: "Convite aceito com sucesso." });
        } catch (error) {
            return res.status(400).json({ message: "Partida não encontrada." });
        }
    } catch (error) {
        return res.status(400).json({
            message: "Erro ao aceitar convite. Verifique o token e tente novamente.",
        });
    }
};