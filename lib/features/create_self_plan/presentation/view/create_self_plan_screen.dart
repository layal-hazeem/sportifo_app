import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sportifo_app/core/di/service_locator.dart';
import 'package:sportifo_app/core/network/api_result.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/core/widgets/wave_app_bar.dart';

import 'package:sportifo_app/features/create_self_plan/data/models/create_self_plan_request.dart';
import 'package:sportifo_app/features/create_self_plan/presentation/view_model/create_self_plan_cubit.dart';
import 'package:sportifo_app/features/create_self_plan/presentation/view_model/create_self_plan_state.dart';

import 'package:sportifo_app/features/create_plan_by_coach/data/models/plan_day_ui_model.dart';
import 'package:sportifo_app/features/create_plan_by_coach/presentation/widgets/create_day_bottom_sheet.dart';
import 'package:sportifo_app/features/create_plan_by_coach/presentation/widgets/day_settings_bottom_sheet.dart';
import 'package:sportifo_app/features/create_plan_by_coach/presentation/widgets/exercises_picker.dart';
import 'package:sportifo_app/features/create_plan_by_coach/presentation/widgets/day_card.dart';
import 'package:sportifo_app/features/create_plan_by_coach/presentation/widgets/plan_details_card.dart';

import 'package:sportifo_app/features/workout/data/models/exercise_model.dart';
import 'package:sportifo_app/features/workout/data/repository/workout_repository.dart';

import 'package:sportifo_app/l10n/app_localizations.dart';

class CreateSelfPlanScreen extends StatefulWidget {
  const CreateSelfPlanScreen({super.key});

  @override
  State<CreateSelfPlanScreen> createState() => _CreateSelfPlanScreenState();
}

class _CreateSelfPlanScreenState extends State<CreateSelfPlanScreen> {
  final PageController _pageController = PageController();

  int _currentStep = 0;

  final List<PlanDayUiModel> days = [];

  bool isFabOpen = false;
  bool isLoadingDialogShown = false;

  String? selectedGoal;
  int durationMonths = 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextStep() {
    if (_currentStep == 0) {
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
  }

  void _goToPreviousStep() {
    if (_currentStep == 1) {
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
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<CreateSelfPlanCubit, CreateSelfPlanState>(
      listener: (context, state) {
        if (state is CreateSelfPlanLoading) {
          _showLoadingDialog();
        }

        if (state is CreateSelfPlanSuccess) {
          if (isLoadingDialogShown) {
            isLoadingDialogShown = false;
            Navigator.pop(context);
          }

          Navigator.pop(context, true);

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.planCreatedSuccessfully)));
        }

        if (state is CreateSelfPlanError) {
          if (isLoadingDialogShown) {
            isLoadingDialogShown = false;
            Navigator.pop(context);
          }

            _showErrorMessage(state.message);

        }
      },
      child: Scaffold(
        appBar: WaveAppBar(title: l10n.createSelfPlan, showBackButton: true),

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
      ),
    );
  }

  void _showLoadingDialog() {
    if (isLoadingDialogShown) return;

    isLoadingDialogShown = true;

    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBtn.withOpacity(.12),
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      color: AppColors.primaryBtn,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  l10n.creatingYourPlan,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  l10n.pleaseWaitWhileSavingWorkout,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ],
            ),
          ),
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
                              : Colors.grey.shade300,
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
                  days.length == 1
                      ? '1 ${l10n.day}'
                      : '${days.length} ${l10n.days}',
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

        if (days.isEmpty) SliverToBoxAdapter(child: _buildEmptyDaysState()),

        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final day = days[index];

            return PlanDayCard(
              day: day,

              onSettings: () async {
                final applyAll = await DaySettingsBottomSheet.show(
                  context,
                  day,
                );

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
              },

              onAddExercise: () {
                addExercise(index);
              },

              onDeleteExercise: (exerciseIndex) {
                setState(() {
                  day.exercises.removeAt(exerciseIndex);
                });
              },

              onDeleteDay: () {
                setState(() {
                  days.removeAt(index);
                });
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
              onPressed: _currentStep == 0 ? _goToNextStep : savePlan,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBtn,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(
                _currentStep == 0 ? l10n.next : l10n.createPlan,
                style: const TextStyle(
                  color: Colors.white,
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

    if (selected == null || selected.isEmpty) {
      return;
    }

    setState(() {
      days[dayIndex].exercises.addAll(
        selected.map((exercise) {
          exercise.sets = null;
          exercise.reps = null;
          exercise.duration = null;

          return exercise;
        }),
      );
    });
  }

  Future<void> savePlan() async {
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

    final request = CreateSelfPlanRequest(
      goal: selectedGoal!,
      durationMonths: durationMonths,
      days: days.map((day) {
        return CreateSelfPlanDayRequest(
          name: day.name,
          sets: day.defaultSets,
          reps: day.defaultReps?.toString(),
          exercises: day.exercises,
        );
      }).toList(),
    );

    debugPrint(request.toMap().toString());

    context.read<CreateSelfPlanCubit>().createSelfPlan(request);
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

  void _showErrorMessage(String message) {
    final l10n = AppLocalizations.of(context)!;

    final lowerMessage = message.toLowerCase();

    String errorMessage;

    if (lowerMessage.contains('sets') ||
        lowerMessage.contains('reps') ||
        lowerMessage.contains('specify sets') ||
        lowerMessage.contains('specify reps')) {
      errorMessage = l10n.setsAndRepsRequired;
    } else if (lowerMessage.contains('subscription')) {
      errorMessage = l10n.userHasNoActiveSubscription;
    } else if (lowerMessage.contains('plan')) {
      errorMessage = l10n.planCreationFailed;
    } else if (lowerMessage.contains('unauthorized')) {
      errorMessage = l10n.unauthorizedAction;
    } else {
      errorMessage = l10n.somethingWentWrong;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }
}
