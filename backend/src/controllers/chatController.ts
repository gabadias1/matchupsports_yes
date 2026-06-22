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

export const enviarMensagem = async(req: Request, res: Response)=>{
    const chat = await prisma.chatReserva.findUniqueOrThrow({
        where:{
            id:Number(req.params.id)
        },
        include:{
            participantes:true
        }
    });
    const isParticipante = chat.participantes.some((participante: { usuario_id: string; }) => participante.usuario_id === req.user.id);
    if(!isParticipante){
        return res.status(403).json({message:"Você não é participante deste chat."});       
    }
    await prisma.mensagemChat.create({
        data:{
            chat_id:Number(req.params.id),
            usuario_id:req.user.id,
            mensagem:req.body.mensagem
        }
    })
    return res.status(200).json({message:"Mensagem enviada com sucesso."});
}