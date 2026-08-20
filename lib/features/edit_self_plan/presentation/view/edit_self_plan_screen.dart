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

import 'package:sportifo_app/features/my_plans(user)/data/models/my_plan_model.dart';

import 'package:sportifo_app/features/workout/data/models/exercise_model.dart';
import 'package:sportifo_app/features/workout/data/repository/workout_repository.dart';

import 'package:sportifo_app/features/edit_self_plan/data/models/edit_self_plan_request.dart';
import 'package:sportifo_app/features/edit_self_plan/presentation/view_model/edit_self_plan_cubit.dart';
import 'package:sportifo_app/features/edit_self_plan/presentation/view_model/edit_self_plan_state.dart';

import 'package:sportifo_app/l10n/app_localizations.dart';

class EditSelfPlanScreen extends StatefulWidget {
  final PlanModel plan;

  const EditSelfPlanScreen({super.key, required this.plan});

  @override
  State<EditSelfPlanScreen> createState() => _EditSelfPlanScreenState();
}

class _EditSelfPlanScreenState extends State<EditSelfPlanScreen> {
  final PageController _pageController = PageController();

  int _currentStep = 0;
  late final List<PlanDayUiModel> days;
  final Map<PlanDayUiModel, int> _dayIds = {};
  final Map<PlanDayUiModel, Set<int>> _originalExerciseIds = {};
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

