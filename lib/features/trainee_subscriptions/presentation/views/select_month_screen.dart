import 'package:flutter/material.dart';
import '../../../../core/helpers/snack_bar_utils.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/wave_app_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/subscription_model.dart';
import '../../data/models/subscription_month_model.dart';
import 'payment_screen.dart';

class SelectMonthScreen extends StatefulWidget {
  final int coachId;
  final SubscriptionModel subscription;

  const SelectMonthScreen({
    super.key,
    required this.coachId,
    required this.subscription,
  });

  @override
  State<SelectMonthScreen> createState() => _SelectMonthScreenState();
}

class _SelectMonthScreenState extends State<SelectMonthScreen> {
  SubscriptionMonthModel? _selectedMonth;

  @override
  void initState() {
    super.initState();
    if (widget.subscription.months.isNotEmpty) {
      _selectedMonth = widget.subscription.months.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final months = widget.subscription.months;
    final currency = widget.subscription.currency;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          WaveAppBar(
            title: l10n.subscription_selectMonth_title,
            showBackButton: true,
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
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
                            Text(
                              widget.subscription.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBtn.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                widget.subscription.type.toUpperCase(),
                                style: const TextStyle(
                                  color: AppColors.primaryBtn,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),

                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 24, left: 24, top: 12, bottom: 8),
                    child: Text(
                      l10n.subscription_selectMonth_availablePlans,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: months.length,
                    itemBuilder: (context, index) {
                      final month = months[index];
                      final isSelected = _selectedMonth?.id == month.id;
                      return _buildProfessionalMonthCard(month, isSelected, currency, l10n);
                    },
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 30, top: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _selectedMonth != null
                    ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PaymentScreen(
                        coachId: widget.coachId,
                        subscription: widget.subscription,
                        selectedMonth: _selectedMonth!,
                      ),
                    ),
                  );
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBtn,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _selectedMonth != null
                          ? l10n.subscription_selectMonth_continueToPayment
                          : l10n.subscription_selectMonth_selectToContinue,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalMonthCard(
      SubscriptionMonthModel month,
      bool isSelected,
      String currency,
      AppLocalizations l10n,
      ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMonth = month;
        });
        AppSnackBar.show(
          context,
          message: l10n.subscription_selectMonth_selectionConfirmed(month.number.toString()),
          type: SnackBarType.info,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFFFDFDFD),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryBtn : Colors.grey.shade200,
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primaryBtn.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.01),
              blurRadius: isSelected ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primaryBtn : Colors.grey.shade400,
                  width: isSelected ? 7 : 2,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.subscription_selectMonth_durationLabel(month.number.toString()),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.subscription_selectMonth_monthlyPriceDetail(
                      (month.price / month.number).toStringAsFixed(1),
                      currency,
                    ),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${month.price}',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: isSelected ? AppColors.primaryBtn : const Color(0xFF1A1A1A),
                  ),
                ),
                Text(
                  currency,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}