import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../view_model/categories_cubit/categories_cubit.dart';
import '../view_model/categories_cubit/categories_state.dart';

class MuscleGroupsScreen extends StatefulWidget {
  const MuscleGroupsScreen({super.key});

  @override
  State<MuscleGroupsScreen> createState() => _MuscleGroupsScreenState();
}

class _MuscleGroupsScreenState extends State<MuscleGroupsScreen> {
  @override
  void initState() {
    super.initState();
    // 🔥 2 = جلب العضلات الأساسية (Chest, Back...) حسب الباك إند
    context.read<CategoriesCubit>().fetchCategories(2);
  }

  // 💡 صور افتراضية فخمة للعضلات لأن الباك إند لا يرسل صوراً حالياً
  final Map<String, String> _muscleImages = {
    'Chest': 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=500&q=80',
    'Back': 'https://images.unsplash.com/photo-1603287681836-b174ce5074c2?w=500&q=80',
    'Legs': 'https://images.unsplash.com/photo-1434682881908-b43d0467b798?w=500&q=80',
    'Shoulders': 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=500&q=80',
    'Biceps': 'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=500&q=80',
    'Triceps': 'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=500&q=80',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        title: const Text('Resistance Areas', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
      ),
      body: BlocBuilder<CategoriesCubit, CategoriesState>(
        builder: (context, state) {
          if (state is CategoriesLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryBtn));
          }
          else if (state is CategoriesFailure) {
            return Center(
              child: Text(state.errorMessage, style: const TextStyle(color: Colors.red, fontSize: 16)),
            );
          }
          else if (state is CategoriesSuccess) {
            final muscles = state.categories;

            if (muscles.isEmpty) {
              return const Center(child: Text("No muscle groups found.", style: TextStyle(color: AppColors.hintText)));
            }

            return GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 0.9,
              ),
              itemCount: muscles.length,
              itemBuilder: (context, index) {
                final muscle = muscles[index];
                // مطابقة الاسم مع الصورة، وإذا لم توجد نضع صورة افتراضية
                final imageUrl = _muscleImages[muscle.name] ?? 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=500&q=80';

                return LightMuscleGridItem(
                  title: muscle.name,
                  imageUrl: imageUrl,
                  onTap: () {
                    // 🔥 الانتقال لقائمة التمارين وتمرير organId
                    Navigator.pushNamed(context, AppRoutes.exercisesList, arguments: {'organId': muscle.id});
                  },
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}

// (احتفظي بنفس ويدجت LightMuscleGridItem التي لديكي في الأسفل هنا)
class LightMuscleGridItem extends StatelessWidget {
  final String title;
  final String imageUrl;
  final VoidCallback onTap;

  const LightMuscleGridItem({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(imageUrl, fit: BoxFit.cover),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.0),
                      Colors.white.withOpacity(0.4),
                      Colors.white.withOpacity(0.9),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 15,
                left: 15,
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}