import 'package:flutter/material.dart';
import 'package:sportifo_app/core/routes/app_routes.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';

class CreateSelfPlanCard extends StatelessWidget {
  const CreateSelfPlanCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, AppRoutes.createSelfPlan);
        },
        child: Container(
          height: 205,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryBtn,
                AppColors.primaryBtn.withOpacity(.78),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBtn.withOpacity(.22),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background decoration
              PositionedDirectional(
                end: -20,
                bottom: -70,
                child: Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(.08),
                      width: 28,
                    ),
                  ),
                ),
              ),

              Positioned(
                right: -20,
                bottom: -70,
                child: Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(.06),
                      width: 22,
                    ),
                  ),
                ),
              ),

              // Small decorative icon
              PositionedDirectional(
                end: 24,
                top: 22,
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.12),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white.withOpacity(.10)),
                  ),
                  child: const Icon(
                    Icons.fitness_center_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(22, 22, 22, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Label
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),

                        const SizedBox(width: 8),

                        Text(
                          l10n.personalWorkout,
                          style: TextStyle(
                            color: Colors.white.withOpacity(.78),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Title
                    Text(
                      l10n.createYourOwnPlan,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),

                    const SizedBox(height: 7),

                    // Description
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .65,
                      child: Text(
                        l10n.buildWorkoutPlanThatFitsYou,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(.82),
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // CTA
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 17,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.createPlan,
                            style: TextStyle(
                              color: AppColors.primaryBtn,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),

                          const SizedBox(width: 9),

                          Icon(
                            Directionality.of(context) == TextDirection.rtl
                                ? Icons.arrow_back_rounded
                                : Icons.arrow_forward_rounded,
                            color: AppColors.primaryBtn,
                            size: 17,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
