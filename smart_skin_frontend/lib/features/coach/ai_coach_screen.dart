import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../bloc/coach/coach_bloc.dart';
import '../../bloc/coach/coach_event.dart';
import '../../bloc/coach/coach_state.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../constants/colors.dart';
import '../../data/models/coach_model.dart';

class AICoachScreen extends StatefulWidget {
  const AICoachScreen({super.key});
  @override State<AICoachScreen> createState() => _AICoachScreenState();
}

class _AICoachScreenState extends State<AICoachScreen> {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  late String _sessionId;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _sessionId = const Uuid().v4();
  }

  @override
  void dispose() { _ctrl.dispose(); _scrollCtrl.dispose(); super.dispose(); }

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    _ctrl.clear();
    context.read<CoachBloc>().add(SendMessage(message: text, sessionId: _sessionId));
    Future.delayed(const Duration(milliseconds: 300), _scrollToBottom);
  }

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final userName = authState is AuthAuthenticated ? authState.user.firstName : 'there';

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Row(children: [
          CircleAvatar(radius: 16, backgroundColor: AppColors.accentBlue,
              child: Icon(Icons.auto_awesome, color: Colors.white, size: 16)),
          SizedBox(width: 8),
          Text("AI Skin Coach", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        ]),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<CoachBloc, CoachState>(
              listener: (ctx, state) {
                if (state is CoachMessagesUpdated) _scrollToBottom();
              },
              builder: (ctx, state) {
                if (state is CoachInitial) {
                  return _buildWelcome(userName);
                }
                if (state is CoachMessagesUpdated || state is CoachLoading) {
                  final messages = state is CoachMessagesUpdated ? state.messages
                      : ctx.read<CoachBloc>().messages;
                  return ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length + (state is CoachLoading ? 1 : 0),
                    itemBuilder: (ctx, i) {
                      if (i == messages.length) return _buildTypingIndicator();
                      return _buildMessage(messages[i]);
                    },
                  );
                }
                if (state is CoachError) {
                  return Center(child: Text(state.message, style: const TextStyle(color: AppColors.error)));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildWelcome(String name) {
    final quickQ = [
      "How to treat acne?",
      "Best routine for dry skin?",
      "What is retinol?",
      "How to reduce dark spots?",
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(radius: 20, backgroundColor: AppColors.accentBlue,
                    child: Icon(Icons.auto_awesome, color: Colors.white, size: 18)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text("Hello $name! 👋", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 4),
                    const Text(
                      "I'm your AI Skin Coach. Ask me anything about skincare, routines, ingredients, or your skin concerns!",
                      style: TextStyle(height: 1.4, color: AppColors.textDark),
                    ),
                  ]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Align(alignment: Alignment.centerLeft,
              child: Text("Quick questions", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10, runSpacing: 10,
            children: quickQ.map((q) => GestureDetector(
              onTap: () {
                _ctrl.text = q;
                _send();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primaryPink.withOpacity(0.3)),
                ),
                child: Text(q, style: const TextStyle(fontSize: 13, color: AppColors.textDark)),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(CoachMessageModel msg) {
    final isUser = msg.isUser;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            const CircleAvatar(radius: 16, backgroundColor: AppColors.accentBlue,
                child: Icon(Icons.auto_awesome, color: Colors.white, size: 14)),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primaryPink : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
              ),
              child: Text(msg.content, style: TextStyle(
                color: isUser ? Colors.white : AppColors.textDark, height: 1.4,
              )),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Row(
      children: [
        const CircleAvatar(radius: 16, backgroundColor: AppColors.accentBlue,
            child: Icon(Icons.auto_awesome, color: Colors.white, size: 14)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)]),
          child: Row(
            children: [1, 2, 3].map((i) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 6, height: 6,
              decoration: const BoxDecoration(color: AppColors.textGrey, shape: BoxShape.circle),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, -4))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(30)),
              child: TextField(
                controller: _ctrl,
                onSubmitted: (_) => _send(),
                decoration: const InputDecoration(
                  hintText: "Ask about your skin...",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
                maxLines: null,
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _send,
            child: Container(
              padding: const EdgeInsets.all(13),
              decoration: const BoxDecoration(color: AppColors.primaryPink, shape: BoxShape.circle),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
