import 'package:flutter/material.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/features/profile/data/models/coach_profile_response.dart';

class CoachTabsSection extends StatefulWidget {
final CoachProfileModel coach;

  const CoachTabsSection({
    super.key,
    required this.coach,
  });

  @override
  State<CoachTabsSection> createState() =>
      _CoachTabsSectionState();
}

class _CoachTabsSectionState
    extends State<CoachTabsSection> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.05),
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            children: [
              _tabButton("Information", 0),
              _tabButton("Certificates", 1),
            ],
          ),
        ),

        const SizedBox(height: 20),

        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: selectedTab == 0
              ? _buildInfoTab()
              : _buildCertificatesTab(),
        ),
      ],
    );
  }

  Widget _tabButton(
    String title,
    int index,
  ) {
    final isSelected =
        selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTab = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(
            milliseconds: 250,
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryBtn
                : Colors.transparent,
            borderRadius:
                BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : Colors.grey,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTab() {
  final coach = widget.coach;

  return Container(
    key: const ValueKey("info"),
    padding: const EdgeInsets.all(16),
    margin: const EdgeInsets.symmetric(
      horizontal: 20,
    ),
    decoration: _cardStyle(),
    child: Column(
      children: [

        _row(
          "Years of Experience",
          "${coach.yearsOfExp}",
        ),

        _row(
          "Date of Birth",
          coach.dateOfBirth
              .toString()
              .split(" ")
              .first,
        ),

        _row(
          "Gender",
          coach.gender == true
              ? "Male"
              : "Female",
        ),

        const SizedBox(height: 20),

        Align(
          alignment:
              Alignment.centerLeft,
          child: Text(
            "Description",
            style: TextStyle(
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 8),

        Text(
          coach.description,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    ),
  );
}

Widget _buildCertificatesTab() {
  final coach = widget.coach;

  if (coach.certificates.isEmpty) {
    return Container(
      key: const ValueKey(
        "certificates",
      ),
      padding:
          const EdgeInsets.all(16),
      margin:
          const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      decoration: _cardStyle(),
      child: const Center(
        child: Text(
          "No certificates yet",
        ),
      ),
    );
  }

  return Container(
    key: const ValueKey(
      "certificates",
    ),
    padding:
        const EdgeInsets.all(16),
    margin:
        const EdgeInsets.symmetric(
      horizontal: 20,
    ),
    decoration: _cardStyle(),
    child: GridView.builder(
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(),
      itemCount:
          coach.certificates.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final cert =
            coach.certificates[index];

        return ClipRRect(
          borderRadius:
              BorderRadius.circular(12),
          child: Image.network(
            cert.url,
            fit: BoxFit.cover,
          ),
        );
      },
    ),
  );
}

Widget _row(
  String title,
  String value,
) {
  return Padding(
    padding:
        const EdgeInsets.symmetric(
      vertical: 6,
    ),
    child: Row(
      mainAxisAlignment:
          MainAxisAlignment
              .spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight:
                FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    ),
  );
}

BoxDecoration _cardStyle() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius:
        BorderRadius.circular(18),
    boxShadow: [
      BoxShadow(
        color:
            Colors.black.withOpacity(
          .05,
        ),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );
}
    }