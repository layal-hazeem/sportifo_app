import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/routes/app_routes.dart';
import '../../data/models/subscription_model.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';

class SubscriptionDetailsBottomSheet extends StatelessWidget {
  final int coachId;
  final SubscriptionModel subscription;

  const SubscriptionDetailsBottomSheet({
    super.key,
    required this.subscription,
    required this.coachId,
  });

  static void show(BuildContext context, SubscriptionModel subscription, int coachId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.15),
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: SubscriptionDetailsBottomSheet(subscription: subscription, coachId: coachId),
        );
      },
    );
  }

  List<Color> _getTypeGradients(String type) {
    switch (type.toLowerCase()) {
      case 'gold':
        return [const Color(0xFFFFD700), const Color(0xFFFFB300)];
      case 'silver':
        return [const Color(0xFFE0E0E0), const Color(0xFFB8B8B8)];
      case 'bronze':
        return [const Color(0xFFE5A65D), const Color(0xFFCD7F32)];
      default:
        return [const Color(0xFFFF8A65), const Color(0xFFFF6B35)];
    }
  }

  List<String> _extractFeatures(String description) {
    if (description.isEmpty) {
      return [];
    }
    final parts = description.split(RegExp(r'[.!?,\n]'));
    final features = parts
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty && s.length > 3)
        .toList();
    return features;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final planColors = _getTypeGradients(subscription.type);
    const mainAppColor = Color(0xFFFF6B35);
    final screenHeight = MediaQuery.of(context).size.height;
    final features = _extractFeatures(subscription.description);

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.3,
      maxChildSize: 0.75,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      color: Colors.black.withOpacity(0.08),
                    ),
                  ),
                ),
              ),

              ListView(
                controller: scrollController,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.zero,
                children: [
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      width: 45,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: planColors),
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: planColors[0].withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.workspace_premium, color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            subscription.type.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Container(
                    width: double.infinity,
                    constraints: BoxConstraints(minHeight: screenHeight * 0.35),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF9FAFC),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 30, 24, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            subscription.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        if (features.isNotEmpty) ...[
                          Row(
                            children: [
                              const Icon(Icons.stars, color: mainAppColor, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                l10n.subscription_details_featuresTitle,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          ...features.map((feature) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    child: Icon(
                                      Icons.check_circle,
                                      color: mainAppColor,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      feature,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF3A3A3A),
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                        if (features.isEmpty) ...[
                          Center(
                            child: Text(
                              l10n.subscription_details_noFeatures,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              // زر الاشتراك
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 15, 24, 30),
                  color: const Color(0xFFF9FAFC),
                  child: Container(
                    width: double.infinity,
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [mainAppColor, Color(0xFFFF5216)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: mainAppColor.withOpacity(0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(
                          context,
                          AppRoutes.selectMonth,
                          arguments: {
                            'coachId': coachId,
                            'subscription': subscription,
                          },
                        );
                      },
                      child: Text(
                        l10n.subscription_details_subscribeButton,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}