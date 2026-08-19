import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sportifo_app/core/di/service_locator.dart';
import 'package:sportifo_app/core/network/api_result.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';
import 'package:sportifo_app/core/widgets/custom_glass_bottom_sheet.dart';
import 'package:sportifo_app/core/widgets/wave_app_bar.dart';

import 'package:sportifo_app/features/create_plan_by_coach/data/models/plan_day_ui_model.dart';
import 'package:sportifo_app/features/create_plan_by_coach/presentation/widgets/create_day_bottom_sheet.dart';
import 'package:sportifo_app/features/create_plan_by_coach/presentation/widgets/day_settings_bottom_sheet.dart';
import 'package:sportifo_app/features/create_plan_by_coach/presentation/widgets/exercises_picker.dart';
import 'package:sportifo_app/features/create_plan_by_coach/presentation/widgets/day_card.dart';
import 'package:sportifo_app/features/create_plan_by_coach/presentation/widgets/plan_details_card.dart';

import 'package:sportifo_app/features/edit_coach_plan/presentation/widgets/edit_plan_loading.dart';

import 'package:sportifo_app/features/existing_days/data/model/existing_days_model.dart';
import 'package:sportifo_app/features/existing_days/presentation/view/existing_days_screen.dart';
import 'package:sportifo_app/features/existing_days/presentation/view_model/existing_days_cubit.dart';

import 'package:sportifo_app/features/plan_details/data/models/plan_details_model.dart';

import 'package:sportifo_app/features/workout/data/models/exercise_model.dart';
import 'package:sportifo_app/features/workout/data/repository/workout_repository.dart';

import 'package:sportifo_app/features/edit_coach_plan/data/models/edit_coach_plan_model.dart';
import 'package:sportifo_app/features/edit_coach_plan/data/models/edit_coach_plan_request.dart';
import 'package:sportifo_app/features/edit_coach_plan/presentation/view_model/edit_coach_plan_cubit.dart';
import 'package:sportifo_app/features/edit_coach_plan/presentation/view_model/edit_coach_plan_state.dart';

import 'package:sportifo_app/l10n/app_localizations.dart';

class EditCoachPlanScreen extends StatefulWidget {
  final PlanDetailsModel plan;

  const EditCoachPlanScreen({super.key, required this.plan});

  @override
  State<EditCoachPlanScreen> createState() => _EditCoachPlanScreenState();
}

class _EditCoachPlanScreenState extends State<EditCoachPlanScreen> {
  final PageController _pageController = PageController();

  int _currentStep = 0;

  late final List<PlanDayUiModel> days;

  /// Original backend day ID for every UI day.
  final Map<PlanDayUiModel, int> _dayIds = {};

  /// Exercise IDs that existed when the screen was opened.
  final Map<PlanDayUiModel, Set<int>> _originalExerciseIds = {};

  /// IDs of days deleted by the coach.
  final List<int> _deletedDayIds = [];

  bool isFabOpen = false;

  String? selectedGoal;
  int durationMonths = 1;

