import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../ ads/presentation/view_model/ads_cubit.dart';
import '../../../ ads/presentation/widgets/ads_carousel_widget.dart';
import '../../../../core/di/service_locator.dart';

class CoachScreen extends StatelessWidget {
  const CoachScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10), 
          BlocProvider(
            create: (context) => getIt<AdsCubit>(),
            child: const AdsCarouselWidget(),
          ),

          const SizedBox(height: 20),

          const Padding(padding: EdgeInsets.symmetric(horizontal: 20)),
          // مثلاً: قائمة المتدربين المشتركين اليوم، إحصائيات سريعة، الخ.
        ],
      ),
    );
  }
}
