import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/message.dart';
import '../services/app_state.dart';
import '../services/i18n.dart';
import '../theme/app_colors.dart';
import '../widgets/hero_characters.dart';

/// Chat — Professor bilan suhbat.
/// Editorial: hero greeting empty state, bolder bubbles, type-led header.
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutQuart,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    await context.read<AppState>().sendMessage(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final messages = state.messages;
    _scrollToBottom();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.cosmicGradient),
        child: SafeArea(
          child: Column(
            children: [
              _editorialHeader(context),
              Expanded(
                child: messages.isEmpty
                    ? _emptyState(state)
                    : _messagesList(messages),
              ),
              if (state.isLoading) _typingIndicator(),
              _inputBar(state),
            ],
          ),
        ),
      ),
    );
  }

  // ─── HEADER — editorial ──────────────────────────────────────
  Widget _editorialHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              child: Icon(
                Icons.arrow_back_rounded,
                color: AppColors.pureWhite.withValues(alpha: 0.6),
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const ProfessorImage(size: 38, animated: false),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  I18n.professorName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.pureWhite,
                    letterSpacing: -0.01,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: AppColors.neuronGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'TAYYOR',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.pureWhite.withValues(alpha: 0.55),
                        letterSpacing: 2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── EMPTY STATE — hero ─────────────────────────────────────
  Widget _emptyState(AppState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 18,
                height: 0.5,
                color: AppColors.professorWarmth.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 10),
              Text(
                'CHOY TAYYOR',
                style: TextStyle(
                  color: AppColors.professorWarmth.withValues(alpha: 0.85),
                  fontSize: 11,
                  letterSpacing: 2.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ).animate().fadeIn(duration: 500.ms),
          const SizedBox(height: 24),
          Text(
            state.greeting(),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: AppColors.pureWhite,
              height: 1.25,
              letterSpacing: -0.015,
            ),
          )
              .animate(delay: 200.ms)
              .fadeIn(duration: 600.ms)
              .slideY(begin: 0.05, end: 0, curve: Curves.easeOutQuart),
          const SizedBox(height: 18),
          Text(
            'Savolingizni pastdan yozing.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.pureWhite.withValues(alpha: 0.45),
              height: 1.5,
            ),
          ).animate(delay: 500.ms).fadeIn(),
          const SizedBox(height: 48),
          Center(
            child: HeroCharacters(size: 220, glow: true, floating: false)
                .animate(delay: 700.ms)
                .fadeIn(duration: 800.ms)
                .scale(
                  begin: const Offset(0.9, 0.9),
                  end: const Offset(1, 1),
                  curve: Curves.easeOutQuart,
                ),
          ),
          if (!state.hasApiKey) ...[
            const SizedBox(height: 36),
            _apiKeyHint(),
          ],
        ],
      ),
    );
  }

  Widget _apiKeyHint() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: AppColors.cosmicMid,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.plasmaYellow.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.vpn_key_outlined,
              color: AppColors.plasmaYellow, size: 20),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI suhbat uchun',
                  style: TextStyle(
                    color: AppColors.pureWhite,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Pasport → API kalitini kiriting',
                  style: TextStyle(
                    color: AppColors.pureWhite,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── MESSAGES LIST ───────────────────────────────────────────
  Widget _messagesList(List<Message> messages) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      itemCount: messages.length,
      itemBuilder: (_, i) => _messageBubble(messages[i], i),
    );
  }

  Widget _messageBubble(Message msg, int index) {
    final isProfessor = msg.isFromProfessor;
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment:
            isProfessor ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          // Mayda attribuyatsiya
          Padding(
            padding: const EdgeInsets.only(left: 4, right: 4, bottom: 6),
            child: Text(
              isProfessor ? I18n.professorName.toUpperCase() : 'SIZ',
              style: TextStyle(
                fontSize: 10,
                color: isProfessor
                    ? AppColors.professorWarmth.withValues(alpha: 0.7)
                    : AppColors.neuronGreen.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.78,
            ),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: isProfessor
                    ? AppColors.cosmicMid
                    : AppColors.neuronGreen.withValues(alpha: 0.14),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isProfessor ? 4 : 18),
                  topRight: Radius.circular(isProfessor ? 18 : 4),
                  bottomLeft: const Radius.circular(18),
                  bottomRight: const Radius.circular(18),
                ),
                border: isProfessor
                    ? Border.all(
                        color: AppColors.professorWarmth.withValues(alpha: 0.2),
                        width: 1,
                      )
                    : null,
              ),
              child: Text(
                msg.text,
                style: TextStyle(
                  color: isProfessor
                      ? AppColors.pureWhite
                      : AppColors.neuronGreen,
                  fontSize: 15,
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    )
        .animate(key: ValueKey('msg-$index'))
        .fadeIn(duration: 220.ms)
        .slideY(begin: 0.08, end: 0, curve: Curves.easeOutQuart);
  }

  // ─── TYPING INDICATOR ────────────────────────────────────────
  Widget _typingIndicator() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 16, 14),
      child: Row(
        children: [
          Text(
            '${I18n.professorName.toUpperCase()} YOZAYOTIR',
            style: TextStyle(
              fontSize: 10,
              color: AppColors.professorWarmth.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
              letterSpacing: 1.8,
            ),
          ),
          const SizedBox(width: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              3,
              (i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.professorWarmth.withValues(alpha: 0.7),
                  ),
                )
                    .animate(
                      onPlay: (c) => c.repeat(),
                      delay: (i * 180).ms,
                    )
                    .fadeOut(duration: 500.ms)
                    .then()
                    .fadeIn(duration: 500.ms),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── INPUT BAR ───────────────────────────────────────────────
  Widget _inputBar(AppState state) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        14,
        14 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.cosmicDeep,
        border: Border(
          top: BorderSide(
            color: AppColors.pureWhite.withValues(alpha: 0.06),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.cosmicMid,
                borderRadius: BorderRadius.circular(22),
              ),
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 5,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.pureWhite,
                  height: 1.4,
                ),
                decoration: InputDecoration(
                  hintText: 'Savolingiz...',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  hintStyle: TextStyle(
                    color: AppColors.pureWhite.withValues(alpha: 0.35),
                    fontSize: 15,
                  ),
                ),
                onSubmitted: (_) => _send(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: state.isLoading ? null : _send,
            child: AnimatedContainer(
              duration: 200.ms,
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: state.isLoading
                    ? AppColors.cosmicMid
                    : AppColors.neuronGreen,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.arrow_upward_rounded,
                color: state.isLoading
                    ? AppColors.pureWhite.withValues(alpha: 0.3)
                    : AppColors.cosmicDeep,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
