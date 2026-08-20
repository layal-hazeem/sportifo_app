import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';
import 'package:sportifo_app/core/widgets/wave_app_bar.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';

import '../../data/models/my_subscription_record_model.dart';
import '../view_model/my_subscriptions_cubit/my_subscriptions_cubit.dart';
import '../view_model/my_subscriptions_cubit/my_subscriptions_state.dart';

class MySubscriptionsScreen extends StatelessWidget {
  const MySubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: WaveAppBar(
        title: l10n.mySubscriptions,
        showBackButton: true,
      ),
      body: BlocBuilder<MySubscriptionsCubit, MySubscriptionsState>(
        builder: (context, state) {
          if (state is MySubscriptionsLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBtn),
            );
          } else if (state is MySubscriptionsError) {
            return _ErrorView(
              message: state.message,
              onRetry: () =>
                  context.read<MySubscriptionsCubit>().fetchMySubscriptions(),
            );
          } else if (state is MySubscriptionsSuccess) {
            final list = state.subscriptions;

            if (list.isEmpty) {
              return const _EmptyView();
            }

            return RefreshIndicator(
              color: AppColors.primaryBtn,
              backgroundColor: context.backgroundColor,
              onRefresh: () => context
                  .read<MySubscriptionsCubit>()
                  .fetchMySubscriptions(isRefresh: true),
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  return _SubscriptionRecordCard(item: list[index]);
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ============================================================
// حالة الخطأ - تصميم احترافي
// ============================================================
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                color: Colors.redAccent,
                size: 45,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: TextStyle(
                color: context.textColor.withOpacity(0.8),
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: 200,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 22),
                label: Text(
                  l10n.tryAgain,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBtn,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                  shadowColor: AppColors.primaryBtn.withOpacity(0.4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// حالة عدم وجود اشتراكات
// ============================================================
class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryBtn.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                color: AppColors.primaryBtn,
                size: 50,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noSubscriptionsYet,
              style: TextStyle(
                color: context.textColor.withOpacity(0.7),
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// 💎 بطاقة الاشتراك بتصميم "التذكرة الرقمية" (Premium UI)
// ============================================================
class _SubscriptionRecordCard extends StatelessWidget {
  final MySubscriptionRecordModel item;

  const _SubscriptionRecordCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // تجهيز البيانات
    final statusColor = _getStatusColor(item.status);
    final statusIcon = _getStatusIcon(item.status);
    final statusText = _getStatusText(item.status, l10n);
    final isCurrent = item.isActive == 1;

    final startDateFormatted =
    MySubscriptionRecordModel.formatDateOnly(item.startDate);
    final endDateFormatted =
    MySubscriptionRecordModel.formatDateOnly(item.endDate);
    final confirmedAtFormatted =
    MySubscriptionRecordModel.formatDateOnly(item.confirmedAt);

    final showConfirmedAt =
        (item.status == 'active' || item.status == 'expired') &&
            item.confirmedAt != null &&
            item.confirmedAt!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isCurrent
              ? AppColors.primaryBtn
              : Colors.grey.withOpacity(0.2),
          width: isCurrent ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isCurrent
                ? AppColors.primaryBtn.withOpacity(0.12)
                : Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ------------------------------------
          // 1️⃣ القسم العلوي: السعر والحالة واسم الخطة
          // ------------------------------------
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatusChip(
                      color: statusColor,
                      icon: statusIcon,
                      text: statusText,
                    ),
                    _AmountText(
                      amount: item.amount,
                      currency: item.currency,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.subscription?.title ?? l10n.subscription,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: context.textColor,
                          letterSpacing: -0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCurrent) ...[
                      const SizedBox(width: 8),
                      _CurrentBadge(text: l10n.currentSubscription),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // خط فاصل شفاف
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey.withOpacity(0.15),
            indent: 20,
            endIndent: 20,
          ),

          // ------------------------------------
          // 2️⃣ القسم الأوسط: التفاصيل (كوتش، رقم عملية)
          // ------------------------------------
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                if (item.subscription?.coach != null) ...[
                  _buildModernDetailRow(
                    context,
                    icon: Icons.sports_kabaddi_rounded,
                    label: l10n.coach,
                    value: item.subscription!.coach!.fullName,
                  ),
                  const SizedBox(height: 16),
                ],
                _buildModernDetailRow(
                  context,
                  icon: Icons.receipt_long_rounded,
                  label: l10n.processNumber,
                  value: (item.processNumber != null &&
                      item.processNumber!.isNotEmpty)
                      ? item.processNumber!
                      : "—",
                ),
                if (showConfirmedAt) ...[
                  const SizedBox(height: 16),
                  _buildModernDetailRow(
                    context,
                    icon: Icons.verified_rounded,
                    label: l10n.confirmedAt,
                    value: confirmedAtFormatted,
                    iconColor: const Color(0xFF2E7D32), // لون أخضر للتأكيد
                  ),
                ],
              ],
            ),
          ),

          // ------------------------------------
          // 3️⃣ القسم السفلي (Footer): التواريخ (ستايل التذكرة)
          // ------------------------------------
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: isCurrent
                  ? AppColors.primaryBtn.withOpacity(0.04)
                  : Colors.grey.withOpacity(0.04),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(22), // نفس انحناء الكارد
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildDateColumn(
                    context,
                    label: l10n.startDate,
                    date: startDateFormatted,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                ),
                Expanded(
                  child: _buildDateColumn(
                    context,
                    label: l10n.endDate,
                    date: endDateFormatted,
                    isEnd: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ودجت لعرض صف التفاصيل بشكل أنيق
  Widget _buildModernDetailRow(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String value,
        Color? iconColor,
      }) {
    final effectiveIconColor = iconColor ?? AppColors.primaryBtn;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: effectiveIconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: effectiveIconColor),
        ),
        const SizedBox(width: 12),
        Text(
          "$label: ",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: context.textColor,
            ),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ودجت لعرض التواريخ في الـ Footer
  Widget _buildDateColumn(
      BuildContext context, {
        required String label,
        required String date,
        bool isEnd = false,
      }) {
    return Column(
      crossAxisAlignment:
      isEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          date,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: context.textColor,
          ),
        ),
      ],
    );
  }

