import { Request, Response } from "express";
import { prisma } from "../config/prisma";
import { DiaSemana } from "@prisma/client";

const diaSemanaMap = [
  "DOMINGO",
  "SEGUNDA",
  "TERCA",
  "QUARTA",
  "QUINTA",
  "SEXTA",
  "SABADO",
];

const parseDateOnly = (dateString: string) => {
  const parts = dateString.split("-").map(Number);
  if (parts.length !== 3 || parts.some((p) => Number.isNaN(p))) {
    return null;
  }
  const [year, month, day] = parts;
  return new Date(year, month - 1, day);
};

export const createReserva = async (req: Request, res: Response) => {
  const { quadra_id, data, hora_inicio, hora_fim } = req.body;

  if (!quadra_id || !data || hora_inicio === undefined || hora_fim === undefined) {
    return res.status(400).json({ message: "Dados incompletos para criar a reserva." });
  }

  const reservaData = parseDateOnly(String(data));
  if (!reservaData || Number.isNaN(reservaData.getTime())) {
    return res.status(400).json({ message: "Data inválida para a reserva." });
  }

  // Verifica se a quadra existe
  try {
    await prisma.quadra.findUniqueOrThrow({ where: { id: Number(quadra_id) } });
  } catch {
    return res.status(404).json({ message: "Quadra não encontrada." });
  }

  // Verifica se há disponibilidade ativa para o dia da semana e horário
  const diaSemana = diaSemanaMap[reservaData.getDay()] as DiaSemana;

  const disponibilidades = await prisma.disponibilidade.findMany({
    where: {
      quadra_id: Number(quadra_id),
      dia_semana: diaSemana,
      ativo: true,
    },
  });

  const novoHoraFim = hora_fim === 0 ? 2400 : hora_fim;

  const temDisponibilidade = disponibilidades.some((d) => {
    const horaFimExistente = d.hora_fim === 0 ? 2400 : d.hora_fim;
    return d.hora_inicio <= hora_inicio && horaFimExistente >= novoHoraFim;
  });

  if (!temDisponibilidade) {
    return res.status(400).json({ message: "Horário não disponível para reserva." });
  }

  // Verifica conflitos com reservas existentes no mesmo dia
  const startOfDay = new Date(reservaData);
  const nextDay = new Date(startOfDay);
  nextDay.setDate(startOfDay.getDate() + 1);

  const reservasExistentes = await prisma.reserva.findMany({
    where: {
      quadra_id: Number(quadra_id),
      data: { gte: startOfDay, lt: nextDay },
    },
  });

  const conflito = reservasExistentes.find((r) => {
    const rHoraFim = r.hora_fim === 0 ? 2400 : r.hora_fim;
    return r.hora_inicio < novoHoraFim && rHoraFim > hora_inicio;
  });

  if (conflito) {
    return res.status(409).json({ message: "Já existe uma reserva nesse intervalo de horário." });
  }

  try {
    const usuarioId = Number(req.user?.id);

    const reserva = await prisma.reserva.create({
      data: {
        usuario_id: usuarioId,
        quadra_id: Number(quadra_id),
        data: startOfDay,
        hora_inicio: hora_inicio,
        hora_fim: hora_fim,
      },
    });

    return res.status(201).json(reserva);
  } catch (error: any) {
    console.error(error);
    // Tratamento específico para erro de constraint única (horário duplicado)
    if (error.code === 'P2002' && error.meta?.target?.includes('hora_inicio')) {
      return res.status(409).json({ message: "Este horário já possui uma reserva para esta quadra." });
    }
    return res.status(500).json({ message: "Erro ao criar reserva." });
  }
};

export const getMinhasReservas = async (req: Request, res: Response) => {
  const usuarioId = Number(req.user?.id);

  if (!usuarioId) {
    return res.status(401).json({ message: "Usuário não autenticado." });
  }

  const reservas = await prisma.reserva.findMany({
    where: { usuario_id: usuarioId },
    include: {
      quadra: {
        include: {
          estabelecimento: {
            select: { nome_local: true },
          },
        },
      },
    },
    orderBy: { data: "desc" },
  });

  res.json(reservas);
};

