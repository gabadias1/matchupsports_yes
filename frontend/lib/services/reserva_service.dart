import 'package:dio/dio.dart';
import 'package:match_up_sports/services/auth_service.dart';

class Reserva {
  final int id;
  final DateTime data;
  final int horaInicio;
  final int horaFim;
  final String status;
  final String quadraNome;
  final String? esporte;
  final double? valorHora;
  final String estabelecimentoNome;
  final String estabelecimentoEndereco;

  Reserva({
    required this.id,
    required this.data,
    required this.horaInicio,
    required this.horaFim,
    required this.status,
    required this.quadraNome,
    this.esporte,
    this.valorHora,
    required this.estabelecimentoNome,
    required this.estabelecimentoEndereco,
  });

  factory Reserva.fromJson(Map<String, dynamic> json) {
    final quadra = json['quadra'] as Map<String, dynamic>;
    final estabelecimento = quadra['estabelecimento'] as Map<String, dynamic>;

    return Reserva(
      id: json['id'],
      data: DateTime.parse(json['data']),
      horaInicio: json['hora_inicio'],
      horaFim: json['hora_fim'],
      status: json['status'],
      quadraNome: quadra['identificacao'],
      esporte: quadra['esporte'],
      valorHora: (quadra['valor_hora'] as num?)?.toDouble(),
      estabelecimentoNome: estabelecimento['nome_local'],
      estabelecimentoEndereco: estabelecimento['endereco'],
    );
  }

  // Formata horário de HHMM para "18:00"
  static String formatarHora(int hhmm) {
    final h = hhmm ~/ 100;
    final m = hhmm % 100;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }
}

class ReservaService {
  static final Dio _dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'));

  static Future<Map<String, String>> _headers() async {
    final token = await AuthService().getToken();
    return {'Authorization': 'Bearer $token'};
  }

  // GET /reservas/me
  static Future<List<Reserva>> getMinhasReservas() async {
    final headers = await _headers();
    final response = await _dio.get(
      '/reservas/me',
      options: Options(headers: headers),
    );
    final List data = response.data;
    return data.map((json) => Reserva.fromJson(json)).toList();
  }

  // DELETE /reservas/:id
  static Future<void> cancelarReserva(int id) async {
    final headers = await _headers();
    await _dio.delete(
      '/reservas/$id',
      options: Options(headers: headers),
    );
  }
}
