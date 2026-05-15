import { Request, Response } from "express";
import { prisma } from "../config/prisma";

export const createDisponibilidade = async (
  req: Request,
  res: Response
) => {
  const {
    dia_semana,
    hora_inicio,
    hora_fim,
    quadra_id,
  } = req.body;

  let new_hora_fim = hora_fim == 0 ? 2400 : hora_fim; // Ajuste para permitir horário de término às 24:00

  if (new_hora_fim <= hora_inicio) {
    return res.status(400).json({
      message:
        "O horário final deve ser maior que o horário inicial.",
    });
  }

  try {
    await prisma.quadra.findUniqueOrThrow({
      where: {
        id: Number(quadra_id),
      },
    });
  } catch {
    return res.status(404).json({
      message: "Quadra não encontrada.",
    });
  }

  // Busca todas do mesmo dia
  const disponibilidades =
    await prisma.disponibilidade.findMany({
      where: {
        quadra_id: Number(quadra_id),
        dia_semana,
      },
    });

  // Verifica conflitos manualmente
  const conflito = disponibilidades.find((d) => {
    const horaFimExistente =
      d.hora_fim == 0 ? 2400 : d.hora_fim;

    return (
      d.hora_inicio < new_hora_fim &&
      horaFimExistente > hora_inicio
    );
  });

  if (conflito) {
    return res.status(409).json({
      message:
        "Já existe uma disponibilidade nesse intervalo de horário.",
    });
  }

  const disponibilidade =
    await prisma.disponibilidade.create({
      data: {
        dia_semana,
        hora_inicio,
        hora_fim,
        quadra_id: Number(quadra_id),
      },
    });

  return res.status(201).json(disponibilidade);
};

export const getDisponibilidades = async (req: Request, res: Response) => {
    const disponibilidades = await prisma.disponibilidade.findMany();
    res.json(disponibilidades);
};

export const getDisponibilidadesPorQuadra = async (
  req: Request,
  res: Response
) => {
  const { quadra_id } = req.params;

  try {
    await prisma.quadra.findUniqueOrThrow({
      where: {
        id: Number(quadra_id),
      },
    });
  } catch {
    return res.status(404).json({
      message: "Quadra não encontrada.",
    });
  }

  const ordemDias = [
    "SEGUNDA",
    "TERCA",
    "QUARTA",
    "QUINTA",
    "SEXTA",
    "SABADO",
    "DOMINGO",
  ];

  const disponibilidades =
    await prisma.disponibilidade.findMany({
      where: {
        quadra_id: Number(quadra_id),
      },
    });

  disponibilidades.sort(
    (
      a: {
        ativo: boolean;
        dia_semana: string;
        hora_inicio: number;
      },
      b: {
        ativo: boolean;
        dia_semana: string;
        hora_inicio: number;
      }
    ) => {

      // Ativas primeiro
      if (a.ativo !== b.ativo) {
        return a.ativo ? -1 : 1;
      }

      const diaA = ordemDias.indexOf(a.dia_semana);
      const diaB = ordemDias.indexOf(b.dia_semana);

      // Ordena por dia da semana
      if (diaA !== diaB) {
        return diaA - diaB;
      }

      // Ordena por horário inicial
      return a.hora_inicio - b.hora_inicio;
    }
  );

  return res.json(disponibilidades);
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

export const updateDisponibilidade = async (
  req: Request,
  res: Response
) => {
  const { id } = req.params;

  const {
    dia_semana,
    hora_inicio,
    hora_fim,
    quadra_id,
  } = req.body;

  let disponibilidadeExistente;

  try {
    disponibilidadeExistente =
      await prisma.disponibilidade.findUniqueOrThrow({
        where: {
          id: Number(id),
        },
      });
  } catch {
    return res.status(404).json({
      message: "Disponibilidade não encontrada.",
    });
  }

  const quadraIdFinal =
    quadra_id ?? disponibilidadeExistente.quadra_id;

  const horaInicioFinal =
    hora_inicio ?? disponibilidadeExistente.hora_inicio;

  const horaFimFinal =
    hora_fim ?? disponibilidadeExistente.hora_fim;

  const newHoraFim = horaFimFinal == 0 ? 2400 : horaFimFinal; // Ajuste para permitir horário de término às 24:00

  if (newHoraFim <= horaInicioFinal) {
    return res.status(400).json({
      message:
        "O horário final deve ser maior que o horário inicial.",
    });
  }

  try {
    await prisma.quadra.findUniqueOrThrow({
      where: {
        id: Number(quadraIdFinal),
      },
    });
  } catch {
    return res.status(404).json({
      message: "Quadra não encontrada.",
    });
  }

  // Busca todas do mesmo dia
  const disponibilidades =
    await prisma.disponibilidade.findMany({
      where: {
        quadra_id: Number(quadraIdFinal),
        dia_semana,
      },
    });

  // Verifica conflitos manualmente
  const conflito = disponibilidades.find((d) => {
    const horaFimExistente =
      d.hora_fim == 0 ? 2400 : d.hora_fim;

    return (
      d.hora_inicio < newHoraFim &&
      horaFimExistente > hora_inicio
    );
  });

  if (conflito) {
    return res.status(409).json({
      message:
        "Já existe uma disponibilidade nesse intervalo de horário.",
    });
  }

  const disponibilidade =
    await prisma.disponibilidade.update({
      where: {
        id: Number(id),
      },

      data: {
        dia_semana,
        hora_inicio,
        hora_fim,
        quadra_id,
      },
    });

  return res.json(disponibilidade);
};

export const deleteDisponibilidade = async (req: Request, res: Response) => {
    const { id } = req.params;
    
    try {
        await prisma.disponibilidade.findUniqueOrThrow({
            where: { id: Number(id) }
        });
    } catch {
        return res.status(404).json({ message : "Disponibilidade não encontrada." });
    }

    await prisma.disponibilidade.delete({
        where: { id: Number(id) }
    });
    
    res.status(204).send();
};

export const desativarDisponibilidade = async (req: Request, res: Response) => {
    const { id } = req.params;
    
    let disponibilidadeExistente;
    
    try {
        disponibilidadeExistente = await prisma.disponibilidade.findUniqueOrThrow({
            where: { id: Number(id) }
        });
    } catch {
        return res.status(404).json({ message : "Disponibilidade não encontrada." });
    }

    if (!disponibilidadeExistente.ativo) {
        return res.status(400).json({ message: "Disponibilidade já está desativada." });
    }

    const disponibilidade = await prisma.disponibilidade.update({
        where: { id: Number(id) },
        data: { ativo: false }
    });

    res.json(disponibilidade);
};

export const ativarDisponibilidade = async (req: Request, res: Response) => {
    const { id } = req.params;
    
    let disponibilidadeExistente;
    
    try {
        disponibilidadeExistente = await prisma.disponibilidade.findUniqueOrThrow({
            where: { id: Number(id) }
        });
    } catch {
        return res.status(404).json({ message : "Disponibilidade não encontrada." });
    }

    if (disponibilidadeExistente.ativo) {
        return res.status(400).json({ message: "Disponibilidade já está ativa." });
    }

    const disponibilidade = await prisma.disponibilidade.update({
        where: { id: Number(id) },
        data: { ativo: true }
    });

    res.json(disponibilidade);
};