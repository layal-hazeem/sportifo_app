import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';
import '../../../ ads/presentation/view_model/ads_cubit.dart';
import '../../../ ads/presentation/widgets/ads_carousel_widget.dart';
import '../../../../core/di/service_locator.dart';
import '../../../coaches/presentation/view_model/coaches_cubit.dart';
import '../../../coaches/presentation/view_model/coaches_state.dart';
import '../../../coaches/presentation/views/all_coaches_screen.dart';
import '../../../coaches/presentation/views/coach_details_screen.dart';
import '../../../coaches/presentation/widgets/coach_card.dart';

// 🔥 الاستيرادات الجديدة الخاصة بالأهداف الذكية
import '../../../targets/presentation/view_model/target_cubit/target_cubit.dart';
import '../../../targets/presentation/view_model/target_cubit/target_state.dart';
import '../../../targets/presentation/widgets/daily_nutrition_card.dart';
import '../../../targets/presentation/widgets/target_activation_card.dart';
import '../../../../core/widgets/loading_shimmer.dart';

class TraineeScreen extends StatelessWidget {
  const TraineeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<AdsCubit>()),
        // 🔥 حقن كوبيت الأهداف وتشغيله فورا عند فتح الهوم لجلب البيانات
        BlocProvider(create: (context) => getIt<TargetCubit>()..fetchLatestTarget()),
      ],
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // 1️⃣ الإعلانات (مقرها الأساسي)
            const AdsCarouselWidget(),

            const SizedBox(height: 10),

            // 2️⃣ ⚡ القسم العالمي الجديد: إدارة وتتبع الأهداف الغذائية والسعرات الحرارية
            BlocBuilder<TargetCubit, TargetState>(
              builder: (context, state) {
                if (state is TargetLoading) {
                  // تأثير الشيمر اللطيف أثناء التحميل
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: LoadingShimmer(width: double.infinity, height: 160, borderRadius: 24),
                  );
                } else if (state is TargetSuccess) {
                  // عيشي الفخامة! إذا في داتا مسجلة، بيظهر كرت الحلقات والماكروز فوراً
                  return DailyNutritionCard(target: state.targetData);
                } else {
                  // الـ World-Class UX: لو اليوزر جديد وماله حاطط هدف (TargetInitial)
                  // بيختفي كرت السعرات الفاضي وبيظهر كرت التفعيل المثير للاهتمام!
                  return const TargetActivationCard();
                }
              },
            ),

            const SizedBox(height: 15),

            // 3️⃣ قسم المدربين والمشتركين (كودك الأصلي النظيف)
            BlocProvider(
              create: (context) => getIt<CoachesCubit>()..fetchCoaches(),
              child: BlocBuilder<CoachesCubit, CoachesState>(
                builder: (context, state) {
                  if (state is CoachesLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is CoachesLoaded) {
                    final coaches = state.coaches;
                    if (coaches.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.coaches,
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const AllCoachesScreen()),
                                  );
                                },
                                child: Text(l10n.see_all),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 220,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemCount: coaches.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final coach = coaches[index];
                              return CoachCard(
                                coach: coach,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CoachDetailsScreen(coachId: coach.id),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  } else if (state is CoachesError) {
                    return Center(child: Text('${l10n.error}: ${state.message}'));
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}