// lib/features/home/presentation/view/user_screen.dart
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

class TraineeScreen extends StatelessWidget {
  const TraineeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),

          // الإعلانات (موجودة سابقاً)
          BlocProvider(
            create: (context) => getIt<AdsCubit>(),
            child: const AdsCarouselWidget(),
          ),

          const SizedBox(height: 20),

          // lib/features/home/presentation/view/user_screen.dart
// استبدلي الجزء الخاص بجلب المدربين بهذا الكود:
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
                      // عنوان القسم مع زر See All
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                             Text(
                              l10n.coaches,
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const AllCoachesScreen()),
                                );
                              },
                              child:  Text(l10n.see_all),
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

          // هنا يمكنك إضافة محتوى آخر مستقبلاً (تمارين مقترحة، نصائح...)
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}