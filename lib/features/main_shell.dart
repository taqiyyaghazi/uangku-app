import 'package:flutter/material.dart';

import 'package:uangku/features/dashboard/screens/dashboard_screen.dart';
import 'package:uangku/features/insights/screens/insights_screen.dart';
import 'package:uangku/features/portfolio/screens/portfolio_screen.dart';

/// The main shell with bottom navigation.
///
/// Hosts [DashboardScreen] (Home) and [PortfolioScreen] (Strategy Zone).
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const _screens = [
    DashboardScreen(),
    PortfolioScreen(),
    InsightsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.trending_up_outlined),
            selectedIcon: Icon(Icons.trending_up),
            label: 'Portfolio',
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart_outline),
            selectedIcon: Icon(Icons.pie_chart),
            label: 'Insights',
          ),
        ],
      ),
    );
  }
}
