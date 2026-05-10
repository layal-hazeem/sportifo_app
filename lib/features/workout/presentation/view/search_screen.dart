import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/routes/app_routes.dart';
import '../view_model/search_cubit/search_cubit.dart';
import '../view_model/search_cubit/search_state.dart';
import '../widgets/exercise_list_item.dart';
// ... المستوردات الأخرى

class SearchExercisesScreen extends StatefulWidget {
  const SearchExercisesScreen({super.key});

  @override
  State<SearchExercisesScreen> createState() => _SearchExercisesScreenState();
}

class _SearchExercisesScreenState extends State<SearchExercisesScreen> {
  Timer? _debounce;
  final TextEditingController _controller = TextEditingController();

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {

      // 🔥 شلنا شرط الـ if لحتى إذا مسح اليوزر النص، يروح طلب للكيوبت ليفضي الشاشة
      context.read<SearchCubit>().searchExercises(query); // تأكدي من اسم الدالة بالكيوبت

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: "Search exercises (e.g. calves)"),
          onChanged: _onSearchChanged,
        ),
      ),
      body: BlocBuilder<SearchCubit, SearchState>(
        builder: (context, state) {
          if (state is SearchLoading) return const Center(child: CircularProgressIndicator());
          if (state is SearchSuccess) {
            return ListView.builder(
              itemCount: state.exercises.length,
              itemBuilder: (context, index) {
                final exercise = state.exercises[index];
                return ExerciseListItem(
                  exerciseName: exercise.name,
                  muscleName: exercise.category?.organ?.name ?? "",
                  imageUrl: exercise.gifUrl ?? "",
                  onTap: () => Navigator.pushNamed(context, AppRoutes.exerciseDetails, arguments: exercise),
                );
              },
            );
          }
          return const Center(child: Text("Start searching for exercises!"));
        },
      ),
    );
  }
}