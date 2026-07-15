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
import 'package:sportifo_app/features/plans/data/models/create_plan_request.dart';
import 'package:sportifo_app/features/plans/data/models/plan_day_ui_model.dart';
import 'package:sportifo_app/features/plans/presentation/view_model/create_plan_cubit.dart';
import 'package:sportifo_app/features/plans/presentation/view_model/create_plan_state.dart';
import 'package:sportifo_app/features/plans/presentation/widgets/create_day_bottom_sheet.dart';
import 'package:sportifo_app/features/plans/presentation/widgets/exercise_multi_picker_bottom_sheet.dart';
import 'package:sportifo_app/features/plans/presentation/widgets/plan_day_card.dart';
import 'package:sportifo_app/features/workout/data/models/exercise_model.dart';
import 'package:sportifo_app/features/workout/data/repository/workout_repository.dart';

class CreatePlanScreen extends StatefulWidget {
  final int userId;
  const CreatePlanScreen({super.key,required this.userId,});
  @override
  State<CreatePlanScreen> createState() => _CreatePlanScreenState();
}

class _CreatePlanScreenState extends State<CreatePlanScreen> {
  final List<PlanDayUiModel> days = [];
  bool isFabOpen = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreatePlanCubit, CreatePlanState>(
      listener: (context, state) {
        if (state is CreatePlanLoading) {
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

        if (state is CreatePlanSuccess) {
          Navigator.pop(context,true);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Plan created successfully 🎉")),
          );
        }

        if (state is CreatePlanError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },

      child: Scaffold(
        appBar: WaveAppBar(title: "Create Plan", showBackButton: true),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: days.length,
                itemBuilder: (context, index) {
                  final day = days[index];

                  return PlanDayCard(
                    day: day,

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
                },
              ),
            ),
          ],
        ),

        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(16),

          child: SizedBox(
            width: double.infinity,

            child: ElevatedButton(
              onPressed: savePlan,

              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBtn,
                padding: const EdgeInsets.symmetric(vertical: 16),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),

              child: const Text(
                "Create Plan",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        floatingActionButton: AnimatedRotation(
          turns: isFabOpen ? 0.125 : 0,
          duration: const Duration(milliseconds: 250),

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

                                child: const ExistingDaysListBottomSheet(),
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
                                                    name:
                                                        e.category!.name ?? "",
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
        ),
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
      days[dayIndex].exercises.addAll(selected);
    });
  }

  Future<void> savePlan() async {
    if (days.isEmpty) {
      return;
    }
    if (days.any((day) => day.exercises.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Every day must have at least one exercise"),
        ),
      );
      return;
    }

    final request = CreatePlanRequest(
  userId: widget.userId,
  days: days.map((day) {
    return PlanDayRequest(
      name: day.name,
      sets: day.defaultSets,
      reps: day.defaultReps.toString(),
      exercises: day.exercises,
    );
  }).toList(),
);
    context.read<CreatePlanCubit>().createPlan(request);
  }
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
