import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/wave_app_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../view_model/exercises_cubit/exercises_cubit.dart';
import '../view_model/exercises_cubit/exercises_state.dart';
import '../widgets/exercises_grid_view.dart';

class ExercisesListScreen extends StatelessWidget {
  final int categoryId;
  final String categoryName;

  const ExercisesListScreen({
    super.key,
    required this.categoryId,
    required this.categoryName
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: WaveAppBar(
        title: categoryName,
        showBackButton: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.search,color: AppColors.background),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.searchScreen,
                  arguments: {
                    'categoryId': 2,
                    'organId': null,
                    'partIds': null,
                  },
                );
              },
            ),
    ]
      ),
      body: BlocBuilder<ExercisesCubit, ExercisesState>(
        builder: (context, state) {
          if (state is ExercisesLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryBtn));
          } else if (state is ExercisesSuccess) {
            final exercises = state.exercises;

            if (exercises.isEmpty) {
              return  Center(child: Text(l10n.no_exercises_found, style: TextStyle(color: Colors.white)));
            }

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
    );
  }
}