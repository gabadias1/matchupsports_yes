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
        final data = e.response?.data;
        if (data is Map && data.containsKey('message')) {
          throw Exception(data['message']);
        }
      }
      throw Exception('Erro ao criar partida');
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
        final data = e.response?.data;
        if (data is Map && data.containsKey('message')) {
          throw Exception(data['message']);
        }
      }
      throw Exception('Erro ao buscar partidas');
    }
  }

  // NOVO MÉTODO ATUALIZADO (Issue #17)
  static Future<void> entrarPartida(int partidaId) async {
    try {
      final token = await _authService.getToken();
      _dio.options.headers['Authorization'] = 'Bearer $token';

      // CORREÇÃO: A rota correta no backend é /partidas e não /match
      await _dio.post('/partidas/$partidaId/entrar');
    } on DioException catch (e) {
      if (e.response != null) {
        final data = e.response?.data;
        // Validação segura para evitar o TypeError que vimos na tela
        if (data is Map && data.containsKey('message')) {
          throw Exception(data['message']);
        }
        // Se a rota falhar ou o erro não for JSON, mostra o Status Code para facilitar debug
        throw Exception(
            'Erro no servidor ao tentar entrar (Status: ${e.response?.statusCode})');
      }
      throw Exception('Erro de conexão: ${e.message}');
    }
  }

  // NOVO MÉTODO PARA SAIR DA PARTIDA
  static Future<void> sairDaPartida(int partidaId) async {
    try {
      final token = await _authService.getToken();
      _dio.options.headers['Authorization'] = 'Bearer $token';

      await _dio.delete('/partidas/$partidaId/sair');
    } on DioException catch (e) {
      if (e.response != null && e.response?.data is Map) {
        final data = e.response?.data;
        if (data.containsKey('message')) {
          throw Exception(data['message']);
        }
      }
      throw Exception('Erro ao sair da partida');
    }
  }

  static Future<void> alterarTipo(int partidaId, String tipo) async {
    try {
      final token = await _authService.getToken();
      _dio.options.headers['Authorization'] = 'Bearer $token';

      await _dio.post('/partidas/alterarTipo/$partidaId', data: {
        'tipo': tipo,
      });
    } on DioException catch (e) {
      if (e.response != null) {
        final data = e.response?.data;
        if (data is Map && data.containsKey('message')) {
          throw Exception(data['message']);
        }
      }
      throw Exception('Erro ao alterar tipo da partida');
    }
  }

  static Future<void> removerJogador(int partidaId, int jogadorId) async {
    try {
      final token = await _authService.getToken();
      _dio.options.headers['Authorization'] = 'Bearer $token';
      await _dio.post('/partidas/removerJogador/$partidaId/$jogadorId');
    } on DioException catch (e) {
      if (e.response != null) {
        final data = e.response?.data;
        if (data is Map && data.containsKey('message')) {
          throw Exception(data['message']);
        }
      }
    }
  }

  static Future<List<Partida>> minhas() async {
    try {
      final token = await _authService.getToken();
      _dio.options.headers['Authorization'] = 'Bearer $token';
      final response = await _dio.get('/partidas/minhas');
      return (response.data as List)
          .map((json) => Partida.fromJson(json))
          .toList();
    } on DioException catch (e) {
      if (e.response != null) {
        final data = e.response?.data;
        if (data is Map && data.containsKey('message')) {
          throw Exception(data['message']);
        }
      }
      throw Exception('Erro ao obter minhas partidas');
    }
  }

  static Future<void> cancelarPartida(int partidaId) async {
    try {
      final token = await _authService.getToken();
      _dio.options.headers['Authorization'] = 'Bearer $token';
      await _dio.delete('/partidas/$partidaId/cancelar');
    } on DioException catch (e) {
      if (e.response != null) {
        final data = e.response?.data;
        if (data is Map && data.containsKey('message')) {
          throw Exception(data['message']);
        }
      }
      throw Exception('Erro ao cancelar partida');
    }
  }

  static Future<String> gerarConvite(int partidaId) async {
    try {
      final token = await _authService.getToken();
      _dio.options.headers['Authorization'] = 'Bearer $token';
      final response = await _dio.post('/convites/criar/', data: {
        'partida_id': partidaId,
      });
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        final data = e.response?.data;
        if (data is Map && data.containsKey('message')) {
          throw Exception(data['message']);
        }
      }
      throw Exception('Erro ao gerar convite');
    }
  }

  static Future<void> aceitarConvite(String codigo) async {
    try {
      final token = await _authService.getToken();
      _dio.options.headers['Authorization'] = 'Bearer $token';
      await _dio.post('/convites/$codigo/aceitar/');
    } on DioException catch (e) {
      if (e.response != null) {
        final data = e.response?.data;
        if (data is Map && data.containsKey('message')) {
          throw Exception(data['message']);
        }
      }
    }
  }

}
