import { Request, Response } from "express";
import { prisma } from "../config/prisma";

export const createQuadra = async (req: Request, res: Response) => {
    const { identificacao, descricao, estabelecimento_id, esporte, valor_hora } = req.body;
    
    // Pega o ID do usuário que o seu autenticacaoMiddleware injetou no req
    const ownerId = req.user?.id; 

    try {
        // Valida se o estabelecimento existe
        await prisma.estabelecimento.findUniqueOrThrow({
            where: { id: Number(estabelecimento_id) }
        });

        // Cria a quadra vinculando ao dono (ownerId)
        const quadra = await prisma.quadra.create({
            data: { 
                identificacao, 
                descricao, 
                estabelecimento_id: Number(estabelecimento_id),
                dono_id: Number(ownerId),
                esporte, 
                valor_hora: valor_hora ? Number(valor_hora) : null
            }
        });

        return res.status(201).json(quadra);
    } catch (error) {
        console.error(error);
        return res.status(500).json({ message: "Erro ao criar quadra ou estabelecimento não encontrado" });
    }
};

export const getQuadras = async (req: Request, res: Response) => {
    const quadras = await prisma.quadra.findMany();
    res.json(quadras);
}

export const getQuadra = async (req: Request, res: Response) => {
    const { id } = req.params;

    const quadra = await prisma.quadra.findUnique({
        where: { id: Number(id) }
    });

    if (!quadra) {
        return res.status(404).json({ message: "Quadra não encontrada" });
    }

    res.json(quadra);
};

export const getQuadrasByEstabelecimento = async (req: Request, res: Response) => {
    const { estabelecimentoId } = req.params;

    try {
        await prisma.estabelecimento.findUniqueOrThrow({
            where: { id: Number(estabelecimentoId) }
        });
    }
    catch {
        return res.status(404).json({ message: "Estabelecimento não encontrado" });
    }
    
    const quadras = await prisma.quadra.findMany({
        where: { estabelecimento_id: Number(estabelecimentoId) }
    });

    res.json(quadras);
};

export const getQuadrasByDono = async (req: Request, res: Response) => {
    const ownerId = req.user?.id;

    if (!ownerId) {
        return res.status(401).json({ message: "Usuário não autenticado" });
    }
    
    const quadras = await prisma.quadra.findMany({
        where: { dono_id: Number(ownerId) }
    });
    res.json(quadras);
};

export const updateQuadra = async (req: Request, res: Response) => {
    const { id } = req.params;
    const { identificacao, descricao, estabelecimento_id } = req.body;

    try {
        await prisma.quadra.findUniqueOrThrow({
            where: { id: Number(id) }
        });
    } catch {
        return res.status(404).json({ message: "Quadra não encontrada" });
    }

    if (estabelecimento_id) {
        try {
            await prisma.estabelecimento.findUniqueOrThrow({
                where: { id: Number(estabelecimento_id) }
            });
        } catch {
            return res.status(404).json({ message: "Estabelecimento não encontrado" });
        }
    }

    const quadra = await prisma.quadra.update({
        where: { id: Number(id) },
        data: { identificacao, descricao, estabelecimento_id }
    });

    res.json(quadra);
};

export const deleteQuadra = async (req: Request, res: Response) => {
    const { id } = req.params;

    try {
        await prisma.quadra.findUniqueOrThrow({
            where: { id: Number(id) }
        });
    } catch {
        return res.status(404).json({ message: "Quadra não encontrada" });
    }

    await prisma.quadra.delete({
        where: { id: Number(id) }
    });

    return res.status(204).send();
};