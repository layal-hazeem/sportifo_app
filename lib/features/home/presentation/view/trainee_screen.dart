import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../ ads/presentation/view_model/ads_cubit.dart';
import '../../../ ads/presentation/widgets/ads_carousel_widget.dart';
import '../../../../core/di/service_locator.dart';

class TraineeScreen extends StatelessWidget {
  const TraineeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10), // مسافة صغيرة من الـ AppBar

          BlocProvider(
            create: (context) => getIt<AdsCubit>(), // استدعاء الكيوبت من GetIt
            child: const AdsCarouselWidget(),
          ),

          const SizedBox(height: 20),

          //  2. هون رح تحطي باقي محتوى الهوم مستقبلاً
          // مثلاً: "أكمل تمرينك"، "نصيحة اليوم"، "تمارين مقترحة"
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            // child: Text(
            //   "Recommended for you",
            //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            // ),
          ),
          // ... باقي الويدجتات
        ],
      ),
    );
  }
}