import 'package:flutter/material.dart';
import 'package:gif_view/gif_view.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/snack_bar_utils.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/exercise_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../view_model/saved_exercises/saved_exercises_cubit.dart';
import '../view_model/saved_exercises/saved_exercises_state.dart';

class ExerciseDetailsScreen extends StatelessWidget {
  final ExerciseModel exercise;

  const ExerciseDetailsScreen({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.primaryBtn,
            leading: IconButton(
              icon:  Icon(Icons.arrow_back_ios,
                color:Colors.black,),
              onPressed: () => Navigator.pop(context),
            ),

            actions: [
              // داخل الـ Actions في الـ AppBar وداخل الـ Stack في الكارد
              // استبدلي الـ BlocBuilder القديم بهذا المزيج
              BlocConsumer<SavedExercisesCubit, SavedExercisesState>(
                // استمعي للتغييرات لإظهار السناك بار
                listener: (context, state) {
                  // نتحقق أن الحالة هي نجاح التبديل "لهذا التمرين بالتحديد"
                  if (state is SavedExercisesToggleSuccess && state.exerciseId == exercise.id) {
                    AppSnackBar.show(
                      context,
                      message: state.isSaved ? "Added to saved" : "Removed from saved",
                      type: SnackBarType.success,
                      onActionPressed: () => Navigator.pushNamed(context, AppRoutes.savedExercises),
                    );
                  }
                },
                // حافظي على الـ builder كما هو لرسم الأيقونة
                builder: (context, state) {
                  return IconButton(
                    icon: Icon(
                      exercise.isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: AppColors.primaryBtn,
                    ),
                    onPressed: () => context.read<SavedExercisesCubit>().toggleSave(exercise),
                  );
                },
              )
            ],

            flexibleSpace: FlexibleSpaceBar(
              title: Text(exercise.name, style: const TextStyle(color: Colors.white, fontSize: 16)),
              background:Hero(
                tag: 'exercise_${exercise.id}',
                child: Container(
                  color: Colors.white,
                  child: GifView.network(
                    exercise.gifUrl ?? '',
                    fit: BoxFit.contain,
                    autoPlay: true,
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  if (exercise.category?.organ != null) ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Text(
                          l10n.target_muscle,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
                        ),
                        const SizedBox(height: 8),

                        _buildChip(exercise.category!.organ!.name, AppColors.primaryBtn),

                        const SizedBox(height: 16),
                        if (exercise.category!.organ!.part != null) ...[
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildChip(exercise.category!.organ!.part!.name, Colors.grey.shade600),
                            ],
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 25),
                  ],

                   Text(
                    l10n.how_to_perform,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
                  ),
                  const SizedBox(height: 10),

                  Text(
                    exercise.description,
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade800, height: 1.6),
                  ),

                  const SizedBox(height: 30),

                  if (exercise.pictureUrls.isNotEmpty) ...[
                     Text(
                      l10n.gallery,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      height: 150,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: exercise.pictureUrls.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.network(
                                exercise.pictureUrls[index],
                                width: 200,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }
}