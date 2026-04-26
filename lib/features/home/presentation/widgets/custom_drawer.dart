import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/features/home/presentation/view/home_page.dart';
import 'package:sportifo_app/features/home/presentation/view_model/home_view_model.dart';
import 'package:sportifo_app/features/profile/presentation/view/profile_page.dart';

class CustomDrawer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTap;

  const CustomDrawer({
    super.key,
    required this.selectedIndex,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.primaryBtn,
      child: Stack(
        children: [
          Container(color: AppColors.primaryBtn),
          Positioned.fill(
            top: 120,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(40)),
              ),
              child: Column(
                children: [
                  _buildUserInfo(),
                  const SizedBox(height: 20),

                  _buildItem(
                    icon: Icons.person_outline,
                    text: "profile",
                    index: 0,
                    context: context,
                  ),
                  _buildItem(
                    icon: Icons.settings,
                    text: "Settings",
                    index: 1,
                    context: context,
                  ),
                  _buildItem(
                    icon: Icons.info_outline,
                    text: "about us",
                    index: 2,
                    context: context,
                  ),

                  const Spacer(),

                  _buildItem(
                    icon: Icons.logout,
                    text: "Logout",
                    index: 3,
                    context: context,
                  ),
                ],
              ),
            ),
          ),

          // الصورة + الدائرة
          Positioned(
            top: 70,
            left: 0,
            right: 0,
            child: Center(
              child: Stack(
                children: [
                  Neumorphic(
                    style: NeumorphicStyle(
                      depth: 6,
                      boxShape: const NeumorphicBoxShape.circle(),
                      color: Colors.white,
                    ),
                    child: const CircleAvatar(
                      radius: 45,
                      // backgroundImage: AssetImage("assets/user.jpg"),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBtn,
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        "20",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return Column(
      children: const [
        Text(
          "User name",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5),
        Text("VIP", style: TextStyle(color: Colors.orange)),
        SizedBox(height: 5),
        Text("user@gmail.com", style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildItem({
    required IconData icon,
    required String text,
    required int index,
    required BuildContext context,
  }) {
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        onItemTap(index);
        Navigator.pop(context);
        _navigateToPage(context, index);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Neumorphic(
          duration: const Duration(milliseconds: 250),
          style: NeumorphicStyle(
            depth: isSelected ? 6 : -4, 
            intensity: 0.8,
            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
            color: isSelected
                ? AppColors.primaryBtn.withOpacity(0.15)
                : Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected ? AppColors.primaryBtn : AppColors.hintText,
                ),
                const SizedBox(width: 15),
                Text(
                  text,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: AppColors.hintText,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToPage(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProfilePage()),
        );
        break;
      case 1:
        // Navigator.push(context,MaterialPageRoute(builder: (_) => WorkoutsPage()));
        break;
      case 2:
        // Navigator.push(context,MaterialPageRoute(builder: (_) => StatsPage()));
        break;
    }
  }
}
