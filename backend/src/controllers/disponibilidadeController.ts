import { Request, Response } from "express";
import { prisma } from "../config/prisma";

export const createDisponibilidade = async (req: Request, res: Response) => {
    const { dia_semana, hora_inicio, hora_fim, quadra_id } = req.body;

    try {
        await prisma.quadra.findUniqueOrThrow({
            where: { id: Number(quadra_id) }
        });
    } catch {
        return res.status(404).json({ message: "Quadra não encontrada." });
    }

    const disponibilidade = await prisma.disponibilidade.create({
        data: { dia_semana, hora_inicio, hora_fim, quadra_id }
    });
    
    res.status(201).json(disponibilidade);
};

export const getDisponibilidades = async (req: Request, res: Response) => {
    const disponibilidades = await prisma.disponibilidade.findMany();
    res.json(disponibilidades);
};

export const getDisponibilidadesPorQuadra = async (req: Request, res: Response) => {
    const { quadra_id } = req.params;
    
    try {
        await prisma.quadra.findUniqueOrThrow({
            where: { id: Number(quadra_id) }
        });
    } catch {
        return res.status(404).json({ message: "Quadra não encontrada." });
    }
    
    const disponibilidades = await prisma.disponibilidade.findMany({
        where: { quadra_id: Number(quadra_id) }
    });

    res.json(disponibilidades);
};

export const getDisponibilidade = async (req: Request, res: Response) => {
    const { id } = req.params;
    
    const disponibilidade = await prisma.disponibilidade.findUnique({
        where: { id: Number(id) }
    });

    if (!disponibilidade) {
        return res.status(404).json({ message: "Disponibilidade não encontrada." });
    }

    res.json(disponibilidade);
};

export const updateDisponibilidade = async (req: Request, res: Response) => {
    const { id } = req.params;
    const { dia_semana, hora_inicio, hora_fim, quadra_id } = req.body;
    
    try {
        await prisma.disponibilidade.findUniqueOrThrow({
            where: { id: Number(id) }
        });
    } catch {
        return res.status(404).json({ message: "Disponibilidade não encontrada." });
    }

    if (quadra_id) {
        try {
            await prisma.quadra.findUniqueOrThrow({
                where: { id: Number(quadra_id) }
            });
        } catch {
            return res.status(404).json({ message: "Quadra não encontrada." });
        }
    }
    
    const disponibilidade = await prisma.disponibilidade.update({
        where: { id: Number(id) },
        data: { dia_semana, hora_inicio, hora_fim, quadra_id }
    });

    res.json(disponibilidade);
};

export const deleteDisponibilidade = async (req: Request, res: Response) => {
    const { id } = req.params;
    
    try {
        await prisma.disponibilidade.findUniqueOrThrow({
            where: { id: Number(id) }
        });
    } catch {
        return res.status(404).json({ message: "Disponibilidade não encontrada." });
    }

    await prisma.disponibilidade.delete({
        where: { id: Number(id) }
    });
    
    res.status(204).send();
};

