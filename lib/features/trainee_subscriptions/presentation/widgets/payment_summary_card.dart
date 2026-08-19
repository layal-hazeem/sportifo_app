import 'package:flutter/material.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

class PaymentSummaryCard extends StatelessWidget {
  final String subscriptionTitle;
  final int months;
  final num totalPrice;
  final String currency;

  const PaymentSummaryCard({
    super.key,
    required this.subscriptionTitle,
    required this.months,
    required this.totalPrice,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.receipt_long,
                color: AppColors.primaryBtn,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.subscription_payment_orderSummary,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Colors.grey.shade200, height: 1),
          ),
          _buildSummaryRow(
            l10n.subscription_payment_planLabel,
            subscriptionTitle,
          ),
          const SizedBox(height: 10),
          _buildSummaryRow(
            l10n.subscription_payment_durationLabel,
            l10n.subscription_selectMonth_monthsLabel(months),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Colors.grey.shade200, height: 1),
          ),
          _buildSummaryRow(
            l10n.subscription_payment_totalLabel,
            '$totalPrice $currency',
            isPrice: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isPrice = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        Text(
          value,
          style: TextStyle(
            color: isPrice ? AppColors.primaryBtn : Colors.black87,
            fontWeight: isPrice ? FontWeight.bold : FontWeight.w600,
            fontSize: isPrice ? 18 : 14,
          ),
        ),
      ],
    );
  }
}
