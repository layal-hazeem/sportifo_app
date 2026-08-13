import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sportifo_app/core/di/service_locator.dart';
import 'package:sportifo_app/core/network/api_result.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/core/widgets/custom_glass_bottom_sheet.dart';
import 'package:sportifo_app/core/widgets/wave_app_bar.dart';
import 'package:sportifo_app/features/existing_days/data/model/existing_days_model.dart';
import 'package:sportifo_app/features/existing_days/presentation/view/existing_days_screen.dart';
import 'package:sportifo_app/features/existing_days/presentation/view_model/existing_days_cubit.dart';
import 'package:sportifo_app/features/create_plan_by_coach/data/models/create_plan_request.dart';
import 'package:sportifo_app/features/create_plan_by_coach/data/models/plan_day_ui_model.dart';
import 'package:sportifo_app/features/create_plan_by_coach/presentation/view_model/create_plan_cubit.dart';
import 'package:sportifo_app/features/create_plan_by_coach/presentation/view_model/create_plan_state.dart';
import 'package:sportifo_app/features/create_plan_by_coach/presentation/widgets/create_day_bottom_sheet.dart';
import 'package:sportifo_app/features/create_plan_by_coach/presentation/widgets/day_settings_bottom_sheet.dart';
import 'package:sportifo_app/features/create_plan_by_coach/presentation/widgets/exercise_multi_picker_bottom_sheet.dart';
import 'package:sportifo_app/features/create_plan_by_coach/presentation/widgets/plan_day_card.dart';
import 'package:sportifo_app/features/create_plan_by_coach/presentation/widgets/plan_details_card.dart';
import 'package:sportifo_app/features/workout/data/models/exercise_model.dart';
import 'package:sportifo_app/features/workout/data/repository/workout_repository.dart';

class CreatePlanScreen extends StatefulWidget {
  final int userId;
  const CreatePlanScreen({super.key, required this.userId});

  @override
  State<CreatePlanScreen> createState() => _CreatePlanScreenState();
}

