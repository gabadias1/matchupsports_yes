// ignore_for_file: constant_identifier_names

enum DiaSemana {
  SEGUNDA,
  TERCA,
  QUARTA,
  QUINTA,
  SEXTA,
  SABADO,
  DOMINGO,
}

class Disponibilidade {
  final int? id;
  final DiaSemana dia;
  final int quadraId;
  final int horaInicio;
  final int horaFim;
  final bool? ativo;

  Disponibilidade({
    this.id,
    required this.dia,
    required this.quadraId,
    required this.horaInicio,
    required this.horaFim,
    this.ativo,
  });

  factory Disponibilidade.fromJson(Map<String, dynamic> json) {
    return Disponibilidade(
      id: json['id'],
      dia: DiaSemana.values.firstWhere(
        (e) => e.name.toUpperCase() == json['dia_semana'],
      ),
      quadraId: json['quadra_id'],
      horaInicio: json['hora_inicio'],
      horaFim: json['hora_fim'],
      ativo: json['ativo'],
    );
  }
}