export const getAvailableSlots = async (req: Request, res: Response) => {
  const { quadra_id, date } = req.query as { quadra_id?: string; date?: string };

  if (!quadra_id || !date) {
    return res.status(400).json({ message: 'Parâmetros quadra_id e date são obrigatórios.' });
  }

  const reservaData = parseDateOnly(String(date));
  if (!reservaData || Number.isNaN(reservaData.getTime())) {
    const fallback = new Date(String(date));
    if (!Number.isNaN(fallback.getTime())) {
      const normalized = new Date(fallback.getFullYear(), fallback.getMonth(), fallback.getDate());
      return res.json([]);
    }
    return res.status(400).json({ message: 'Data inválida para consulta de horários.' });
  }

  const diaSemanaMap = [
    "DOMINGO",
    "SEGUNDA",
    "TERCA",
    "QUARTA",
    "QUINTA",
    "SEXTA",
    "SABADO",
  ];

  const diaSemana = diaSemanaMap[reservaData.getDay()] as DiaSemana;

  // Buscar disponibilidades ativas para o dia
  const disponibilidades = await prisma.disponibilidade.findMany({
    where: { quadra_id: Number(quadra_id), dia_semana: diaSemana, ativo: true },
  });

  if (!disponibilidades.length) {
    return res.json([]);
  }

  // Buscar reservas existentes para a quadra na data
  const startOfDay = new Date(reservaData);
  const nextDay = new Date(startOfDay);
  nextDay.setDate(startOfDay.getDate() + 1);

  const reservasExistentes = await prisma.reserva.findMany({
    where: {
      quadra_id: Number(quadra_id),
      data: { gte: startOfDay, lt: nextDay },
    },
  });

  // Função auxiliar para subtrair reservas de um intervalo
  const subtractReservations = (interval: { start: number; end: number }) => {
    let intervals = [interval];

    for (const r of reservasExistentes) {
      const rStart = r.hora_inicio;
      const rEnd = r.hora_fim === 0 ? 2400 : r.hora_fim;

      intervals = intervals.flatMap((intv) => {
        // sem overlap
        if (rEnd <= intv.start || rStart >= intv.end) return [intv];

        const parts: { start: number; end: number }[] = [];

        if (rStart > intv.start) {
          parts.push({ start: intv.start, end: rStart });
        }

        if (rEnd < intv.end) {
          parts.push({ start: rEnd, end: intv.end });
        }

        return parts;
      });
    }

    return intervals.filter((i) => i.end > i.start);
  };

  const results: { start: number; end: number }[] = [];

  for (const d of disponibilidades) {
    const start = d.hora_inicio;
    const end = d.hora_fim === 0 ? 2400 : d.hora_fim;

    const free = subtractReservations({ start, end });

    for (const f of free) results.push(f);
  }

  const toMinutes = (hhmm: number) => Math.floor(hhmm / 100) * 60 + (hhmm % 100);
  const fromMinutes = (minutes: number) =>
    Math.floor(minutes / 60) * 100 + (minutes % 60);

  const hourlySlots: { start: number; end: number }[] = [];
  for (const free of results) {
    let current = toMinutes(free.start);
    const endMinutes = toMinutes(free.end);

    while (current + 60 <= endMinutes) {
      hourlySlots.push({ start: fromMinutes(current), end: fromMinutes(current + 60) });
      current += 60;
    }
  }

  hourlySlots.sort((a, b) => a.start - b.start);

  return res.json(hourlySlots);
};

export const cancelarReserva = async (req: Request, res: Response) => {
  const reservaId = Number(req.params.id);
  const usuarioId = Number(req.user?.id);

  if (!usuarioId) {
    return res.status(401).json({ message: "Usuário não autenticado." });
  }

  try {
    // 1. Busca a reserva para garantir que ela existe
    const reserva = await prisma.reserva.findUnique({
      where: { id: reservaId },
    });

    if (!reserva) {
      return res.status(404).json({ message: "Reserva não encontrada." });
    }

    // 2. Garante que o usuário só pode deletar a PRÓPRIA reserva
    if (reserva.usuario_id !== usuarioId) {
      return res.status(403).json({ message: "Você não tem permissão para cancelar esta reserva." });
    }

    // 3. Limpeza do banco de dados usando Transação
    await prisma.$transaction(async (tx) => {
        // Verifica se existe uma partida vinculada a essa reserva
        const partida = await tx.partida.findFirst({
            where: { reserva_id: reservaId }
        });

        if (partida) {
            // Remove todos os jogadores da partida
            await tx.usuariosPartida.deleteMany({
                where: { partida_id: partida.id }
            });
            
            // Deleta a partida
            await tx.partida.delete({
                where: { id: partida.id }
            });
        }

        // 4. Agora sim, deleta a reserva em segurança!
        await tx.reserva.delete({
            where: { id: reservaId },
        });
    });

    return res.status(200).json({ message: "Reserva cancelada com sucesso." });
  } catch (error) {
    console.error("Erro ao cancelar reserva:", error);
    return res.status(500).json({ message: "Erro ao cancelar a reserva. Verifique se há conflitos." });
  }
};

