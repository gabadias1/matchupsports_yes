import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:match_up_sports/routes/app_router.dart';
import 'package:go_router/go_router.dart';
import 'package:match_up_sports/services/quadra_service.dart';
import 'package:match_up_sports/theme/app_theme.dart';

class CriarQuadraScreen extends StatefulWidget {
  const CriarQuadraScreen({super.key});

  @override
  State<CriarQuadraScreen> createState() => _CriarQuadraScreenState();
}

class _CriarQuadraScreenState extends State<CriarQuadraScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identificacaoController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _estabelecimentoIdController = TextEditingController();
  final _valorHoraController = TextEditingController();
  
  String? _selectedEsporte;
  bool _isLoading = false;

  final List<Map<String, String>> _esportes = [
    {'nome': 'Futebol', 'emoji': '⚽'},
    {'nome': 'Vôlei', 'emoji': '🏐'},
    {'nome': 'Basquete', 'emoji': '🏀'},
  ];

  @override
  void dispose() {
    _identificacaoController.dispose();
    _descricaoController.dispose();
    _estabelecimentoIdController.dispose();
    _valorHoraController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedEsporte == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Por favor, selecione um esporte',
            style: GoogleFonts.dmSans(color: Colors.white),
          ),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final quadra = await QuadraService.createQuadra(
        identificacao: _identificacaoController.text,
        descricao: _descricaoController.text,
        estabelecimentoId: int.parse(_estabelecimentoIdController.text),
        esporte: _selectedEsporte!,
        valorHora: double.parse(_valorHoraController.text),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Quadra "${quadra.identificacao}" cadastrada com sucesso!',
              style: GoogleFonts.dmSans(color: Colors.white),
            ),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 2),
          ),
        );

        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceAll('Exception: ', ''),
              style: GoogleFonts.dmSans(color: Colors.white),
            ),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //Adicionando forma de voltar para a tela inicial
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.dark),
          onPressed: () => context.go(AppRoutes.home),
          ),
        title: Text(
          'Cadastrar Quadra',
          style: GoogleFonts.dmSans(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card com ícone
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '🏟️',
                        style: GoogleFonts.dmSans(fontSize: 48),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Nova Quadra',
                        style: GoogleFonts.dmSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.dark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Preencha os dados para cadastrar',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: AppColors.gray,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Campo: Identificação
                Text(
                  'Identificação',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.dark,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _identificacaoController,
                  decoration: InputDecoration(
                    hintText: 'Ex: Quadra 1, Quadra A, etc.',
                    hintStyle: GoogleFonts.dmSans(color: AppColors.grayLight),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.grayLight),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: GoogleFonts.dmSans(color: AppColors.dark),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Informe a identificação da quadra';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Campo: Descrição
                Text(
                  'Descrição',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.dark,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descricaoController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Ex: Quadra de futebol society coberta',
                    hintStyle: GoogleFonts.dmSans(color: AppColors.grayLight),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.grayLight),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: GoogleFonts.dmSans(color: AppColors.dark),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Informe a descrição da quadra';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Campo: Esporte
                Text(
                  'Tipo de Esporte',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.dark,
                  ),
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: _esportes.length,
                  itemBuilder: (context, index) {
                    final esporte = _esportes[index];
                    final isSelected = _selectedEsporte == esporte['nome'];

                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedEsporte = esporte['nome']);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.grayLight,
                            width: isSelected ? 2 : 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              esporte['emoji']!,
                              style: const TextStyle(fontSize: 28),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              esporte['nome']!,
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.dark,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Campo: ID do Estabelecimento
                Text(
                  'ID do Estabelecimento',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.dark,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _estabelecimentoIdController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Ex: 1, 2, 3...',
                    hintStyle: GoogleFonts.dmSans(color: AppColors.grayLight),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.grayLight),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: GoogleFonts.dmSans(color: AppColors.dark),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Informe o ID do estabelecimento';
                    }
                    if (int.tryParse(value!) == null) {
                      return 'O ID deve ser um número válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Campo: Valor por Hora
                Text(
                  'Valor por Hora (R\$)',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.dark,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _valorHoraController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: 'Ex: 50.00',
                    hintStyle: GoogleFonts.dmSans(color: AppColors.grayLight),
                    prefixText: 'R\$ ',
                    prefixStyle: GoogleFonts.dmSans(
                      color: AppColors.dark,
                      fontWeight: FontWeight.w600,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.grayLight),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: GoogleFonts.dmSans(color: AppColors.dark),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Informe o valor por hora';
                    }
                    if (double.tryParse(value!) == null) {
                      return 'O valor deve ser um número válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),

                // Botão: Cadastrar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isLoading ? AppColors.grayLight : AppColors.primary,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white.withOpacity(0.7),
                              ),
                            ),
                          )
                        : Text(
                            'Cadastrar Quadra',
                            style: GoogleFonts.dmSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
