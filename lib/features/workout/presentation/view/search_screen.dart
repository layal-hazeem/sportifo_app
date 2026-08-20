import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../../../../l10n/app_localizations.dart';
import '../view_model/search_cubit/search_cubit.dart';
import '../view_model/search_cubit/search_state.dart';
import '../widgets/exercises_grid_view.dart';

class SearchExercisesScreen extends StatefulWidget {
  final int? categoryId;
  final int? organId;
  final List<int>? smallestCategoryId;

  const SearchExercisesScreen({
    super.key,
    this.categoryId,
    this.organId,
    this.smallestCategoryId,
  });
  @override
  State<SearchExercisesScreen> createState() => _SearchExercisesScreenState();
}

class _SearchExercisesScreenState extends State<SearchExercisesScreen> {
  Timer? _debounce;
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (query.isEmpty) {
      context.read<SearchCubit>().searchExercises('');
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<SearchCubit>().searchExercises(
        query,
        categoryId: widget.categoryId,
        organId: widget.organId,
        smallestCategoryId: widget.smallestCategoryId,
      );
    });
  }

  void _triggerQuickSearch(String keyword) {
    _controller.text = keyword;
    _onSearchChanged(keyword);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: context.textColor,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Container(
          height: 45,
          margin: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(15),
          ),
          child: TextField(
            controller: _controller,
            autofocus: true,
            style: TextStyle(fontSize: 16, color: context.textColor),
            decoration: InputDecoration(
              hintText: l10n.searchForExercises, // 🔥 ترجمة
              hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
              border: InputBorder.none,
              prefixIcon: Icon(
                CupertinoIcons.search,
                color: Colors.grey.shade500,
                size: 20,
              ),
              suffixIcon: IconButton(
                icon: Icon(Icons.cancel, color: Colors.grey.shade400, size: 20),
                onPressed: () {
                  _controller.clear();
                  _onSearchChanged('');
                },
              ),
            ),
            onChanged: _onSearchChanged,
          ),
        ),
      ),
      body: BlocBuilder<SearchCubit, SearchState>(
        builder: (context, state) {
          if (state is SearchLoading) {
            return GridView.builder(
              padding: const EdgeInsets.all(20),
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 0.8,
              ),
              itemCount: 6,
              itemBuilder: (context, index) => const LoadingShimmer(
                width: double.infinity,
                height: double.infinity,
                borderRadius: 20,
              ),
            );
          } else if (state is SearchSuccess) {
            if (state.exercises.isEmpty) {
              return _buildNoResults(l10n);
            }
            return ExercisesGridView(exercises: state.exercises);
          } else if (state is SearchFailure) {
            return _buildNoResults(l10n);
          }
          return _buildSuggestions(l10n);
        },
      ),
    );
  }

  Widget _buildSuggestions(AppLocalizations l10n) {
    final bool isCardio = widget.categoryId == 2;

    // 🔥 تم ربطها بملف الترجمة لتتغير حسب لغة التطبيق
    final List<String> resistanceSearches = [
      l10n.search_chest,
      l10n.search_abs,
      l10n.search_legs,
      l10n.search_back,
      l10n.search_biceps,
      l10n.search_shoulders,
    ];

    final List<String> cardioSearches = [
      l10n.search_running,
      l10n.search_jump_rope,
      l10n.search_burpees,
      l10n.search_cycling,
    ];

    final List<String> popularSearches = isCardio
        ? cardioSearches
        : resistanceSearches;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.popularSearches,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: context.textColor,
            ),
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: popularSearches.map((keyword) {
              return ActionChip(
                label: Text(keyword),
                labelStyle: TextStyle(
                  color: context.textColor,
                  fontWeight: FontWeight.w600,
                ),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                // 🔥 عندما يضغط عليها، سيتم البحث بالكلمة المترجمة (عربي أو إنجليزي)
                onPressed: () => _triggerQuickSearch(keyword),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.search_circle_fill,
            size: 100,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 20),
          Text(
            l10n.no_exercises_found,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.trySearchingForSomethingElse, // 🔥 ترجمة
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
