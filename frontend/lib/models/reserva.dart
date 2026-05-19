class Reserva {
  final int id;
  final int usuarioId;
  final int quadraId;
  final String data; // YYYY-MM-DD
  final int horaInicio;
  final int horaFim;
  final String status;

  Reserva({
    required this.id,
    required this.usuarioId,
    required this.quadraId,
    required this.data,
    required this.horaInicio,
    required this.horaFim,
    required this.status,
  });

  factory Reserva.fromJson(Map<String, dynamic> json) {
    return Reserva(
      id: json['id'],
      usuarioId: json['usuario_id'],
      quadraId: json['quadra_id'],
      data: (json['data'] as String).split('T').first,
      horaInicio: json['hora_inicio'],
      horaFim: json['hora_fim'],
      status: json['status'],
    );
  }
}
