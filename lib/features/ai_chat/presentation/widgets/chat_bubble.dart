import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sportifo_app/core/routes/app_routes.dart';
import 'package:sportifo_app/features/ai_chat/presentation/widgets/nutrition_card.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/helpers/snack_bar_utils.dart';
import '../../data/models/chat_message_model.dart';
import '../../../nutrition/presentation/view_model/nutrition_cubit.dart';
import '../../../nutrition/presentation/view_model/nutrition_state.dart';

class ChatBubble extends StatefulWidget {
  final ChatMessageModel message;
  final bool showTypingEffect;

  const ChatBubble({
    super.key,
    required this.message,
    this.showTypingEffect = false,
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  String? _displayedText;
  Timer? _typingTimer;

  bool _hasNutritionData() {
    return widget.message.sender == 'ai' && widget.message.hasNutritionData();
  }

  void _saveMeal() async {
    final nutritionCubit = context.read<NutritionCubit>();
    await nutritionCubit.addMealFromAi(widget.message.id);
  }

  @override
  void initState() {
    super.initState();
    if (widget.showTypingEffect && widget.message.sender == 'ai') {
      _startTyping();
    } else {
      _displayedText = widget.message.body;
    }
  }

  @override
  void didUpdateWidget(ChatBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showTypingEffect &&
        !oldWidget.showTypingEffect &&
        widget.message.sender == 'ai') {
      _startTyping();
    }
    if (widget.message.body != oldWidget.message.body &&
        !widget.showTypingEffect) {
      setState(() => _displayedText = widget.message.body);
    }
  }

  void _startTyping() {
    _typingTimer?.cancel();
    final fullText = widget.message.body;
    _displayedText = '';
    int index = 0;
    final totalTime = 2500;
    final delay = (totalTime / fullText.length).clamp(5, 40).toInt();

    _typingTimer = Timer.periodic(Duration(milliseconds: delay), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (index >= fullText.length) {
        timer.cancel();
        setState(() => _displayedText = fullText);
        return;
      }
      setState(() {
        _displayedText = fullText.substring(0, index + 1);
      });
      index++;
    });
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUserMessage = widget.message.sender == 'user';
    final hasNutrition = _hasNutritionData();
    final displayBody = _displayedText ?? widget.message.body;
    final l10n = AppLocalizations.of(context)!;

    return Align(
      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          crossAxisAlignment: isUserMessage
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              decoration: BoxDecoration(
                color: isUserMessage
                    ? AppColors.primaryBtn
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayBody,
                    style: TextStyle(
                      color: isUserMessage ? Colors.white : Colors.black87,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.message.time,
                    style: TextStyle(
                      color: isUserMessage
                          ? Colors.white.withValues(alpha: 0.7)
                          : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (!isUserMessage &&
                widget.showTypingEffect &&
                _displayedText != widget.message.body)
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 2),
                child: Container(
                  width: 6,
                  height: 14,
                  color: AppColors.primaryBtn.withValues(alpha: 0.6),
                ),
              ),
            if (!isUserMessage && hasNutrition)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: NutritionCard(
                        calories: widget.message.calories,
                        protein: widget.message.protein,
                        carbs: widget.message.carbs,
                        fat: widget.message.fat,
                      ),
                    ),
                    const SizedBox(width: 8),
                    BlocConsumer<NutritionCubit, NutritionState>(
                      listener: (context, state) {
                        if (state is AddMealSuccess &&
                            state.messageId == widget.message.id) {
                          AppSnackBar.show(
                            context,
                            message: l10n.meal_saved_success,
                            type: SnackBarType.success,
                            actionLabel: l10n.view_meals,
                            onActionPressed: () {
                              Navigator.pushNamed(context, AppRoutes.foodLogs);
                            },
                          );
                        } else if (state is AddMealError &&
                            state.messageId == widget.message.id) {
                          AppSnackBar.show(
                            context,
                            message: state.message,
                            type: SnackBarType.error,
                          );
                        }
                      },
                      builder: (context, state) {
                        final nutritionCubit = context.read<NutritionCubit>();
                        final isLoading =
                            state is AddMealLoading &&
                            state.messageId == widget.message.id;

                        if (widget.showTypingEffect &&
                            _displayedText != widget.message.body) {
                          return const SizedBox.shrink();
                        }

                        return FutureBuilder<bool>(
                          future: nutritionCubit.isMessageSaved(widget.message),
                          initialData: false,
                          builder: (context, snapshot) {
                            final isSaved = snapshot.data ?? false;

                            return AnimatedOpacity(
                              opacity: isLoading ? 0.6 : 1.0,
                              duration: const Duration(milliseconds: 200),
                              child: ElevatedButton.icon(
                                onPressed:
                                    isSaved || isLoading ? null : _saveMeal,
                                icon: isLoading
                                    ? SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                isSaved
                                                    ? Colors.grey.shade400
                                                    : Colors.white,
                                              ),
                                        ),
                                      )
                                    : Icon(
                                        isSaved
                                            ? Icons.check_circle
                                            : Icons.bookmark_border,
                                        size: 16,
                                      ),
                                label: Text(
                                  isSaved ? l10n.saved : l10n.save,
                                  style: const TextStyle(fontSize: 11),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isSaved
                                      ? Colors.grey.shade400
                                      : AppColors.primaryBtn,
                                  disabledBackgroundColor: Colors.grey.shade400,
                                  foregroundColor: Colors.white,
                                  disabledForegroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  minimumSize: const Size(0, 44),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}