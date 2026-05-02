import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/routes/app_routes.dart';
import '../view_model/exercises_cubit/exercises_cubit.dart';
import '../view_model/exercises_cubit/exercises_state.dart';
import '../widgets/exercise_list_item.dart';

class ExercisesListScreen extends StatefulWidget {
  final int? organId; // إذا كان جاي من شاشة العضلات
  final int? categoryId; // إذا كان جاي من الكارديو (مثلاً الكارديو ID تبعه 2)

  const ExercisesListScreen({super.key, this.organId, this.categoryId});

  @override
  State<ExercisesListScreen> createState() => _ExercisesListScreenState();
}

class _ExercisesListScreenState extends State<ExercisesListScreen> {
  @override
  void initState() {
    super.initState();
    // 🔥 أول ما تفتح الشاشة، نطلب التمارين من الباك إند
    context.read<ExercisesCubit>().fetchExercises(
      organId: widget.organId,
      categoryId: widget.categoryId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Exercises', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // 🔥 استماع لحالات الكيوبت
      body: BlocBuilder<ExercisesCubit, ExercisesState>(
        builder: (context, state) {
          if (state is ExercisesLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFFF7A00)));
          }

          else if (state is ExercisesFailure) {
            return Center(child: Text(state.errorMessage, style: const TextStyle(color: Colors.red)));
          }

          else if (state is ExercisesSuccess) {
            final exercises = state.exercises;

            if (exercises.isEmpty) {
              return const Center(child: Text("No exercises found.", style: TextStyle(color: Colors.white54)));
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final exercise = exercises[index];

                // جلب صورة الـ GIF أو أول صورة عادية
                final imageUrl = exercise.gifUrl ?? (exercise.pictureUrls.isNotEmpty ? exercise.pictureUrls.first : '');

                return ExerciseListItem(
                  exerciseName: exercise.name, // إذا في عربي وانجليزي بنعدلها لاحقاً
                  muscleName: exercise.category?.organ?.name ?? "Full Body",
                  imageUrl: imageUrl,
                  onTap: () {
                    // 🔥 الانتقال لصفحة تفاصيل التمرين
                     Navigator.pushNamed(context, AppRoutes.exerciseDetails, arguments: exercise);
                  },
                );
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}