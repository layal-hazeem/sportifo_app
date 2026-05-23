import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
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
  List<int> selectedPartIds = [];

  final Map<String, String> _muscleAssets = {
    'Chest': 'assets/images/muscles/chest.jpg',
    'Back': 'assets/images/muscles/back.jpg',
    'Legs': 'assets/images/muscles/legs.jpg',
    'Shoulders': 'assets/images/muscles/shoulders.jpg',
    'Biceps': 'assets/images/muscles/biceps.jpg',
    'Triceps': 'assets/images/muscles/triceps.jpg',
    'ABS': 'assets/images/muscles/ABS.jpg'
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
      backgroundColor: AppColors.background,
      appBar: WaveAppBar(
        title: l10n.resistance_training,
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.background),
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.searchScreen,
                arguments: {
                  'categoryId': 1,
                  'organId': selectedMuscleId,
                  'partIds': selectedPartIds,
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
          SizedBox(
            height: 115, // كبرنا الارتفاع قليلاً ليستوعب النص بالأسفل براحة
            child: BlocConsumer<CategoriesCubit, CategoriesState>(
              listener: (context, state) {
                if (state is CategoriesSuccess && state.categories.isNotEmpty) {
                  setState(() {
                    selectedMuscleId = null;
                    selectedPartIds.clear();
                  });
                  context.read<ExercisesCubit>().fetchExercises(categoryId: 1);
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
                        anyMuscleSelected: selectedMuscleId != null, // 🔥 تمرير حالة الفلترة الحالية
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              selectedMuscleId = null;
                              selectedPartIds.clear();
                              context.read<ExercisesCubit>().fetchExercises(categoryId: 1);
                              context.read<PartsCubit>().emit(PartsInitial());
                            } else {
                              selectedMuscleId = muscle.id;
                              selectedPartIds.clear();
                              context.read<ExercisesCubit>().fetchExercises(
                                  categoryId: 1, organId: muscle.id);
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
                      final isSelected = selectedPartIds.contains(part.id);

                      return PartFilterChip(
                        label: part.name,
                        isSelected: isSelected,
                        onSelected: (bool selected) {
                          setState(() {
                            if (selected) {
                              selectedPartIds.add(part.id);
                            } else {
                              selectedPartIds.remove(part.id);
                            }

                            if (selectedPartIds.length == state.Parts.length) {
                              selectedPartIds.clear();
                            }
                          });

                          context.read<ExercisesCubit>().fetchExercises(
                            categoryId: 1,
                            organId: selectedMuscleId,
                            partIds: selectedPartIds.isEmpty ? null : selectedPartIds,
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
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primaryBtn),
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