import 'package:go_router/go_router.dart';
import 'package:match_up_sports/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:match_up_sports/services/auth_service.dart';
import 'package:match_up_sports/services/usuario_service.dart';
import 'package:match_up_sports/services/partida_service.dart';
import 'package:match_up_sports/theme/app_theme.dart';
import 'package:match_up_sports/widgets/app_widgets.dart';
import 'package:match_up_sports/widgets/session_switcher.dart';
import 'package:match_up_sports/models/reserva.dart';
import 'package:match_up_sports/models/partida.dart';
import 'package:match_up_sports/services/quadra_service.dart';
import 'package:match_up_sports/services/reserva_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';



class HomeScreen extends StatefulWidget {

  final int initialTab;



  const HomeScreen({super.key, this.initialTab = 0});



  @override

  State<HomeScreen> createState() => _HomeScreenState();

}



class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<_MatchTabState> _matchTabKey = GlobalKey<_MatchTabState>();
  final GlobalKey<_MinhasPartidasTabState> _minhasPartidasTabKey = GlobalKey<_MinhasPartidasTabState>();
  final GlobalKey<_MinhasReservasTabState> _reservasTabKey =
    GlobalKey<_MinhasReservasTabState>();

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

  Future<void> _refreshTodasPartidas() async {
    await _matchTabKey.currentState?.refreshPartidas();
    await _minhasPartidasTabKey.currentState?.refreshPartidas();
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

        child: Column(

          children: [

            SessionSwitcher(

              onSessionChanged: () {

                setState(() {

                  _loadQuadras();

                });

              },

            ),

            Expanded(

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
                    onReservaCriada: () async {
                      await _reservasTabKey.currentState?.refreshReservas();
                    },
                    isLoading: _isLoading,

                  ),
                  _MatchTab(key: _matchTabKey),
                  _MinhasPartidasTab(key: _minhasPartidasTabKey),
                  MinhasReservasTab(key: _reservasTabKey),
                  const _PerfilTabWidget(), // Sua aba de perfil completa e integrada

                ],

              ),

            ),

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
            icon: Icon(Icons.sports_soccer_outlined),
            activeIcon: Icon(Icons.sports_soccer),
            label: 'Minhas',
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
  final Future<void> Function()? onReservaCriada;
  final bool isLoading;



  const _HomeTab({

    required this.selectedSport,

    required this.priceRange,

    required this.filteredCourts,

    required this.onSportSelected,

    required this.onPriceChanged,

    required this.isLoading,
    this.onReservaCriada,
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

                      divisions: 38,

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



  Future<void> _showReservaDialog(

      BuildContext context, Map<String, dynamic> court) async {

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



    Future<void> loadSlots(

        void Function(void Function()) setStateDialog) async {

      setStateDialog(() {

        loadingSlots = true;

        availableSlots = null;

        selectedSlotIndex = null;

      });



      try {

        final dateStr = selectedDate.toIso8601String().split('T').first;

        final slots = await ReservaService.getAvailableSlots(

            quadraId: court['id'], date: dateStr);

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

                        child: Text(

                            selectedDate.toIso8601String().split('T').first),

                      ),

                      TextButton(

                        onPressed: () async {

                          final d = await showDatePicker(

                            context: context,

                            initialDate: selectedDate,

                            firstDate: DateTime.now(),

                            lastDate:

                                DateTime.now().add(const Duration(days: 365)),

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

                  if (loadingSlots)

                    const Center(child: CircularProgressIndicator()),

                  if (!loadingSlots && availableSlots == null)

                    ElevatedButton(

                        onPressed: () => loadSlots(setStateDialog),

                        child: const Text('Buscar horários disponíveis')),

                  if (!loadingSlots &&

                      availableSlots != null &&

                      availableSlots!.isEmpty)

                    const Padding(

                      padding: EdgeInsets.symmetric(vertical: 12),

                      child: Text(

                          'Nenhum horário disponível para a data selecionada.'),

                    ),

                  if (!loadingSlots &&

                      availableSlots != null &&

                      availableSlots!.isNotEmpty)

                    ConstrainedBox(

                      constraints: const BoxConstraints(maxHeight: 240),

                      child: ListView.builder(

                        shrinkWrap: true,

                        itemCount: availableSlots!.length,

                        itemBuilder: (context, i) {

                          final s = availableSlots![i];

                          final label =

                              '${fmt(s['start'] ?? 0)} — ${fmt(s['end'] ?? 0)}';

                          final selected = selectedSlotIndex == i;

                          return ListTile(

                            title: Text(label),

                            trailing: selected

                                ? const Icon(Icons.check_circle,

                                    color: Colors.green)

                                : null,

                            onTap: () =>

                                setStateDialog(() => selectedSlotIndex = i),

                          );

                        },

                      ),

                    ),

                ],

              ),

            ),

            actions: [

              TextButton(

                  onPressed: () => Navigator.of(ctx).pop(),

                  child: const Text('Cancelar')),

              ElevatedButton(

                onPressed: () async {

                  if (availableSlots == null || availableSlots!.isEmpty) {

                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(

                        content: Text('Nenhum horário disponível.')));

                    return;

                  }



                  if (selectedSlotIndex == null) {

                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(

                        content: Text(

                            'Selecione um horário disponível antes de reservar.')));

                    return;

                  }



                  final chosen = availableSlots![selectedSlotIndex!];

                  final hi = chosen['start']!;

                  final hf = chosen['end']!;

                  final dateStr =

                      selectedDate.toIso8601String().split('T').first;



                  try {

                    await ReservaService.createReserva(

                      quadraId: court['id'],

                      data: dateStr,

                      horaInicio: hi,

                      horaFim: hf,

                    );
                    await widget.onReservaCriada?.call();
                    await (context.findAncestorStateOfType<_HomeScreenState>())
                        ?._reservasTabKey
                        .currentState
                        ?.refreshReservas();
                    Navigator.of(ctx).pop();

                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(

                        content: Text('Reserva criada com sucesso')));

                  } catch (e) {

                    final errorMessage =

                        e.toString().replaceFirst('Exception: ', '');

                    ScaffoldMessenger.of(context)

                        .showSnackBar(SnackBar(content: Text(errorMessage)));

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

class _MatchTab extends StatefulWidget {

  const _MatchTab({super.key});



  @override

  State<_MatchTab> createState() => _MatchTabState();

}



class _MatchTabState extends State<_MatchTab> {
  final TextEditingController _conviteController =
      TextEditingController();
  List<Partida> _partidas = [];

  bool _isLoading = true;

  bool _isJoining = false;

  int? _meuUserId;



  @override

  void initState() {

    super.initState();

    _carregarDadosIniciais();

  }

  Future<void> refreshPartidas() async {
    await _loadPartidas();
  }

  // Carrega o ID do usuário logado lendo o Token antes de puxar as partidas
  Future<void> _carregarDadosIniciais() async {

    try {

      final token = await AuthService().getToken();

      if (token != null) {

        final parts = token.split('.');

        if (parts.length == 3) {

          final payloadString = String.fromCharCodes(

              base64Url.decode(base64Url.normalize(parts[1])));

          final payloadMap = jsonDecode(payloadString);

          _meuUserId = payloadMap['id'];

        }

      }

    } catch (e) {

      debugPrint('Erro ao extrair ID do token: $e');

    }
    await (context.findAncestorStateOfType<_HomeScreenState>())
        ?._refreshTodasPartidas();
  }



  Future<void> _loadPartidas() async {

    try {

      final partidas = await PartidaService.obterPartidasDisponiveis();

      setState(() {

        _partidas = partidas;

        _isLoading = false;

      });

    } catch (e) {

      setState(() => _isLoading = false);

      if (mounted) {

        ScaffoldMessenger.of(context).showSnackBar(

          SnackBar(

            content: Text('Erro ao carregar partidas: $e'),

            backgroundColor: AppColors.error,

          ),

        );

      }

    }

  }



  Future<void> _entrarNaPartida(int partidaId) async {

    setState(() => _isJoining = true);

    try {

      await PartidaService.entrarPartida(partidaId);

      if (mounted) {

        ScaffoldMessenger.of(context).showSnackBar(

          const SnackBar(

            content: Text('Você entrou na partida com sucesso! ⚽'),

            backgroundColor: Colors.green,

          ),

        );
        await (context.findAncestorStateOfType<_HomeScreenState>())
            ?._refreshTodasPartidas();
      }

    } catch (e) {

      if (mounted) {

        final errorMessage = e.toString().replaceFirst('Exception: ', '');

        ScaffoldMessenger.of(context).showSnackBar(

          SnackBar(

              content: Text(errorMessage), backgroundColor: AppColors.error),

        );

      }

    } finally {

      setState(() => _isJoining = false);

    }

  }



  Future<void> _sairDaPartida(int partidaId) async {

    setState(() => _isJoining = true);

    try {

      await PartidaService.sairDaPartida(partidaId);

      if (mounted) {

        ScaffoldMessenger.of(context).showSnackBar(

          const SnackBar(

            content: Text('Você saiu da partida.'),

            backgroundColor: Colors.orange,

          ),

        );
        await (context.findAncestorStateOfType<_HomeScreenState>())
            ?._refreshTodasPartidas();
      }

    } catch (e) {

      if (mounted) {

        final errorMessage = e.toString().replaceFirst('Exception: ', '');

        ScaffoldMessenger.of(context).showSnackBar(

          SnackBar(

              content: Text(errorMessage), backgroundColor: AppColors.error),

        );

      }

    } finally {

      setState(() => _isJoining = false);

    }

  }



  void _mostrarJogadores(BuildContext context, Partida partida) {

    showModalBottomSheet(

      context: context,

      shape: const RoundedRectangleBorder(

        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),

      ),

      builder: (context) {

        return Padding(

          padding: const EdgeInsets.all(24.0),

          child: Column(

            mainAxisSize: MainAxisSize.min,

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              Text(

                'Jogadores Confirmados (${partida.quantidade_atual}/${partida.vagas})',

                style: GoogleFonts.bebasNeue(

                    fontSize: 24, color: AppColors.dark, letterSpacing: 1),

              ),

              const SizedBox(height: 16),

              if (partida.nomesJogadores.isEmpty)

                Text(

                  'Ninguém entrou nesta partida ainda. Seja o primeiro!',

                  style: GoogleFonts.dmSans(color: AppColors.gray),

                )

              else

                Flexible(

                  child: ListView.builder(

                    shrinkWrap: true,

                    itemCount: partida.nomesJogadores.length,

                    itemBuilder: (context, i) {

                      return ListTile(

                        contentPadding: EdgeInsets.zero,

                        leading: CircleAvatar(

                          backgroundColor: AppColors.primary.withOpacity(0.1),

                          child: const Icon(Icons.person,

                              color: AppColors.primary),

                        ),

                        title: Text(

                          partida.nomesJogadores[i],

                          style: GoogleFonts.dmSans(

                            fontWeight: FontWeight.w600,

                            color: AppColors.dark,

                          ),

                        ),

                      );

                    },

                  ),

                ),

            ],

          ),

        );

      },

    );

  }

  void _mostrarJogadoresGerenciavel(
    BuildContext context,
    Partida partida,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return ListView.builder(
          itemCount: partida.nomesJogadores.length,
          itemBuilder: (_, i) {

            return ListTile(
              leading: const Icon(Icons.person),
              title: Text(partida.nomesJogadores[i]),

              trailing: partida.idsUsuarios[i] == partida.criadorId
                  ? const Text("Dono")
                  : IconButton(
                      icon: const Icon(
                        Icons.person_remove,
                        color: Colors.red,
                      ),
                      onPressed: () async {
                        final confirmar = await showDialog<bool>(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: const Text('Remover jogador'),
                            content: Text(
                              'Deseja realmente remover "${partida.nomesJogadores[i]}" desta partida?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dialogContext, false),
                                child: const Text('Cancelar'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                onPressed: () => Navigator.pop(dialogContext, true),
                                child: const Text(
                                  'Remover',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (confirmar != true) {
                          return;
                        }

                        try {
                          await PartidaService.removerJogador(
                            partida.id,
                            partida.idsUsuarios[i],
                          );

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Jogador removido da partida.'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }

                          Navigator.pop(context);

                          await (context.findAncestorStateOfType<_HomeScreenState>())
                              ?._refreshTodasPartidas();
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  e.toString().replaceFirst('Exception: ', ''),
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                    ),
            );
          },
        );
      },
    );
  }

  Future<void> _alterarTipoPartida(
    int partidaId,
    String tipo,
  ) async {
    try {
      await PartidaService.alterarTipo(
        partidaId,
        tipo,
      );

      await (context.findAncestorStateOfType<_HomeScreenState>())
    ?._refreshTodasPartidas();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              tipo == 'ABERTA'
                  ? 'Partida aberta para novos jogadores.'
                  : 'Partida fechada para novos jogadores.',
            ),
            backgroundColor: tipo == 'ABERTA' ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _gerarConvite(int partidaId) async {
    try {
      final convite = await PartidaService.gerarConvite(partidaId);
      if (kIsWeb) {
        await Clipboard.setData(
          ClipboardData(text: convite),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Link do convite copiado para a área de transferência!',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        await Share.share(
          '⚽ Você foi convidado para uma partida!\n$convite',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao gerar convite: $e'), 
                   backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _cancelarPartida(int partidaId) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Cancelar Partida',
          style: GoogleFonts.bebasNeue(
            fontSize: 24,
            color: AppColors.dark,
            letterSpacing: 1,
          ),
        ),
        content: Text(
          'Tem certeza que deseja cancelar esta partida?\n\nTodos os jogadores serão removidos e esta ação não poderá ser desfeita.',
          style: GoogleFonts.dmSans(fontSize: 14),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Voltar',
              style: GoogleFonts.dmSans(
                color: AppColors.gray,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Cancelar Partida',
              style: GoogleFonts.dmSans(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      await PartidaService.cancelarPartida(partidaId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Partida cancelada com sucesso'),
            backgroundColor: Colors.green,
          ),
        );

        await (context.findAncestorStateOfType<_HomeScreenState>())
            ?._refreshTodasPartidas();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _entrarPorConvite() async {
    final token = _conviteController.text.trim();

    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe um convite'),
        ),
      );
      return;
    }

    try {
      await PartidaService.aceitarConvite(token);

      _conviteController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Você entrou na partida com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );

        await (context.findAncestorStateOfType<_HomeScreenState>())
            ?._refreshTodasPartidas();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceFirst('Exception: ', ''),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override

  Widget build(BuildContext context) {

    if (_isLoading) {

      return const Center(child: CircularProgressIndicator());

    }



    if (_partidas.isEmpty) {

      return Center(

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            const Text('⚡', style: TextStyle(fontSize: 56)),

            const SizedBox(height: 16),

            Text(

              'Nenhuma partida disponível',

              style: GoogleFonts.bebasNeue(

                  fontSize: 24, color: AppColors.dark, letterSpacing: 1),

            ),

            const SizedBox(height: 8),

            Text(

              'Volte em breve!',

              textAlign: TextAlign.center,

              style: GoogleFonts.dmSans(fontSize: 15, color: AppColors.gray),

            ),

          ],

        ),

      );

    }



    return CustomScrollView(

      slivers: [

        SliverToBoxAdapter(

          child: Container(

            color: AppColors.dark,

            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Text(

                  'Partidas Disponíveis',

                  style: GoogleFonts.bebasNeue(

                    fontSize: 28,

                    color: AppColors.white,

                    letterSpacing: 1,

                  ),

                ),

                const SizedBox(height: 8),

                Text(

                  '${_partidas.length} partida(s) aberta(s)',

                  style: GoogleFonts.dmSans(

                    fontSize: 13,

                    color: AppColors.gray,

                  ),

                ),

              ],

            ),

          ),

        ),
        // CARD DE CONVITE
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.link,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Entrar com convite',
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _conviteController,
                      decoration: InputDecoration(
                        hintText: 'Cole o token do convite',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.login),
                        label: const Text('Entrar na partida'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        onPressed: _entrarPorConvite,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverPadding(

          padding: const EdgeInsets.all(16),

          sliver: SliverList(

            delegate: SliverChildBuilderDelegate(

              (context, index) {

                final partida = _partidas[index];

                final int vagasDisponiveis =

                    partida.vagas - partida.quantidade_atual;



                final bool isCheia = vagasDisponiveis <= 0;

                final bool estaNaPartida = _meuUserId != null &&

                    partida.idsUsuarios.contains(_meuUserId);
                final bool souDono = _meuUserId == partida.criadorId;
                return Card(

                  margin: const EdgeInsets.only(bottom: 16),

                  shape: RoundedRectangleBorder(

                    borderRadius: BorderRadius.circular(12),

                    side: const BorderSide(color: AppColors.grayLight),

                  ),

                  child: InkWell(

                    borderRadius: BorderRadius.circular(12),

                    onTap: () => _mostrarJogadores(context, partida),

                    child: Padding(

                      padding: const EdgeInsets.all(16),

                      child: Column(

                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [

                          Row(
                            children: [

                              Expanded(

                                child: Text(
                                  partida.quadraNome ?? 'Partida #${partida.id}',
                                  style: GoogleFonts.dmSans(

                                    fontSize: 16,

                                    fontWeight: FontWeight.w700,

                                    color: AppColors.dark,

                                  ),

                                ),

                              ),

                              if (souDono)
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert),
                                  onSelected: (value) async {
                                    switch (value) {
                                      case 'abrir':
                                        await _alterarTipoPartida(partida.id, 'ABERTA');
                                        break;

                                      case 'fechar':
                                        await _alterarTipoPartida(partida.id, 'FECHADA');
                                        break;

                                      case 'convite':
                                        await _gerarConvite(partida.id);
                                        break;

                                      case 'cancelar':
                                        await _cancelarPartida(partida.id);
                                        break;

                                      case 'gerenciar':
                                        _mostrarJogadoresGerenciavel(context, partida);
                                        break;
                                    }
                                  },
                                  itemBuilder: (_) => [
                                    const PopupMenuItem(
                                      value: 'abrir',
                                      child: Text('Abrir partida'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'fechar',
                                      child: Text('Fechar partida'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'gerenciar',
                                      child: Text('Gerenciar jogadores'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'convite',
                                      child: Text('Gerar convite'),
                                    ),
                                    const PopupMenuDivider(),
                                    const PopupMenuItem(
                                      value: 'cancelar',
                                      child: Text(
                                        'Cancelar partida',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              Container(

                                padding: const EdgeInsets.symmetric(

                                    horizontal: 12, vertical: 6),

                                decoration: BoxDecoration(

                                  color: vagasDisponiveis > 0

                                      ? AppColors.primary

                                      : AppColors.gray,

                                  borderRadius: BorderRadius.circular(20),

                                ),

                                child: Text(

                                  '$vagasDisponiveis vaga${vagasDisponiveis != 1 ? 's' : ''}',

                                  style: GoogleFonts.dmSans(

                                    fontSize: 12,

                                    fontWeight: FontWeight.w600,

                                    color: AppColors.white,

                                  ),

                                ),

                              ),

                            ],

                          ),

                          const SizedBox(height: 12),

                          Row(

                            children: [

                              const Icon(Icons.location_on_outlined,

                                  size: 16, color: AppColors.gray),

                              const SizedBox(width: 8),

                              Expanded(

                                child: Text(

                                  'Local: ${partida.estabelecimentoNome ?? 'Não informado'}',

                                  style: GoogleFonts.dmSans(

                                      fontSize: 13, color: AppColors.gray),

                                ),

                              ),

                            ],

                          ),

                          const SizedBox(height: 8),

                          Row(

                            children: [

                              const Icon(Icons.calendar_today_outlined,

                                  size: 16, color: AppColors.gray),

                              const SizedBox(width: 8),

                              Text(

                                '${partida.formatarData()} • ${partida.formatarHora(partida.horaInicio)} às ${partida.formatarHora(partida.horaFim)}',

                                style: GoogleFonts.dmSans(

                                    fontSize: 13, color: AppColors.gray),

                              ),

                            ],

                          ),

                          const SizedBox(height: 8),

                          Row(

                            children: [

                              const Icon(Icons.person_outline,

                                  size: 16, color: AppColors.gray),

                              const SizedBox(width: 8),

                              Expanded(

                                child: Text(

                                  'Organizado por: ${partida.criadorNome ?? 'Anônimo'}',

                                  style: GoogleFonts.dmSans(

                                      fontSize: 13, color: AppColors.gray),

                                ),

                              ),

                              const Icon(Icons.people_outline,

                                  size: 16, color: AppColors.gray),

                              const SizedBox(width: 4),

                              Text(

                                '${partida.quantidade_atual}/${partida.vagas}',

                                style: GoogleFonts.dmSans(

                                  fontSize: 13,

                                  fontWeight: FontWeight.bold,

                                  color: AppColors.gray,

                                ),

                              ),

                            ],

                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.sports_soccer_outlined,
                                  size: 16, color: AppColors.gray),
                              const SizedBox(width: 8),
                              Text(
                                'Esporte: ${partida.esporte ?? 'Não informado'}',
                                style: GoogleFonts.dmSans(
                                    fontSize: 13, color: AppColors.gray),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.door_front_door_outlined,
                                  size: 16, color: AppColors.gray),
                              const SizedBox(width: 8),
                              Text(
                                'Tipo: ${partida.tipo.toString().split('.').last.toLowerCase() == 'aberta' ? 'Aberta' : 'Fechada'}',
                                style: GoogleFonts.dmSans(
                                    fontSize: 13, color: AppColors.gray),
                              ),
                            ],
                          ),
                          // Divisor e Botão Inteligente (Entrar/Sair)
                          const SizedBox(height: 16),

                          const Divider(height: 1, color: AppColors.grayLight),

                          const SizedBox(height: 16),

                          SizedBox(

                            width: double.infinity,

                            child: ElevatedButton(

                              onPressed: _isJoining ||
                                      souDono ||
                                      (isCheia && !estaNaPartida)

                                  ? null
                                  : () => estaNaPartida

                                      ? _sairDaPartida(partida.id)

                                      : _entrarNaPartida(partida.id),

                              style: ElevatedButton.styleFrom(

                                backgroundColor: estaNaPartida

                                    ? Colors.redAccent

                                    : AppColors.primary,

                                padding: const EdgeInsets.symmetric(vertical: 12),

                                shape: RoundedRectangleBorder(

                                  borderRadius: BorderRadius.circular(8),

                                ),

                              ),

                              child: _isJoining
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  souDono
                                      ? 'Você é o Organizador'
                                      : estaNaPartida
                                          ? 'Sair da Partida'

                                          : 'Entrar na Partida',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
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

              },

              childCount: _partidas.length,

            ),

          ),

        ),

      ],

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

  Future<void> refreshReservas() async {
    await _loadReservas();
  }

  Future<void> _loadReservas() async {

    try {

      final res = await ReservaService.getMinhasReservas();

      setState(() {

        _reservas = res;

        _isLoading = false;

      });

    } catch (e) {

      setState(() => _isLoading = false);

      if (mounted) {

        ScaffoldMessenger.of(context).showSnackBar(

          SnackBar(

            content: Text('Erro ao buscar reservas: $e'),

            backgroundColor: Colors.redAccent,

          ),

        );

      }

    }

  }



  Future<void> _cancelarReserva(int reservaId) async {

    final confirmar = await showDialog<bool>(

      context: context,

      builder: (context) => AlertDialog(

        title: Text(

          'Cancelar Reserva',

          style: GoogleFonts.bebasNeue(

              fontSize: 22, color: AppColors.dark, letterSpacing: 1),

        ),

        content: Text(

          'Tem certeza que deseja cancelar esta reserva? Esta ação não pode ser desfeita.',

          style: GoogleFonts.dmSans(fontSize: 15),

        ),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

        actions: [

          TextButton(

            onPressed: () => Navigator.pop(context, false),

            child: Text('Não',

                style: GoogleFonts.dmSans(

                    color: AppColors.gray, fontWeight: FontWeight.bold)),

          ),

          ElevatedButton(

            style: ElevatedButton.styleFrom(

              backgroundColor: Colors.redAccent,

              shape: RoundedRectangleBorder(

                  borderRadius: BorderRadius.circular(8)),

            ),

            onPressed: () => Navigator.pop(context, true),

            child: Text('Sim, cancelar',

                style: GoogleFonts.dmSans(

                    color: Colors.white, fontWeight: FontWeight.bold)),

          ),

        ],

      ),

    );



    if (confirmar == true) {

      try {

        await ReservaService.cancelarReserva(reservaId);

        if (mounted) {

          ScaffoldMessenger.of(context).showSnackBar(

            const SnackBar(

              content: Text('Reserva cancelada com sucesso!'),

              backgroundColor: Colors.green,

            ),

          );
          await refreshReservas(); // Recarrega a lista para sumir com o card
        }

      } catch (e) {

        if (mounted) {

          final errorMessage = e.toString().replaceFirst('Exception: ', '');

          ScaffoldMessenger.of(context).showSnackBar(

            SnackBar(

                content: Text(errorMessage), backgroundColor: AppColors.error),

          );

        }

      }

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

          shape: RoundedRectangleBorder(

            borderRadius: BorderRadius.circular(12),

            side: const BorderSide(color: AppColors.grayLight),

          ),

          child: Padding(

            padding: const EdgeInsets.all(16),

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Row(

                  children: [

                    const Icon(Icons.event, color: AppColors.dark),

                    const SizedBox(width: 12),

                    Expanded(

                      child: Text(

                        'Data: ${r.data}',

                        style: GoogleFonts.dmSans(

                          fontWeight: FontWeight.bold,

                          color: AppColors.dark,

                        ),

                      ),

                    ),

                  ],

                ),

                const SizedBox(height: 8),

                Text(

                  'Quadra: ${r.quadraId}',

                  style: GoogleFonts.dmSans(color: AppColors.dark),

                ),

                Text(

                  '${Reserva.formatarHora(r.horaInicio)} às ${Reserva.formatarHora(r.horaFim)}',

                  style: GoogleFonts.dmSans(

                    color: AppColors.gray,

                  ),

                ),

                const SizedBox(height: 16),

                Row(

                  children: [

                    Expanded(

                      child: OutlinedButton.icon(

                        icon: const Icon(Icons.cancel_outlined, size: 18),

                        label: const Text('Cancelar'),

                        style: OutlinedButton.styleFrom(

                          foregroundColor: Colors.redAccent,

                          side: const BorderSide(color: Colors.redAccent),

                          padding: const EdgeInsets.symmetric(vertical: 12),

                          shape: RoundedRectangleBorder(

                              borderRadius: BorderRadius.circular(8)),

                        ),

                        onPressed: () => _cancelarReserva(r.id),

                      ),

                    ),

                    const SizedBox(width: 8),

                    Expanded(

                      child: ElevatedButton.icon(

                        icon: const Icon(Icons.sports_soccer, size: 18),

                        label: const Text('Criar Partida'),

                        style: ElevatedButton.styleFrom(

                          backgroundColor: AppColors.primary,

                          padding: const EdgeInsets.symmetric(vertical: 12),

                          shape: RoundedRectangleBorder(

                              borderRadius: BorderRadius.circular(8)),

                        ),
                        onPressed: () async {
                          final result = await context.push('/criar-partida/${r.id}');

                          if (result == true) {
                            await (context.findAncestorStateOfType<_HomeScreenState>())
                                ?._matchTabKey
                                .currentState
                                ?.refreshPartidas();
                          }
                        },

                      ),

                    ),

                  ],

                ),

              ],

            ),

          ),

        );

      },

    );

  }

}



// ── Aba Perfil (Sua versão completa e editável) ─────────────────────────────────

class _PerfilTabWidget extends StatefulWidget {

  const _PerfilTabWidget();



  @override

  State<_PerfilTabWidget> createState() => _PerfilTabWidgetState();

}



class _PerfilTabWidgetState extends State<_PerfilTabWidget> {

  final _authService = AuthService();

  late Future<Map<String, dynamic>> _usuarioFuture;

  bool _isEditing = false;



  late TextEditingController _nomeController;

  late TextEditingController _emailController;

  late TextEditingController _celularController;



  @override

  void initState() {

    super.initState();

    _usuarioFuture = UsuarioService.getMe();

    _nomeController = TextEditingController();

    _emailController = TextEditingController();

    _celularController = TextEditingController();

  }



  @override

  void dispose() {

    _nomeController.dispose();

    _emailController.dispose();

    _celularController.dispose();

    super.dispose();

  }



  Future<void> _updateUsuario(Map<String, dynamic> usuarioData) async {

    try {

      if (_nomeController.text.isEmpty ||

          _emailController.text.isEmpty ||

          _celularController.text.isEmpty) {

        ScaffoldMessenger.of(context).showSnackBar(

          const SnackBar(content: Text('Todos os campos são obrigatórios')),

        );

        return;

      }



      await UsuarioService.updateUsuario(

        usuarioId: usuarioData['id'],

        nome: _nomeController.text,

        email: _emailController.text,

        celular: _celularController.text,

      );



      setState(() {

        _usuarioFuture = UsuarioService.getMe();

        _isEditing = false;

      });



      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(content: Text('Perfil updated com sucesso!')),

      );

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(content: Text('Erro ao atualizar perfil: $e')),

      );

    }

  }



  void _logout() async {

    showDialog(

      context: context,

      builder: (BuildContext context) {

        return AlertDialog(

          title: const Text('Sair'),

          content: const Text('Tem certeza que deseja sair?'),

          actions: [

            TextButton(

              onPressed: () => Navigator.pop(context),

              child: const Text('Cancelar'),

            ),

            TextButton(

              onPressed: () async {

                await _authService.logout();

                if (mounted) {

                  context.go(AppRoutes.login);

                }

              },

              child: const Text('Sair'),

            ),

          ],

        );

      },

    );

  }



  @override

  Widget build(BuildContext context) {

    return FutureBuilder<Map<String, dynamic>>(

      future: _usuarioFuture,

      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {

          return const Center(child: CircularProgressIndicator());

        }



        if (snapshot.hasError) {

          return Center(

            child: Column(

              mainAxisAlignment: MainAxisAlignment.center,

              children: [

                const Icon(Icons.error_outline, size: 64, color: AppColors.error),

                const SizedBox(height: 16),

                Text(

                  'Erro ao carregar perfil',

                  style: GoogleFonts.dmSans(

                    fontSize: 16,

                    fontWeight: FontWeight.w600,

                  ),

                ),

                const SizedBox(height: 8),

                Text(

                  '${snapshot.error}',

                  style: GoogleFonts.dmSans(

                    fontSize: 14,

                    color: AppColors.gray,

                  ),

                  textAlign: TextAlign.center,

                ),

                const SizedBox(height: 24),

                ElevatedButton(

                  onPressed: () {

                    setState(() {

                      _usuarioFuture = UsuarioService.getMe();

                    });

                  },

                  child: const Text('Tentar novamente'),

                ),

              ],

            ),

          );

        }



        final usuario = snapshot.data!;

        final nome = usuario['nome'] ?? 'Usuário';

        final email = usuario['email'] ?? '';

        final celular = usuario['celular'] ?? '';

        final tipo = usuario['tipo'] ?? 0;

        final isOwner = tipo == 1;



        if (_isEditing && _nomeController.text.isEmpty) {

          _nomeController.text = nome;

          _emailController.text = email;

          _celularController.text = celular;

        }



        return SingleChildScrollView(

          padding: const EdgeInsets.all(20),

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              _buildProfileHeader(nome, email, isOwner),

              const SizedBox(height: 32),

              if (!_isEditing)

                _buildProfileInfo(nome, email, celular, isOwner)

              else

                _buildEditForm(),

              const SizedBox(height: 24),

              if (isOwner && !_isEditing) ...[

                _buildOwnerSection(usuario),

                const SizedBox(height: 24),

              ],

              if (!isOwner && !_isEditing) ...[

                _buildPlayerSection(usuario),

                const SizedBox(height: 24),

              ],

              _buildActionButtons(),

            ],

          ),

        );

      },

    );

  }



  Widget _buildProfileHeader(String nome, String email, bool isOwner) {

    return Container(

      decoration: BoxDecoration(

        gradient: LinearGradient(

          begin: Alignment.topLeft,

          end: Alignment.bottomRight,

          colors: [

            AppColors.primary.withOpacity(0.1),

            AppColors.secondary.withOpacity(0.1),

          ],

        ),

        borderRadius: BorderRadius.circular(20),

        border: Border.all(

          color: AppColors.primary.withOpacity(0.2),

          width: 1,

        ),

      ),

      padding: const EdgeInsets.all(20),

      child: Row(

        children: [

          Container(

            width: 80,

            height: 80,

            decoration: const BoxDecoration(

              shape: BoxShape.circle,

              gradient: LinearGradient(

                begin: Alignment.topLeft,

                end: Alignment.bottomRight,

                colors: [

                  AppColors.primary,

                  AppColors.secondary,

                ],

              ),

            ),

            child: Center(

              child: Text(

                nome.isNotEmpty ? nome[0].toUpperCase() : '👤',

                style: GoogleFonts.bebasNeue(

                  fontSize: 36,

                  color: Colors.white,

                  letterSpacing: 1,

                ),

              ),

            ),

          ),

          const SizedBox(width: 16),

          Expanded(

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Text(

                  nome,

                  style: GoogleFonts.bebasNeue(

                    fontSize: 22,

                    color: AppColors.dark,

                    letterSpacing: 1,

                  ),

                  maxLines: 2,

                  overflow: TextOverflow.ellipsis,

                ),

                const SizedBox(height: 6),

                Container(

                  padding: const EdgeInsets.symmetric(

                    horizontal: 12,

                    vertical: 4,

                  ),

                  decoration: BoxDecoration(

                    color: isOwner ? AppColors.primary : AppColors.secondary,

                    borderRadius: BorderRadius.circular(20),

                  ),

                  child: Text(

                    isOwner ? 'Dono de Quadra' : 'Jogador',

                    style: GoogleFonts.dmSans(

                      fontSize: 12,

                      fontWeight: FontWeight.w600,

                      color: Colors.white,

                    ),

                  ),

                ),

              ],

            ),

          ),

        ],

      ),

    );

  }



  Widget _buildProfileInfo(

      String nome, String email, String celular, bool isOwner) {

    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Text(

          'Informações Pessoais',

          style: GoogleFonts.dmSans(

            fontSize: 16,

            fontWeight: FontWeight.w700,

            color: AppColors.dark,

          ),

        ),

        const SizedBox(height: 16),

        _buildInfoCard(

          icon: Icons.person,

          label: 'Nome',

          value: nome,

          color: AppColors.primary,

        ),

        const SizedBox(height: 12),

        _buildInfoCard(

          icon: Icons.email,

          label: 'E-mail',

          value: email,

          color: AppColors.secondary,

        ),

        const SizedBox(height: 12),

        _buildInfoCard(

          icon: Icons.phone,

          label: 'Telefone',

          value: celular,

          color: Colors.orange,

        ),

      ],

    );

  }



  Widget _buildInfoCard({

    required IconData icon,

    required String label,

    required String value,

    required Color color,

  }) {

    return Container(

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius: BorderRadius.circular(12),

        border: Border.all(

          color: color.withOpacity(0.2),

          width: 1.5,

        ),

      ),

      padding: const EdgeInsets.all(16),

      child: Row(

        children: [

          Container(

            width: 48,

            height: 48,

            decoration: BoxDecoration(

              color: color.withOpacity(0.1),

              borderRadius: BorderRadius.circular(12),

            ),

            child: Center(

              child: Icon(icon, color: color, size: 24),

            ),

          ),

          const SizedBox(width: 16),

          Expanded(

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Text(

                  label,

                  style: GoogleFonts.dmSans(

                    fontSize: 12,

                    color: AppColors.gray,

                    fontWeight: FontWeight.w500,

                  ),

                ),

                const SizedBox(height: 4),

                Text(

                  value,

                  style: GoogleFonts.dmSans(

                    fontSize: 14,

                    fontWeight: FontWeight.w600,

                    color: AppColors.dark,

                  ),

                  overflow: TextOverflow.ellipsis,

                ),

              ],

            ),

          ),

        ],

      ),

    );

  }



  Widget _buildEditForm() {

    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Text(

          'Editar Perfil',

          style: GoogleFonts.dmSans(

            fontSize: 16,

            fontWeight: FontWeight.w700,

            color: AppColors.dark,

          ),

        ),

        const SizedBox(height: 16),

        _buildTextField('Nome', _nomeController),

        const SizedBox(height: 16),

        _buildTextField('E-mail', _emailController),

        const SizedBox(height: 16),

        _buildTextField('Telefone', _celularController),

      ],

    );

  }



  Widget _buildTextField(String label, TextEditingController controller) {

    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Text(

          label,

          style: GoogleFonts.dmSans(

            fontSize: 13,

            fontWeight: FontWeight.w600,

            color: AppColors.dark,

          ),

        ),

        const SizedBox(height: 8),

        TextField(

          controller: controller,

          decoration: InputDecoration(

            hintText: 'Digite $label',

            hintStyle: GoogleFonts.dmSans(color: AppColors.gray),

            contentPadding: const EdgeInsets.symmetric(

              horizontal: 16,

              vertical: 12,

            ),

            border: OutlineInputBorder(

              borderRadius: BorderRadius.circular(12),

              borderSide: const BorderSide(color: AppColors.grayLight),

            ),

            focusedBorder: OutlineInputBorder(

              borderRadius: BorderRadius.circular(12),

              borderSide: const BorderSide(

                color: AppColors.primary,

                width: 2,

              ),

            ),

          ),

          style: GoogleFonts.dmSans(

            fontSize: 14,

            color: AppColors.dark,

          ),

        ),

      ],

    );

  }



  Widget _buildOwnerSection(Map<String, dynamic> usuario) {

    final estabelecimentos = usuario['estabelecimentos'] as List? ?? [];

    final quadras = <Map<String, dynamic>>[];



    for (var est in estabelecimentos) {

      final quadrasEst = est['quadras'] as List? ?? [];

      quadras.addAll(quadrasEst.cast<Map<String, dynamic>>());

    }



    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Row(

          mainAxisAlignment: MainAxisAlignment.spaceBetween,

          children: [

            Text(

              'Seus Estabelecimentos',

              style: GoogleFonts.dmSans(

                fontSize: 16,

                fontWeight: FontWeight.w700,

                color: AppColors.dark,

              ),

            ),

            IconButton(

              icon: const Icon(Icons.add_business, color: AppColors.primary),

              onPressed: () => context.push(AppRoutes.criarEstabelecimento),

            )

          ],

        ),

        const SizedBox(height: 12),

        if (estabelecimentos.isEmpty)

          Container(

            width: double.infinity,

            padding: const EdgeInsets.all(24),

            decoration: BoxDecoration(

              color: AppColors.grayLight,

              borderRadius: BorderRadius.circular(12),

            ),

            child: Column(

              children: [

                Text('🏗️', style: GoogleFonts.dmSans(fontSize: 32)),

                const SizedBox(height: 8),

                Text(

                  'Nenhum estabelecimento cadastrado',

                  style: GoogleFonts.dmSans(

                    fontSize: 14,

                    color: AppColors.gray,

                  ),

                ),

              ],

            ),

          )

        else

          Column(

            children: estabelecimentos.map((est) {

              return Padding(

                padding: const EdgeInsets.only(bottom: 12),

                child: Container(

                  decoration: BoxDecoration(

                    color: Colors.white,

                    borderRadius: BorderRadius.circular(12),

                    border: Border.all(

                      color: AppColors.grayLight,

                      width: 1,

                    ),

                  ),

                  padding: const EdgeInsets.all(16),

                  child: Column(

                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [

                      Text(

                        est['nome_local'] ?? 'Estabelecimento',

                        style: GoogleFonts.dmSans(

                          fontSize: 15,

                          fontWeight: FontWeight.w700,

                          color: AppColors.dark,

                        ),

                      ),

                      const SizedBox(height: 6),

                      Row(

                        children: [

                          const Icon(Icons.location_on,

                              size: 14, color: AppColors.gray),

                          const SizedBox(width: 6),

                          Expanded(

                            child: Text(

                              est['endereco'] ?? '',

                              style: GoogleFonts.dmSans(

                                fontSize: 12,

                                color: AppColors.gray,

                              ),

                              overflow: TextOverflow.ellipsis,

                            ),

                          ),

                        ],

                      ),

                      const SizedBox(height: 10),

                      Text(

                        '${(est['quadras'] as List).length} quadra(s)',

                        style: GoogleFonts.dmSans(

                          fontSize: 12,

                          fontWeight: FontWeight.w600,

                          color: AppColors.primary,

                        ),

                      ),

                    ],

                  ),

                ),

              );

            }).toList(),

          ),

        const SizedBox(height: 20),

        Row(

          mainAxisAlignment: MainAxisAlignment.spaceBetween,

          children: [

            Text(

              'Suas Quadras',

              style: GoogleFonts.dmSans(

                fontSize: 16,

                fontWeight: FontWeight.w700,

                color: AppColors.dark,

              ),

            ),

            IconButton(

              icon: const Icon(Icons.add_box, color: AppColors.secondary),

              onPressed: () => context.push(AppRoutes.criarQuadra),

            )

          ],

        ),

        const SizedBox(height: 12),

        if (quadras.isEmpty)

          Container(

            width: double.infinity,

            padding: const EdgeInsets.all(24),

            decoration: BoxDecoration(

              color: AppColors.grayLight,

              borderRadius: BorderRadius.circular(12),

            ),

            child: Column(

              children: [

                Text('⚽', style: GoogleFonts.dmSans(fontSize: 32)),

                const SizedBox(height: 8),

                Text(

                  'Nenhuma quadra cadastrada',

                  style: GoogleFonts.dmSans(

                    fontSize: 14,

                    color: AppColors.gray,

                  ),

                ),

              ],

            ),

          )

        else

          Column(

            children: quadras.map((quadra) {

              return Padding(

                padding: const EdgeInsets.only(bottom: 12),

                child: Container(

                  decoration: BoxDecoration(

                    color: Colors.white,

                    borderRadius: BorderRadius.circular(12),

                    border: Border.all(

                      color: AppColors.secondary.withOpacity(0.2),

                      width: 1,

                    ),

                  ),

                  padding: const EdgeInsets.all(16),

                  child: Column(

                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [

                      Text(

                        quadra['descricao'] ?? 'Quadra',

                        style: GoogleFonts.dmSans(

                          fontSize: 14,

                          fontWeight: FontWeight.w700,

                          color: AppColors.dark,

                        ),

                      ),

                      const SizedBox(height: 8),

                      Row(

                        children: [

                          Expanded(

                            child: Row(

                              children: [

                                const Icon(Icons.sports_soccer,

                                    size: 14, color: AppColors.gray),

                                const SizedBox(width: 6),

                                Text(

                                  quadra['esporte'] ?? 'Futebol',

                                  style: GoogleFonts.dmSans(

                                    fontSize: 12,

                                    color: AppColors.gray,

                                  ),

                                ),

                              ],

                            ),

                          ),

                          Text(

                            'R\$ ${(quadra['valor_hora']?.toString() ?? '0').replaceAll('.', ',')} /h',

                            style: GoogleFonts.dmSans(

                              fontSize: 12,

                              fontWeight: FontWeight.w700,

                              color: AppColors.primary,

                            ),

                          ),

                        ],

                      ),

                    ],

                  ),

                ),

              );

            }).toList(),

          ),

      ],

    );

  }



  Widget _buildPlayerSection(Map<String, dynamic> usuario) {

    final reservas = (usuario['reservas'] as List? ?? [])

        .cast<Map<String, dynamic>>()

        .toList();



    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Text(

          'Últimas Reservas',

          style: GoogleFonts.dmSans(

            fontSize: 16,

            fontWeight: FontWeight.w700,

            color: AppColors.dark,

          ),

        ),

        const SizedBox(height: 12),

        if (reservas.isEmpty)

          Container(

            width: double.infinity,

            padding: const EdgeInsets.all(24),

            decoration: BoxDecoration(

              color: AppColors.grayLight,

              borderRadius: BorderRadius.circular(12),

            ),

            child: Column(

              children: [

                Text('📅', style: GoogleFonts.dmSans(fontSize: 32)),

                const SizedBox(height: 8),

                Text(

                  'Nenhuma reserva feita ainda',

                  style: GoogleFonts.dmSans(

                    fontSize: 14,

                    color: AppColors.gray,

                  ),

                ),

              ],

            ),

          )

        else

          Column(

            children: reservas.take(5).map((reserva) {

              final quadra = reserva['quadra'] ?? {};

              final estabelecimento = quadra['estabelecimento'] ?? {};

              final dataStr = reserva['data'].toString();

              final data = DateTime.parse(dataStr);

              final dataFormatada = '${data.day}/${data.month}/${data.year}';



              return Padding(

                padding: const EdgeInsets.only(bottom: 12),

                child: Container(

                  decoration: BoxDecoration(

                    color: Colors.white,

                    borderRadius: BorderRadius.circular(12),

                    border: Border.all(

                      color: AppColors.primary.withOpacity(0.2),

                      width: 1,

                    ),

                  ),

                  padding: const EdgeInsets.all(16),

                  child: Column(

                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [

                      Row(

                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: [

                          Expanded(

                            child: Text(

                              quadra['identificacao'] ?? 'Quadra',

                              style: GoogleFonts.dmSans(

                                fontSize: 14,

                                fontWeight: FontWeight.w700,

                                color: AppColors.dark,

                              ),

                              overflow: TextOverflow.ellipsis,

                            ),

                          ),

                          Container(

                            padding: const EdgeInsets.symmetric(

                              horizontal: 10,

                              vertical: 4,

                            ),

                            decoration: BoxDecoration(

                              color: _getStatusColor(reserva['status']),

                              borderRadius: BorderRadius.circular(8),

                            ),

                            child: Text(

                              reserva['status'] ?? 'PENDENTE',

                              style: GoogleFonts.dmSans(

                                fontSize: 11,

                                fontWeight: FontWeight.w600,

                                color: Colors.white,

                              ),

                            ),

                          ),

                        ],

                      ),

                      const SizedBox(height: 8),

                      Text(

                        estabelecimento['nome_local'] ?? 'Local',

                        style: GoogleFonts.dmSans(

                          fontSize: 12,

                          color: AppColors.gray,

                        ),

                      ),

                      const SizedBox(height: 8),

                      Row(

                        children: [

                          const Icon(Icons.calendar_today,

                              size: 14, color: AppColors.gray),

                          const SizedBox(width: 6),

                          Text(

                            dataFormatada,

                            style: GoogleFonts.dmSans(

                              fontSize: 12,

                              color: AppColors.gray,

                            ),

                          ),

                          const SizedBox(width: 16),

                          const Icon(Icons.access_time,

                              size: 14, color: AppColors.gray),

                          const SizedBox(width: 6),

                          Text(

                            '${reserva['hora_inicio']}:00 - ${reserva['hora_fim']}:00',

                            style: GoogleFonts.dmSans(

                              fontSize: 12,

                              color: AppColors.gray,

                            ),

                          ),

                        ],

                      ),

                    ],

                  ),

                ),

              );

            }).toList(),

          ),

      ],

    );

  }



  Color _getStatusColor(String? status) {

    switch (status?.toUpperCase()) {

      case 'CONFIRMADA':

        return Colors.green;

      case 'CANCELADA':

        return Colors.red;

      case 'PENDENTE':

      default:

        return Colors.orange;

    }

  }



  Widget _buildActionButtons() {

    return Column(

      children: [

        if (!_isEditing)

          SizedBox(

            width: double.infinity,

            child: ElevatedButton.icon(

              onPressed: () {

                setState(() => _isEditing = true);

              },

              icon: const Icon(Icons.edit, size: 18),

              label: const Text('Editar Perfil'),

              style: ElevatedButton.styleFrom(

                backgroundColor: AppColors.primary,

                foregroundColor: Colors.white,

                minimumSize: const Size(double.infinity, 48),

                shape: RoundedRectangleBorder(

                  borderRadius: BorderRadius.circular(12),

                ),

              ),

            ),

          )

        else

          Row(

            children: [

              Expanded(

                child: ElevatedButton.icon(

                  onPressed: () {

                    setState(() => _isEditing = false);

                  },

                  icon: const Icon(Icons.close, size: 18),

                  label: const Text('Cancelar'),

                  style: ElevatedButton.styleFrom(

                    backgroundColor: AppColors.grayLight,

                    foregroundColor: AppColors.dark,

                    minimumSize: const Size(double.infinity, 48),

                    shape: RoundedRectangleBorder(

                      borderRadius: BorderRadius.circular(12),

                    ),

                  ),

                ),

              ),

              const SizedBox(width: 12),

              Expanded(

                child: ElevatedButton.icon(

                  onPressed: () async {

                    final usuarioData = (await _usuarioFuture);

                    _updateUsuario(usuarioData);

                  },

                  icon: const Icon(Icons.check, size: 18),

                  label: const Text('Salvar'),

                  style: ElevatedButton.styleFrom(

                    backgroundColor: Colors.green,

                    foregroundColor: Colors.white,

                    minimumSize: const Size(double.infinity, 48),

                    shape: RoundedRectangleBorder(

                      borderRadius: BorderRadius.circular(12),

                    ),

                  ),

                ),

              ),

            ],

          ),

        const SizedBox(height: 12),

        SizedBox(

          width: double.infinity,

          child: ElevatedButton.icon(

            onPressed: _logout,

            icon: const Icon(Icons.logout, size: 18),

            label: const Text('Sair'),

            style: ElevatedButton.styleFrom(

              backgroundColor: Colors.red,

              foregroundColor: Colors.white,

              minimumSize: const Size(double.infinity, 48),

              shape: RoundedRectangleBorder(

                borderRadius: BorderRadius.circular(12),

              ),

            ),

          ),

        ),

      ],

    );

  }
}
class _MinhasPartidasTab extends StatefulWidget {
  const _MinhasPartidasTab({super.key});

