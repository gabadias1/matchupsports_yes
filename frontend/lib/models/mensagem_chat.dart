class MensagemChat {
  final int id;
  final String mensagem;
  final DateTime createdAt;
  final int usuarioId;
  final String nomeUsuario;

  MensagemChat({
    required this.id,
    required this.mensagem,
    required this.createdAt,
    required this.usuarioId,
    required this.nomeUsuario,
  });

  factory MensagemChat.fromJson(Map<String,dynamic> json){
    return MensagemChat(
      id: json['id'],
      mensagem: json['mensagem'],
      createdAt:
        DateTime.parse(
          json['createdAt'],
        ),
      usuarioId:
        json['usuario']['id'],
      nomeUsuario:
        json['usuario']['nome'],
    );
  }
}

class MensagensResponse {
  final int page;
  final int limit;
  final bool hasMore;
  final List<MensagemChat> mensagens;

  MensagensResponse({
    required this.page,
    required this.limit,
    required this.hasMore,
    required this.mensagens,
  });

  factory MensagensResponse.fromJson(Map<String, dynamic> json) {
    return MensagensResponse(
      page: json['page'],
      limit: json['limit'],
      hasMore: json['hasMore'],
      mensagens: (json['mensagens'] as List)
          .map(
            (msg) => MensagemChat.fromJson(msg),
          )
          .toList(),
    );
  }
}