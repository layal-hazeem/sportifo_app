import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sportifo_app/core/di/service_locator.dart';
import '../../../../l10n/app_localizations.dart';
import '../view_model/coach_details_cubit.dart';
import '../view_model/coach_details_state.dart';
import '../widgets/coach_banner.dart';
import '../widgets/coach_info_badges.dart';
import '../widgets/certifications_list.dart';
import '../widgets/book_consultation_button.dart';

class CoachDetailsScreen extends StatelessWidget {
  final int coachId;
  const CoachDetailsScreen({super.key, required this.coachId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: BlocProvider(
        create: (context) => getIt<CoachDetailsCubit>()..fetchCoachDetails(coachId),
        child: BlocBuilder<CoachDetailsCubit, CoachDetailsState>(
          builder: (context, state) {
            if (state is CoachDetailsLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B35)),
                ),
              );
            } else if (state is CoachDetailsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      l10n.coach_details_error(state.message),
                      style: const TextStyle(fontSize: 16, color: Colors.red),
                    ),
                  ],
                ),
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
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
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
                        if (coach.pics.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              l10n.qualifications_certifications,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A),
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
                  BookConsultationButton(
                    onTap: () {
                      // منطق الحجز هنا
                    },
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