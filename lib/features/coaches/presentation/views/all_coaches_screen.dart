import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sportifo_app/core/di/service_locator.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';
import '../../../../l10n/app_localizations.dart';
import '../view_model/all_coaches_cubit.dart';
import '../view_model/all_coaches_state.dart';
import '../widgets/coaches_header.dart';
import 'coach_details_screen.dart';
import '../widgets/coach_grid_card.dart';

class AllCoachesScreen extends StatefulWidget {
  const AllCoachesScreen({super.key});

  @override
  State<AllCoachesScreen> createState() => _AllCoachesScreenState();
}

class _AllCoachesScreenState extends State<AllCoachesScreen> {
  final TextEditingController _searchController = TextEditingController();

  String? _searchQuery;
  int? _selectedGender;
  int? _minExp;
  int? _maxExp;

  void _updateFilters({String? search, int? gender, int? minExp, int? maxExp}) {
    setState(() {
      _searchQuery = search;
      _selectedGender = gender;
      _minExp = minExp;
      _maxExp = maxExp;
    });
  }

  void _fetchCoaches(BuildContext blocContext) {
    blocContext.read<AllCoachesCubit>().fetchAllCoaches(
      search: _searchController.text.trim().isEmpty
          ? null
          : _searchController.text.trim(),
      gender: _selectedGender,
      minExp: _minExp,
      maxExp: _maxExp,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (context) => getIt<AllCoachesCubit>()..fetchAllCoaches(),
      child: Builder(
        builder: (blocContext) {
          return Scaffold(
            backgroundColor: context.backgroundColor,
            body: Column(
              children: [
                CoachesHeader(
                  searchController: _searchController,
                  selectedGender: _selectedGender,
                  minExp: _minExp,
                  maxExp: _maxExp,
                  onSearchSubmitted: (value) {
                    _updateFilters(
                      search: value.isEmpty ? null : value,
                      gender: _selectedGender,
                      minExp: _minExp,
                      maxExp: _maxExp,
                    );
                    _fetchCoaches(blocContext);
                  },
                  onClearSearch: () {
                    _updateFilters(
                      search: null,
                      gender: _selectedGender,
                      minExp: _minExp,
                      maxExp: _maxExp,
                    );
                    _fetchCoaches(blocContext);
                  },
                  onFiltersApplied: (gender, minExp, maxExp) {
                    _updateFilters(
                      search: _searchController.text.isEmpty
                          ? null
                          : _searchController.text,
                      gender: gender,
                      minExp: minExp,
                      maxExp: maxExp,
                    );
                    _fetchCoaches(blocContext);
                  },
                ),

                const SizedBox(height: 4),

                Expanded(
                  child: BlocBuilder<AllCoachesCubit, AllCoachesState>(
                    builder: (context, state) {
                      if (state is AllCoachesLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFFFF6B35),
                            ),
                          ),
                        );
                      } else if (state is AllCoachesError) {
                        return Center(
                          child: Text(
                            l10n.coaches_error_loading(state.message),
                          ),
                        );
                      } else if (state is AllCoachesLoaded) {
                        final coaches = state.coaches;
                        if (coaches.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off_rounded,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  l10n.no_coaches_found,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return GridView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.72,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                              ),
                          itemCount: coaches.length,
                          itemBuilder: (context, index) {
                            final coach = coaches[index];
                            return CoachGridCard(
                              coach: coach,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        CoachDetailsScreen(coachId: coach.id),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
