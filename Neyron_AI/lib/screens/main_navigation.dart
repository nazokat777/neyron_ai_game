import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'planet_screen.dart';
import 'lab_screen.dart';
import 'garden_screen.dart';
import 'academy_screen.dart';
import 'profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _index = 0;

  final _screens = const [
    PlanetScreen(),
    LabScreen(),
    GardenScreen(),
    AcademyScreen(),
    ProfileScreen(),
  ];

  static const _items = [
    _NavItem(Icons.public_rounded, 'Sayyora'),
    _NavItem(Icons.science_rounded, 'Lab'),
    _NavItem(Icons.local_florist_rounded, 'Bog\'lar'),
    _NavItem(Icons.emoji_events_rounded, 'Akademiya'),
    _NavItem(Icons.person_rounded, 'Pasport'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: _buildNav(),
    );
  }

  Widget _buildNav() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cosmicMid,
        border: Border(
          top: BorderSide(color: AppColors.cosmicLight, width: 0.3),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (i) {
              final item = _items[i];
              final active = _index == i;
              return Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => setState(() => _index = i),
                    borderRadius: BorderRadius.circular(14),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.neuronGreen.withValues(alpha: 0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.icon,
                            size: 22,
                            color: active
                                ? AppColors.neuronGreen
                                : AppColors.cosmicLight,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 11,
                              color: active
                                  ? AppColors.neuronGreen
                                  : AppColors.cosmicLight,
                              fontWeight:
                                  active ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}
