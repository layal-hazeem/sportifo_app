import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sportifo_app/core/helpers/snack_bar_utils.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/chat_message_model.dart';
import '../view_model/ai_chat_cubit.dart';
import '../view_model/ai_chat_state.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/message_input.dart';
import '../widgets/typing_indicator.dart';
import 'package:sportifo_app/features/nutrition/presentation/view_model/nutrition_cubit.dart';
import 'package:sportifo_app/features/nutrition/presentation/view_model/nutrition_state.dart';

class AiChatScreen extends StatelessWidget {
  const AiChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // 🔥 التعديل الأول والأهم: استخدام value بدلاً من create لمنع تدمير الكيوبيت
        BlocProvider.value(
          value: getIt<AiChatCubit>(),
        ),
        BlocProvider.value(
          value: getIt<NutritionCubit>(),
        ),
      ],
      child: const _AiChatView(),
    );
  }
}

class _AiChatView extends StatefulWidget {
  const _AiChatView();

  @override
  State<_AiChatView> createState() => _AiChatViewState();
}

class _AiChatViewState extends State<_AiChatView> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _lastSentText;
  bool _isDialogOpen = false;
  bool _isAtBottom = true;
  bool _showJumpButton = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NutritionCubit>().initialize();
      // 🔥 التعديل الثاني: استدعاء التحديث من هنا لضمان عمله مرة واحدة عند فتح الشاشة
      context.read<AiChatCubit>().initialize();
      _scrollToBottom(animate: false);
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    final offset = _scrollController.offset;
    final isAtBottom = max <= 0 || (max - offset) < 150;
    final showJump = max > 0 && (max - offset) > 300;

    if (_isAtBottom != isAtBottom || _showJumpButton != showJump) {
      setState(() {
        _isAtBottom = isAtBottom;
        _showJumpButton = showJump;
      });
    }
  }

  void _scrollToBottom({bool animate = true}) {
    if (!_scrollController.hasClients) return;

    int attempts = 0;
    const maxAttempts = 5;

    void tryScroll() {
      if (!_scrollController.hasClients || attempts >= maxAttempts) return;
      attempts++;

      final max = _scrollController.position.maxScrollExtent;
      final current = _scrollController.offset;

      if (max <= 0 || (max - current).abs() < 2) return;

      if (animate && attempts == 1) {
        _scrollController.animateTo(
          max,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
      } else {
        _scrollController.jumpTo(max);
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        tryScroll();
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      tryScroll();
    });
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _handleJump() {
    if (_isAtBottom) {
      _scrollToTop();
    } else {
      _scrollToBottom(animate: true);
    }
  }

  void _handleSend(String text) {
    if (text.trim().isEmpty) return;
    _lastSentText = text.trim();
    context.read<AiChatCubit>().sendMessage(text.trim());
    _controller.clear();
  }

  void _handleCancel() {
    context.read<AiChatCubit>().cancelRequest();
  }

  void _showCancelDialog(String pendingText) {
    if (_isDialogOpen) return;
    _isDialogOpen = true;
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Column(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.primaryBtn,
                size: 50,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.stop_sending_title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Text(
            l10n.stop_sending_content,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () {
                _isDialogOpen = false;
                Navigator.of(ctx).pop();
                context.read<AiChatCubit>().resendPendingMessage();
              },
              child: Text(
                l10n.undo,
                style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {
                _isDialogOpen = false;
                Navigator.of(ctx).pop();
                context.read<AiChatCubit>().removeLastMessage();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: Text(
                l10n.delete,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    ).then((_) => _isDialogOpen = false);
  }

  SnackBarType _getErrorType(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('rate limit') ||
        lower.contains('too long') ||
        lower.contains('took longer')) {
      return SnackBarType.warning;
    }
    return SnackBarType.error;
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: Column(
        children: [
          Expanded(
            child: BlocListener<NutritionCubit, NutritionState>(
              listenWhen: (previous, current) {
                return current is NutritionSuccess ||
                    current is AddMealSuccess ||
                    current is DeleteMealSuccess;
              },
              listener: (context, state) {
                setState(() {});
              },
              child: BlocConsumer<AiChatCubit, AiChatState>(
                listener: (context, state) {
                  if (state is AiChatSuccess) {
                    _scrollToBottom(animate: false);
                  } else if (state is AiChatSending) {
                    _scrollToBottom(animate: true);
                  }

                  if (state is AiChatCancelled) {
                    _showCancelDialog(state.pendingText);
                  }

                  if (state is AiChatError && _lastSentText != null) {
                    AppSnackBar.show(
                      context,
                      message: state.message,
                      type: _getErrorType(state.message),
                      actionLabel: 'Retry',
                      onActionPressed: () => _handleSend(_lastSentText!),
                    );
                  }

                  if (state is AiChatSuccess) {
                    _lastSentText = null;
                  }
                },
                builder: (context, state) {
                  final messages = switch (state) {
                    AiChatInitial() => <ChatMessageModel>[],
                    AiChatLoading(:final messages) => messages,
                    AiChatSending(:final messages) => messages,
                    AiChatSuccess(:final messages) => messages,
                    AiChatError(:final messages) => messages,
                    AiChatCancelled(:final messages) => messages,
                  };

                  final isSending = state is AiChatSending;
                  final isLoading = state is AiChatLoading || state is AiChatInitial;
                  final isError = state is AiChatError && messages.isEmpty;

                  if (isLoading && messages.isEmpty) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primaryBtn));
                  }

                  if (isError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.wifi_off_rounded, size: 50, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text("Connection Failed", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: () => context.read<AiChatCubit>().fetchHistory(forceRefresh: true),
                            icon: const Icon(Icons.refresh, color: AppColors.primaryBtn),
                            label: const Text("Tap to retry", style: TextStyle(color: AppColors.primaryBtn)),
                          )
                        ],
                      ),
                    );
                  }

                  // 🔥 تم إصلاح هذا الجزء بنجاح وإزالة التكرار
                  final lastAiId = state is AiChatSuccess && state.lastAiMessage != null
                      ? state.lastAiMessage!.id
                      : -1;

                  if (messages.isEmpty && !isLoading && !isSending) {
                    return const _EmptyChatView();
                  }

                  return Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        physics: const ClampingScrollPhysics(),
                        itemCount: messages.length + (isSending ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == messages.length && isSending) {
                            return const TypingIndicator();
                          }

                          final msg = messages[index];
                          final showTyping =
                              msg.sender == 'ai' && msg.id == lastAiId;

                          return ChatBubble(
                            key: ValueKey(msg.id),
                            message: msg,
                            showTypingEffect: showTyping,
                          );
                        },
                      ),

                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        right: 16,
                        bottom: _showJumpButton ? 20 : -70,
                        child: Material(
                          elevation: 6,
                          shadowColor: Colors.black.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(28),
                          color: Colors.white,
                          child: InkWell(
                            onTap: _handleJump,
                            borderRadius: BorderRadius.circular(28),
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                  color: Colors.grey.shade200,
                                  width: 1,
                                ),
                              ),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                transitionBuilder: (child, anim) =>
                                    ScaleTransition(scale: anim, child: child),
                                child: Icon(
                                  _isAtBottom
                                      ? Icons.keyboard_arrow_up_rounded
                                      : Icons.keyboard_arrow_down_rounded,
                                  key: ValueKey<bool>(_isAtBottom),
                                  color: AppColors.primaryBtn,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          BlocBuilder<AiChatCubit, AiChatState>(
            builder: (context, state) {
              final isSending = state is AiChatSending;
              return MessageInput(
                controller: _controller,
                isSending: isSending,
                onSend: _handleSend,
                onCancel: _handleCancel,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _EmptyChatView extends StatelessWidget {
  const _EmptyChatView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: constraints.maxHeight,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBtn.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.smart_toy_outlined,
                      size: 48,
                      color: AppColors.primaryBtn,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.ai_coach_ready,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.empty_chat_subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}