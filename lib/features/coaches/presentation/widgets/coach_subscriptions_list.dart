import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../trainee_subscriptions/data/models/subscription_model.dart';
import '../../../trainee_subscriptions/presentation/widgets/SubscriptionDetailsBottomSheet.dart';

class CoachSubscriptionsList extends StatelessWidget {
  final List<SubscriptionModel> subscriptions;
  final int coachId;

  const CoachSubscriptionsList({super.key,required this.coachId, required this.subscriptions});

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'gold':
        return const Color(0xFFFFD700);
      case 'silver':
        return const Color(0xFFC0C0C0);
      case 'bronze':
        return const Color(0xFFCD7F32);
      default:
        return AppColors.primaryBtn;
    }
  }

  String _getPriceRange(SubscriptionModel sub) {
    if (sub.months.isEmpty) return '0';
    if (sub.months.length == 1) {
      return '${sub.months.first.price}';
    }
    // إذا كان هناك أكثر من شهر، نعرض أقل وأعلى سعر
    final prices = sub.months.map((m) => m.price).toList();
    final minPrice = prices.reduce((a, b) => a < b ? a : b);
    final maxPrice = prices.reduce((a, b) => a > b ? a : b);
    if (minPrice == maxPrice) {
      return '$minPrice';
    }
    return '$minPrice - $maxPrice';
  }

  String _getMonthRange(SubscriptionModel sub) {
    if (sub.months.isEmpty) return '0';
    if (sub.months.length == 1) {
      return '${sub.months.first.number} Month';
    }
    final numbers = sub.months.map((m) => m.number).toList();
    final minNum = numbers.reduce((a, b) => a < b ? a : b);
    final maxNum = numbers.reduce((a, b) => a > b ? a : b);
    return '$minNum - $maxNum Months';
  }

  @override
  Widget build(BuildContext context) {
    if (subscriptions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Available Subscriptions",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
              letterSpacing: 0.3,
            ),
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: subscriptions.length,
            itemBuilder: (context, index) {
              final sub = subscriptions[index];
              return Padding(
                padding: const EdgeInsets.only(right: 15),
                child: GestureDetector(
                  onTap: () {
                    SubscriptionDetailsBottomSheet.show(context, sub, coachId);
                  },
                  child: Neumorphic(
                    style: NeumorphicStyle(
                      depth: 4,
                      boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(15)),
                      color: const Color(0xFFF7F7F7),
                      lightSource: LightSource.topLeft,
                    ),
                    child: Container(
                      width: 150,
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.workspace_premium,
                            color: _getTypeColor(sub.type),
                            size: 30,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            sub.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "${_getPriceRange(sub)} ${sub.currency}",
                            style: TextStyle(
                              color: AppColors.primaryBtn,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            _getMonthRange(sub),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}