  // دوال مساعدة للألوان والأيقونات
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return const Color(0xFF10B981); // Emerald Green
      case 'pending':
        return const Color(0xFFF59E0B); // Amber
      case 'rejected':
        return const Color(0xFFEF4444); // Red
      case 'expired':
        return const Color(0xFF6B7280); // Gray
      default:
        return AppColors.primaryBtn;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Icons.verified_user_rounded;
      case 'pending':
        return Icons.pending_actions_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
      case 'expired':
        return Icons.history_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  String _getStatusText(String status, AppLocalizations l10n) {
    switch (status.toLowerCase()) {
      case 'active':
        return l10n.statusActive;
      case 'pending':
        return l10n.statusPending;
      case 'rejected':
        return l10n.statusRejected;
      case 'expired':
        return l10n.statusExpired;
      default:
        return status;
    }
  }
}

// ============================================================
// شارة الحالة (Active / Pending / Rejected / Expired)
// ============================================================
class _StatusChip extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String text;

  const _StatusChip({
    required this.color,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// شارة "الاشتراك الحالي" المضيئة
// ============================================================
class _CurrentBadge extends StatelessWidget {
  final String text;

  const _CurrentBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryBtn,
            AppColors.primaryBtn.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBtn.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.stars_rounded, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// نص المبلغ (مدمج بدون خلفية ليعطي طابع أنظف)
// ============================================================
class _AmountText extends StatelessWidget {
  final num amount;
  final String currency;

  const _AmountText({required this.amount, required this.currency});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          "$amount",
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppColors.primaryBtn,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          currency,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryBtn.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}