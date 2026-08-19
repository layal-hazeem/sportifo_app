import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/helpers/dialog_helper.dart';
import '../../../../core/helpers/snack_bar_utils.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/wave_app_bar.dart';
import '../../../auth/presentation/widgets/custom_neumorphic_field.dart';
import '../../data/models/subscription_model.dart';
import '../../data/models/subscription_month_model.dart';
import '../../data/repositories/trainee_subscription_repository.dart';
import '../widgets/payment_button.dart';
import '../widgets/payment_method_card.dart';
import '../widgets/payment_summary_card.dart';
import '../widgets/payment_upload_section.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';

class PaymentScreen extends StatefulWidget {
  final int coachId;
  final SubscriptionModel subscription;
  final SubscriptionMonthModel selectedMonth;

  const PaymentScreen({
    super.key,
    required this.coachId,
    required this.subscription,
    required this.selectedMonth,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final TextEditingController _transactionController = TextEditingController();
  bool _isPaymentFileUploaded = false;
  String? _paymentFileName;
  String? _paymentFilePath;

  @override
  void dispose() {
    _transactionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final totalPrice = widget.selectedMonth.price;
    final currency = widget.subscription.currency;

    return Scaffold(
      appBar: WaveAppBar(
        title: l10n.subscription_payment_title,
        showBackButton: true,
      ),
      backgroundColor: context.backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PaymentSummaryCard(
              subscriptionTitle: widget.subscription.title,
              months: widget.selectedMonth.number,
              totalPrice: totalPrice,
              currency: currency,
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBtn,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.subscription_payment_paymentMethod,
                  style: TextStyle(
                    color: context.textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            const PaymentMethodCard(),
            const SizedBox(height: 24),

            Text(
              l10n.subscription_payment_confirmTransfer,
              style: TextStyle(
                color: context.textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            PaymentUploadSection(
              onFilePicked: (path, name) {
                setState(() {
                  _paymentFilePath = path;
                  _paymentFileName = name;
                  _isPaymentFileUploaded = true;
                });
              },
            ),
            const SizedBox(height: 16),

            CustomNeumorphicField(
              controller: _transactionController,
              hint: l10n.subscription_payment_transaction_hint,
              keyboardType: TextInputType.text,
              icon: Icons.confirmation_number_outlined,
              onChanged: (value) {},
            ),
            const SizedBox(height: 35),

            PaymentButton(
              isEnabled: _isPaymentFileUploaded,
              onPressed: _confirmPayment,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmPayment() async {
    final l10n = AppLocalizations.of(context)!;
    final transactionId = _transactionController.text.trim();

    if (!_isPaymentFileUploaded || _paymentFilePath == null) {
      AppSnackBar.show(
        context,
        message: l10n.subscription_payment_uploadReceiptFirst,
        type: SnackBarType.error,
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final paymentFile = await MultipartFile.fromFile(
        _paymentFilePath!,
        filename: _paymentFileName,
      );

      final repository = getIt<TraineeSubscriptionRepository>();
      final result = await repository.subscribe(
        coachId: widget.coachId,
        subscriptionId: widget.subscription.id,
        months: widget.selectedMonth.number,
        totalPrice: widget.selectedMonth.price.toDouble(),
        transactionId: transactionId.isNotEmpty ? transactionId : null,
        paymentFile: paymentFile,
      );

      if (mounted) Navigator.pop(context);

      if (result is Success<String>) {
        if (mounted) {
          _showSuccessDialog(result.data, transactionId);
        }
      } else if (result is Failure<String>) {
        if (mounted) {
          AppSnackBar.show(
            context,
            message: l10n.subscription_payment_requestFailed(result.message),
            type: SnackBarType.error,
          );
        }
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        AppSnackBar.show(
          context,
          message: l10n.subscription_payment_unexpectedError(e.toString()),
          type: SnackBarType.error,
        );
      }
    }
  }

  void _showSuccessDialog(String message, String transactionId) {
    final l10n = AppLocalizations.of(context)!;
    String dialogMessage = message;
    if (transactionId.isNotEmpty) {
      dialogMessage =
          '$message\n\n${l10n.subscription_payment_transactionId(transactionId)}';
    }

    DialogHelper.showCustomDialog(
      context: context,
      title: l10n.subscription_payment_successTitle,
      message: dialogMessage,
      type: DialogType.success,
      confirmBtnText: l10n.subscription_payment_ok,
      onConfirm: () {
        Navigator.pop(context);
        Navigator.pop(context);
      },
    );
  }
}
