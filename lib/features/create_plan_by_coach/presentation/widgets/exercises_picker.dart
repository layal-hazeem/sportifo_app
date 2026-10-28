import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sportifo_app/core/di/service_locator.dart';
import 'package:sportifo_app/core/network/api_result.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';
import 'package:sportifo_app/features/auth/presentation/widgets/custom_button.dart';
import 'package:sportifo_app/features/create_plan_by_coach/presentation/widgets/select_exercise.dart';
import 'package:sportifo_app/features/workout/data/models/exercise_model.dart';
import 'package:sportifo_app/features/workout/data/models/filter_item_model.dart';
import 'package:sportifo_app/features/workout/data/repository/workout_repository.dart';
import 'package:sportifo_app/features/workout/presentation/widgets/part_filter_chip.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';

class ExerciseMultiPickerBottomSheet extends StatefulWidget {
  final List<ExerciseModel> exercises;

  const ExerciseMultiPickerBottomSheet({super.key, required this.exercises});

  @override
  State<ExerciseMultiPickerBottomSheet> createState() =>
      _ExerciseMultiPickerBottomSheetState();
}

class _ExerciseMultiPickerBottomSheetState
    extends State<ExerciseMultiPickerBottomSheet> {
  final Map<int, ExerciseModel> selected = {};
  final TextEditingController _searchController = TextEditingController();

  late List<ExerciseModel> resistanceExercises;
  late List<ExerciseModel> cardioExercises;
  late List<ExerciseModel> visibleResistanceExercises;
  final WorkoutRepository _workoutRepository = getIt<WorkoutRepository>();

  int? selectedMuscleId;
  List<FilterItemModel> smallMuscleGroups = [];
  final Set<int> selectedSmallMuscleIds = {};
  bool isLoadingSmallMuscleGroups = false;
  bool isFilteringResistanceExercises = false;
  String? smallMuscleGroupsError;
  String? resistanceExercisesError;
  int _filterRequestId = 0;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();

    resistanceExercises = widget.exercises
        .where((e) => e.category?.id == 1)
        .toList();

    cardioExercises = widget.exercises
        .where((e) => e.category?.id == 2)
        .toList();
    visibleResistanceExercises = resistanceExercises;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ExerciseOrgan> get muscles {
    final values = <int, ExerciseOrgan>{};
    for (final exercise in resistanceExercises) {
      final organ = exercise.category?.organ;
      if (organ != null) {
        values[organ.id] = organ;
      }
    }

    final result = values.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    return result;
  }

  List<ExerciseModel> _filterBySearch(List<ExerciseModel> exercises) {
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) return exercises;

    return exercises
        .where((exercise) => exercise.name.toLowerCase().contains(query))
        .toList();
  }

  List<ExerciseModel> get matchingResistanceExercises =>
      _filterBySearch(visibleResistanceExercises);

  List<ExerciseModel> get matchingCardioExercises =>
      _filterBySearch(cardioExercises);

  Future<void> _selectMuscle(ExerciseOrgan? muscle) async {
    final requestId = ++_filterRequestId;

    setState(() {
      selectedMuscleId = muscle?.id;
      selectedSmallMuscleIds.clear();
      smallMuscleGroups = [];
      smallMuscleGroupsError = null;
      resistanceExercisesError = null;
      isLoadingSmallMuscleGroups = muscle != null;
      isFilteringResistanceExercises = muscle != null;
      visibleResistanceExercises = muscle == null ? resistanceExercises : [];
    });

    if (muscle == null) return;

    await Future.wait([
      _loadSmallMuscleGroups(muscle.id, requestId),
      _loadResistanceExercises(muscle.id, const [], requestId),
    ]);
  }

  Future<void> _loadSmallMuscleGroups(int muscleId, int requestId) async {
    final result = await _workoutRepository.getSubCategories(muscleId);
    if (!mounted || requestId != _filterRequestId) return;

    setState(() {
      isLoadingSmallMuscleGroups = false;
      switch (result) {
        case Success<List<FilterItemModel>>():
          smallMuscleGroups = result.data;
        case Failure<List<FilterItemModel>>():
          smallMuscleGroupsError = result.message;
      }
    });
  }

  Future<void> _loadResistanceExercises(
    int muscleId,
    List<int> smallMuscleIds,
    int requestId,
  ) async {
    final result = await _workoutRepository.getExercises(
      categoryId: 1,
      organId: muscleId,
      smallestCategoryId: smallMuscleIds.isEmpty ? null : smallMuscleIds,
    );
    if (!mounted || requestId != _filterRequestId) return;

    setState(() {
      isFilteringResistanceExercises = false;
      switch (result) {
        case Success<List<ExerciseModel>>():
          visibleResistanceExercises = result.data;
          resistanceExercisesError = null;
        case Failure<List<ExerciseModel>>():
          resistanceExercisesError = result.message;
      }
    });
  }

  Future<void> _toggleSmallMuscle(FilterItemModel part, bool isSelected) async {
    final muscleId = selectedMuscleId;
    if (muscleId == null) return;

    setState(() {
      if (isSelected) {
        selectedSmallMuscleIds.add(part.id);
      } else {
        selectedSmallMuscleIds.remove(part.id);
      }
      resistanceExercisesError = null;
      isFilteringResistanceExercises = true;
    });

    final requestId = ++_filterRequestId;
    await _loadResistanceExercises(
      muscleId,
      selectedSmallMuscleIds.toList(),
      requestId,
    );
  }

  Future<void> _clearSmallMuscleFilters() async {
    final muscleId = selectedMuscleId;
    if (muscleId == null || selectedSmallMuscleIds.isEmpty) return;

    setState(() {
      selectedSmallMuscleIds.clear();
      resistanceExercisesError = null;
      isFilteringResistanceExercises = true;
    });

    final requestId = ++_filterRequestId;
    await _loadResistanceExercises(muscleId, const [], requestId);
  }

  Future<void> _retrySmallMuscleGroups() async {
    final muscleId = selectedMuscleId;
    if (muscleId == null) return;

    final requestId = ++_filterRequestId;
    setState(() {
      smallMuscleGroupsError = null;
      isLoadingSmallMuscleGroups = true;
    });
    await _loadSmallMuscleGroups(muscleId, requestId);
  }

  Future<void> _retryResistanceExercises() async {
    final muscleId = selectedMuscleId;
    if (muscleId == null) return;

    setState(() {
      resistanceExercisesError = null;
      isFilteringResistanceExercises = true;
    });

    final requestId = ++_filterRequestId;
    await _loadResistanceExercises(
      muscleId,
      selectedSmallMuscleIds.toList(),
      requestId,
    );
  }

  Widget _buildSmallMuscleFilters(AppLocalizations l10n) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
      alignment: Alignment.topCenter,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: _buildSmallMuscleFiltersContent(l10n),
      ),
    );
  }

  Widget _buildSmallMuscleFiltersContent(AppLocalizations l10n) {
    if (selectedMuscleId == null) {
      return const SizedBox.shrink(key: ValueKey('no-muscle'));
    }

    if (isLoadingSmallMuscleGroups) {
      return const SizedBox(
        key: ValueKey('loading-small-muscles'),
        height: 44,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (smallMuscleGroupsError != null) {
      return Padding(
        key: const ValueKey('small-muscle-error'),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                smallMuscleGroupsError!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
            TextButton(
              onPressed: _retrySmallMuscleGroups,
              child: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    if (smallMuscleGroups.isEmpty) {
      return const SizedBox.shrink(key: ValueKey('empty-small-muscles'));
    }

    return Column(
      key: ValueKey('small-muscles-$selectedMuscleId'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.refineMuscleTarget,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBtn,
                  ),
                ),
              ),
              if (selectedSmallMuscleIds.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    '(${selectedSmallMuscleIds.length})',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryBtn,
                    ),
                  ),
                ),
              if (selectedSmallMuscleIds.isNotEmpty)
                TextButton(
                  onPressed: _clearSmallMuscleFilters,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryBtn,
                    disabledForegroundColor: AppColors.primaryBtn.withValues(
                      alpha: 0.5,
                    ),
                    minimumSize: const Size(44, 32),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    l10n.clear,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          height: 42,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            scrollDirection: Axis.horizontal,
            itemCount: smallMuscleGroups.length,
            itemBuilder: (context, index) {
              final part = smallMuscleGroups[index];
              return PartFilterChip(
                label: part.name,
                isSelected: selectedSmallMuscleIds.contains(part.id),
                onSelected: (selected) {
                  HapticFeedback.selectionClick();
                  _toggleSmallMuscle(part, selected);
                },
              );
            },
            separatorBuilder: (_, _) => const SizedBox(width: 0),
          ),
        ),
      ],
    );
  }

  Widget _buildResistanceExerciseList() {
    if (isFilteringResistanceExercises) {
      return const Center(child: CircularProgressIndicator());
    }
    if (resistanceExercisesError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 32, color: Colors.red),
              const SizedBox(height: 8),
              Text(
                resistanceExercisesError!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _retryResistanceExercises,
                icon: const Icon(Icons.refresh),
                label: Text(AppLocalizations.of(context)!.retry),
              ),
            ],
          ),
        ),
      );
    }
    if (matchingResistanceExercises.isEmpty) {
      return _buildEmptyState(AppLocalizations.of(context)!);
    }
    return buildGrid(matchingResistanceExercises);
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    final hasSearch = searchQuery.trim().isNotEmpty;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasSearch ? Icons.search_off_rounded : Icons.fitness_center,
              size: 38,
              color: AppColors.hintText.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 10),
            Text(
              hasSearch ? l10n.noSearchResults : l10n.no_exercises_found,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (hasSearch) ...[
              const SizedBox(height: 4),
              Text(
                l10n.tryDifferentSearch,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.hintText, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => searchQuery = value),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: l10n.searchForExercises,
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: searchQuery.isEmpty
              ? null
              : IconButton(
                  tooltip: l10n.clear,
                  onPressed: () {
                    _searchController.clear();
                    setState(() => searchQuery = '');
                  },
                  icon: const Icon(Icons.close_rounded),
                ),
          filled: true,
          fillColor: AppColors.hintText.withValues(alpha: 0.07),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionActions(
    AppLocalizations l10n,
    List<ExerciseModel> exercises,
  ) {
    final selectedCount = exercises
        .where((exercise) => selected.containsKey(exercise.id))
        .length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l10n.matchingExercises(exercises.length),
              style: TextStyle(
                color: AppColors.hintText,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: exercises.isEmpty
                ? null
                : () {
                    setState(() {
                      for (final exercise in exercises) {
                        selected[exercise.id] = exercise;
                      }
                    });
                  },
            child: Text(
              l10n.selectVisible,
              style: const TextStyle(color: AppColors.lightText),
            ),
          ),
          TextButton(
            onPressed: selectedCount == 0
                ? null
                : () {
                    setState(() {
                      for (final exercise in exercises) {
                        selected.remove(exercise.id);
                      }
                    });
                  },
            child: Text(
              l10n.clearVisible,
              style: const TextStyle(color: AppColors.lightText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMuscleCard({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: 78,
          margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
          decoration: BoxDecoration(
            gradient: selected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryBtn,
                      AppColors.primaryBtn.withValues(alpha: 0.78),
                    ],
                  )
                : null,
            color: selected ? null : AppColors.hintText.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? AppColors.primaryBtn
                  : AppColors.hintText.withValues(alpha: 0.16),
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.primaryBtn.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? Colors.white : context.textColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMuscleFilters(AppLocalizations l10n) {
    return SizedBox(
      height: 48,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        children: [
          _buildMuscleCard(
            label: l10n.all,
            selected: selectedMuscleId == null,
            onTap: () => _selectMuscle(null),
          ),
          for (final muscle in muscles)
            _buildMuscleCard(
              label: muscle.name,
              selected: selectedMuscleId == muscle.id,
              onTap: () => _selectMuscle(muscle),
            ),
        ],
      ),
    );
  }

  Widget _buildSelectedExercisesSummary(AppLocalizations l10n) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      child: selected.isEmpty
          ? const SizedBox.shrink()
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Material(
                elevation: 6,
                color: context.backgroundColor,
                borderRadius: BorderRadius.circular(28),
                shadowColor: AppColors.primaryBtn.withValues(alpha: 0.22),
                child: Container(
                  height: 54,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: AppColors.primaryBtn.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: selected.values
                              .take(5)
                              .map(
                                (exercise) => Tooltip(
                                  message: exercise.name,
                                  child: GestureDetector(
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      setState(
                                        () => selected.remove(exercise.id),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 3,
                                        vertical: 7,
                                      ),
                                      child: Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          CircleAvatar(
                                            radius: 19,
                                            backgroundColor: AppColors
                                                .primaryBtn
                                                .withValues(alpha: 0.12),
                                            backgroundImage:
                                                exercise.gifUrl == null
                                                ? null
                                                : CachedNetworkImageProvider(
                                                    exercise.gifUrl!,
                                                  ),
                                            child: exercise.gifUrl == null
                                                ? const Icon(
                                                    Icons.fitness_center,
                                                    size: 16,
                                                    color: AppColors.primaryBtn,
                                                  )
                                                : null,
                                          ),
                                          Positioned(
                                            right: -2,
                                            top: -2,
                                            child: Container(
                                              width: 15,
                                              height: 15,
                                              decoration: const BoxDecoration(
                                                color: AppColors.primaryBtn,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.close,
                                                size: 11,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        transitionBuilder: (child, animation) =>
                            ScaleTransition(scale: animation, child: child),
                        child: Container(
                          key: ValueKey(selected.length),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBtn,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            '${selected.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 2,
      child: Container(
        decoration: BoxDecoration(
          color: context.backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [

            const SizedBox(height: 16),

            Center(
              child: Text(
                l10n.selectExercises,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            _buildSearchField(l10n),

            TabBar(
              labelColor: AppColors.primaryBtn,
              unselectedLabelColor: AppColors.hintText.withValues(alpha: 0.85),
              indicatorColor: AppColors.primaryBtn,
              indicatorWeight: 2.5,
              dividerColor: AppColors.hintText.withValues(alpha: 0.15),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
              tabs: [
                Tab(
                  icon: Icon(Icons.fitness_center, size: 22),
                  text: l10n.resistance,
                ),
                Tab(
                  icon: Icon(Icons.directions_run, size: 22),
                  text: l10n.cardio,
                ),
              ],
            ),

            Expanded(
              child: TabBarView(
                children: [buildResistanceTab(), buildCardioTab()],
              ),
            ),

            SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSelectedExercisesSummary(l10n),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: CustomAuthButton(
                      text: l10n.addExercises(selected.length),
                      onPressed: selected.isEmpty
                          ? null
                          : () {
                              Navigator.pop(context, selected.values.toList());
                            },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildGrid(List<ExerciseModel> exercises) {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      itemCount: exercises.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final ex = exercises[index];
        final isSelected = selected.containsKey(ex.id);

        return ExerciseSelectableCard(
          exercise: ex,
          isSelected: isSelected,
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() {
              if (isSelected) {
                selected.remove(ex.id);
              } else {
                selected[ex.id] = ex;
              }
            });
          },
        );
      },
    );
  }

  Widget buildResistanceTab() {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 2),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.target_muscle,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.primaryBtn,
              ),
            ),
          ),
        ),

        _buildMuscleFilters(l10n),

        _buildSmallMuscleFilters(l10n),

        _buildSelectionActions(l10n, matchingResistanceExercises),

        Expanded(child: _buildResistanceExerciseList()),
      ],
    );
  }

  Widget buildCardioTab() {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        _buildSelectionActions(l10n, matchingCardioExercises),

        Expanded(
          child: matchingCardioExercises.isEmpty
              ? _buildEmptyState(l10n)
              : buildGrid(matchingCardioExercises),
        ),
      ],
    );
  }
}
