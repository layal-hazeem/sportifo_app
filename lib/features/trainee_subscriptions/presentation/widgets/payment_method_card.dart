import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';
import '../../../../core/constants/payment_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/helpers/snack_bar_utils.dart';
import '../../../../l10n/app_localizations.dart';

class PaymentMethodCard extends StatelessWidget {
  const PaymentMethodCard({super.key});

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
            color: AppColors.primaryBtn.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                PaymentConstants.qrImageUrl,
                width: 150,
                height: 150,
                fit: BoxFit.fill,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.qr_code_scanner,
                  size: 100,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildAccountDetailRow(
            l10n.subscription_payment_accountNameLabel,
            PaymentConstants.accountName,
            Icons.person_outline,
            context,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: Colors.grey.shade200, height: 1),
          ),
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                color: Colors.grey.shade500,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.subscription_payment_walletNumberLabel,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  PaymentConstants.accountNumber,
                  style: const TextStyle(
                    color: AppColors.primaryBtn,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(text: PaymentConstants.accountNumber),
                  );
                  AppSnackBar.show(
                    context,
                    message: l10n.subscription_payment_copySuccess,
                    type: SnackBarType.success,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBtn.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.copy,
                    size: 16,
                    color: AppColors.primaryBtn,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccountDetailRow(
    String label,
    String value,
    IconData icon,
    BuildContext context,
  ) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade500, size: 20),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: context.textColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            textAlign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}
