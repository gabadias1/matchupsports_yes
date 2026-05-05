class QuadraModel {
  final int id;
  final String identificacao;
  final String descricao;
  final int estabelecimentoId;
  final int donoId;
  final String? esporte;
  final double? valorHora;

  QuadraModel({
    required this.id,
    required this.identificacao,
    required this.descricao,
    required this.estabelecimentoId,
    required this.donoId,
    this.esporte,
    this.valorHora,
  });

  factory QuadraModel.fromJson(Map<String, dynamic> json) {
    return QuadraModel(
      id: json['id'],
      identificacao: json['identificacao'],
      descricao: json['descricao'],
      estabelecimentoId: json['estabelecimento_id'],
      donoId: json['dono_id'] ?? 0,
      esporte: json['esporte'],
      valorHora: json['valor_hora'] != null ? (json['valor_hora'] as num).toDouble() : null,
    );
  }
}
