import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../view_model/categories_cubit/categories_cubit.dart';
import '../view_model/categories_cubit/categories_state.dart';
import '../view_model/exercises_cubit/exercises_cubit.dart';
import '../view_model/exercises_cubit/exercises_state.dart';
import '../view_model/parts_cubit/parts_cubit.dart';
import '../view_model/parts_cubit/parts_state.dart';
import '../widgets/exercise_list_item.dart';
import '../widgets/horizontal_muscle_card.dart';
import '../widgets/part_filter_chip.dart';

class MuscleGroupsScreen extends StatefulWidget {
  const MuscleGroupsScreen({super.key});

  @override
  State<MuscleGroupsScreen> createState() => _MuscleGroupsScreenState();
}

class _MuscleGroupsScreenState extends State<MuscleGroupsScreen> {
  int? selectedMuscleId;

  // 🔥 التعديل هنا: تحول إلى List ليدعم التحديد المتعدد
  List<int> selectedPartIds = [];

  final Map<String, String> _muscleAssets = {
    'Chest': 'assets/images/muscles/chest.jpg',
    'Back': 'assets/images/muscles/back.jpg',
    'Legs': 'assets/images/muscles/legs.jpg',
    'Shoulders': 'assets/images/muscles/shoulders.jpg',
    'Biceps': 'assets/images/muscles/biceps.jpg',
    'Triceps': 'assets/images/muscles/triceps.jpg',
  };

  @override
  void initState() {
    super.initState();
    context.read<CategoriesCubit>().fetchCategories(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        title: const Text(
          'Resistance Training',
          style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==========================================
          // 1. شريط العضلات (الصور)
          // ==========================================
          SizedBox(
            height: 110,
            child: BlocConsumer<CategoriesCubit, CategoriesState>(
              listener: (context, state) {
                if (state is CategoriesSuccess && state.categories.isNotEmpty) {
                  final firstMuscleId = state.categories.first.id;
                  setState(() {
                    selectedMuscleId = firstMuscleId;
                    selectedPartIds.clear(); // تصفير الفلاتر (عرض الكل)
                  });
                  context.read<ExercisesCubit>().fetchExercises(organId: firstMuscleId);
                  context.read<PartsCubit>().fetchParts(firstMuscleId);
                }
              },
              builder: (context, state) {
                if (state is CategoriesLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is CategoriesSuccess) {
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: state.categories.length,
                    itemBuilder: (context, index) {
                      final muscle = state.categories[index];
                      final isSelected = selectedMuscleId == muscle.id;
                      final imagePath = _muscleAssets[muscle.name] ?? 'assets/images/muscles/default.jpg';

                      return HorizontalMuscleCard(
                        name: muscle.name,
                        imagePath: imagePath,
                        isSelected: isSelected,
                        onTap: () {
                          if (!isSelected) {
                            setState(() {
                              selectedMuscleId = muscle.id;
                              selectedPartIds.clear(); // 🔥 تصفير الفلاتر عند اختيار عضلة جديدة
                            });
                            // نجلب كل التمارين لأن الفلاتر فاضية (يعني الكل)
                            context.read<ExercisesCubit>().fetchExercises(organId: muscle.id);
                            context.read<PartsCubit>().fetchParts(muscle.id);
                          }
                        },
                      );
                    },
                  );
                }
                return const SizedBox();
              },
            ),
          ),

          const SizedBox(height: 15),

          // ==========================================
          // 2. شريط الفلاتر (الأقسام الصغيرة بدون زر All)
          // ==========================================
          BlocBuilder<PartsCubit, PartsState>(
            builder: (context, state) {
              if (state is PartsSuccess && state.Parts.isNotEmpty) {
                return SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: state.Parts.length, // 🔥 شلنا الـ +1 تبع الـ All
                    itemBuilder: (context, index) {
                      final part = state.Parts[index];
                      // الكبسولة تكون محددة إذا كان الـ ID تبعها موجود باللستة
                      final isSelected = selectedPartIds.contains(part.id);

                      return PartFilterChip(
                        label: part.name,
                        isSelected: isSelected,
                        onSelected: (bool selected) {
                          setState(() {
                            // إذا ضغط عليها بنضيفها للستة، وإذا لغى الضغط بنحذفها
                            if (selected) {
                              selectedPartIds.add(part.id);
                            } else {
                              selectedPartIds.remove(part.id);
                            }

                            // 🔥 المنطق الذكي: إذا حددهم كلهم، بنفضيلو اللستة ليرجع للحالة الافتراضية
                            if (selectedPartIds.length == state.Parts.length) {
                              selectedPartIds.clear();
                            }
                          });

                          // طلب التمارين بناءً على اللستة الجديدة
                          context.read<ExercisesCubit>().fetchExercises(
                            organId: selectedMuscleId,
                            partIds: selectedPartIds.isEmpty ? null : selectedPartIds, // إذا اللستة فاضية بنبعت Null يعني الكل
                          );
                        },
                      );
                    },
                  ),
                );
              }
              return const SizedBox();
            },
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: Colors.black12, thickness: 1),
          ),

          // ==========================================
          // 3. قائمة التمارين
          // ==========================================
          Expanded(
            child: BlocBuilder<ExercisesCubit, ExercisesState>(
              builder: (context, state) {
                if (state is ExercisesLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ExercisesSuccess) {
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: state.exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = state.exercises[index];

                      return ExerciseListItem(
                        exerciseName: exercise.name,
                        muscleName: exercise.category?.organ?.name ?? "",
                        imageUrl: exercise.gifUrl ?? (exercise.pictureUrls.isNotEmpty ? exercise.pictureUrls.first : ''),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.exerciseDetails,
                            arguments: exercise,
                          );
                        },
                      );
                    },
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}