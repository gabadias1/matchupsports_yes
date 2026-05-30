import 'package:go_router/go_router.dart';
import 'package:match_up_sports/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:match_up_sports/services/auth_service.dart';
import 'package:match_up_sports/theme/app_theme.dart';
import 'package:match_up_sports/widgets/app_widgets.dart';
import 'package:match_up_sports/models/reserva.dart';
import 'package:match_up_sports/services/quadra_service.dart';
import 'package:match_up_sports/services/reserva_service.dart';

class HomeScreen extends StatefulWidget {
  final int initialTab;

  const HomeScreen({super.key, this.initialTab = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _currentTab;
  String _selectedSport = 'Todos';
  RangeValues _priceRange = const RangeValues(10, 200);
  List<Map<String, dynamic>> _courts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
    _loadQuadras();
  }

  Future<void> _loadQuadras() async {
    try {
      final quadras = await QuadraService.getQuadras();
      setState(() {
        _courts = quadras
            .map((q) => {
                  'id': q.id,
                  'name': q.identificacao,
                  'sport': q.esporte ?? 'Futebol',
                  'location': q.descricao,
                  'distance': '',
                  'price': q.valorHora != null
                      ? q.valorHora!.toStringAsFixed(2)
                      : '—',
                  'available': true,
                  'valor': q.valorHora ?? 0.0,
                })
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredCourts {
    var filtered = _courts;

    if (_selectedSport != 'Todos') {
      filtered = filtered.where((c) => c['sport'] == _selectedSport).toList();
    }
    
    filtered = filtered.where((c) {
      final double valor = (c['valor'] as double?) ?? 0.0;
      return valor >= _priceRange.start && valor <= _priceRange.end;
    }).toList();
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _currentTab,
          children: [
            _HomeTab(
              selectedSport: _selectedSport,
              priceRange: _priceRange,
              filteredCourts: _filteredCourts,
              onSportSelected: (sport) =>
                  setState(() => _selectedSport = sport),
              onPriceChanged: (range) =>
                  setState(() => _priceRange = range),
              isLoading: _isLoading,
            ),
            _MatchTab(),
            const MinhasReservasTab(), 
            const _PerfilTab(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.grayLight)),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentTab,
        onTap: (index) => setState(() => _currentTab = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.gray,
        selectedLabelStyle:
            GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 11),
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Match',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Reservas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

// ── Aba Home ─────────────────────────────────────────────────────────────────
class _HomeTab extends StatefulWidget {
  final String selectedSport;
  final RangeValues priceRange;
  final List<Map<String, dynamic>> filteredCourts;
  final Function(String) onSportSelected;
  final Function(RangeValues) onPriceChanged;
  final bool isLoading;

  const _HomeTab({
    required this.selectedSport,
    required this.priceRange,
    required this.filteredCourts,
    required this.onSportSelected,
    required this.onPriceChanged,
    required this.isLoading,
  });

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: AppColors.dark,
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Olá, Jogador! 👋',
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                color: AppColors.gray,
                              ),
                            ),
                            Text(
                              'Onde vai jogar hoje?',
                              style: GoogleFonts.dmSans(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.notifications_outlined,
                              color: AppColors.white, size: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppColors.white.withOpacity(0.12)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search,
                              color: AppColors.gray, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            'Buscar quadras próximas...',
                            style: GoogleFonts.dmSans(
                                fontSize: 14, color: AppColors.gray),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sistema Match',
                            style: GoogleFonts.bebasNeue(
                              fontSize: 22,
                              color: AppColors.white,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Encontre jogadores e complete seu time agora mesmo!',
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: AppColors.white.withOpacity(0.85),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Ver partidas',
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Text('⚽🏐🏀', style: TextStyle(fontSize: 32)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SectionHeader(
                  title: 'Quadras disponíveis',
                  actionLabel: 'Ver todas',
                  onAction: () => context.go(AppRoutes.quadras),
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: ['Todos', 'Futebol', 'Vôlei', 'Basquete']
                      .map((sport) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: SportChip(
                              label: sport,
                              emoji: _sportEmoji(sport),
                              isSelected: widget.selectedSport == sport,
                              onTap: () => widget.onSportSelected(sport),
                            ),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filtro de Preço',
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.dark,
                          ),
                        ),
                        // Mostra a faixa de preço atualizada dinamicamente
                        Text(
                          'R\$ ${widget.priceRange.start.toStringAsFixed(0)} - R\$ ${widget.priceRange.end.toStringAsFixed(0)}',
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    RangeSlider(
                      values: widget.priceRange,
                      min: 10,
                      max: 200,
                      divisions: 38, // 38 divisões cria passos de R$ 5
                      labels: RangeLabels(
                        'R\$ ${widget.priceRange.start.toStringAsFixed(0)}',
                        'R\$ ${widget.priceRange.end.toStringAsFixed(0)}',
                      ),
                      activeColor: AppColors.primary,
                      inactiveColor: AppColors.grayLight,
                      onChanged: (RangeValues newRange) {
                        widget.onPriceChanged(newRange);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: isLoading
              ? const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                )
              : widget.filteredCourts.isEmpty
                  ? SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            children: [
                              const Text('🏟️', style: TextStyle(fontSize: 48)),
                              const SizedBox(height: 12),
                              Text(
                                'Nenhuma quadra encontrada',
                                style: GoogleFonts.dmSans(
                                  fontSize: 16,
                                  color: AppColors.gray,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final court = widget.filteredCourts[index];
                          return CourtCard(
                            name: court['name'],
                            sport: court['sport'],
                            location: court['location'],
                            distance: court['distance'],
                            pricePerHour: court['price'],
                            isAvailable: court['available'],
                            onTap: () => _showReservaDialog(context, court),
                          );
                        },
                        childCount: widget.filteredCourts.length,
                      ),
                    ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }

  String _sportEmoji(String sport) {
    switch (sport) {
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

  Future<void> _showReservaDialog(BuildContext context, Map<String, dynamic> court) async {
    DateTime selectedDate = DateTime.now();
    List<Map<String, int>>? availableSlots;
    bool loadingSlots = false;
    int? selectedSlotIndex;
    bool slotsLoaded = false;

    String fmt(int hhmm) {
      final h = (hhmm ~/ 100).toString().padLeft(2, '0');
      final m = (hhmm % 100).toString().padLeft(2, '0');
      return '$h:$m';
    }

    Future<void> loadSlots(void Function(void Function()) setStateDialog) async {
      setStateDialog(() {
        loadingSlots = true;
        availableSlots = null;
        selectedSlotIndex = null;
      });

      try {
        final dateStr = selectedDate.toIso8601String().split('T').first;
        final slots = await ReservaService.getAvailableSlots(quadraId: court['id'], date: dateStr);
        final filtered = slots.where((s) => (s['start'] ?? 0) >= 600).toList();
        setStateDialog(() {
          availableSlots = filtered;
          selectedSlotIndex = filtered.isNotEmpty ? 0 : null;
          slotsLoaded = true;
        });
      } catch (_) {
        setStateDialog(() {
          availableSlots = [];
          selectedSlotIndex = null;
          slotsLoaded = true;
        });
      } finally {
        setStateDialog(() => loadingSlots = false);
      }
    }

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          if (!slotsLoaded && !loadingSlots) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              loadSlots(setStateDialog);
            });
          }

          return AlertDialog(
            title: Text('Reservar ${court['name']}'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(selectedDate.toIso8601String().split('T').first),
                      ),
                      TextButton(
                        onPressed: () async {
                          final d = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (d != null) {
                            setStateDialog(() {
                              selectedDate = d;
                              slotsLoaded = false;
                            });
                            await loadSlots(setStateDialog);
                          }
                        },
                        child: const Text('Data'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (loadingSlots) const Center(child: CircularProgressIndicator()),
                  if (!loadingSlots && availableSlots == null)
                    ElevatedButton(onPressed: () => loadSlots(setStateDialog), child: const Text('Buscar horários disponíveis')),
                  if (!loadingSlots && availableSlots != null && availableSlots!.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('Nenhum horário disponível para a data selecionada.'),
                    ),
                  if (!loadingSlots && availableSlots != null && availableSlots!.isNotEmpty)
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 240),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: availableSlots!.length,
                        itemBuilder: (context, i) {
                          final s = availableSlots![i];
                          final label = '${fmt(s['start'] ?? 0)} — ${fmt(s['end'] ?? 0)}';
                          final selected = selectedSlotIndex == i;
                          return ListTile(
                            title: Text(label),
                            trailing: selected ? const Icon(Icons.check_circle, color: Colors.green) : null,
                            onTap: () => setStateDialog(() => selectedSlotIndex = i),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancelar')),
              ElevatedButton(
                onPressed: () async {
                  if (availableSlots == null || availableSlots!.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nenhum horário disponível.')));
                    return;
                  }

                  if (selectedSlotIndex == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecione um horário disponível antes de reservar.')));
                    return;
                  }

                  final chosen = availableSlots![selectedSlotIndex!];
                  final hi = chosen['start']!;
                  final hf = chosen['end']!;
                  final dateStr = selectedDate.toIso8601String().split('T').first;

                  try {
                    await ReservaService.createReserva(
                      quadraId: court['id'],
                      data: dateStr,
                      horaInicio: hi,
                      horaFim: hf,
                    );
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reserva criada com sucesso')));
                  } catch (e) {
                    final errorMessage = e.toString().replaceFirst('Exception: ', '');
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
                  }
                },
                child: const Text('Reservar'),
              ),
            ],
          );
        });
      },
    );
  }
}

// ── Aba Match ─────────────────────────────────────────────────────────────────
class _MatchTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('⚡', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text(
            'Sistema Match',
            style: GoogleFonts.bebasNeue(
                fontSize: 32, color: AppColors.dark, letterSpacing: 1),
          ),
          const SizedBox(height: 8),
          Text(
            'Em breve: encontre jogadores\ne complete seu time!',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(fontSize: 15, color: AppColors.gray),
          ),
        ],
      ),
    );
  }
}

// ── Aba Reservas ──────────────────────────────────────────────────────────────
class MinhasReservasTab extends StatefulWidget {
  const MinhasReservasTab({super.key});

  @override
  State<MinhasReservasTab> createState() => _MinhasReservasTabState();
}

class _MinhasReservasTabState extends State<MinhasReservasTab> {
  List<Reserva> _reservas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReservas();
  }

  Future<void> _loadReservas() async {
    try {
      final res = await ReservaService.getMinhasReservas();
      setState(() {
        _reservas = res;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_reservas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📅', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(
              'Minhas Reservas',
              style: GoogleFonts.bebasNeue(
                  fontSize: 32, color: AppColors.dark, letterSpacing: 1),
            ),
            const SizedBox(height: 8),
            Text(
              'Você ainda não possui reservas.',
              style: GoogleFonts.dmSans(fontSize: 15, color: AppColors.gray),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _reservas.length,
      itemBuilder: (context, index) {
        final r = _reservas[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.event),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Data: ${r.data}',
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Text(
                  'Quadra: ${r.quadraId}',
                  style: GoogleFonts.dmSans(),
                ),

                Text(
                  '${Reserva.formatarHora(r.horaInicio)} às '
                  '${Reserva.formatarHora(r.horaFim)}',
                  style: GoogleFonts.dmSans(
                    color: AppColors.gray,
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.sports_soccer),
                    label: const Text('Criar Partida'),
                    onPressed: () {
                      context.push('/criar-partida/${r.id}');
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Aba Perfil ────────────────────────────────────────────────────────────────
class _PerfilTab extends StatefulWidget {
  const _PerfilTab();

  @override
  State<_PerfilTab> createState() => _PerfilTabState();
}

class _PerfilTabState extends State<_PerfilTab> {
  final _authService = AuthService();
  bool? _isOwner;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserType();
  }

  Future<void> _loadUserType() async {
    final tipo = await _authService.getTipo();
    setState(() {
      _isOwner = tipo == 1;
      _isLoading = false;
    });
  }

  void _logout(BuildContext context) async {
    await _authService.logout();
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('👤', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text(
            'Meu Perfil',
            style: GoogleFonts.bebasNeue(
                fontSize: 32, color: AppColors.dark, letterSpacing: 1),
          ),
          const SizedBox(height: 8),
          Text(
            'Gerencie sua conta aqui.',
            style: GoogleFonts.dmSans(fontSize: 15, color: AppColors.gray),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                if (_isOwner == true) ...[
                  ElevatedButton.icon(
                    onPressed: () => context.go(AppRoutes.criarEstabelecimento),
                    icon: const Icon(Icons.business, size: 18),
                    label: const Text('Cadastrar Estabelecimento'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => context.go(AppRoutes.criarQuadra),
                    icon: const Icon(Icons.sports_soccer, size: 18),
                    label: const Text('Cadastrar Quadra'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                OutlinedButton.icon(
                  onPressed: () => _logout(context),
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text('Sair da conta'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}