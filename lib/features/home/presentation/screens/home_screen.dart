import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/shared_widgets.dart';
import '../../bloc/home_bloc.dart';
import '../../data/models/home_models.dart';
import '../../data/repositories/home_repository.dart';
import '../../../internship/presentation/screens/internship_detail_screen.dart';
import '../../../career/presentation/screens/career_path_detail_screen.dart';
import '../../../learning/presentation/screens/my_learning_screen.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../wishlist/presentation/screens/wishlist_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const _HomeTab(),
    const WishlistScreen(),
    const MyLearningScreen(),
    const NotificationsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: _AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class _AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _AppBottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const items = [
      BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home_rounded), label: 'Home'),
      BottomNavigationBarItem(
          icon: Icon(Icons.favorite_outline), activeIcon: Icon(Icons.favorite_rounded), label: 'Wish list'),
      BottomNavigationBarItem(
          icon: Icon(Icons.play_circle_outline), activeIcon: Icon(Icons.play_circle_rounded), label: 'My Learning'),
      BottomNavigationBarItem(
          icon: Icon(Icons.notifications_outlined), activeIcon: Icon(Icons.notifications_rounded), label: 'Notifications'),
      BottomNavigationBarItem(
          icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person_rounded), label: 'Profile'),
    ];

    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        items: items,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.bottomNavInactive,
        backgroundColor: AppColors.background,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
      ),
    );
  }
}

// ─── Home Tab ────────────────────────────────────────────────────────────────

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final HomeBloc _homeBloc;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _homeBloc = HomeBloc(homeRepository: HomeRepositoryImpl())
      ..add(const HomeDataLoaded());
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _homeBloc.add(
              HomeTabChanged(tab: _tabController.index == 0 ? 'internships' : 'courses'),
            );
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _homeBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _homeBloc,
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  pinned: true,
                  backgroundColor: AppColors.primary,
                  expandedHeight: 100,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      color: AppColors.primary,
                      padding: const EdgeInsets.fromLTRB(16, 50, 16, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            state is HomeLoaded
                                ? 'Hello ${state.userName} 👋'
                                : 'Hello 👋',
                            style: const TextStyle(
                              color: AppColors.textWhite,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.shopping_cart_outlined,
                                color: AppColors.textWhite, size: 24),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(0),
                    child: const SizedBox.shrink(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      // Search
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: _SearchBar(
                          controller: _searchController,
                          hint: state is HomeLoaded && state.activeTab == 'courses'
                              ? 'Search courses'
                              : 'Search internships',
                          onChanged: (q) {
                            final tab = state is HomeLoaded ? state.activeTab : 'internships';
                            _homeBloc.add(HomeSearchChanged(query: q, type: tab));
                          },
                        ),
                      ),
                      // Tab Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: TabBar(
                          controller: _tabController,
                          labelColor: AppColors.primary,
                          unselectedLabelColor: AppColors.textSecondary,
                          labelStyle: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                          unselectedLabelStyle: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w400),
                          indicatorColor: AppColors.primary,
                          indicatorWeight: 2.5,
                          tabs: const [
                            Tab(text: AppStrings.internships),
                            Tab(text: AppStrings.courses),
                          ],
                        ),
                      ),
                      if (state is HomeLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                        )
                      else if (state is HomeLoaded) ...[
                        // Items grid
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _ItemsGrid(items: state.items),
                        ),
                        const SizedBox(height: 24),
                        // Career Paths
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: SectionHeader(title: AppStrings.careerPaths),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 180,
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            scrollDirection: Axis.horizontal,
                            itemCount: state.careerPaths.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemBuilder: (ctx, i) => _CareerPathCard(
                              career: state.careerPaths[i],
                              onTap: () => Navigator.of(ctx).push(MaterialPageRoute(
                                builder: (_) => CareerPathDetailScreen(
                                    careerId: state.careerPaths[i].id),
                              )),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Continue Learning
                        if (state.continueLearning != null) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: SectionHeader(title: AppStrings.continueLearning),
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: _ContinueLearningCard(
                              data: state.continueLearning!,
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                      ] else if (state is HomeError)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Text(state.message, style: AppTextStyles.bodyMD),
                          ),
                        ),
                    ],
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

// ─── Search Bar ───────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  const _SearchBar({
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.backgroundGrey,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 14, color: AppColors.textHint),
          prefixIcon: const Icon(Icons.search, color: AppColors.textHint, size: 20),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

// ─── Items Grid ───────────────────────────────────────────────────────────────

class _ItemsGrid extends StatelessWidget {
  final List<InternshipModel> items;

  const _ItemsGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemCount: items.length,
      itemBuilder: (ctx, i) => _InternshipCard(
        item: items[i],
        onTap: () => Navigator.of(ctx).push(MaterialPageRoute(
          builder: (_) => InternshipDetailScreen(internshipId: items[i].id),
        )),
      ),
    );
  }
}

class _InternshipCard extends StatelessWidget {
  final InternshipModel item;
  final VoidCallback onTap;

  const _InternshipCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppSizes.radiusMD)),
            child: Container(
              height: 110,
              width: double.infinity,
              color: AppColors.cardBackground,
              child: item.imageUrl.isNotEmpty
                  ? Image.network(item.imageUrl, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const _PlaceholderImage())
                  : const _PlaceholderImage(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(item.description,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 32,
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text('View Details',
                        style: TextStyle(fontSize: 11, color: AppColors.textWhite)),
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

class _PlaceholderImage extends StatelessWidget {
  const _PlaceholderImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.cardBackground,
      child: const Center(
        child: Icon(Icons.biotech_outlined, color: AppColors.accent, size: 40),
      ),
    );
  }
}

// ─── Career Path Card ─────────────────────────────────────────────────────────

class _CareerPathCard extends StatelessWidget {
  final CareerPathModel career;
  final VoidCallback onTap;

  const _CareerPathCard({required this.career, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.accentLight,
              borderRadius: BorderRadius.circular(AppSizes.radiusSM),
            ),
            child: const Icon(Icons.health_and_safety_outlined,
                color: AppColors.primary, size: 24),
          ),
          const SizedBox(height: 10),
          Text(career.title,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary),
              maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Expanded(
            child: Text(career.description,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary),
                maxLines: 2, overflow: TextOverflow.ellipsis),
          ),
          GestureDetector(
            onTap: onTap,
            child: const Row(
              children: [
                Text('Explore Path',
                    style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600,
                        color: AppColors.primary)),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 10, color: AppColors.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Continue Learning Card ───────────────────────────────────────────────────

class _ContinueLearningCard extends StatelessWidget {
  final ContinueLearningModel data;

  const _ContinueLearningCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(data.courseTitle,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(data.currentModule, style: AppTextStyles.bodySM),
              Text('${(data.progress * 100).toInt()}%',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600,
                      color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: data.progress,
              backgroundColor: AppColors.progressBg,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MyLearningScreen()),
              ),
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }
}