class _CreatePlanScreenState extends State<CreatePlanScreen> {
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
        _showValidationMessage("Choose a goal for this training plan");
        return;
      }
      _pageController
          .animateToPage(
            1,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeInOut,
          )
          .then((_) {
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
            setState(() {
              _currentStep = 0;
            });
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreatePlanCubit, CreatePlanState>(
      listener: (context, state) {
        if (state is CreatePlanLoading) {
          if (!isLoadingDialogShown) {
            isLoadingDialogShown = true;
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
                    padding: const EdgeInsets.symmetric(
                      vertical: 30,
                      horizontal: 25,
                    ),
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
                        const Text(
                          "Creating your plan...",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Please wait while we save your workout",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        }

        if (state is CreatePlanSuccess) {
          if (isLoadingDialogShown) {
            isLoadingDialogShown = false;
            Navigator.pop(context);
          }
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Plan created successfully 🎉")),
          );
        }

        if (state is CreatePlanError) {
          if (isLoadingDialogShown) {
            isLoadingDialogShown = false;
            Navigator.pop(context);
          }
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        appBar: WaveAppBar(title: "Create Plan", showBackButton: true),
        body: Column(
          children: [
            // Header with Steps Indicator Line
            _buildStepHeader(),

            // Pages View
            Expanded(
              child: PageView(
                controller: _pageController,
                physics:
                    const NeverScrollableScrollPhysics(), // منع السحب اليدوي لضمان التحكم عبر الأزرار
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
            ? AnimatedRotation(
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
                              color: Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildActionTile(
                            icon: Icons.add_circle_outline,
                            color: AppColors.primaryBtn,
                            title: "Create New Day",
                            subtitle: "Build a custom workout day",
                            onTap: () {
                              Navigator.pop(context);
                              addDay();
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildActionTile(
                            icon: Icons.copy_outlined,
                            color: Colors.blue,
                            title: "Add Existing Day",
                            subtitle: "Reuse a saved workout",
                            onTap: () async {
                              Navigator.pop(context);
                              final selectedDays =
                                  await CustomGlassBottomSheet.show<
                                    List<ExistingDaysModel>
                                  >(
                                    context: context,
                                    height: 0.85,
                                    child: BlocProvider(
                                      create: (_) =>
                                          getIt<ExistingDaysCubit>()
                                            ..getExistingDays(),
                                      child:
                                          const ExistingDaysListBottomSheet(),
                                    ),
                                  );

                              if (selectedDays == null) return;

                              setState(() {
                                for (final day in selectedDays) {
                                  days.add(
                                    PlanDayUiModel(
                                      name: day.name ?? "",
                                      exercises:
                                          day.exercises
                                              ?.map(
                                                (e) => ExerciseModel(
                                                  id: e.id ?? 0,
                                                  name: e.name ?? "",
                                                  description:
                                                      e.description ?? "",
                                                  images:
                                                      e.images
                                                          ?.map(
                                                            (
                                                              img,
                                                            ) => ExerciseMedia(
                                                              url:
                                                                  img.url ?? "",
                                                              type:
                                                                  img.type ??
                                                                  "",
                                                            ),
                                                          )
                                                          .toList() ??
                                                      [],
                                                  category: e.category != null
                                                      ? ExerciseCategory(
                                                          id:
                                                              e.category!.id ??
                                                              0,
                                                          name:
                                                              e
                                                                  .category!
                                                                  .name ??
                                                              "",
                                                        )
                                                      : null,
                                                ),
                                              )
                                              .toList() ??
                                          [],
                                    ),
                                  );
                                }
                              });
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
              )
            : null,
      ),
    );
  }

  // Header Widget showing the steps and orange line
  Widget _buildStepHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentStep == 0
                      ? "Step 1: Goal & Duration"
                      : "Step 2: Days & Exercises",
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
                          color: AppColors
                              .primaryBtn, // الخط الأول دائماً مفعل أو مكتمل عند الانتقال
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
                              : Colors
                                    .grey
                                    .shade300, // يلون برتقالي فقط عند الوصول للخطوة الثانية
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

  // Step 1 Widget
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

  // Step 2 Widget
  Widget _buildDaysAndExercisesStep() {
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
                const Text(
                  'WORKOUT DAYS',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
                const Spacer(),
                Text(
                  '${days.length} ${days.length == 1 ? 'day' : 'days'}',
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

  // Bottom Navigation Bar with dynamic buttons (Next / Create Plan)
  Widget _buildBottomNavigationBar() {
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
                  "Back",
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
                _currentStep == 0 ? "Next" : "Create Plan",
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

    if (selected == null || selected.isEmpty) return;

    setState(() {
      days[dayIndex].exercises.addAll(
        selected.map((exercise) {
          if (exercise.isCardio) {
            exercise.sets = null;
            exercise.reps = null;
            exercise.duration = null;
          } else {
            exercise.sets = null;
            exercise.reps = null;
            exercise.duration = null;
          }
          return exercise;
        }).toList(),
      );
    });
  }

  Future<void> savePlan() async {
    if (days.isEmpty) {
      _showValidationMessage("Add at least one workout day");
      return;
    }

    if (days.any((day) => day.exercises.isEmpty)) {
      _showValidationMessage("Every workout day needs at least one exercise");
      return;
    }

    final request = CreatePlanRequest(
      userId: widget.userId,
      goal: selectedGoal!,
      durationMonths: durationMonths,
      days: days.map((day) {
        return PlanDayRequest(
          name: day.name,
          sets: day.defaultSets,
          reps: day.defaultReps?.toString(),
          exercises: day.exercises,
        );
      }).toList(),
    );

    print(request.toMap());
    context.read<CreatePlanCubit>().createPlan(request);
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
}

Widget _buildEmptyDaysState() {
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
        const Text(
          'No workout days yet',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          'Create a new workout day or reuse one '
          'from your saved workouts.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Tap + to get started',
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
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
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
                Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    ),
  );
}