  @override
  void initState() {
    super.initState();

    selectedGoal = widget.plan.goal;
    durationMonths = widget.plan.durationMonths ?? 1;

    days = widget.plan.days.map((day) {
      final uiDay = PlanDayUiModel(
        name: day.name,
        exercises: List<ExerciseModel>.from(day.exercises),
      );

      _dayIds[uiDay] = day.id;

      _originalExerciseIds[uiDay] = day.exercises
          .map((exercise) => exercise.id)
          .toSet();

      return uiDay;
    }).toList();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ============================================================
  // STEP NAVIGATION
  // ============================================================

  void _goToNextStep() {
    if (_currentStep != 0) return;

    if (selectedGoal == null) {
      _showValidationMessage(
        AppLocalizations.of(context)!.chooseGoalForTrainingPlan,
      );
      return;
    }

    _pageController
        .animateToPage(
          1,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
        )
        .then((_) {
          if (!mounted) return;

          setState(() {
            _currentStep = 1;
          });
        });
  }

  void _goToPreviousStep() {
    if (_currentStep != 1) return;

    _pageController
        .animateToPage(
          0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
        )
        .then((_) {
          if (!mounted) return;

          setState(() {
            _currentStep = 0;
          });
        });
  }

  // ============================================================
  // ADD DAY
  // ============================================================

  void addDay() {
    CreateDayBottomSheet.show(context, (value) {
      setState(() {
        days.add(PlanDayUiModel(name: value, exercises: []));
      });
    });
  }

  // ============================================================
  // ADD EXISTING DAY
  // ============================================================

  Future<void> addExistingDays() async {
    final selectedDays =
        await CustomGlassBottomSheet.show<List<ExistingDaysModel>>(
          context: context,
          height: 0.85,
          child: BlocProvider(
            create: (_) => getIt<ExistingDaysCubit>()..getExistingDays(),
            child: const ExistingDaysListBottomSheet(),
          ),
        );

    if (selectedDays == null || selectedDays.isEmpty) {
      return;
    }

    setState(() {
      for (final day in selectedDays) {
        final uiDay = PlanDayUiModel(
          name: day.name ?? '',
          exercises:
              day.exercises
                  ?.map(
                    (exercise) => ExerciseModel(
                      id: exercise.id ?? 0,
                      name: exercise.name ?? '',
                      description: exercise.description ?? '',
                      images:
                          exercise.images
                              ?.map(
                                (image) => ExerciseMedia(
                                  url: image.url ?? '',
                                  type: image.type ?? '',
                                ),
                              )
                              .toList() ??
                          [],
                      category: exercise.category != null
                          ? ExerciseCategory(
                              id: exercise.category!.id ?? 0,
                              name: exercise.category!.name ?? '',
                            )
                          : null,
                    ),
                  )
                  .toList() ??
              [],
        );

        days.add(uiDay);
      }
    });
  }

  // ============================================================
  // ADD EXERCISE
  // ============================================================

  Future<void> addExercise(int dayIndex) async {
    final workoutRepository = getIt<WorkoutRepository>();

    final result = await workoutRepository.getExercises();

    if (result is Failure) {
      return;
    }

    final exercises = (result as Success<List<ExerciseModel>>).data;

    final selected = await showModalBottomSheet<List<ExerciseModel>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.9,
          child: ExerciseMultiPickerBottomSheet(exercises: exercises),
        );
      },
    );

    if (selected == null || selected.isEmpty) {
      return;
    }

    setState(() {
      days[dayIndex].exercises.addAll(selected);
    });
  }

  // ============================================================
  // DELETE EXERCISE
  // ============================================================

  void _onDeleteExercise(int dayIndex, int exerciseIndex) {
    setState(() {
      days[dayIndex].exercises.removeAt(exerciseIndex);
    });
  }

  // ============================================================
  // DELETE DAY
  // ============================================================

  void _onDeleteDay(int index) {
    final day = days[index];

    final originalId = _dayIds[day];

    setState(() {
      days.removeAt(index);

      if (originalId != null) {
        _deletedDayIds.add(originalId);
      }
    });
  }

  // ============================================================
  // DAY SETTINGS
  // ============================================================

  Future<void> _onDaySettings(PlanDayUiModel day) async {
    final applyAll = await DaySettingsBottomSheet.show(context, day);

    if (applyAll == true) {
      setState(() {
        for (final exercise in day.exercises) {
          if (exercise.isCardio) {
            exercise.sets = null;
            exercise.reps = null;
          } else {
            exercise.sets = day.defaultSets;
            exercise.reps = day.defaultReps?.toString();
          }
        }
      });
    } else {
      setState(() {});
    }
  }

  // ============================================================
  // BUILD REQUEST
  // ============================================================

  EditCoachPlanRequest _buildRequest() {
    final dayPayloads = <PlanDay>[];

    for (final day in days) {
      final originalId = _dayIds[day];

      final currentExerciseIds = day.exercises
          .map((exercise) => exercise.id)
          .toSet();

      final removedExerciseIds = (_originalExerciseIds[day] ?? <int>{})
          .difference(currentExerciseIds);

      final exercisePayloads = <PlanExercise>[
        for (var i = 0; i < day.exercises.length; i++)
          PlanExercise(
            exerciseId: day.exercises[i].id,
            sets: day.exercises[i].sets,
            reps: day.exercises[i].reps,
            order: i + 1,
          ),

        for (final id in removedExerciseIds)
          PlanExercise(exerciseId: id, order: 0, delete: true),
      ];

      dayPayloads.add(
        PlanDay(
          id: originalId,
          name: day.name,
          sets: day.defaultSets,
          reps: day.defaultReps?.toString(),
          exercises: exercisePayloads,
        ),
      );
    }

    // Deleted backend days
    for (final deletedDayId in _deletedDayIds) {
      dayPayloads.add(PlanDay(id: deletedDayId, name: '', delete: true));
    }

    return EditCoachPlanRequest(
      goal: selectedGoal ?? '',
      durationMonths: durationMonths,
      days: dayPayloads,
    );
  }

  // ============================================================
  // SAVE
  // ============================================================

  void saveChanges() {
    final l10n = AppLocalizations.of(context)!;

    if (days.isEmpty) {
      _showValidationMessage(l10n.addAtLeastOneWorkoutDay);
      return;
    }

    if (days.any((day) => day.exercises.isEmpty)) {
      _showValidationMessage(l10n.everyWorkoutDayNeedsExercise);
      return;
    }

    if (selectedGoal == null) {
      _showValidationMessage(l10n.chooseGoalForTrainingPlan);
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const EditPlanLoadingDialog(),
    );

    context.read<EditCoachPlanCubit>().updatePlan(
      planId: widget.plan.id,
      requestBody: _buildRequest(),
    );
  }

  // ============================================================
  // VALIDATION
  // ============================================================

  void _showValidationMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<EditCoachPlanCubit, EditCoachPlanState>(
      listener: (context, state) {
        if (state is EditCoachPlanSuccess) {
          Navigator.of(context).pop();
          Navigator.of(context).pop(true);
        }

        if (state is EditCoachPlanError) {
          Navigator.of(context).pop();

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error)));
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: WaveAppBar(title: l10n.editPlan, showBackButton: true),

          body: Column(
            children: [
              _buildStepHeader(),

              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildGoalAndDurationStep(),
                    _buildDaysAndExercisesStep(),
                  ],
                ),
              ),
            ],
          ),

          bottomNavigationBar: _buildBottomNavigationBar(),

          floatingActionButton: _currentStep == 1 ? _buildAddDayFab() : null,
        );
      },
    );
  }

  // ============================================================
  // STEP HEADER
  // ============================================================

  Widget _buildStepHeader() {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentStep == 0 ? l10n.stepOne : l10n.stepTwo,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBtn,
                  ),
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBtn,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: _currentStep == 1
                              ? AppColors.primaryBtn
                              : AppColors.hintText,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // GOAL + DURATION
  // ============================================================

  Widget _buildGoalAndDurationStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: PlanDetailsCard(
        selectedGoal: selectedGoal,
        durationMonths: durationMonths,
        onGoalChanged: (goal) {
          setState(() {
            selectedGoal = goal;
          });
        },
        onDurationChanged: (duration) {
          setState(() {
            durationMonths = duration;
          });
        },
      ),
    );
  }

  // ============================================================
  // DAYS + EXERCISES
  // ============================================================

  Widget _buildDaysAndExercisesStep() {
    final l10n = AppLocalizations.of(context)!;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 22,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBtn,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(width: 10),

                Text(
                  l10n.workoutDays,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),

                const Spacer(),

                Text(
                  '${days.length} '
                  '${days.length == 1 ? l10n.day : l10n.days}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.hintText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),

        if (days.isEmpty) SliverToBoxAdapter(child: _buildEmptyDaysState()),

        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final day = days[index];

            return PlanDayCard(
              day: day,

              onSettings: () {
                _onDaySettings(day);
              },

              onAddExercise: () {
                addExercise(index);
              },

              onDeleteExercise: (exerciseIndex) {
                _onDeleteExercise(index, exerciseIndex);
              },

              onDeleteDay: () {
                _onDeleteDay(index);
              },
            );
          }, childCount: days.length),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  Widget _buildBottomNavigationBar() {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (_currentStep == 1) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: _goToPreviousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: AppColors.primaryBtn),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text(
                  l10n.back,
                  style: TextStyle(
                    color: AppColors.primaryBtn,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),
          ],

          Expanded(
            flex: _currentStep == 1 ? 2 : 1,
            child: ElevatedButton(
              onPressed: _currentStep == 0 ? _goToNextStep : saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBtn,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(
                _currentStep == 0 ? l10n.next : l10n.saveChanges,
                style: TextStyle(
                  color: context.backgroundColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ADD DAY FAB
  // ============================================================

  Widget _buildAddDayFab() {
    final l10n = AppLocalizations.of(context)!;

    return AnimatedRotation(
      turns: isFabOpen ? 0.125 : 0,
      duration: const Duration(milliseconds: 200),
      child: FloatingActionButton(
        backgroundColor: AppColors.primaryBtn,
        elevation: 6,
        onPressed: () async {
          setState(() {
            isFabOpen = !isFabOpen;
          });

          await Future.delayed(const Duration(milliseconds: 200));

          if (!mounted) return;

          CustomGlassBottomSheet.show(
            context: context,
            height: 0.30,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.hintText,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                const SizedBox(height: 20),

                // =========================
                // CREATE NEW DAY
                // =========================
                _buildActionTile(
                  icon: Icons.add_circle_outline,
                  color: AppColors.primaryBtn,
                  title: l10n.createNewDay,
                  subtitle: l10n.creatDaySubtitle,
                  onTap: () {
                    Navigator.pop(context);
                    addDay();
                  },
                ),

                const SizedBox(height: 12),

                // =========================
                // ADD EXISTING DAY
                // =========================
                _buildActionTile(
                  icon: Icons.copy_outlined,
                  color: Colors.blue,
                  title: l10n.addExistingDay,
                  subtitle: l10n.addExistingDaySubtitle,
                  onTap: () async {
                    Navigator.pop(context);

                    await addExistingDays();
                  },
                ),
              ],
            ),
          );
        },
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 100),
          child: Icon(
            isFabOpen ? Icons.close : Icons.add,
            key: ValueKey(isFabOpen),
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.backgroundColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.hintText),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withOpacity(.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(subtitle, style: TextStyle(color: AppColors.hintText)),
                ],
              ),
            ),

            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY DAYS
  // ============================================================

  Widget _buildEmptyDaysState() {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primaryBtn.withOpacity(.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.calendar_today_rounded,
              color: AppColors.primaryBtn,
              size: 28,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            l10n.noWorkoutDaysYet,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),

          const SizedBox(height: 6),

          Text(
            l10n.createFirstWorkoutDay,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 18),

          Text(
            l10n.tapPlusToGetStarted,
            style: TextStyle(
              color: AppColors.primaryBtn,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
