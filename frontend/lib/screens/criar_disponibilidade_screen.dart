import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:match_up_sports/models/disponibilidade.dart';
import 'package:match_up_sports/services/disponibilidade_service.dart';
import 'package:match_up_sports/theme/app_theme.dart';

class CriarDisponibilidadeQuadraScreen extends StatefulWidget {
  final int quadraId;

  const CriarDisponibilidadeQuadraScreen({
    super.key,
    required this.quadraId,
  });

  @override
  State<CriarDisponibilidadeQuadraScreen> createState() =>
      _CriarDisponibilidadeQuadraScreenState();
}

class _CriarDisponibilidadeQuadraScreenState
    extends State<CriarDisponibilidadeQuadraScreen> {
  final List<String> diasSemana = [
    'Segunda',
    'Terça',
    'Quarta',
    'Quinta',
    'Sexta',
    'Sábado',
    'Domingo',
  ];

  final List<String> horarios = List.generate(
    24,
    (index) => '${index.toString().padLeft(2, '0')}:00',
  );

  List<Map<String, dynamic>> disponibilidades = [];
  final DisponibilidadeService _disponibilidadeService = DisponibilidadeService();

  String? diaSelecionado;
  String? horarioInicio;
  String? horarioFim;

  @override
  void initState() {
    super.initState();
    _loadDisponibilidades();
  }

  Future<void> _loadDisponibilidades() async {
    try {
      final disponiveis = await _disponibilidadeService
          .listarDisponibilidadesQuadra(widget.quadraId);
      setState(() {
        disponibilidades.clear();
        disponibilidades.addAll(disponiveis.map((d) => {
              'id': d.id,
              'dia': diasSemana[d.dia.index],
              'inicio': '${(d.horaInicio ~/ 100).toString().padLeft(2, '0')}:${(d.horaInicio % 100).toString().padLeft(2, '0')}',
              'fim': '${(d.horaFim ~/ 100).toString().padLeft(2, '0')}:${(d.horaFim % 100).toString().padLeft(2, '0')}',
              'ativo': d.ativo,
            }));
      });
    } on Exception catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error,
          content: Text(e.toString().replaceAll('Exception: ', ''),
            style: GoogleFonts.dmSans(color: Colors.white),
          ),
        ),
      );
    }
  }

  void adicionarDisponibilidade() async {
    if (diaSelecionado == null ||
        horarioInicio == null ||
        horarioFim == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error,
          content: Text(
            'Preencha todos os campos.',
            style: GoogleFonts.dmSans(color: Colors.white),
          ),
        ),
      );
      return;
    }

    final inicioIndex = horarios.indexOf(horarioInicio!);
    final fimIndex = horarios.indexOf(horarioFim!);

    if ((fimIndex <= inicioIndex) && (fimIndex != 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error,
          content: Text(
            'Horário final deve ser maior que o inicial.',
            style: GoogleFonts.dmSans(color: Colors.white),
          ),
        ),
      );
      return;
    }

    setState(() async {

      try {
        await _disponibilidadeService.criarDisponibilidade(
          disponibilidade: Disponibilidade(
            quadraId: widget.quadraId,
            dia: DiaSemana.values[diasSemana.indexOf(diaSelecionado!)],
            horaInicio: int.parse(
              horarioInicio!.replaceAll(':', ''),
            ),
            horaFim: int.parse(
              horarioFim!.replaceAll(':', ''),
            ),
            ativo: true,
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.primary,
            content: Text(
              'Disponibilidade adicionada com sucesso!',
              style: GoogleFonts.dmSans(color: Colors.white),
            ),
          ),
        );
      } on Exception catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text(e.toString().replaceAll('Exception: ', ''),
              style: GoogleFonts.dmSans(color: Colors.white),
            ),
          ),
        );
        return;
      }
      _loadDisponibilidades();

      diaSelecionado = null;
      horarioInicio = null;
      horarioFim = null;
    });
  }

  Future<void> _confirmarExclusao(
    Map<String, dynamic> disponibilidade,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(
            'Excluir disponibilidade',
            style: GoogleFonts.dmSans(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Deseja realmente excluir esta disponibilidade?',
            style: GoogleFonts.dmSans(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Cancelar',
                style: GoogleFonts.dmSans(),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                'Excluir',
                style: GoogleFonts.dmSans(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await _disponibilidadeService.deletarDisponibilidade(
        disponibilidade['id'],
      );

      await _loadDisponibilidades();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.primary,
          content: Text(
            'Disponibilidade excluída.',
            style: GoogleFonts.dmSans(
              color: Colors.white,
            ),
          ),
        ),
      );
    } on Exception catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error,
          content: Text(
            e.toString().replaceAll('Exception: ', ''),
            style: GoogleFonts.dmSans(
              color: Colors.white,
            ),
          ),
        ),
      );
    }
  }

  Future<void> _editarDisponibilidade(
    Map<String, dynamic> disponibilidade,
  ) async {
    String? dia = disponibilidade['dia'];

    String? inicio = disponibilidade['inicio'];

    String? fim = disponibilidade['fim'];

    await showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: Text(
                'Editar disponibilidade',
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.bold,
                ),
              ),

              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildDropdown<String>(
                    hint: 'Dia',
                    value: dia,
                    items: diasSemana,
                    onChanged: (value) {
                      setModalState(() {
                        dia = value;
                      });
                    },
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: buildDropdown<String>(
                          hint: 'Início',
                          value: inicio,
                          items: horarios,
                          onChanged: (value) {
                            setModalState(() {
                              inicio = value;
                            });
                          },
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: buildDropdown<String>(
                          hint: 'Fim',
                          value: fim,
                          items: horarios,
                          onChanged: (value) {
                            setModalState(() {
                              fim = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancelar',
                    style: GoogleFonts.dmSans(),
                  ),
                ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  onPressed: () async {
                    final inicioIndex = horarios.indexOf(inicio!);
                    final fimIndex = horarios.indexOf(fim!);

                    // Horário final menor que inicial
                    if ((fimIndex <= inicioIndex) && (fimIndex != 0)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.error,
                          content: Text(
                            'Horário final deve ser maior que o inicial.',
                            style: GoogleFonts.dmSans(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                      return;
                    }
                    try {
                      await _disponibilidadeService
                          .atualizarDisponibilidade(
                        disponibilidade['id'],
                        Disponibilidade(
                          quadraId: widget.quadraId,
                          dia: DiaSemana.values[
                              diasSemana.indexOf(dia!)],
                          horaInicio: int.parse(
                            inicio!.replaceAll(':', ''),
                          ),
                          horaFim: int.parse(
                            fim!.replaceAll(':', ''),
                          ),
                        ),
                      );

                      Navigator.pop(context);

                      await _loadDisponibilidades();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.primary,
                          content: Text(
                            'Disponibilidade atualizada.',
                            style: GoogleFonts.dmSans(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    } on Exception catch (e) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.error,
                          content: Text(
                            e.toString().replaceAll(
                              'Exception: ',
                              '',
                            ),
                            style: GoogleFonts.dmSans(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    }
                  },
                  child: Text(
                    'Salvar',
                    style: GoogleFonts.dmSans(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _toggleDisponibilidade(
    Map<String, dynamic> disponibilidade,
  ) async {
    try {
      final bool ativo = disponibilidade['ativo'];

      if (ativo) {
        await _disponibilidadeService.desativarDisponibilidade(
          disponibilidade['id'],
        );
      } else {
        await _disponibilidadeService.ativarDisponibilidade(
          disponibilidade['id'],
        );
      }

      await _loadDisponibilidades();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.primary,
          content: Text(
            ativo
                ? 'Disponibilidade desativada.'
                : 'Disponibilidade ativada.',
            style: GoogleFonts.dmSans(
              color: Colors.white,
            ),
          ),
        ),
      );
    } on Exception catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error,
          content: Text(
            e.toString().replaceAll('Exception: ', ''),
            style: GoogleFonts.dmSans(
              color: Colors.white,
            ),
          ),
        ),
      );
    }
  }

  Future<void> salvarDisponibilidades() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primary,
        content: Text(
          'Disponibilidades salvas com sucesso!',
          style: GoogleFonts.dmSans(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
    context.pop();
  }

  Widget buildDropdown<T>({
    required String hint,
    required T? value,
    required List<T> items,
    required Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(
            item.toString(),
            style: GoogleFonts.dmSans(),
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget buildDisponibilidadeCard(
    Map<String, dynamic> disponibilidade,
    int index,
  ) {
    final bool ativo = disponibilidade['ativo'];

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: ativo ? 1 : 0.45,

      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),

          border: Border.all(
            color: ativo
                ? AppColors.grayLight
                : AppColors.error.withOpacity(0.25),
          ),
        ),

        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,

              decoration: BoxDecoration(
                color: ativo
                    ? AppColors.primary.withOpacity(0.1)
                    : AppColors.error.withOpacity(0.1),

                borderRadius: BorderRadius.circular(14),
              ),

              child: Icon(
                ativo
                    ? Icons.schedule
                    : Icons.visibility_off,

                color: ativo
                    ? AppColors.primary
                    : AppColors.error,
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Row(
                    children: [
                      Text(
                        disponibilidade['dia'],

                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.dark,
                        ),
                      ),

                      const SizedBox(width: 8),

                      if (!ativo)
                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),

                          decoration: BoxDecoration(
                            color: AppColors.error
                                .withOpacity(0.12),

                            borderRadius:
                                BorderRadius.circular(20),
                          ),

                          child: Text(
                            'Inativa',

                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  Text(
                    '${disponibilidade['inicio']} até ${disponibilidade['fim']}',

                    style: GoogleFonts.dmSans(
                      color: AppColors.gray,
                    ),
                  ),
                ],
              ),
            ),

            PopupMenuButton<String>(
              onSelected: (value) async {
                switch (value) {
                  case 'toggle':
                    await _toggleDisponibilidade(
                      disponibilidade,
                    );
                    break;

                  case 'edit':
                    await _editarDisponibilidade(
                      disponibilidade,
                    );
                    break;

                  case 'delete':
                    await _confirmarExclusao(
                      disponibilidade,
                    );
                    break;
                }
              },

              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'toggle',

                  child: Row(
                    children: [
                      Icon(
                        ativo
                            ? Icons.visibility_off
                            : Icons.visibility,

                        size: 20,
                      ),

                      const SizedBox(width: 10),

                      Text(
                        ativo
                            ? 'Desativar'
                            : 'Ativar',

                        style: GoogleFonts.dmSans(),
                      ),
                    ],
                  ),
                ),

                PopupMenuItem(
                  value: 'edit',

                  child: Row(
                    children: [
                      const Icon(
                        Icons.edit_outlined,
                        size: 20,
                      ),

                      const SizedBox(width: 10),

                      Text(
                        'Editar',
                        style: GoogleFonts.dmSans(),
                      ),
                    ],
                  ),
                ),

                PopupMenuItem(
                  value: 'delete',

                  child: Row(
                    children: [
                      const Icon(
                        Icons.delete_outline,
                        color: AppColors.error,
                        size: 20,
                      ),

                      const SizedBox(width: 10),

                      Text(
                        'Excluir',

                        style: GoogleFonts.dmSans(
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        title: Text(
          'Disponibilidade da Quadra',
          style: GoogleFonts.dmSans(
            color: AppColors.dark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(20, 8, 20, 18),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.schedule,
                  color: Colors.white,
                  size: 40,
                ),

                const SizedBox(height: 12),

                Text(
                  'Defina a disponibilidade da quadra',
                  style: GoogleFonts.dmSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Defina os dias e horários disponíveis para reserva.',
                  style: GoogleFonts.dmSans(
                    color: Colors.white.withOpacity(0.9),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                Text(
                  'Nova disponibilidade',
                  style: GoogleFonts.dmSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.dark,
                  ),
                ),

                const SizedBox(height: 18),

                buildDropdown<String>(
                  hint: 'Selecione o dia',
                  value: diaSelecionado,
                  items: diasSemana,
                  onChanged: (value) {
                    setState(() {
                      diaSelecionado = value;
                    });
                  },
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: buildDropdown<String>(
                        hint: 'Início',
                        value: horarioInicio,
                        items: horarios,
                        onChanged: (value) {
                          setState(() {
                            horarioInicio = value;
                          });
                        },
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: buildDropdown<String>(
                        hint: 'Fim',
                        value: horarioFim,
                        items: horarios,
                        onChanged: (value) {
                          setState(() {
                            horarioFim = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: adicionarDisponibilidade,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.dark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                    label: Text(
                      'Adicionar disponibilidade',
                      style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                Text(
                  'Disponibilidade atual',
                  style: GoogleFonts.dmSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.dark,
                  ),
                ),

                const SizedBox(height: 16),

                if (disponibilidades.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppColors.grayLight,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '📅',
                          style: TextStyle(fontSize: 42),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          'Nenhuma disponibilidade adicionada.',
                          style: GoogleFonts.dmSans(
                            color: AppColors.gray,
                          ),
                        ),
                      ],
                    ),
                  ),

                ...disponibilidades.asMap().entries.map(
                  (entry) {
                    return buildDisponibilidadeCard(
                      entry.value,
                      entry.key,
                    );
                  },
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: AppColors.grayLight,
                ),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: salvarDisponibilidades,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                ),
                label: Text(
                  'Salvar a disponibilidade',
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}