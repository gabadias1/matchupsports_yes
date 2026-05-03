class QuadraModel {
  final int id;
  final String identificacao;
  final String descricao;
  final int estabelecimentoId;

  QuadraModel({
    required this.id,
    required this.identificacao,
    required this.descricao,
    required this.estabelecimentoId,
  });

  factory QuadraModel.fromJson(Map<String, dynamic> json) {
    return QuadraModel(
      id: json['id'],
      identificacao: json['identificacao'],
      descricao: json['descricao'],
      estabelecimentoId: json['estabelecimento_id'],
    );
  }
}
