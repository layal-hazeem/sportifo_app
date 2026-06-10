import 'package:flutter/material.dart';
import '../../../../core/widgets/wave_app_bar.dart';
import '../../../../l10n/app_localizations.dart';
import 'coaches_filter_bottom_sheet.dart';

class CoachesHeader extends StatelessWidget {
  final TextEditingController searchController;
  final int? selectedGender;
  final int? minExp;
  final int? maxExp;
  final ValueChanged<String> onSearchSubmitted;
  final VoidCallback onClearSearch;
  final Function(int? gender, int? minExp, int? maxExp) onFiltersApplied;

  const CoachesHeader({
    super.key,
    required this.searchController,
    required this.selectedGender,
    required this.minExp,
    required this.maxExp,
    required this.onSearchSubmitted,
    required this.onClearSearch,
    required this.onFiltersApplied,
  });

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (_) => CoachesFilterBottomSheet(
        initialGender: selectedGender,
        initialMinExp: minExp,
        initialMaxExp: maxExp,
        onApply: onFiltersApplied,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      height: 210,
      color: const Color(0xFFF7F7F7),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: WaveAppBar(
              title: l10n.all_coaches,
              showBackButton: true,
            ),
          ),
          Positioned(
            bottom: 10,
            left: 16,
            right: 16,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: l10n.search_coach_hint,
                        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                        prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFFF6B35)),
                        suffixIcon: searchController.text.isNotEmpty
                            ? IconButton(
                          icon: const Icon(Icons.clear_rounded, color: Colors.grey),
                          onPressed: () {
                            searchController.clear();
                            onClearSearch();
                          },
                        )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      onSubmitted: onSearchSubmitted,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => _showFilterBottomSheet(context),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.tune_rounded, color: Colors.white, size: 22),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}