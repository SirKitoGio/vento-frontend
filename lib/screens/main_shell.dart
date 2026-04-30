import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/navigation_provider.dart';
import '../widgets/sidebar/app_sidebar.dart';
import 'dashboard_screen.dart';
import 'warehouse_logistics_screen.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navState = ref.watch(navigationProvider);
    final selectedIndex = navState.index;

    Widget currentScreen;
    switch (selectedIndex) {
      case 0:
        currentScreen = const DashboardScreenContent();
        break;
      case 1:
        currentScreen = const WarehouseLogisticsContent();
        break;
      default:
        currentScreen = const DashboardScreenContent();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          const AppSidebar(),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.01, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: Container(
                // Unique key composed of index AND refresh version
                key: ValueKey<String>('${navState.index}_${navState.refreshVersion}'),
                child: currentScreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
