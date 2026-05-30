// ignore_for_file: constant_identifier_names, non_constant_identifier_names

enum StatusPartida {
  ABERTA,
  FECHADA,
  LOTADA,
  ENCERRADA,
  CANCELADA,
}

class Partida {
  final int? id;
  final int reservaId;
  final int criadorId;
  final String nome;
  final String descricao;
  final int vagas;
  final int quantidade_atual;
  final StatusPartida status;

  Partida({
    this.id,
    required this.reservaId,
    required this.criadorId,
    required this.nome,
    required this.descricao,
    required this.vagas,
    required this.quantidade_atual,
    required this.status,
  });

  factory Partida.fromJson(Map<String, dynamic> json) {
    return Partida(
      id: json['id'],
      reservaId: json['reserva_id'],
      criadorId: json['criador_id'],
      nome: json['nome'],
      descricao: json['descricao'],
      vagas: json['vagas'],
      status: StatusPartida.values.firstWhere(
        (e) => e.name.toUpperCase() == json['status_partida'],
      ),
      quantidade_atual: json['quantidade_atual'],
    );
  }
}