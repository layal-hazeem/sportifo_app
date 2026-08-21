import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sportifo_app/core/di/service_locator.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';
import 'package:sportifo_app/core/widgets/no_internet_view.dart'; // ✅ استدعاء الودجت الموحدة
import '../../../../l10n/app_localizations.dart';
import '../view_model/coach_details_cubit.dart';
import '../view_model/coach_details_state.dart';
import '../widgets/coach_banner.dart';
import '../widgets/coach_info_badges.dart';
import '../widgets/certifications_list.dart';
import '../widgets/coach_subscriptions_list.dart';

class CoachDetailsScreen extends StatelessWidget {
  final int coachId;
  const CoachDetailsScreen({super.key, required this.coachId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: BlocProvider(
        create: (context) =>
            getIt<CoachDetailsCubit>()..fetchCoachDetails(coachId),
        child: BlocBuilder<CoachDetailsCubit, CoachDetailsState>(
          builder: (context, state) {
            if (state is CoachDetailsLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B35)),
                ),
              );
            }
            // ✅✅✅ هون عدلنا: إذا فشل التحميل وما في بيانات مخزنة
            // بنعرض NoInternetView الموحدة بدل الـ Center القديم
            else if (state is CoachDetailsError) {
              return NoInternetView(
                onRetry: () =>
                    context.read<CoachDetailsCubit>().fetchCoachDetails(coachId),
                title: 'Unable to Load Coach Details',
                subtitle:
                    'Please check your connection and try again.\nCoach details will appear automatically when available.',
              );
            } else if (state is CoachDetailsLoaded) {
              final coach = state.coachDetails;
              return Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CoachBanner(
                          profilePic: coach.profilePic,
                          fullName: coach.fullName,
                        ),
                        const SizedBox(height: 24),
                        CoachInfoBadges(
                          yearsOfExp: coach.yearsOfExp,
                          dateOfBirth: coach.dateOfBirth,
                          gender: coach.gender,
                        ),
                        const SizedBox(height: 28),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            l10n.biography,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: context.textColor,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            coach.description.isNotEmpty
                                ? coach.description
                                : l10n.no_biography,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF555555),
                              height: 1.6,
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),
                        CoachSubscriptionsList(
                          subscriptions: coach.subscriptions,
                          coachId: coach.id,
                        ),
                        const SizedBox(height: 28),
                        if (coach.pics.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              l10n.qualifications_certifications,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: context.textColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          CertificationsList(pics: coach.pics),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}