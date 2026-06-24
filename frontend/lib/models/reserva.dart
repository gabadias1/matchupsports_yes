class Reserva {
  final int id;
  final int usuarioId;
  final int quadraId;
  final String data; // YYYY-MM-DD
  final int horaInicio;
  final int horaFim;
  final String status;
  final String? quadraNome;
  final String? nomeJogador;
  final String? estabelecimentoNome;
  final double? valorHora;
  final String? esporte;

  Reserva({
    required this.id,
    required this.usuarioId,
    required this.quadraId,
    required this.data,
    required this.horaInicio,
    required this.horaFim,
    required this.status,
    this.quadraNome,
    this.estabelecimentoNome,
    this.nomeJogador,
    this.valorHora,
    this.esporte,
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
      quadraNome: json['quadra']?['identificacao'] ?? json['quadraNome'],
      estabelecimentoNome: json['quadra']?['estabelecimento']?['nome_local'] ?? json['estabelecimentoNome'],
      nomeJogador: json['usuario']?['nome'] ?? json['nomeUsuario'],
      valorHora: (json['quadra']?['valor_hora'] ?? json['valorHora'])?.toDouble(),
      esporte: json['quadra']?['esporte'] ?? json['esporte'],
    );
  }

  /// Formata a hora em formato HH:MM
  /// Exemplo: 800 -> "8:00", 1400 -> "14:00"
  static String formatarHora(int hora) {
    int h = hora ~/ 100;
    int m = hora % 100;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  // Função auxiliar para formatar a data
  String formatarData() {
    try {
      final parts = data.split('-');
      if (parts.length >= 3) {
        final day = parts[2].substring(0, 2); // ignora o T00:00:00 caso venha
        return '$day/${parts[1]}/${parts[0]}';
      }
      return data;
    } catch (_) {
      return data;
    }
  }
}
