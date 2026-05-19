import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:match_up_sports/theme/app_theme.dart';
import 'package:match_up_sports/services/reserva_service.dart';

class MinhasReservasTab extends StatefulWidget {
  const MinhasReservasTab({super.key});

  @override
  State<MinhasReservasTab> createState() => _MinhasReservasTabState();
}

class _MinhasReservasTabState extends State<MinhasReservasTab> {
  List<Reserva> _reservas = [];
  bool _isLoading = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregarReservas();
  }

  Future<void> _carregarReservas() async {
    setState(() {
      _isLoading = true;
      _erro = null;
    });
    try {
      final reservas = await ReservaService.getMinhasReservas();
      setState(() {
        _reservas = reservas;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _erro = 'Não foi possível carregar suas reservas.';
        _isLoading = false;
      });
    }
  }

  Future<void> _cancelarReserva(Reserva reserva) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Cancelar reserva',
          style: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Deseja cancelar a reserva de "${reserva.quadraNome}" em ${_formatarData(reserva.data)}?',
          style: GoogleFonts.dmSans(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child:
                Text('Não', style: GoogleFonts.dmSans(color: AppColors.gray)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Sim, cancelar',
                style: GoogleFonts.dmSans(
                    color: AppColors.error, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      await ReservaService.cancelarReserva(reserva.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reserva cancelada com sucesso.')),
        );
        _carregarReservas();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao cancelar reserva.')),
        );
      }
    }
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_erro != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('😕', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(_erro!,
                style: GoogleFonts.dmSans(fontSize: 15, color: AppColors.gray)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _carregarReservas,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (_reservas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📅', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(
              'Nenhuma reserva ainda',
              style: GoogleFonts.bebasNeue(
                  fontSize: 28, color: AppColors.dark, letterSpacing: 1),
            ),
            const SizedBox(height: 8),
            Text(
              'Suas reservas aparecerão aqui.',
              style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.gray),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _carregarReservas,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _reservas.length,
        itemBuilder: (context, index) {
          final reserva = _reservas[index];
          return _ReservaCard(
            reserva: reserva,
            formatarData: _formatarData,
            onCancelar: reserva.status != 'CANCELADA'
                ? () => _cancelarReserva(reserva)
                : null,
          );
        },
      ),
    );
  }
}

class _ReservaCard extends StatelessWidget {
  final Reserva reserva;
  final String Function(DateTime) formatarData;
  final VoidCallback? onCancelar;

  const _ReservaCard({
    required this.reserva,
    required this.formatarData,
    this.onCancelar,
  });

  Color _statusColor(String status) {
    switch (status) {
      case 'CONFIRMADA':
        return AppColors.primary;
      case 'CANCELADA':
        return AppColors.error;
      default:
        return AppColors.secondary;
    }
  }

  Color _statusBg(String status) {
    switch (status) {
      case 'CONFIRMADA':
        return AppColors.primaryLight;
      case 'CANCELADA':
        return const Color(0xFFFAECE7);
      default:
        return AppColors.secondaryLight;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'CONFIRMADA':
        return 'Confirmada';
      case 'CANCELADA':
        return 'Cancelada';
      default:
        return 'Pendente';
    }
  }

  String _sportEmoji(String? esporte) {
    switch (esporte) {
      case 'Futebol':
        return '⚽';
      case 'Vôlei':
        return '🏐';
      case 'Basquete':
        return '🏀';
      default:
        return '🏟️';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grayLight),
      ),
      child: Column(
        children: [
          // Header do card
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ícone do esporte
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      _sportEmoji(reserva.esporte),
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Infos principais
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reserva.quadraNome,
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.dark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        reserva.estabelecimentoNome,
                        style: GoogleFonts.dmSans(
                            fontSize: 13, color: AppColors.gray),
                      ),
                    ],
                  ),
                ),
                // Badge de status
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusBg(reserva.status),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _statusLabel(reserva.status),
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _statusColor(reserva.status),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Divider
          const Divider(height: 1, color: AppColors.grayLight),

          // Detalhes da reserva
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _InfoChip(
                  icon: Icons.calendar_today_outlined,
                  label: formatarData(reserva.data),
                ),
                const SizedBox(width: 12),
                _InfoChip(
                  icon: Icons.access_time_outlined,
                  label:
                      '${Reserva.formatarHora(reserva.horaInicio)} – ${Reserva.formatarHora(reserva.horaFim)}',
                ),
                if (reserva.valorHora != null) ...[
                  const SizedBox(width: 12),
                  _InfoChip(
                    icon: Icons.attach_money_outlined,
                    label: 'R\$ ${reserva.valorHora!.toStringAsFixed(0)}/h',
                  ),
                ],
              ],
            ),
          ),

          // Botão cancelar
          if (onCancelar != null) ...[
            const Divider(height: 1, color: AppColors.grayLight),
            TextButton.icon(
              onPressed: onCancelar,
              icon: const Icon(Icons.cancel_outlined,
                  size: 16, color: AppColors.error),
              label: Text(
                'Cancelar reserva',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.gray),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.darkMid),
        ),
      ],
    );
  }
}
