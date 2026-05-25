import { Request, Response } from "express";
import { prisma } from "../config/prisma";

export const createPartida = async (req: Request, res: Response) => {
    const { vagas, status, reserva_id } = req.body;
    const criador_id = req.user?.id;

    try {
        const reserva = await prisma.reserva.findUniqueOrThrow({
        where: { id: reserva_id },
        });

        const partida = await prisma.$transaction(async (tx) => {
            const novaPartida = await tx.partida.create({
                data: {
                vagas,
                status,
                reserva_id: reserva.id,
                criador_id: Number(criador_id),
                quantidade_atual: 1,
                },
            });

            await tx.usuariosPartida.create({
                data: {
                usuario_id: Number(criador_id),
                partida_id: novaPartida.id,
                },
            });

            return novaPartida;
        });

        return res.status(201).json(partida);
    } catch (error) {
        return res.status(400).json({
        message: "Erro ao criar partida.",
        });
    }
};

export const entrarPartida = async (req: Request, res: Response) => {
    const { partidaId } = req.params;
    const userId = req.user?.id;

    try {
        await prisma.$transaction(async (tx) => {
        const partida = await tx.partida.findUniqueOrThrow({
            where: { id: Number(partidaId) },
        });

        if (partida.quantidade_atual >= partida.vagas) {
            throw new Error("PARTIDA_CHEIA");
        }

        const usuarioJaEntrou = await tx.usuariosPartida.findUnique({
            where: {
            usuario_id_partida_id: {
                usuario_id: Number(userId),
                partida_id: Number(partidaId),
            },
            },
        });

        if (usuarioJaEntrou) {
            throw new Error("USUARIO_JA_ENTROU");
        }

        await tx.usuariosPartida.create({
            data: {
            usuario_id: Number(userId),
            partida_id: Number(partidaId),
            },
        });

        await tx.partida.update({
            where: { id: Number(partidaId) },
            data: {
            quantidade_atual: {
                increment: 1,
            },
            },
        });
        });

        return res.status(200).json({
        message: "Entrou na partida com sucesso.",
        });
    } catch (error: any) {
        if (error.message === "PARTIDA_CHEIA") {
        return res.status(400).json({
            message: "Partida cheia.",
        });
        }

        if (error.message === "USUARIO_JA_ENTROU") {
        return res.status(400).json({
            message: "Usuário já está na partida.",
        });
        }

        return res.status(400).json({
        message: "Erro ao entrar na partida.",
        });
    }
};

export const sairPartida = async (req: Request, res: Response) => {
    const { partidaId } = req.params;
    const userId = req.user?.id;
    try {
        await prisma.usuariosPartida.delete({
            where: { usuarioId_partidaId: { usuarioId: Number(userId), partidaId: Number(partidaId) } },
        });
        await prisma.partida.update({
            where: { id: Number(partidaId) },
            data: { quantidade_atual: { decrement: 1 } },
        });
        return res.status(200).json({ message: "Saiu da partida com sucesso." });
    } catch (error) {
        return res.status(400).json({
            message: "Erro ao sair da partida. Verifique os dados e tente novamente.",
        });
    }
};

export const getPartidasAbertas = async (req: Request, res: Response) => {
    try {
        const partidas = await prisma.partida.findMany({
            where: { status: "aberta" },
        });
        return res.status(200).json(partidas);
    } catch (error) {
        return res.status(400).json({
            message: "Erro ao buscar partidas. Tente novamente mais tarde.",
        });
    }
};

export const getMinhasPartidas = async (req: Request, res: Response) => {
    const userId = req.user?.id;
    try {
        const partidas = await prisma.partida.findMany({
            where: {
                usuariosPartida: {
                    some: {
                        usuarioId: Number(userId),
                    },
                },
            },
        });
        return res.status(200).json(partidas);
    } catch (error) {
        return res.status(400).json({
            message: "Erro ao buscar suas partidas. Tente novamente mais tarde.",
        });
    }
};