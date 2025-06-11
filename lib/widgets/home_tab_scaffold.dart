import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../pages/daily_habits_page.dart';
import '../pages/partner_habits_page.dart';
import '../core/theme/app_colors.dart';
import '../providers/habits_provider.dart';
import '../providers/repository_init_provider.dart';

class HomeTabScaffold extends ConsumerStatefulWidget {
  const HomeTabScaffold({Key? key}) : super(key: key);

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
      data: (_) => Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              const Text('Habit Level Up'),
              const SizedBox(width: 8),
              Icon(
                isUsingRemote ? Icons.cloud : Icons.cloud_off,
                size: 16,
                color: isUsingRemote ? Colors.green : Colors.grey,
              ),
            ],
          ),
          backgroundColor: AppColors.draculaBackground,
          elevation: 0,
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(
                icon: Icon(Icons.person),
                text: 'My Habits',
              ),
              Tab(
                icon: Icon(Icons.people),
                text: 'Partner Habits',
              ),
            ],
            indicatorColor: AppColors.completedBackground,
            labelColor: AppColors.completedBackground,
            unselectedLabelColor: AppColors.draculaComment.withOpacity(0.6),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [
            MyHabitsTab(),
            PartnerHabitsTab(),
          ],
        ),
      ),
    );
  }
}

class MyHabitsTab extends ConsumerWidget {
  const MyHabitsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const DailyHabitsPage();
  }
}

class PartnerHabitsTab extends ConsumerWidget {
  const PartnerHabitsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const PartnerHabitsPage();
  }
}