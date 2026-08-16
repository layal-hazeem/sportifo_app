import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart'; // 🔥 استدعاء ملف الترجمة

class HowToPerformCard extends StatefulWidget {
  final String description;
  final String title;

  const HowToPerformCard({
    super.key,
    required this.description,
    required this.title,
  });

  @override
  State<HowToPerformCard> createState() => _HowToPerformCardState();
}

class _HowToPerformCardState extends State<HowToPerformCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _arrowController;
  late Animation<double> _arrowAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _arrowController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _arrowAnimation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _arrowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _arrowController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _arrowController.forward();
      } else {
        _arrowController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // 🔥 تعريف متغير الترجمة

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isExpanded
              ? AppColors.primaryBtn.withValues(alpha:0.3)
              : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: _isExpanded
                ? AppColors.primaryBtn.withValues(alpha:0.1)
                : Colors.black.withValues(alpha:0.03),
            blurRadius: _isExpanded ? 20 : 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            // Header
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _toggle,
                splashColor: AppColors.primaryBtn.withValues(alpha:0.05),
                highlightColor: AppColors.primaryBtn.withValues(alpha:0.02),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  decoration: BoxDecoration(
                    gradient: _isExpanded
                        ? LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        AppColors.primaryBtn.withValues(alpha:0.08),
                        AppColors.primaryBtn.withValues(alpha:0.02),
                      ],
                    )
                        : null,
                    color: _isExpanded ? null : Colors.white,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBtn.withValues(alpha:0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.menu_book_rounded,
                          color: AppColors.primaryBtn,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _isExpanded
                                  ? l10n.tapToHideInstructions // 🔥 التعديل هنا
                                  : l10n.tapToViewInstructions, // 🔥 التعديل هنا
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      RotationTransition(
                        turns: _arrowAnimation,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: _isExpanded
                                ? AppColors.primaryBtn.withValues(alpha:0.1)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: _isExpanded
                                ? AppColors.primaryBtn
                                : Colors.grey.shade600,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Body
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(
                      height: 1,
                      color: Colors.grey.shade200,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.description,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.blueGrey.shade800,
                        height: 1.8,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
              firstCurve: Curves.easeInOut,
              secondCurve: Curves.easeInOut,
              sizeCurve: Curves.easeInOut,
            ),
          ],
        ),
      ),
    );
  }
}