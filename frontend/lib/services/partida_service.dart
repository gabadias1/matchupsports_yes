import 'package:dio/dio.dart';
import 'package:match_up_sports/services/auth_service.dart';
import 'package:match_up_sports/models/partida.dart';

class PartidaService {
  static const String _baseUrl = 'http://localhost:3000';
  static final _dio = Dio(BaseOptions(baseUrl: _baseUrl));
  static final _authService = AuthService();

  static Future<void> criarPartida({
    required int vagas,
    required int reservaId,
    required String tipo,
  }) async {
    try {
      final token = await _authService.getToken();
      _dio.options.headers['Authorization'] = 'Bearer $token';

      await _dio.post('/partidas', data: {
        'vagas': vagas,
        'reserva_id': reservaId,
        'tipo': tipo,
      });
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data?['message'] ?? 'Erro ao criar partida');
      }
      throw Exception('Erro ao criar partida: ${e.message}');
    }
  }

  static Future<List<Partida>> obterPartidasDisponiveis() async {
    try {
      final response = await _dio.get('/match');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Partida.fromJson(json)).toList();
      } else {
        throw Exception('Erro ao buscar partidas');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data?['message'] ?? 'Erro ao buscar partidas');
      }
      throw Exception('Erro ao buscar partidas: ${e.message}');
    }
  }
}