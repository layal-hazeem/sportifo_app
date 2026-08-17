// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:sportifo_app/core/di/service_locator.dart';
// import 'package:sportifo_app/features/create_plan_by_coach/presentation/widgets/exercises_picker.dart';
// import 'package:sportifo_app/features/workout/data/models/exercise_model.dart';
// import 'package:sportifo_app/features/workout/presentation/view_model/saved_exercises/saved_exercises_cubit.dart';

// class ExercisePickerBottomSheet extends StatefulWidget {
//   final List<ExerciseModel> exercises;

//   const ExercisePickerBottomSheet({super.key, required this.exercises});

//   @override
//   State<ExercisePickerBottomSheet> createState() =>
//       _ExercisePickerBottomSheetState();
// }

// class _ExercisePickerBottomSheetState extends State<ExercisePickerBottomSheet> {
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider.value(
//       value: getIt<SavedExercisesCubit>(),
//       child: ExerciseMultiPickerBottomSheet(exercises: widget.exercises),
//     );
//   }
// }
