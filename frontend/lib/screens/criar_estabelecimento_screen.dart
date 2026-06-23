import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:match_up_sports/routes/app_router.dart';
import 'package:match_up_sports/services/estabelecimento_service.dart';
import 'package:match_up_sports/theme/app_theme.dart';

class CriarEstabelecimentoScreen extends StatefulWidget {
  const CriarEstabelecimentoScreen({super.key});

  @override
  State<CriarEstabelecimentoScreen> createState() => _CriarEstabelecimentoScreenState();
}

class _CriarEstabelecimentoScreenState extends State<CriarEstabelecimentoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeLocalController = TextEditingController();
  final _enderecoController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nomeLocalController.dispose();
    _enderecoController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final estabelecimento = await EstabelecimentoService.createEstabelecimento(
        nomeLocal: _nomeLocalController.text.trim(),
        endereco: _enderecoController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Estabelecimento "${estabelecimento.nomeLocal}" cadastrado com sucesso!',
              style: GoogleFonts.dmSans(color: Colors.white),
            ),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 2),
          ),
        );

        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          context.pop();
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.dark),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Cadastrar Estabelecimento',
          style: GoogleFonts.dmSans(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(14)
                ),
                child: Column(
                  children: [
                    Text(
                      '⚽ / 🏀 / 🏐 / 🎾',
                      style: GoogleFonts.dmSans(fontSize: 48),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Novo estabelecimento',
                      style: GoogleFonts.dmSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.dark,
                      ),
                    ),
                    Text(
                      'Preencha as informações do estabelecimento',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: AppColors.gray,
                      ),
                    )
                  ],
                ),
              ),
              // Nome Local
              Text(
                'Nome do local',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.dark,
                ),
              ),
              TextFormField(
                controller: _nomeLocalController,
                decoration: InputDecoration(
                  hintText: 'Ex: Arena do Moranguinho',
                  hintStyle: GoogleFonts.dmSans(color: AppColors.grayLight),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.grayLight),
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nome do local é obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Endereço
              Text(
                'Endereço',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.dark,
                ),
              ),
              TextFormField(
                controller: _enderecoController,
                decoration: InputDecoration(
                  hintText: 'Ex: Rua B, 456',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Endereço é obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Botão de Submit
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Cadastrar Estabelecimento',
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
    );
  }
}