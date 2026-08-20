import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sportifo_app/core/di/service_locator.dart';
import 'package:sportifo_app/core/network/api_result.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/core/widgets/wave_app_bar.dart';

import 'package:sportifo_app/features/create_plan_by_coach/data/models/plan_day_ui_model.dart';
import 'package:sportifo_app/features/create_plan_by_coach/presentation/widgets/create_day_bottom_sheet.dart';
import 'package:sportifo_app/features/create_plan_by_coach/presentation/widgets/day_settings_bottom_sheet.dart';
import 'package:sportifo_app/features/create_plan_by_coach/presentation/widgets/day_card.dart';
import 'package:sportifo_app/features/create_plan_by_coach/presentation/widgets/exercises_picker.dart';
import 'package:sportifo_app/features/create_plan_by_coach/presentation/widgets/plan_details_card.dart';

import 'package:sportifo_app/features/edit_self_plan/data/models/edit_self_plan_model.dart';
import 'package:sportifo_app/features/edit_self_plan/data/models/edit_self_plan_request.dart';
import 'package:sportifo_app/features/edit_self_plan/presentation/view_model/edit_self_plan_cubit.dart';
import 'package:sportifo_app/features/edit_self_plan/presentation/view_model/edit_self_plan_state.dart';

import 'package:sportifo_app/features/workout/data/models/exercise_model.dart';
import 'package:sportifo_app/features/workout/data/repository/workout_repository.dart';

import 'package:sportifo_app/l10n/app_localizations.dart';

class EditSelfPlanScreen extends StatefulWidget {
  final SelfPlanData plan;

  const EditSelfPlanScreen({
    super.key,
    required this.plan,
  });

  @override
  State<EditSelfPlanScreen> createState() =>
      _EditSelfPlanScreenState();
}

class _EditSelfPlanScreenState extends State<EditSelfPlanScreen> {
  final PageController _pageController = PageController();

  int _currentStep = 0;

  late final List<PlanDayUiModel> days;

  /// Backend ID for existing days.
  final Map<PlanDayUiModel, int> _dayIds = {};

  /// Backend IDs of days deleted by the user.
  final List<int> _deletedDayIds = [];

  String? selectedGoal;

  int durationMonths = 1;

  bool isFabOpen = false;

  bool get _isLoading =>
      context.read<EditSelfPlanCubit>().state
          is EditSelfPlanLoading;

  @override
  void initState() {
    super.initState();

    selectedGoal = widget.plan.goal;

    /*
     * durationMonths can come from the edit model
     * as String or another numeric representation.
     *
     * toString() keeps this conversion safe.
     */
    durationMonths =
        int.tryParse(widget.plan.durationMonths.toString()) ?? 1;

    days = widget.plan.days.map((day) {
      final uiDay = PlanDayUiModel(
        name: day.name,
        exercises: List<ExerciseModel>.from(
          day.exercises,
        ),
      );

      final dayId = day.id;

      if (dayId != null) {
        _dayIds[uiDay] = dayId;
      }

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

  Future<void> _goToNextStep() async {
    if (_currentStep != 0) return;

    final l10n = AppLocalizations.of(context)!;

    if (selectedGoal == null ||
        selectedGoal!.trim().isEmpty) {
      _showValidationMessage(
        l10n.chooseGoalForTrainingPlan,
      );
      return;
    }

    await _pageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );

    if (!mounted) return;

    setState(() {
      _currentStep = 1;
    });
  }

  Future<void> _goToPreviousStep() async {
    if (_currentStep != 1) return;

    await _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );

    if (!mounted) return;

    setState(() {
      _currentStep = 0;
    });
  }

  // ============================================================
  // ADD DAY
  // ============================================================

  void addDay() {
    CreateDayBottomSheet.show(
      context,
      (value) {
        if (!mounted) return;

        setState(() {
          days.add(
            PlanDayUiModel(
              name: value,
              exercises: [],
            ),
          );
        });
      },
    );
  }

  // ============================================================
  // ADD EXERCISE
  // ============================================================

  Future<void> addExercise(int dayIndex) async {
    final workoutRepository = getIt<WorkoutRepository>();

    final result = await workoutRepository.getExercises();

    if (!mounted) return;

    if (result is Failure) {
      _showValidationMessage(
        result.toString(),
      );
      return;
    }

    final exercises =
        (result as Success<List<ExerciseModel>>).data;

    final selected =
        await showModalBottomSheet<List<ExerciseModel>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (bottomSheetContext) {
        return SizedBox(
          height:
              MediaQuery.of(bottomSheetContext).size.height *
                  0.9,
          child: ExerciseMultiPickerBottomSheet(
            exercises: exercises,
          ),
        );
      },
    );

    if (!mounted) return;

    if (selected == null || selected.isEmpty) {
      return;
    }

    setState(() {
      days[dayIndex].exercises.addAll(
        selected.map(
          (exercise) {
            exercise.sets = null;
            exercise.reps = null;
            exercise.duration = null;

            return exercise;
          },
        ),
      );
    });
  }

