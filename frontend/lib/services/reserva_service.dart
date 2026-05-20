import 'package:dio/dio.dart';
import 'package:match_up_sports/services/auth_service.dart';
import 'package:match_up_sports/models/reserva.dart';

class ReservaService {
  static const String _baseUrl = 'http://localhost:3000/reservas';
  static final _dio = Dio(BaseOptions(baseUrl: _baseUrl));
  static final _authService = AuthService();

  static Future<Reserva> createReserva({
    required int quadraId,
    required String data,
    required int horaInicio,
    required int horaFim,
  }) async {
    try {
      final token = await _authService.getToken();
      _dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await _dio.post('', data: {
        'quadra_id': quadraId,
        'data': data,
        'hora_inicio': horaInicio,
        'hora_fim': horaFim,
      });

      return Reserva.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data?['message'] ?? 'Erro ao criar reserva');
      }
      throw Exception('Erro ao criar reserva: ${e.message}');
    }
  }

  static Future<List<Reserva>> getMinhasReservas() async {
    try {
      final token = await _authService.getToken();
      _dio.options.headers['Authorization'] = 'Bearer $token';
      final response = await _dio.get('/minhas');
      return (response.data as List)
          .map((json) => Reserva.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw Exception('Erro ao buscar reservas: ${e.message}');
    }
  }

  static Future<List<Reserva>> getReservasDonoQuadras() async {
    try {
      final token = await _authService.getToken();
      _dio.options.headers['Authorization'] = 'Bearer $token';
      final response = await _dio.get('/dono');
      return (response.data as List)
          .map((json) => Reserva.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw Exception('Erro ao buscar reservas: ${e.message}');
    }
  }

  static Future<List<Map<String, int>>> getAvailableSlots({required int quadraId, required String date}) async {
    try {
      final response = await _dio.get('/available', queryParameters: {
        'quadra_id': quadraId,
        'date': date,
      });

      final List data = response.data as List;
      return data.map((item) => {
        'start': item['start'] as int,
        'end': item['end'] as int,
      }).toList();
    } on DioException catch (e) {
      throw Exception('Erro ao buscar horários disponíveis: ${e.message}');
    }
  }

  static Future<void> cancelarReserva(int reservaId) async {
    try {
      final token = await _authService.getToken();
      _dio.options.headers['Authorization'] = 'Bearer $token';
      await _dio.delete('/$reservaId');
    } on DioException catch (e) {
      throw Exception('Erro ao cancelar reserva: ${e.message}');
    }
  }
}
