import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../../../../core/widgets/wave_app_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../view_model/categories_cubit/categories_cubit.dart';
import '../view_model/categories_cubit/categories_state.dart';
import '../view_model/exercises_cubit/exercises_cubit.dart';
import '../view_model/exercises_cubit/exercises_state.dart';
import '../view_model/parts_cubit/parts_cubit.dart';
import '../view_model/parts_cubit/parts_state.dart';
import '../widgets/exercises_grid_view.dart';
import '../widgets/horizontal_muscle_card.dart';
import '../widgets/part_filter_chip.dart';

class MuscleGroupsScreen extends StatefulWidget {
  const MuscleGroupsScreen({super.key});

  @override
  State<MuscleGroupsScreen> createState() => _MuscleGroupsScreenState();
}

class _MuscleGroupsScreenState extends State<MuscleGroupsScreen> {
  int? selectedMuscleId;
  List<int> selectedSmallestCategoryId = [];

  // 🔥 تم التعديل هنا: استخدام int (الـ ID) كـ Key بدلاً من String (الاسم)
  // ⚠️ يرجى التأكد من مطابقة هذه الأرقام مع الـ IDs الحقيقية في الباك إند
  final Map<int, String> _muscleAssets = {
    1: 'assets/images/muscles/chest.jpg', // id الصدر
    2: 'assets/images/muscles/back.jpg', // id الظهر
    3: 'assets/images/muscles/shoulders.jpg', // id الأرجل
    4: 'assets/images/muscles/legs.jpg', // id الأكتاف
    5: 'assets/images/muscles/biceps.jpg', // id البايسبس
    6: 'assets/images/muscles/triceps.jpg', // id الترايسبس
    7: 'assets/images/muscles/ABS.jpg', // id المعدة
  };

  @override
  void initState() {
    super.initState();
    context.read<CategoriesCubit>().fetchCategories(2);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: WaveAppBar(
        title: l10n.resistance_training,
        showBackButton: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: context.backgroundColor),
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.searchScreen,
                arguments: {
                  'categoryId': 1,
                  'organId': selectedMuscleId,
                  'smallestCategoryId': selectedSmallestCategoryId,
                },
              );
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1️⃣ شيمر العضلات الأفقية العلوي
          SizedBox(
            height: 115,
            child: BlocConsumer<CategoriesCubit, CategoriesState>(
              listener: (context, state) {
                if (state is CategoriesSuccess && state.categories.isNotEmpty) {
                  setState(() {
                    selectedMuscleId = null;
                    selectedSmallestCategoryId.clear();
                  });
                  context.read<ExercisesCubit>().fetchExercises(categoryId: 1);
                }
              },
              builder: (context, state) {
                if (state is CategoriesLoading) {
                  // 🔥 تأثير شيمر أفقي للكروت العلوية
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: 4,
                    itemBuilder: (context, index) => const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: LoadingShimmer(
                        width: 100,
                        height: 110,
                        borderRadius: 16,
                      ),
                    ),
                  );
                } else if (state is CategoriesSuccess) {
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: state.categories.length,
                    itemBuilder: (context, index) {
                      final muscle = state.categories[index];
                      final isSelected = selectedMuscleId == muscle.id;

                      // 🔥 جلب الصورة بناءً على الـ ID الخاص بالعضلة بدلاً من اسمها المتغير
                      final imagePath =
                          _muscleAssets[muscle.id] ??
                          'assets/images/muscles/default.jpg';

                      return HorizontalMuscleCard(
                        name: muscle
                            .name, // الاسم يظهر باللغة الصحيحة (عربي/إنجليزي)
                        imagePath:
                            imagePath, // الصورة تظهر بشكل دائم بغض النظر عن اللغة
                        isSelected: isSelected,
                        anyMuscleSelected: selectedMuscleId != null,
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              selectedMuscleId = null;
                              selectedSmallestCategoryId.clear();
                              context.read<ExercisesCubit>().fetchExercises(
                                categoryId: 1,
                              );
                              context.read<PartsCubit>().emit(PartsInitial());
                            } else {
                              selectedMuscleId = muscle.id;
                              selectedSmallestCategoryId.clear();
                              context.read<ExercisesCubit>().fetchExercises(
                                categoryId: 1,
                                organId: muscle.id,
                              );
                              context.read<PartsCubit>().fetchParts(muscle.id);
                            }
                          });
                        },
                      );
                    },
                  );
                } else if (state is CategoriesFailure) {
                  return Center(
                    child: Text(
                      state.errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          const SizedBox(height: 15),

          BlocBuilder<PartsCubit, PartsState>(
            builder: (context, state) {
              if (state is PartsSuccess && state.Parts.isNotEmpty) {
                return SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: state.Parts.length,
                    itemBuilder: (context, index) {
                      final part = state.Parts[index];
                      final isSelected = selectedSmallestCategoryId.contains(
                        part.id,
                      );

                      return PartFilterChip(
                        label: part.name,
                        isSelected: isSelected,
                        onSelected: (bool selected) {
                          setState(() {
                            if (selected) {
                              selectedSmallestCategoryId.add(part.id);
                            } else {
                              selectedSmallestCategoryId.remove(part.id);
                            }
                            if (selectedSmallestCategoryId.length ==
                                state.Parts.length) {
                              selectedSmallestCategoryId.clear();
                            }
                          });
                          context.read<ExercisesCubit>().fetchExercises(
                            categoryId: 1,
                            organId: selectedMuscleId,
                            smallestCategoryId:
                                selectedSmallestCategoryId.isEmpty
                                ? null
                                : selectedSmallestCategoryId,
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
          Expanded(
            child: BlocBuilder<ExercisesCubit, ExercisesState>(
              builder: (context, state) {
                if (state is ExercisesLoading) {
                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio: 0.85,
                        ),
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      return const LoadingShimmer(
                        width: double.infinity,
                        height: double.infinity,
                        borderRadius: 16,
                      );
                    },
                  );
                } else if (state is ExercisesSuccess) {
                  return ExercisesGridView(exercises: state.exercises);
                } else if (state is ExercisesFailure) {
                  return Center(
                    child: Text(
                      state.errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
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
