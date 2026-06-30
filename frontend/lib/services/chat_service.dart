import 'package:dio/dio.dart';
import 'package:match_up_sports/models/mensagem_chat.dart';
import 'package:match_up_sports/services/auth_service.dart';

class ChatService {
  final Dio _dio = Dio();
  final AuthService _authService = AuthService();
  final String _baseUrl = 'http://localhost:3000/chat';

  Future<MensagensResponse> buscarMensagens({
    required int reservaId,
    int page = 0,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/mensagens',
        queryParameters: {
          'reserva_id': reservaId,
          'page': page,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${await _getToken()}',
          },
        ),
      );
      return MensagensResponse.fromJson(response.data);
    } on DioException catch(e) {
      if(e.response != null){
        throw Exception(
          e.response?.data['message'] ??
          'Erro ao buscar mensagens',
        );
      }
      throw Exception(
        'Erro de conexão com servidor',
      );
    }
  }

  Future<MensagemChat> enviarMensagem({required int reservaId, required String mensagem}) async {
    final token = await AuthService().getToken();
    final response = await _dio.post(
      "$_baseUrl/$reservaId/mensagens",
      data: {
        "mensagem": mensagem,
      },
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
        },
      ),
    );
    return MensagemChat.fromJson(
      response.data,
    );
  }

  Future<String?> _getToken() async {
    return _authService.getToken();
  }
}