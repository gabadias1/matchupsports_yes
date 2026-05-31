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

  Partida({
    required this.id,
    required this.reservaId,
    required this.criadorId,
    required this.vagas,
    required this.quantidade_atual,
    required this.status,
    required this.tipo,
    required this.createdAt,
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
    );
  }
}