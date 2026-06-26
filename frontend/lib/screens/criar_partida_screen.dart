import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:match_up_sports/services/partida_service.dart';
import 'package:match_up_sports/theme/app_theme.dart';

class CriarPartidaScreen extends StatefulWidget {
  final int reservaId;

  const CriarPartidaScreen({
    super.key,
    required this.reservaId,
  });

  @override
  State<CriarPartidaScreen> createState() =>
      _CriarPartidaScreenState();
}

class _CriarPartidaScreenState
    extends State<CriarPartidaScreen> {
  final TextEditingController vagasController =
      TextEditingController();

  String tipoPartida = 'ABERTA';

  @override
  void initState() {
    super.initState();
    vagasController.text = '10';
  }

  Future<void> criarPartida() async {
    final vagas = int.tryParse(vagasController.text);

    if (vagas == null || vagas <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe uma quantidade válida de vagas.'),
        ),
      );
      return;
    }
    try {
      await PartidaService.criarPartida(
        vagas: vagas,
        reservaId: widget.reservaId,
        tipo: tipoPartida,
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
    if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
   SnackBar(
    backgroundColor: AppColors.primary,
    content: Text(
      'Partida criada com sucesso!',
    style: GoogleFonts.dmSans(color: Colors.white),
    ),
   ),
  );

  context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Partida'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: vagasController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantidade de vagas',
              ),
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: tipoPartida,
              decoration: const InputDecoration(
                labelText: 'Tipo da partida',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'ABERTA',
                  child: Text('Aberta'),
                ),
                DropdownMenuItem(
                  value: 'FECHADA',
                  child: Text('Fechada'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    tipoPartida = value;
                  });
                }
              },
            ),

            const SizedBox(height: 8),

            Text(
              tipoPartida == 'ABERTA'
                  ? 'Jogadores poderão entrar livremente até atingir o limite de vagas.'
                  : 'Somente jogadores convidados poderão participar.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall,
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: criarPartida,
                child: const Text(
                  'Criar Partida',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}