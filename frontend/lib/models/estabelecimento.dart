class EstabelecimentoModel {
  final int id;
  final String nomeLocal;
  final String endereco;
  final int proprietarioId;

  EstabelecimentoModel({
    required this.id,
    required this.nomeLocal,
    required this.endereco,
    required this.proprietarioId,
  });

  factory EstabelecimentoModel.fromJson(Map<String, dynamic> json) {
    return EstabelecimentoModel(
      id: json['id'],
      nomeLocal: json['nome_local'],
      endereco: json['endereco'],
      proprietarioId: json['proprietario_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome_local': nomeLocal,
      'endereco': endereco,
      'proprietario_id': proprietarioId,
    };
  }
}