  @override
  State<_MinhasPartidasTab> createState() => _MinhasPartidasTabState();
}

class _MinhasPartidasTabState extends State<_MinhasPartidasTab> {
  List<Partida> _partidas = [];
  bool _isLoading = true;
  int? _meuUserId;

  @override
  void initState() {
    super.initState();
    _loadPartidas();
    _carregarDadosIniciais();
  }

  // Carrega o ID do usuário logado lendo o Token antes de puxar as partidas
  Future<void> _carregarDadosIniciais() async {
    try {
      final token = await AuthService().getToken();
      if (token != null) {
        final parts = token.split('.');
        if (parts.length == 3) {
          final payloadString = String.fromCharCodes(
              base64Url.decode(base64Url.normalize(parts[1])));
          final payloadMap = jsonDecode(payloadString);
          _meuUserId = payloadMap['id'];
        }
      }
    } catch (e) {
      debugPrint('Erro ao extrair ID do token: $e');
    }
    await (context.findAncestorStateOfType<_HomeScreenState>())
        ?._refreshTodasPartidas();
  }

  Future<void> refreshPartidas() async {
    await _loadPartidas();
  }

  Future<void> _loadPartidas() async {
    try {
      final partidas = await PartidaService.minhas();

      setState(() {
        _partidas = partidas;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar partidas: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _cancelarPartida(int partidaId) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Cancelar Partida',
          style: GoogleFonts.bebasNeue(
            fontSize: 24,
            color: AppColors.dark,
            letterSpacing: 1,
          ),
        ),
        content: Text(
          'Tem certeza que deseja cancelar esta partida?\n\nTodos os jogadores serão removidos e esta ação não poderá ser desfeita.',
          style: GoogleFonts.dmSans(fontSize: 14),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Voltar',
              style: GoogleFonts.dmSans(
                color: AppColors.gray,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Cancelar Partida',
              style: GoogleFonts.dmSans(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      await PartidaService.cancelarPartida(partidaId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Partida cancelada com sucesso'),
            backgroundColor: Colors.green,
          ),
        );

        await (context.findAncestorStateOfType<_HomeScreenState>())
            ?._refreshTodasPartidas();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _abrirFecharPartida(
      int partidaId,
      bool aberta,
  ) async {
    try {
      if (aberta) {
        await PartidaService.alterarTipo(partidaId, 'FECHADA');
      } else {
        await PartidaService.alterarTipo(partidaId, 'ABERTA');
      }

      await (context.findAncestorStateOfType<_HomeScreenState>())
          ?._refreshTodasPartidas();

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), 
          backgroundColor: AppColors.error,),
        );
      }
    }
  }

  void _mostrarJogadoresGerenciavel(
    BuildContext context,
    Partida partida,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return ListView.builder(
          itemCount: partida.nomesJogadores.length,
          itemBuilder: (_, i) {

            return ListTile(
              leading: const Icon(Icons.person),
              title: Text(partida.nomesJogadores[i]),

              trailing: partida.idsUsuarios[i] == partida.criadorId
                  ? const Text("Dono")
                  : IconButton(
                      icon: const Icon(
                        Icons.person_remove,
                        color: Colors.red,
                      ),
                      onPressed: () async {
                        final confirmar = await showDialog<bool>(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: const Text('Remover jogador'),
                            content: Text(
                              'Deseja realmente remover "${partida.nomesJogadores[i]}" desta partida?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dialogContext, false),
                                child: const Text('Cancelar'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                onPressed: () => Navigator.pop(dialogContext, true),
                                child: const Text(
                                  'Remover',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (confirmar != true) {
                          return;
                        }

                        try {
                          await PartidaService.removerJogador(
                            partida.id,
                            partida.idsUsuarios[i],
                          );

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Jogador removido da partida.'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }

                          Navigator.pop(context);

                          await (context.findAncestorStateOfType<_HomeScreenState>())
                              ?._refreshTodasPartidas();
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  e.toString().replaceFirst('Exception: ', ''),
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                    ),
            );
          },
        );
      },
    );
  }

  Future<void> _gerarConvite(int partidaId) async {
    try {
      final convite = await PartidaService.gerarConvite(partidaId);
      if (kIsWeb) {
        await Clipboard.setData(
          ClipboardData(text: convite),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Link do convite copiado para a área de transferência!',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        await Share.share(
          '⚽ Você foi convidado para uma partida!\n$convite',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao gerar convite: $e'), 
                   backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_partidas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '⚽',
              style: TextStyle(fontSize: 60),
            ),
            const SizedBox(height: 12),
            Text(
              'Nenhuma partida encontrada',
              style: GoogleFonts.bebasNeue(
                fontSize: 28,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPartidas,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _partidas.length,
        itemBuilder: (context, index) {
          final partida = _partidas[index];

          final vagasDisponiveis =
              partida.vagas - partida.quantidade_atual;

          final bool souDono =
              partida.criadorId == _meuUserId;

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// TÍTULO
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          partida.quadraNome ??
                              'Partida #${partida.id}',
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                              if (souDono)
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert),
                                  onSelected: (value) async {
                                    switch (value) {
                                      case 'convite':
                                        await _gerarConvite(partida.id);
                                        break;

                                      case 'gerenciar':
                                        _mostrarJogadoresGerenciavel(context, partida);
                                        break;
                                    }
                                  },
                                  itemBuilder: (_) => [
                                    const PopupMenuItem(
                                      value: 'gerenciar',
                                      child: Text('Gerenciar jogadores'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'convite',
                                      child: Text('Gerar convite'),
                                    ),
                                  ],
                                ),
                      if (souDono)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Dono',
                            style: GoogleFonts.dmSans(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Text(
                    partida.estabelecimentoNome ?? '',
                    style: GoogleFonts.dmSans(
                      color: AppColors.gray,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    '${partida.formatarData()} • ${partida.formatarHora(partida.horaInicio)} às ${partida.formatarHora(partida.horaFim)}',
                    style: GoogleFonts.dmSans(
                      color: AppColors.gray,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    '${partida.quantidade_atual}/${partida.vagas} jogadores',
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    '$vagasDisponiveis vaga(s) restante(s)',
                    style: GoogleFonts.dmSans(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  if (souDono) ...[
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: Icon(
                              partida.tipo == TipoPartida.ABERTA
                                  ? Icons.lock
                                  : Icons.lock_open,
                            ),
                            label: Text(
                              partida.tipo == TipoPartida.ABERTA
                                  ? 'Fechar'
                                  : 'Abrir',
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: partida.tipo == TipoPartida.ABERTA
                                  ? Colors.red
                                  : Colors.green,
                              side: BorderSide(
                                color: partida.tipo == TipoPartida.ABERTA
                                    ? Colors.red
                                    : Colors.green,
                                width: 1.5,
                              ),
                            ),
                            onPressed: () => _abrirFecharPartida(
                              partida.id,
                              partida.tipo == TipoPartida.ABERTA,
                            ),
                          )
                        ),

                        const SizedBox(width: 8),

                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.cancel),
                            label: const Text('Cancelar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                            ),
                            onPressed: () =>
                                _cancelarPartida(partida.id),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}