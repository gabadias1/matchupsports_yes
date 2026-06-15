import { Request, Response } from "express";
import { prisma } from "../config/prisma";

export const createPartida = async (req: Request, res: Response) => {
    const { vagas, tipo, reserva_id } = req.body;
    const criador_id = req.user?.id;

    // ── VALIDAÇÃO DE LIMITE ──────────────────────────────────────────────
    const vagasNum = Number(vagas);
    if (!Number.isInteger(vagasNum) || vagasNum < 1 || vagasNum > 100) {
        return res.status(400).json({
            message: "O número de vagas deve ser um inteiro entre 1 e 100.",
        });
    }

    try {
        const reserva = await prisma.reserva.findUniqueOrThrow({
            where: { id: Number(reserva_id) },
        });

        // Verifica se o criador da partida é dono da reserva (opcional, mas recomendado)
        if (reserva.usuario_id !== Number(criador_id)) {
            return res.status(403).json({
                message: "Você só pode criar partidas para suas próprias reservas.",
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
                    vagas: vagasNum,
                    tipo,
                    reserva_id: reserva.id,
                    criador_id: Number(criador_id),
                    quantidade_atual: 1, // Criador já entra automaticamente
                    status: vagasNum === 1 ? "LOTADA" : "ABERTA", // Se só tem 1 vaga, já lota
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
        console.error("Erro createPartida:", error);
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
            // Lock pessimista implícito via transação + findUniqueOrThrow
            const partida = await tx.partida.findUniqueOrThrow({
                where: { id: Number(partidaId) },
            });

            // ── VALIDAÇÃO DE LIMITE REFORÇADA ──────────────────────────────
            if (partida.quantidade_atual >= partida.vagas) {
                throw new Error("PARTIDA_CHEIA");
            }

            // Verifica se o usuário já está na partida
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

            // Cria o vínculo
            await tx.usuariosPartida.create({
                data: {
                    usuario_id: Number(userId),
                    partida_id: Number(partidaId),
                },
            });

            // Atualiza contador e status com verificação de segurança
            const novaQuantidade = partida.quantidade_atual + 1;
            const novoStatus = novaQuantidade >= partida.vagas ? "LOTADA" : "ABERTA";

            await tx.partida.update({
                where: { id: Number(partidaId) },
                data: {
                    quantidade_atual: novaQuantidade,
                    status: novoStatus,
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

        console.error("Erro entrarPartida:", error);
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
            const partida = await tx.partida.findUniqueOrThrow({
                where: { id: Number(partidaId) },
            });

            if (partida.criador_id === Number(userId)) {
                throw new Error("CRIADOR_NAO_PODE_SAIR");
            }

            if (partida.status === "ENCERRADA" || partida.status === "CANCELADA") {
                throw new Error("PARTIDA_NAO_ATIVA");
            }

            const usuarioNaPartida = await tx.usuariosPartida.findUnique({
                where: {
                    usuario_id_partida_id: {
                        usuario_id: Number(userId),
                        partida_id: Number(partidaId),
                    },
                },
            });

            if (!usuarioNaPartida) {
                throw new Error("USUARIO_NAO_ESTA_NA_PARTIDA");
            }

            await tx.usuariosPartida.delete({
                where: {
                    usuario_id_partida_id: {
                        usuario_id: Number(userId),
                        partida_id: Number(partidaId),
                    },
                },
            });

            // ── GARANTE CONSISTÊNCIA DO LIMITE ───────────────────────────────
            const novaQuantidade = Math.max(0, partida.quantidade_atual - 1);
            const novoStatus = novaQuantidade < partida.vagas ? "ABERTA" : partida.status;

            await tx.partida.update({
                where: { id: Number(partidaId) },
                data: {
                    quantidade_atual: novaQuantidade,
                    status: novoStatus,
                },
            });
        });

        return res.status(200).json({ message: "Saiu da partida com sucesso." });
    } catch (error: any) {
        console.error("Erro no sairPartida:", error);

        if (error.message === "CRIADOR_NAO_PODE_SAIR") {
            return res.status(403).json({ message: "O criador não pode sair da partida." });
        }

        if (error.message === "PARTIDA_NAO_ATIVA") {
            return res.status(400).json({ message: "Não é possível sair de uma partida encerrada ou cancelada." });
        }

        if (error.message === "USUARIO_NAO_ESTA_NA_PARTIDA") {
            return res.status(404).json({ message: "Você não está nesta partida." });
        }

        return res.status(500).json({ message: "Erro interno ao sair da partida." });
    }
};

export const getPartidasAbertas = async (req: Request, res: Response) => {
    try {
        const partidas = await prisma.partida.findMany({
            where: { status: "ABERTA" },
        });
        return res.status(200).json(partidas);
    } catch (error) {
        console.error("Erro interno no getPartidasAbertas:", error);
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
                        usuario_id: Number(userId),
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

export const getMatchesDisponiveis = async (req: Request, res: Response) => {
    try {
        const partidas = await prisma.partida.findMany({
            where: {
                status: "ABERTA",
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