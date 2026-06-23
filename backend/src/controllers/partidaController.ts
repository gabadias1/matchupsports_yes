import { Request, Response } from "express";
import { prisma } from "../config/prisma";

export const createPartida = async (req: Request, res: Response) => {
    const { vagas, tipo, reserva_id } = req.body;
    const criador_id = req.user?.id;

    try {
        const reserva = await prisma.reserva.findUniqueOrThrow({
            where: { id: reserva_id },
        });

        if (reserva.status !== "CONFIRMADA") {
            return res.status(400).json({
                message: "A reserva deve estar confirmada para criar uma partida.",
            });
        }

        const partidaExistente = await prisma.partida.findFirst({
            where: { reserva_id: reserva.id },
        });
        
        if (partidaExistente) {
            return res.status(400).json({
                message: "Já existe uma partida para esta reserva.",
            });
        }

        const partida = await prisma.$transaction(async (tx) => {
            const novaPartida = await tx.partida.create({
                data: {
                vagas,
                tipo,
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
                where: { id: Number(partidaId) }, include: { reserva: true },
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
            const chat = await prisma.chatReserva.findUnique({
                where:{
                    reserva_id: partida.reserva_id
                }
            });

            await prisma.chatParticipante.create({
                data:{
                    chat_id:chat.id,
                    usuario_id:req.user.id
                }
            });
            return res.status(200).json({
            message: "Entrou na partida com sucesso.",
            });
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
        await prisma.$transaction(async (tx) => {
            await tx.usuariosPartida.delete({
                where: { 
                    usuario_id_partida_id: { // <-- Corrigido para snake_case
                        usuario_id: Number(userId), 
                        partida_id: Number(partidaId) 
                    } 
                },
            });
            await tx.partida.update({
                where: { id: Number(partidaId) },
                data: { quantidade_atual: { decrement: 1 } },
            });
            const partida = await tx.partida.findUnique({
                where: {
                    id: Number(partidaId)
                }
            });
            const chat = await tx.chatReserva.findUnique({
                where:{
                    reserva_id: partida.reserva_id
                }
            });
            await tx.chatParticipante.delete({
                where:{
                    chat_id_usuario_id: {
                        chat_id:chat.id,
                        usuario_id:req.user.id
                    }
                }
            });
        })
        return res.status(200).json({ message: "Saiu da partida com sucesso." });
    } catch (error) {
        // Coloquei um console.log aqui pra caso dê erro no futuro, você ver o motivo no terminal do Node
        console.error("Erro no sairPartida:", error); 
        return res.status(400).json({
            message: "Erro ao sair da partida. Verifique os dados e tente novamente.",
        });
    }
};

export const getPartidasAbertas = async (req: Request, res: Response) => {
    try {
        const partidas = await prisma.partida.findMany({
            where: { tipo: "ABERTA" },
        });
        return res.status(200).json(partidas);
    } catch (error) {
        return res.status(400).json({
            message: "Erro ao buscar partidas. Tente novamente mais tarde.",
        });
    }
};

export const getMatchesDisponiveis = async (req: Request, res: Response) => {
    try {
        const partidas = await prisma.partida.findMany({
            where: {
                tipo: "ABERTA",
            },
            include: {
                criador: true,
                reserva: {
                    include: {
                        quadra: {
                            include: {
                                estabelecimento: true,
                            },
                        },
                    },
                },
                usuariosPartida: {
                    include: {
                        usuario: true,
                    },
                },
            },
            orderBy: {
                created_at: "desc",
            },
        });
        return res.status(200).json(partidas);
    } catch (error) {
        return res.status(400).json({
            message: "Erro ao buscar partidas disponíveis. Tente novamente mais tarde.",
        });
    }
};

export const alterarTipoPartida = async (req: Request, res: Response) => {
    const { partidaId } = req.params;
    const { tipo } = req.body;
    try {
        const partidaAtualizada = await prisma.partida.update({
            where: { id: Number(partidaId) },
            data: { tipo },
        });
        return res.status(200).json(partidaAtualizada);
    } catch (error) {
        return res.status(400).json({
            message: "Erro ao atualizar tipo da partida. Tente novamente mais tarde.",
        });
    }
};

export const getMinhasPartidas = async (req: Request, res: Response) => {
    const userId = req.user?.id;
    try {
        const partidas = await prisma.partida.findMany({
        where: {
            OR: [
            {
                criador_id: userId,
            },
            {
                usuariosPartida: {
                some: {
                    usuario_id: userId,
                },
                },
            },
            ],
        },
        include: {
            criador: true,
            reserva: {
            include: {
                quadra: {
                include: {
                    estabelecimento: true,
                },
                },
            },
            },
            usuariosPartida: {
            include: {
                usuario: true,
            },
            },
        },
        orderBy: {
            created_at: "desc",
        },
        });
        return res.status(200).json(partidas);
    } catch (error) {
        return res.status(400).json({
            message: "Erro ao buscar suas partidas. Tente novamente mais tarde.",
        });
    }
};

export const removerJogadorPartida = async (req: Request, res: Response) => { 
    const { partidaId, usuarioId } = req.params;
    try {
        const donoPartida = await prisma.partida.findUniqueOrThrow({
            where: { id: Number(partidaId) },
            select: { criador_id: true },
        });

        if (donoPartida.criador_id !== req.user?.id) {
            return res.status(403).json({
                message: "Apenas o criador da partida pode remover jogadores.",
            });
        }  
    } catch (error) {
        return res.status(400).json({
            message: "Partida não encontrada.",
        });
    }
    try {
        await prisma.$transaction(async (tx) => {
            await tx.usuariosPartida.delete({
                where: {
                    usuario_id_partida_id: {
                        usuario_id: Number(usuarioId),
                        partida_id: Number(partidaId),
                    },
                },
            });
            await tx.partida.update({
                where: { id: Number(partidaId) },
                data: { quantidade_atual: { decrement: 1 } },
            });
        });
        return res.status(200).json({ message: "Jogador removido da partida com sucesso." });
    } catch (error) {
        return res.status(400).json({
            message: "Erro ao remover jogador da partida. Verifique os dados e tente novamente.",
        });
    }
};

export const cancelarPartida = async (req: Request, res: Response) => {
    const { partidaId } = req.params;
    try {
        const donoPartida = await prisma.partida.findUniqueOrThrow({
            where: { id: Number(partidaId) },
            select: { criador_id: true },
        });

        if (donoPartida.criador_id !== req.user?.id) {
            return res.status(403).json({
                message: "Apenas o criador da partida pode cancelar.",
            });
        }  
    } catch (error) {
        return res.status(400).json({
            message: "Partida não encontrada.",
        });
    }
    try {
        await prisma.$transaction(async (tx) => {
            await tx.usuariosPartida.deleteMany({
                where: {
                    partida_id: Number(partidaId),
                },
            });

            await tx.convitePartida.deleteMany({
                where: {
                    partida_id: Number(partidaId),
                },
            });

            await tx.partida.delete({
                where: {
                    id: Number(partidaId),
                },
            });
        });
        return res.status(200).json({ message: "Partida cancelada com sucesso." });
    } catch (error) {
        console.error("Erro no cancelarPartida:", error);
        return res.status(400).json({
            message: "Erro ao cancelar partida. Verifique os dados e tente novamente.",
        });
    }
};