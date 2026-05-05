import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../providers/navigation_provider.dart';

class AppSidebar extends ConsumerWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navState = ref.watch(navigationProvider);
    final selectedIndex = navState.index;

    return Container(
      width: 140,
      height: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF001F3D),
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(4, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 50),
            
            // 0. HOME
            _buildSidebarIcon(ref, context, 0, PhosphorIcons.house(), isActive: selectedIndex == 0),
            
            // 1. INVENTORY
            _buildSidebarIcon(ref, context, 1, PhosphorIcons.package(), isActive: selectedIndex == 1),
            
            const Spacer(),
            
            // 4. PROFILE
            _buildSidebarIcon(ref, context, 4, PhosphorIcons.user(), isActive: selectedIndex == 4, isLarge: true),
            
            // 5. LOGOUT
            _buildSidebarIcon(ref, context, 5, PhosphorIcons.signOut(), isActive: selectedIndex == 5),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarIcon(WidgetRef ref, BuildContext context, int index, IconData icon, {required bool isActive, bool isLarge = false}) {
    double size = isLarge ? 70 : 60;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: GestureDetector(
        onTap: () {
          if (index == 5) {
            ref.read(navigationProvider.notifier).setIndex(0);
            Navigator.pushReplacementNamed(context, '/');
          } else {
            // This now triggers a refresh version if index is the same
            ref.read(navigationProvider.notifier).setIndex(index);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: isActive 
                ? Colors.white.withValues(alpha: 0.15) 
                : const Color(0xFFFFD509), 
            shape: BoxShape.circle,
            border: isActive 
                ? Border.all(color: Colors.white.withValues(alpha: 0.3)) 
                : null,
          ),
          child: Center(
            child: Icon(
              icon,
              size: isLarge ? 32 : 28,
              color: isActive ? const Color(0xFFFFD509) : const Color(0xFF001F3D),
            ),
          ),
        ),
      ),
    );
  }
}
