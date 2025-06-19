import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../pages/daily_habits_page.dart';
import '../pages/partner_habits_page.dart';
import '../screens/settings_screen.dart';
import '../core/theme/flexible_theme_system.dart';
import '../providers/repository_init_provider.dart';

class HomeTabScaffold extends ConsumerStatefulWidget {
  const HomeTabScaffold({super.key});

  @override
  ConsumerState<HomeTabScaffold> createState() => _HomeTabScaffoldState();
}

class _HomeTabScaffoldState extends ConsumerState<HomeTabScaffold>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // TODO: Initialize repository when provider is available
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch repository initialization
    final repositoryInit = ref.watch(repositoryProvider);
    final isUsingRemote = ref.watch(isUsingRemoteRepositoryProvider);
    final colors = ref.watchColors;

    return repositoryInit.when(
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error,
                size: 64,
                color: Colors.red[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to initialize database',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Retry initialization
                  ref.invalidate(repositoryProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (_) => DefaultTabController(
        length: 2,
        child: Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                // Collapsible header with title and settings
                SliverAppBar(
                  title: Row(
                    children: [
                      Flexible(
                        child: Text(
                          'Habit Level Up',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.draculaForeground,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        isUsingRemote ? Icons.cloud : Icons.cloud_off,
                        size: 16,
                        color: isUsingRemote
                            ? colors.success
                            : colors.draculaComment,
                      ),
                    ],
                  ),
                  backgroundColor: colors.draculaBackground,
                  foregroundColor: colors.draculaForeground,
                  iconTheme: IconThemeData(color: colors.draculaForeground),
                  elevation: 0,
                  pinned: false,
                  floating: true,
                  snap: true,
                  expandedHeight: 0,
                  collapsedHeight: 56,
                  toolbarHeight: 56,
                  actions: [
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SettingsScreen(),
                          ),
                        );
                      },
                      icon:
                          Icon(Icons.settings, color: colors.draculaForeground),
                      tooltip: 'Settings',
                    ),
                  ],
                ),
                // Tab bar
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _TabBarHeaderDelegate(
                    tabController: _tabController,
                    context: context,
                    colors: colors,
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: const [
                MyHabitsTab(),
                PartnerHabitsTab(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyHabitsTab extends ConsumerWidget {
  const MyHabitsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: DailyHabitsPage(),
    );
  }
}

class PartnerHabitsTab extends ConsumerWidget {
  const PartnerHabitsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: PartnerHabitsPage(),
    );
  }
}

// Custom delegate for tab bar header
class _TabBarHeaderDelegate extends SliverPersistentHeaderDelegate {
  final TabController tabController;
  final BuildContext context;
  final FlexibleColors colors;

  _TabBarHeaderDelegate(
      {required this.tabController,
      required this.context,
      required this.colors});

  @override
  double get minExtent => 48;

  @override
  double get maxExtent => 48;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: colors.draculaBackground,
      child: TabBar(
        controller: tabController,
        tabs: [
          Tab(
            icon: Icon(Icons.person,
                size: MediaQuery.of(context).size.width < 600 ? 20 : 24),
            text: 'My Habits',
          ),
          Tab(
            icon: Icon(Icons.people,
                size: MediaQuery.of(context).size.width < 600 ? 20 : 24),
            text: 'Partner Habits',
          ),
        ],
        indicatorColor: colors.primaryPurple,
        labelColor: colors.primaryPurple,
        unselectedLabelColor: colors.draculaComment.withOpacity(0.6),
        labelStyle: TextStyle(
          fontSize: MediaQuery.of(context).size.width < 600 ? 12 : 14,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: MediaQuery.of(context).size.width < 600 ? 12 : 14,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return oldDelegate is _TabBarHeaderDelegate && oldDelegate.colors != colors;
  }
}