        defaultSets: day.sets,
        defaultReps: int.tryParse(day.reps?.toString() ?? ''),
      );

      _dayIds[uiDay] = day.id;

      _originalExerciseIds[uiDay] = day.exercises
          .map((exercise) => exercise.id)
          .toSet();

      // Apply day defaults to exercises that don't have their own values
      for (final exercise in uiDay.exercises) {
        _applyDayDefaultsToExercise(uiDay, exercise);
      }

      return uiDay;
    }).toList();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextStep() {
    if (_currentStep != 0) return;

    final l10n = AppLocalizations.of(context)!;

    if (selectedGoal == null || selectedGoal!.trim().isEmpty) {
      _showValidationMessage(l10n.chooseGoalForTrainingPlan);
      return;
    }

    _pageController
        .animateToPage(
          1,
          duration: const Duration(milliseconds: 180),
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
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
        )
        .then((_) {
          if (!mounted) return;

          setState(() {
            _currentStep = 0;
          });
        });
  }

  void _applyDayDefaultsToExercise(PlanDayUiModel day, ExerciseModel exercise) {
    if (exercise.isCardio) {
      exercise.sets = null;
      exercise.reps = null;
      return;
    }

    exercise.sets ??= day.defaultSets;
    exercise.reps ??= day.defaultReps?.toString();
  }

  void addDay() {
    CreateDayBottomSheet.show(context, (value) {
      setState(() {
        days.add(PlanDayUiModel(name: value, exercises: []));
      });
    });
  }

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
      final day = days[dayIndex];

      for (final exercise in selected) {
        _applyDayDefaultsToExercise(day, exercise);
        day.exercises.add(exercise);
      }
    });
  }

  void _onDeleteExercise(int dayIndex, int exerciseIndex) {
    setState(() {
      days[dayIndex].exercises.removeAt(exerciseIndex);
    });
  }

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

  EditSelfPlanRequest _buildRequest() {
    final dayPayloads = <EditSelfPlanDayRequest>[];

    for (final day in days) {
      final originalDayId = _dayIds[day];

      final currentExerciseIds = day.exercises
          .map((exercise) => exercise.id)
          .toSet();

      final removedExerciseIds = (_originalExerciseIds[day] ?? <int>{})
          .difference(currentExerciseIds);

      final exercisePayloads = <EditSelfPlanExerciseRequest>[];

      for (var index = 0; index < day.exercises.length; index++) {
        final exercise = day.exercises[index];

        // Cardio doesn't need sets/reps
        if (exercise.isCardio) {
          exercisePayloads.add(
            EditSelfPlanExerciseRequest(
              exerciseId: exercise.id,
              sets: null,
              reps: null,
              order: index + 1,
            ),
          );

          continue;
        }

        // Exercise value first, otherwise use day defaults
        final effectiveSets = exercise.sets ?? day.defaultSets;

        final effectiveReps = exercise.reps ?? day.defaultReps?.toString();

        exercisePayloads.add(
          EditSelfPlanExerciseRequest(
            exerciseId: exercise.id,
            sets: effectiveSets,
            reps: effectiveReps,
            order: index + 1,
          ),
        );
      }

      // Deleted exercises
      for (final exerciseId in removedExerciseIds) {
        exercisePayloads.add(
          EditSelfPlanExerciseRequest(
            exerciseId: exerciseId,
            order: 0,
            delete: true,
          ),
        );
      }

      dayPayloads.add(
        EditSelfPlanDayRequest(
          id: originalDayId,
          name: day.name,

          // Day defaults
          sets: day.defaultSets,
          reps: day.defaultReps?.toString(),

          exercises: exercisePayloads,
        ),
      );
    }

    // Deleted days
    for (final deletedDayId in _deletedDayIds) {
      dayPayloads.add(EditSelfPlanDayRequest(id: deletedDayId, delete: true));
    }

    return EditSelfPlanRequest(
      goal: selectedGoal ?? '',
      durationMonths: durationMonths,
      days: dayPayloads,
    );
  }

  void saveChanges() {
    final l10n = AppLocalizations.of(context)!;

    if (days.isEmpty) {
      _showValidationMessage(l10n.addAtLeastOneWorkoutDay);
      return;
    }

    final hasEmptyDay = days.any((day) => day.exercises.isEmpty);

    if (hasEmptyDay) {
      _showValidationMessage(l10n.everyWorkoutDayNeedsExercise);
      return;
    }

    if (selectedGoal == null || selectedGoal!.trim().isEmpty) {
      _showValidationMessage(l10n.chooseGoalForTrainingPlan);
      return;
    }

    for (final day in days) {
      for (final exercise in day.exercises) {

        if (exercise.isCardio) continue;

        final effectiveSets = exercise.sets ?? day.defaultSets;

        final effectiveReps = exercise.reps ?? day.defaultReps?.toString();

        if (effectiveSets == null ||
            effectiveReps == null ||
            effectiveReps.trim().isEmpty) {
          _showValidationMessage('Missing sets/reps for ${exercise.name}');
          debugPrint('''
━━━━━━━━━━━━━━━━━━━━━━
DAY: ${day.name}
EXERCISE: ${exercise.name}
ID: ${exercise.id}
isCardio: ${exercise.isCardio}

exercise.sets: ${exercise.sets}
exercise.reps: ${exercise.reps}

dayDefaultSets: ${day.defaultSets}
dayDefaultReps: ${day.defaultReps}

EFFECTIVE SETS: $effectiveSets
EFFECTIVE REPS: $effectiveReps
━━━━━━━━━━━━━━━━━━━━━━
''');
          return;
        }
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const EditPlanLoadingDialog(),
    );

    context.read<EditSelfPlanCubit>().updatePlan(
      planId: widget.plan.id,
      requestBody: _buildRequest(),
    );
  }

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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<EditSelfPlanCubit, EditSelfPlanState>(
      listener: (context, state) {
        if (state is EditSelfPlanSuccess) {
          Navigator.of(context).pop();

          Navigator.of(context).pop(true);
        }

        if (state is EditSelfPlanError) {
          Navigator.of(context).pop();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              behavior: SnackBarBehavior.floating,
            ),
          );
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

          floatingActionButton: _currentStep == 1
              ? FloatingActionButton(
                  backgroundColor: AppColors.primaryBtn,
                  elevation: 6,
                  onPressed: addDay,
                  child: const Icon(Icons.add, color: Colors.white),
                )
              : null,
        );
      },
    );
  }

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

  Widget _buildDaysAndExercisesStep() {
    final l10n = AppLocalizations.of(context)!;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
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
                  color: context.textColor,
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

  Widget _buildEmptyDaysState() {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      decoration: BoxDecoration(
        color: context.backgroundColor,
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
