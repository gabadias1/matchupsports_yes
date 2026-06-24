import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:match_up_sports/models/mensagem_chat.dart';
import 'package:match_up_sports/services/auth_service.dart';
import 'package:match_up_sports/services/chat_service.dart';
import 'package:match_up_sports/theme/app_theme.dart';
import 'dart:async';

class ChatReservaScreen extends StatefulWidget {
  final int reservaId;

  const ChatReservaScreen({
    super.key,
    required this.reservaId,
  });

  @override
  State<ChatReservaScreen> createState() => _ChatReservaScreenState();
}

class _ChatReservaScreenState extends State<ChatReservaScreen> {
  final TextEditingController _messageController =
      TextEditingController();
  final ScrollController _scrollController =
      ScrollController();
  final ChatService _chatService = ChatService();
  bool _isLoading = true;
  List<MensagemChat> _messages = [];
  int? usuarioAtualId;
  int page = 0;
  bool hasMore = true;
  Timer? _timer;
  bool _carregandoMais = false;

  @override
  void initState() {
    super.initState();
    _carregarUsuario();
    _carregarMensagens();
    _timer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _buscarNovasMensagens(),
    );
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _carregarUsuario() async {
    usuarioAtualId = await AuthService().getUserId();
  }

  Future<void> _carregarMensagens() async {
    try {
      final result = await _chatService.buscarMensagens(
        reservaId: widget.reservaId,
        page: page,
      );
      setState(() {
        _messages.insertAll(0, result.mensagens);
        hasMore = result.hasMore;
        page++;
        _isLoading = false;
      });
      Future.delayed(
        const Duration(milliseconds: 300),
        () {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(
              _scrollController.position.maxScrollExtent,
            );
          }
        },
      );
    } catch(e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _buscarNovasMensagens() async {
    try {
      final response = await _chatService.buscarMensagens(
        reservaId: widget.reservaId,
        page: 0,
      );
      final novasMensagens = response.mensagens;
      if (novasMensagens.isEmpty) return;
      final idsExistentes = _messages
          .map((msg) => msg.id)
          .toSet();
      final adicionadas = novasMensagens
          .where((msg) => !idsExistentes.contains(msg.id))
          .toList();
      if (adicionadas.isEmpty) return;
      final estavaNoFinal =
          _scrollController.hasClients &&
          _scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100;
      setState(() {
        _messages.addAll(adicionadas);
      });
      if (estavaNoFinal) {
        Future.delayed(
          const Duration(milliseconds: 100),
          () {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          },
        );
      }
    } catch (e) {
      debugPrint(
        "Erro atualizando mensagens: $e",
      );
    }
  }

  Future<void> _carregarMaisMensagens() async {
    if (!hasMore || _carregandoMais) return;
    setState(() {
      _carregandoMais = true;
    });
    try {
      final response = await _chatService.buscarMensagens(
        reservaId: widget.reservaId,
        page: page,
      );
      final antigas = response.mensagens;
      if (antigas.isEmpty) {
        setState(() {
          hasMore = false;
        });
        return;
      }
      final posicaoAntes =
          _scrollController.hasClients
              ? _scrollController.position.maxScrollExtent
              : 0.0;
      setState(() {
        _messages.insertAll(
          0,
          antigas.reversed,
        );
        hasMore = response.hasMore;
        page++;
      });
      Future.delayed(
        const Duration(milliseconds: 100),
        () {
          if (_scrollController.hasClients) {
            final diferenca =
                _scrollController.position.maxScrollExtent -
                posicaoAntes;
            _scrollController.jumpTo(
              diferenca,
            );
          }
        },
      );
    } catch (e) {
      debugPrint(
        "Erro carregando mensagens antigas: $e",
      );
    } finally {
      setState(() {
        _carregandoMais = false;
      });
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels <= 100 &&
        !_carregandoMais) {
      _carregarMaisMensagens();
    }
  }

Future<void> _enviarMensagem() async {
  final texto = _messageController.text.trim();
  if(texto.isEmpty) return;
  _messageController.clear();
  try {
    final mensagem = await _chatService.enviarMensagem(reservaId: widget.reservaId, mensagem: texto);
    setState(() {
      _messages.add(mensagem);
    });
    Future.delayed(
      const Duration(milliseconds:100),
      (){
        if(_scrollController.hasClients){
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration:
                const Duration(milliseconds:300),
            curve: Curves.easeOut,
          );
        }
      },
    );
  } catch(e){
    ScaffoldMessenger.of(context)
        .showSnackBar(
          SnackBar(
            content:
              Text("Erro ao enviar mensagem: $e"),
          ),
        );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.grayLight),
          onPressed: () => context.pop(),
        ),
        backgroundColor: AppColors.dark,
        elevation: 0,
        title: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              "Chat da Reserva",
              style: GoogleFonts.dmSans(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            Text(
              "Reserva #${widget.reservaId}",
              style: GoogleFonts.dmSans(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: _isLoading
            ? const Center(
                child:
                  CircularProgressIndicator(),
              )
            : ListView.builder(
              controller:
                  _scrollController,
              padding:
                const EdgeInsets.all(20),
              itemCount: _messages.length + 
                  (_carregandoMais ? 1 : 0),
              itemBuilder:
                (context,index){
                if(_carregandoMais && index == 0){
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                final msg =
                    _messages[index];
                final isMe =
                    msg.usuarioId
                    == usuarioAtualId;
                return Align(
                  alignment: isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin:
                      const EdgeInsets.only(
                        bottom: 12,
                      ),
                    padding:
                      const EdgeInsets.all(14),
                    constraints:
                      const BoxConstraints(
                        maxWidth: 280,
                      ),
                    decoration:
                      BoxDecoration(
                        color: isMe
                          ? AppColors.primary
                          : Colors.white,
                        borderRadius:
                          BorderRadius.circular(14),
                        border: isMe
                          ? null
                          : Border.all(
                              color:
                              AppColors.grayLight,
                            ),
                      ),
                    child: Column(
                      crossAxisAlignment:
                        CrossAxisAlignment.start,
                      children: [
                        if(!isMe)
                        Text(
                          msg.nomeUsuario,
                          style:
                            GoogleFonts.dmSans(
                              fontSize: 12,
                              fontWeight:
                                FontWeight.bold,
                              color:
                                AppColors.primary,
                            ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          msg.mensagem,
                          style:
                            GoogleFonts.dmSans(
                              color: isMe
                                ? Colors.white
                                : AppColors.dark,
                              fontSize: 14,
                            ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildInput(){
    return Container(
      padding:
        const EdgeInsets.fromLTRB(
          16,
          10,
          16,
          20,
        ),
      decoration:
        const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color:
                AppColors.grayLight,
            ),
          ),
        ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller:
                _messageController,
              decoration:
                InputDecoration(
                  hintText:
                    "Digite uma mensagem...",
                  hintStyle:
                    GoogleFonts.dmSans(
                      color:
                        AppColors.gray,
                    ),
                  filled:true,
                  fillColor:
                    AppColors.grayLight
                      .withOpacity(.3),
                  border:
                    OutlineInputBorder(
                      borderRadius:
                        BorderRadius.circular(14),
                      borderSide:
                        BorderSide.none,
                    ),
                ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Container(
            decoration:
              BoxDecoration(
                color:
                  AppColors.primary,
                borderRadius:
                  BorderRadius.circular(12),
              ),
            child: IconButton(
              icon:
                const Icon(
                  Icons.send,
                  color: Colors.white,
                ),
              onPressed:
                _enviarMensagem,
            ),
          ),
        ],
      ),
    );
  }
}