  // ============================================================
  // DELETE EXERCISE
  // ============================================================

  void _onDeleteExercise(
    int dayIndex,
    int exerciseIndex,
  ) {
    if (dayIndex < 0 || dayIndex >= days.length) {
      return;
    }

    if (exerciseIndex < 0 ||
        exerciseIndex >= days[dayIndex].exercises.length) {
      return;
    }

    setState(() {
      days[dayIndex].exercises.removeAt(
        exerciseIndex,
      );
    });
  }

  // ============================================================
  // DELETE DAY
  // ============================================================

  void _onDeleteDay(int index) {
    if (index < 0 || index >= days.length) {
      return;
    }

    final day = days[index];

    final originalId = _dayIds[day];

    setState(() {
      days.removeAt(index);

      /*
       * If this day already exists in the backend,
       * we must tell the backend to delete it.
       *
       * New days have no backend ID, therefore there is
       * nothing to delete remotely.
       */
      if (originalId != null &&
          !_deletedDayIds.contains(originalId)) {
        _deletedDayIds.add(originalId);
      }
    });
  }

  // ============================================================
  // DAY SETTINGS
  // ============================================================

  Future<void> _onDaySettings(
    PlanDayUiModel day,
  ) async {
    final applyAll =
        await DaySettingsBottomSheet.show(
      context,
      day,
    );

    if (!mounted) return;

    if (applyAll == true) {
      setState(() {
        for (final exercise in day.exercises) {
          if (exercise.isCardio) {
            exercise.sets = null;
            exercise.reps = null;
          } else {
            exercise.sets = day.defaultSets;
            exercise.reps =
                day.defaultReps?.toString();
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

  EditSelfPlanRequest _buildRequest() {
    final requestDays = <EditSelfPlanDay>[];

    /*
     * ----------------------------------------------------------
     * EXISTING + NEW DAYS
     * ----------------------------------------------------------
     */
    for (final day in days) {
      final dayId = _dayIds[day];

      final requestExercises =
          <EditSelfPlanExercise>[];

      /*
       * Convert UI exercises into edit-plan exercises.
       */
      for (int index = 0;
          index < day.exercises.length;
          index++) {
        final exercise = day.exercises[index];

        /*
         * ExerciseModel.id is nullable.
         *
         * If the exercise already exists, its ID is sent.
         * If it is a newly selected exercise and has no backend
         * ID, exerciseId is still the selected exercise ID.
         *
         * The null case is skipped because the backend cannot
         * identify an exercise without an ID.
         */
        final exerciseId = exercise.id;

        if (exerciseId == null) {
          continue;
        }

        requestExercises.add(
          EditSelfPlanExercise(
            id: exerciseId,
            exerciseId: exerciseId,
            name: exercise.name,
            description: exercise.description,
            sets: exercise.sets,
            reps: exercise.reps,
            order: index + 1,
          ),
        );
      }

      requestDays.add(
        EditSelfPlanDay(
          id: dayId,
          name: day.name,
          exercises: requestExercises,
        ),
      );
    }

    /*
     * ----------------------------------------------------------
     * DELETED DAYS
     * ----------------------------------------------------------
     *
     * The days removed from the UI are no longer inside `days`,
     * so they have to be added explicitly to the request with
     * delete = true.
     */
    for (final deletedDayId in _deletedDayIds) {
      requestDays.add(
        EditSelfPlanDay(
          id: deletedDayId,
          name: '',
          delete: true,
          exercises: const [],
        ),
      );
    }

    return EditSelfPlanRequest(
      goal: selectedGoal!,
      durationMonths: durationMonths,
      days: requestDays,
    );
  }

  // ============================================================
  // SAVE CHANGES
  // ============================================================

  void saveChanges() {
    if (_isLoading) return;

    final l10n = AppLocalizations.of(context)!;

    if (days.isEmpty) {
      _showValidationMessage(
        l10n.addAtLeastOneWorkoutDay,
      );
      return;
    }

    if (days.any(
      (day) => day.exercises.isEmpty,
    )) {
      _showValidationMessage(
        l10n.everyWorkoutDayNeedsExercise,
      );
      return;
    }

    if (selectedGoal == null ||
        selectedGoal!.trim().isEmpty) {
      _showValidationMessage(
        l10n.chooseGoalForTrainingPlan,
      );
      return;
    }

    final request = _buildRequest();

    context.read<EditSelfPlanCubit>().updateSelfPlan(
      widget.plan.id,
      request,
    );
  }

  // ============================================================
  // VALIDATION MESSAGE
  // ============================================================

  void _showValidationMessage(
    String message,
  ) {
    if (!mounted) return;

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

    return BlocConsumer<
        EditSelfPlanCubit,
        EditSelfPlanState>(
      listener: (context, state) {
        if (state is EditSelfPlanSuccess) {
          /*
           * Show the success message BEFORE popping,
           * otherwise the ScaffoldMessenger belongs to a route
           * that is about to disappear.
           */
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n.planUpdatedSuccessfully,
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );

          Navigator.of(context).pop(true);
        }

        if (state is EditSelfPlanError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final loading =
            state is EditSelfPlanLoading;

        return Scaffold(
          appBar: WaveAppBar(
            title: l10n.editPlan,
            showBackButton: true,
          ),

          body: Column(
            children: [
              _buildStepHeader(),

              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics:
                      const NeverScrollableScrollPhysics(),
                  children: [
                    _buildGoalAndDurationStep(),
                    _buildDaysAndExercisesStep(),
                  ],
                ),
              ),
            ],
          ),

          bottomNavigationBar:
              _buildBottomNavigationBar(
            loading: loading,
          ),

          floatingActionButton:
              _currentStep == 1 && !loading
                  ? _buildAddDayFab()
                  : null,
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
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 16,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            _currentStep == 0
                ? l10n.stepOne
                : l10n.stepTwo,
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
                child: _buildStepIndicator(
                  active: true,
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: _buildStepIndicator(
                  active: _currentStep == 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator({
    required bool active,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 4,
      decoration: BoxDecoration(
        color: active
            ? AppColors.primaryBtn
            : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
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
            padding: const EdgeInsets.fromLTRB(
              20,
              10,
              20,
              10,
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 22,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBtn,
                    borderRadius:
                        BorderRadius.circular(10),
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
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),

        if (days.isEmpty)
          SliverToBoxAdapter(
            child: _buildEmptyDaysState(),
          ),

        if (days.isNotEmpty)
          SliverList(
            delegate:
                SliverChildBuilderDelegate(
              (context, index) {
                final day = days[index];

                return PlanDayCard(
                  day: day,

                  onSettings: () {
                    _onDaySettings(day);
                  },

                  onAddExercise: () {
                    addExercise(index);
                  },

                  onDeleteExercise:
                      (exerciseIndex) {
                    _onDeleteExercise(
                      index,
                      exerciseIndex,
                    );
                  },

                  onDeleteDay: () {
                    _onDeleteDay(index);
                  },
                );
              },
              childCount: days.length,
            ),
          ),

        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  Widget _buildBottomNavigationBar({
    required bool loading,
  }) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (_currentStep == 1) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: loading
                      ? null
                      : _goToPreviousStep,
                  style:
                      OutlinedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                    side: BorderSide(
                      color:
                          AppColors.primaryBtn,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(18),
                    ),
                  ),
                  child: Text(
                    l10n.back,
                    style: TextStyle(
                      color:
                          AppColors.primaryBtn,
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),
            ],

            Expanded(
              flex: _currentStep == 1 ? 2 : 1,
              child: ElevatedButton(
                onPressed: loading
                    ? null
                    : _currentStep == 0
                        ? _goToNextStep
                        : saveChanges,
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      AppColors.primaryBtn,
                  disabledBackgroundColor:
                      AppColors.primaryBtn
                          .withValues(alpha: 0.5),
                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(18),
                  ),
                ),
                child: loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<
                                  Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        _currentStep == 0
                            ? l10n.next
                            : l10n.saveChanges,
                        style:
                            const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ADD DAY FAB
  // ============================================================

  Widget _buildAddDayFab() {
    return AnimatedRotation(
      turns: isFabOpen ? 0.125 : 0,
      duration:
          const Duration(milliseconds: 200),
      child: FloatingActionButton(
        backgroundColor:
            AppColors.primaryBtn,
        elevation: 6,
        onPressed: () async {
          if (isFabOpen) return;

          setState(() {
            isFabOpen = true;
          });

          await Future.delayed(
            const Duration(milliseconds: 200),
          );

          if (!mounted) return;

          setState(() {
            isFabOpen = false;
          });

          addDay();
        },
        child: AnimatedSwitcher(
          duration:
              const Duration(milliseconds: 100),
          child: Icon(
            isFabOpen
                ? Icons.close
                : Icons.add,
            key: ValueKey(isFabOpen),
            color: Colors.white,
          ),
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
      margin: const EdgeInsets.fromLTRB(
        20,
        8,
        20,
        20,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 30,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius:
            BorderRadius.circular(24),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primaryBtn
                  .withValues(alpha: 0.10),
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
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
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