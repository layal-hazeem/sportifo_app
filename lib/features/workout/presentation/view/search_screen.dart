import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart'; // تأكدي من مسار الألوان
import '../view_model/search_cubit/search_cubit.dart';
import '../view_model/search_cubit/search_state.dart';
import '../widgets/exercise_card.dart';

class SearchExercisesScreen extends StatefulWidget {
  final int? categoryId; // 🔥 أضفنا هاد المتغير (1 للمقاومة، 2 للكارديو مثلاً)

  const SearchExercisesScreen({super.key, this.categoryId});

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

    // 🔥 إذا مسح النص، نلغي الانتظار ونفضي الشاشة فوراً!
    if (query.isEmpty) {
      context.read<SearchCubit>().searchExercises('');
      return;
    }

    // الانتظار فقط عند الكتابة (لعدم الضغط على السيرفر)
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<SearchCubit>().searchExercises(query, categoryId: widget.categoryId);
    });
  }

  // 🔥 دالة للبحث السريع عند الضغط على الاقتراحات
  void _triggerQuickSearch(String keyword) {
    _controller.text = keyword;
    _onSearchChanged(keyword);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        // 🔥 تصميم شريط بحث احترافي (يشبه تطبيق الآيفون)
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
            style: const TextStyle(fontSize: 16, color: AppColors.textDark),
            decoration: InputDecoration(
              hintText: "Search for exercises...",
              hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
              border: InputBorder.none,
              prefixIcon: Icon(CupertinoIcons.search, color: Colors.grey.shade500, size: 20),
              suffixIcon: IconButton(
                icon: Icon(Icons.cancel, color: Colors.grey.shade400, size: 20),
                onPressed: () {
                  _controller.clear();
                  _onSearchChanged(''); // تفريغ البحث للعودة لحالة الاقتراحات
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
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBtn),
            );
          } else if (state is SearchSuccess) {
            if (state.exercises.isEmpty) {
              return _buildNoResults();
            }
            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              itemCount: state.exercises.length,
              itemBuilder: (context, index) {
                final exercise = state.exercises[index];
                return ExerciseCard(
                  exercise: exercise,
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.exerciseDetails,
                    arguments: exercise,
                  ),
                );
              },
            );
          } else if (state is SearchFailure) {
            // إذا كان الخطأ بسبب أن الحقل فارغ أو لا يوجد نتائج
            return _buildNoResults();
          }

          // 🔥 الحالة الافتراضية (Initial State): عندما يكون الحقل فارغاً
          return _buildSuggestions();
        },
      ),
    );
  }

  // ==========================================
  // 1. واجهة الاقتراحات السريعة (عند فتح الشاشة)
  // ==========================================
  Widget _buildSuggestions() {
      // نفترض أن 1 = مقاومة ، و 2 = كارديو (عدلي الأرقام حسب الباك إند عندك)
      final bool isCardio = widget.categoryId == 2;

      // القوائم المنفصلة
      final List<String> resistanceSearches = ['Chest', 'Abs', 'Legs', 'Back', 'Biceps', 'Shoulders'];
      final List<String> cardioSearches = ['Running', 'Jump Rope', 'Burpees', 'Cycling', 'High Knees'];

      // نختار القائمة المناسبة
      final List<String> popularSearches = isCardio ? cardioSearches : resistanceSearches;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Popular Searches",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: popularSearches.map((keyword) {
              return ActionChip(
                label: Text(keyword),
                labelStyle: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w600),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                onPressed: () => _triggerQuickSearch(keyword),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 2. واجهة "لا يوجد نتائج" (عند البحث عن شيء غير موجود)
  // ==========================================
  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.search_circle_fill, size: 100, color: Colors.grey.shade300),
          const SizedBox(height: 20),
          Text(
            "No exercises found!",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 10),
          Text(
            "Try searching for something else,\nlike 'Shoulders' or 'Yoga'.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}