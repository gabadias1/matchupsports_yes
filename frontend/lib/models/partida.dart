// ignore_for_file: constant_identifier_names, non_constant_identifier_names

enum StatusPartida {
  ABERTA,
  LOTADA,
  ENCERRADA,
  CANCELADA,
}

enum TipoPartida {
  ABERTA,
  FECHADA,
}

class Partida {
  final int id;
  final int reservaId;
  final int criadorId;
  final int vagas;
  final int quantidade_atual;
  final StatusPartida status;
  final TipoPartida tipo;
  final DateTime createdAt;

  // Novos campos para os dados agregados do backend
  final String? criadorNome;
  final String? dataReserva;
  final int? horaInicio;
  final int? horaFim;
  final String? quadraNome;
  final String? estabelecimentoNome;

  // Armazena a lista de IDs dos jogadores
  final List<int> idsUsuarios;

  // NOVO: Armazena os nomes dos jogadores
  final List<String> nomesJogadores;

  Partida({
    required this.id,
    required this.reservaId,
    required this.criadorId,
    required this.vagas,
    required this.quantidade_atual,
    required this.status,
    required this.tipo,
    required this.createdAt,
    this.criadorNome,
    this.dataReserva,
    this.horaInicio,
    this.horaFim,
    this.quadraNome,
    this.estabelecimentoNome,
    required this.idsUsuarios,
    required this.nomesJogadores, // NOVO: Requisitado no construtor
  });

  factory Partida.fromJson(Map<String, dynamic> json) {
    return Partida(
      id: json['id'] ?? 0,
      reservaId: json['reserva_id'] ?? 0,
      criadorId: json['criador_id'] ?? 0,
      vagas: json['vagas'] ?? 0,
      quantidade_atual: json['quantidade_atual'] ?? 0,
      status: StatusPartida.values.firstWhere(
        (e) => e.name == (json['status'] ?? 'ABERTA'),
        orElse: () => StatusPartida.ABERTA,
      ),
      tipo: TipoPartida.values.firstWhere(
        (e) => e.name == (json['tipo'] ?? 'ABERTA'),
        orElse: () => TipoPartida.ABERTA,
      ),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),

      // Extraindo os dados das tabelas relacionadas (Includes do Prisma)
      criadorNome: json['criador']?['nome'],
      dataReserva: json['reserva']?['data'],
      horaInicio: json['reserva']?['hora_inicio'],
      horaFim: json['reserva']?['hora_fim'],
      quadraNome: json['reserva']?['quadra']?['identificacao'],
      estabelecimentoNome: json['reserva']?['quadra']?['estabelecimento']
          ?['nome_local'],

      // Lê o array 'usuariosPartida' que vem do Prisma e extrai só os IDs
      idsUsuarios: json['usuariosPartida'] != null
          ? (json['usuariosPartida'] as List)
              .map((u) => u['usuario_id'] as int)
              .toList()
          : [],

      // NOVO: Lê o array 'usuariosPartida' e extrai os NOMES
      nomesJogadores: json['usuariosPartida'] != null
          ? (json['usuariosPartida'] as List)
              .map(
                  (u) => u['usuario']?['nome']?.toString() ?? 'Jogador Anônimo')
              .toList()
          : [],
    );
  }

  // Função auxiliar para formatar a hora (ex: 1800 -> 18:00)
  String formatarHora(int? horaInt) {
    if (horaInt == null) return '--:--';
    final h = (horaInt ~/ 100).toString().padLeft(2, '0');
    final m = (horaInt % 100).toString().padLeft(2, '0');
    return '$h:$m';
  }

  // Função auxiliar para formatar a data
  String formatarData() {
    if (dataReserva == null) return '--/--/----';
    try {
      final parts = dataReserva!.split('-');
      if (parts.length >= 3) {
        final day = parts[2].substring(0, 2); // ignora o T00:00:00 caso venha
        return '$day/${parts[1]}/${parts[0]}';
      }
      return dataReserva!;
    } catch (_) {
      return dataReserva!;
    }
  }
}
