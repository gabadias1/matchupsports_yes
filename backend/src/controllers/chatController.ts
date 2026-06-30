import { Request, Response } from "express";
import { prisma } from "../config/prisma";

export const meusChats = async(req: Request, res: Response)=>{
    const chats = await prisma.chatReserva.findMany({
        where:{
            participantes:{
                some:{
                    usuario_id:req.user.id
                }
            }
        },
        include:{
            reserva:{
                include:{
                    quadra:true
                }
            },
            mensagens:{
                orderBy:{
                    createdAt:"desc"
                },
                take:1
            }
        }
    });
    return res.json(chats);
}

export const enviarMensagem = async (req: Request, res: Response) => {
    try {
        const reservaId = Number(req.params.reservaId);
        const { mensagem } = req.body;
        const chat = await prisma.chatReserva.findUniqueOrThrow({
            where:{
                reserva_id: reservaId
            },
            include:{
                participantes:true
            }
        });
        const isParticipante =
            chat.participantes.some(
                (participante: { usuario_id: any; }) =>
                    participante.usuario_id === req.user.id
            );
        if(!isParticipante){
            return res.status(403).json({
                message:
                "Você não participa deste chat."
            });
        }
        const novaMensagem =
            await prisma.mensagemChat.create({
                data:{
                    chat_id: chat.id,
                    usuario_id:req.user.id,
                    mensagem
                },
                include:{
                    usuario:true
                }
            });
        return res.status(201).json(novaMensagem);
    } catch(error){
        console.error(
            "Erro ao enviar mensagem:",
            error
        );
        return res.status(400).json({
            message:
            "Erro ao enviar mensagem."
        });
    }
};

export const recuperarMensagens = async (req: Request, res: Response) => {
    const { reserva_id, page = "0" } = req.query;
    const limit = 50;
    const pagina = Number(page);
    try {
        const chat = await prisma.chatReserva.findUnique({
            where: {
                reserva_id: Number(reserva_id),
            },
        });
        if (!chat) {
            return res.status(404).json({
                message: "Chat não encontrado.",
            });
        }
        const mensagens = await prisma.mensagemChat.findMany({
            where: {
                chat_id: chat.id,
            },
            include: {
                usuario: {
                    select: {
                        id: true,
                        nome: true,
                    },
                },
            },
            orderBy: {
                createdAt: "desc",
            },
            skip: pagina * limit,
            take: limit,
        });
        const total = await prisma.mensagemChat.count({
            where:{
                chat_id: chat.id
            }
        });
        return res.status(200).json({
            page: pagina,
            limit,
            hasMore: (pagina + 1) * limit < total,
            mensagens: mensagens.reverse(),
        });
    } catch(error){
        return res.status(400).json({
            message: "Erro ao recuperar mensagens.",
        });
    }
};