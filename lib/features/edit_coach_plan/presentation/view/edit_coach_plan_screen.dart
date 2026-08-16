import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sportifo_app/core/di/service_locator.dart';
import 'package:sportifo_app/core/network/api_result.dart';
import 'package:sportifo_app/core/widgets/custom_glass_bottom_sheet.dart';
import 'package:sportifo_app/core/widgets/wave_app_bar.dart';
import 'package:sportifo_app/features/edit_coach_plan/presentation/widgets/add_day.dart';
import 'package:sportifo_app/features/edit_coach_plan/presentation/widgets/days_step.dart';
import 'package:sportifo_app/features/edit_coach_plan/presentation/widgets/edit_plan_loading.dart';
import 'package:sportifo_app/features/edit_coach_plan/presentation/widgets/goal_step.dart';
import 'package:sportifo_app/features/edit_coach_plan/presentation/widgets/step_header.dart';
import 'package:sportifo_app/features/existing_days/data/model/existing_days_model.dart';
import 'package:sportifo_app/features/existing_days/presentation/view/existing_days_screen.dart';
import 'package:sportifo_app/features/existing_days/presentation/view_model/existing_days_cubit.dart';
import 'package:sportifo_app/features/create_plan_by_coach/data/models/plan_day_ui_model.dart';
import 'package:sportifo_app/features/create_plan_by_coach/presentation/widgets/create_day_bottom_sheet.dart';
import 'package:sportifo_app/features/create_plan_by_coach/presentation/widgets/day_settings_bottom_sheet.dart';
import 'package:sportifo_app/features/create_plan_by_coach/presentation/widgets/exercises_picker.dart';
import 'package:sportifo_app/features/plan_details/data/models/plan_details_model.dart';
import 'package:sportifo_app/features/workout/data/models/exercise_model.dart';
import 'package:sportifo_app/features/workout/data/repository/workout_repository.dart';
import 'package:sportifo_app/features/edit_coach_plan/data/models/edit_coach_plan_model.dart';
import 'package:sportifo_app/features/edit_coach_plan/data/models/edit_coach_plan_request.dart';
import 'package:sportifo_app/features/edit_coach_plan/presentation/view_model/edit_coach_plan_cubit.dart';
import 'package:sportifo_app/features/edit_coach_plan/presentation/view_model/edit_coach_plan_state.dart';
import '../../../../l10n/app_localizations.dart' show AppLocalizations;
import '../widgets/edit_plan_bottom_bar.dart';

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

  final Map<PlanDayUiModel, int> _dayIds = {};
  final Map<PlanDayUiModel, Set<int>> _originalExerciseIds = {};
  final List<int> _deletedDayIds = [];

  bool isFabOpen = false;
  bool isLoadingDialogShown = false;
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
      _originalExerciseIds[uiDay] = day.exercises.map((e) => e.id).toSet();
      return uiDay;
    }).toList();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextStep() {
    if (_currentStep == 0) {
      if (selectedGoal == null) {
        _showValidationMessage( AppLocalizations.of(context)!.chooseGoalForTrainingPlan);
        return;
      }
      _pageController
          .animateToPage(
            1,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeInOut,
          )
          .then((_) => setState(() => _currentStep = 1));
    }
  }

  void _goToPreviousStep() {
    if (_currentStep == 1) {
      _pageController
          .animateToPage(
            0,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeInOut,
          )
          .then((_) => setState(() => _currentStep = 0));
    }
  }

  void addDay() {
    CreateDayBottomSheet.show(context, (value) {
      setState(() {
        days.add(PlanDayUiModel(name: value, exercises: []));
      });
    });
  }

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

    if (selectedDays == null) return;

    setState(() {
      for (final day in selectedDays) {
        final uiDay = PlanDayUiModel(
          name: day.name ?? "",
          exercises:
              day.exercises
                  ?.map(
                    (e) => ExerciseModel(
                      id: e.id ?? 0,
                      name: e.name ?? "",
                      description: e.description ?? "",
                      images:
                          e.images
                              ?.map(
                                (img) => ExerciseMedia(
                                  url: img.url ?? "",
                                  type: img.type ?? "",
                                ),
                              )
                              .toList() ??
                          [],
                      category: e.category != null
                          ? ExerciseCategory(
                              id: e.category!.id ?? 0,
                              name: e.category!.name ?? "",
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

  Future<void> addExercise(int dayIndex) async {
    final workoutRepository = getIt<WorkoutRepository>();
    final result = await workoutRepository.getExercises();
    if (result is Failure) return;

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

    if (selected == null || selected.isEmpty) return;

    setState(() {
      days[dayIndex].exercises.addAll(selected);
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

  EditCoachPlanRequest _buildRequest() {
    final dayPayloads = <PlanDay>[];

    for (final day in days) {
      final originalId = _dayIds[day];
      final currentIds = day.exercises.map((e) => e.id).toSet();
      final removedExerciseIds = (_originalExerciseIds[day] ?? <int>{})
          .difference(currentIds);

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

    for (final deletedDayId in _deletedDayIds) {
      dayPayloads.add(PlanDay(id: deletedDayId, name: '', delete: true));
    }

    return EditCoachPlanRequest(
      goal: selectedGoal ?? '',
      durationMonths: durationMonths,
      days: dayPayloads,
    );
  }

  void saveChanges() {
    if (days.isEmpty) {
      _showValidationMessage( AppLocalizations.of(context)!.addAtLeastOneWorkoutDay);
      return;
    }

    if (days.any((day) => day.exercises.isEmpty)) {
      _showValidationMessage( AppLocalizations.of(context)!.everyWorkoutDayNeedsExercise);
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
      return BlocConsumer<EditCoachPlanCubit, EditCoachPlanState>(
      listener: (context, state) {
        if (state is EditCoachPlanSuccess) {
          Navigator.of(context).pop();
          Navigator.of(context).pop(true);
        } else if (state is EditCoachPlanError) {
          Navigator.of(context).pop(); 
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error)));
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: WaveAppBar(title: l10n.editPlan , showBackButton: true),
          body: Column(
            children: [
              EditPlanStepHeader(currentStep: _currentStep),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    EditPlanGoalStep(
                      selectedGoal: selectedGoal,
                      durationMonths: durationMonths,
                      onGoalChanged: (goal) =>
                          setState(() => selectedGoal = goal),
                      onDurationChanged: (duration) =>
                          setState(() => durationMonths = duration),
                    ),
                    EditPlanDaysStep(
                      days: days,
                      onAddExercise: addExercise,
                      onDeleteExercise: _onDeleteExercise,
                      onDeleteDay: _onDeleteDay,
                      onDaySettings: _onDaySettings,
                    ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: EditPlanBottomBar(
            currentStep: _currentStep,
            onBack: _goToPreviousStep,
            onNext: _currentStep == 0 ? _goToNextStep : saveChanges,
          ),
          floatingActionButton: _currentStep == 1
              ? EditPlanAddDayFab(
                  isOpen: isFabOpen,
                  onToggle: () => setState(() => isFabOpen = !isFabOpen),
                  onCreateNewDay: addDay,
                  onAddExistingDay: addExistingDays,
                )
              : null,
        );
      },
    );
  }
}