export const getReservasDonoQuadras = async (req: Request, res: Response) => {
  const donoId = Number(req.user?.id);

  if (!donoId) {
    return res.status(401).json({ message: "Usuário não autenticado." });
  }

  try {
    // Busca todas as quadras do dono
    const quadras = await prisma.quadra.findMany({
      where: { dono_id: donoId },
      select: { id: true },
    });

    const quadraIds = quadras.map((q) => q.id);

    // Busca todas as reservas dessas quadras
    const reservas = await prisma.reserva.findMany({
      where: { quadra_id: { in: quadraIds } },
      include: {
        quadra: {
          include: {
            estabelecimento: {
              select: { nome_local: true },
            },
          },
        },
        usuario: {
          select: { nome: true, email: true },
        },
      },
      orderBy: { data: "desc" },
    });

    res.json(reservas);
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: "Erro ao buscar reservas." });
  }
};

export const cancelarReservaDono = async (reservaId: number) => {
    try {
        const reserva = await prisma.reserva.findUniqueOrThrow({
            where: { id: reservaId },
        });

        if (reserva.status === "CANCELADA") {
            return { success: false, message: "Reserva já está cancelada." };
        }

        await prisma.reserva.update({
            where: { id: reservaId },
            data: { status: "CANCELADA" },
        });

        return { success: true, message: "Reserva cancelada com sucesso." };
    } catch (error) {
        console.error("Erro ao cancelar reserva:", error);
        return { success: false, message: "Erro ao cancelar a reserva." };
    }
};

export const confirmarReserva = async (req: Request, res: Response) => {
    const { id } = req.params;

    try {
        const reserva = await prisma.reserva.findUnique({
            where: {
                id: Number(id),
            },
            include: {
                quadra: {
                    include: {
                        estabelecimento: true,
                    },
                },
            },
        });

        if (!reserva) {
            return res.status(404).json({
                message: "Reserva não encontrada.",
            });
        }

        if (
            reserva.quadra.estabelecimento.proprietario_id !== req.user.id
        ) {
            return res.status(403).json({
                message: "Você não pode confirmar esta reserva.",
            });
        }

        if (reserva.status === "CONFIRMADA") {
            return res.status(400).json({
                message: "Essa reserva já está confirmada.",
            });
        }

        await prisma.reserva.update({
            where: {
                id: Number(id),
            },
            data: {
                status: "CONFIRMADA",
            },
        });

        const chat = await prisma.chatReserva.create({
            data:{
                reserva_id:Number(id)
            }
        });

        await prisma.chatParticipante.createMany({
            data:[
                {
                    chat_id:chat.id,
                    usuario_id:reserva.usuario_id
                },
                {
                    chat_id:chat.id,
                    usuario_id:
                      reserva.quadra.estabelecimento.proprietario_id
                }
            ]
        });

        return res.status(200).json({
            message: "Reserva confirmada.",
        });

    } catch (error) {
        console.error(error);

        return res.status(400).json({
            message: "Erro ao confirmar reserva.",
        });
    }
};

export const recusarReserva = async (req: Request, res: Response) => {
    const { id } = req.params;

    try {
        const reserva = await prisma.reserva.findUnique({
            where: {
                id: Number(id),
            },
            include: {
                quadra: {
                    include: {
                        estabelecimento: true,
                    },
                },
            },
        });


        if (!reserva) {
            return res.status(404).json({
                message: "Reserva não encontrada.",
            });
        }


        if (
            reserva.quadra.estabelecimento.proprietario_id !== req.user.id
        ) {
            return res.status(403).json({
                message: "Você não pode recusar esta reserva.",
            });
        }


        if (reserva.status === "CONFIRMADA") {
            return res.status(400).json({
                message: "Não é possível recusar uma reserva confirmada.",
            });
        }


        await prisma.reserva.update({
            where: {
                id: Number(id),
            },
            data: {
                status: "RECUSADA",
            },
        });


        return res.status(200).json({
            message: "Reserva recusada.",
        });


    } catch (error) {
        console.error(error);

        return res.status(400).json({
            message: "Erro ao recusar reserva.",
        });
    }
};