import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/portal_store.dart';
import '../../bloc/home_bloc.dart';
import '../../data/models/home_models.dart';
import '../../data/repositories/home_repository.dart';
import '../../../career/presentation/screens/career_path_detail_screen.dart';
import '../../../checkout/presentation/screens/checkout_screen.dart';
import '../../../internship/presentation/screens/internship_detail_screen.dart';
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

  final List<Widget> _pages = const [
    _HomeTab(),
    WishlistScreen(),
    MyLearningScreen(),
    NotificationsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: _AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

class _AppBottomNav extends StatelessWidget {
  const _AppBottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final items = <_NavItemData>[
      const _NavItemData(
        label: 'Home',
        activeIcon: Icons.home_rounded,
        inactiveIcon: Icons.home_outlined,
      ),
      const _NavItemData(
        label: 'Wish list',
        activeIcon: Icons.favorite_rounded,
        inactiveIcon: Icons.favorite_outline,
      ),
      const _NavItemData(
        label: 'My Learning',
        activeIcon: Icons.play_circle_rounded,
        inactiveIcon: Icons.play_circle_outline,
      ),
      const _NavItemData(
        label: 'Notifications',
        activeIcon: Icons.notifications_rounded,
        inactiveIcon: Icons.notifications_outlined,
      ),
      const _NavItemData(
        label: 'Profile',
        activeIcon: Icons.person_rounded,
        inactiveIcon: Icons.person_outline,
      ),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 8, 6, 10),
          child: Row(
            children: List.generate(
              items.length,
              (index) => Expanded(
                child: _NavItem(
                  data: items[index],
                  isActive: currentIndex == index,
                  onTap: () => onTap(index),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  const _NavItemData({
    required this.label,
    required this.activeIcon,
    required this.inactiveIcon,
  });

  final String label;
  final IconData activeIcon;
  final IconData inactiveIcon;
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.data,
    required this.isActive,
    required this.onTap,
  });

  final _NavItemData data;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primary : AppColors.bottomNavInactive;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? data.activeIcon : data.inactiveIcon,
              size: 21,
              color: color,
            ),
            const SizedBox(height: 4),
            Text(
              data.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  late final HomeBloc _homeBloc;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _homeBloc = HomeBloc(homeRepository: HomeRepositoryImpl())
      ..add(const HomeDataLoaded());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _homeBloc.close();
    super.dispose();
  }

  void _openCart(BuildContext context) {
    final cartItems = PortalStore.instance.state.value.cartItems;
    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty.')),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CheckoutScreen(programs: cartItems)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _homeBloc,
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          final loadedState = state is HomeLoaded ? state : null;

          return Scaffold(
            backgroundColor: AppColors.background,
            body: Column(
              children: [
                _HomeHeader(
                  userName: loadedState?.userName ?? 'Learner',
                  onCartTap: () => _openCart(context),
                ),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      if (state is HomeLoading && loadedState == null) {
                        return const Center(
                          child: CircularProgressIndicator(color: AppColors.primary),
                        );
                      }

                      if (state is HomeError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              state.message,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyMD,
                            ),
                          ),
                        );
                      }

                      if (loadedState == null) {
                        return const SizedBox.shrink();
                      }

                      return _HomeLoadedBody(
                        state: loadedState,
                        searchController: _searchController,
                        onSearchChanged: (query) {
                          _homeBloc.add(
                            HomeSearchChanged(
                              query: query,
                              type: loadedState.activeTab,
                            ),
                          );
                        },
                        onTabSelected: (tab) {
                          if (loadedState.activeTab != tab) {
                            _homeBloc.add(HomeTabChanged(tab: tab));
                          }
                        },
                      );
                    },
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

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.userName,
    required this.onCartTap,
  });

  final String userName;
  final VoidCallback onCartTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Hello $userName \u{1F44B}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            ValueListenableBuilder<PortalState>(
              valueListenable: PortalStore.instance.state,
              builder: (context, portalState, _) {
                final cartCount = portalState.cartCount;
                return InkWell(
                  onTap: onCartTap,
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.shopping_cart_checkout_outlined,
                          size: 22,
                          color: Colors.white,
                        ),
                      ),
                      if (cartCount > 0)
                        Positioned(
                          right: -6,
                          top: -4,
                          child: Container(
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(
                              '$cartCount',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeLoadedBody extends StatelessWidget {
  const _HomeLoadedBody({
    required this.state,
    required this.searchController,
    required this.onSearchChanged,
    required this.onTabSelected,
  });

  final HomeLoaded state;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
      children: [
        _SearchBar(
          controller: searchController,
          hint: state.activeTab == 'courses'
              ? 'Search courses'
              : 'Search internships',
          onChanged: onSearchChanged,
        ),
        const SizedBox(height: 14),
        _HomeTabs(
          activeTab: state.activeTab,
          onTabSelected: onTabSelected,
        ),
        const SizedBox(height: 16),
        _ProgramsGrid(
          items: state.items,
        ),
        const SizedBox(height: 22),
        Text('Career Paths', style: AppTextStyles.headingSM),
        const SizedBox(height: 12),
        SizedBox(
          height: 164,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: state.careerPaths.length,
            separatorBuilder: (_, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) => _CareerPathCard(
              career: state.careerPaths[index],
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CareerPathDetailScreen(
                    careerId: state.careerPaths[index].id,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text('Continue Learning', style: AppTextStyles.headingSM),
        const SizedBox(height: 12),
        if (state.continueLearning != null)
          _ContinueLearningCard(data: state.continueLearning!),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFD),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFDEE6F0)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 11),
          const Icon(
            Icons.search_rounded,
            size: 18,
            color: AppColors.textHint,
          ),
          const SizedBox(width: 7),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textAlignVertical: TextAlignVertical.center,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                isCollapsed: true,
                hintText: hint,
                hintStyle: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textHint,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 160),
            child: controller.text.isNotEmpty
                ? InkWell(
                    key: const ValueKey('clear-search'),
                    onTap: () {
                      controller.clear();
                      onChanged('');
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding: EdgeInsets.all(9),
                      child: Icon(
                        Icons.close_rounded,
                        size: 15,
                        color: AppColors.textHint,
                      ),
                    ),
                  )
                : const SizedBox(
                    key: ValueKey('search-spacer'),
                    width: 11,
                  ),
          ),
        ],
      ),
    );
  }
}

class _HomeTabs extends StatelessWidget {
  const _HomeTabs({
    required this.activeTab,
    required this.onTabSelected,
  });

  final String activeTab;
  final ValueChanged<String> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _HomeTabButton(
              label: 'Internships',
              isActive: activeTab == 'internships',
              onTap: () => onTabSelected('internships'),
            ),
          ),
          Expanded(
            child: _HomeTabButton(
              label: 'Courses',
              isActive: activeTab == 'courses',
              onTap: () => onTabSelected('courses'),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeTabButton extends StatelessWidget {
  const _HomeTabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ),
          Container(
            height: 3,
            color: isActive ? AppColors.primary : Colors.transparent,
          ),
        ],
      ),
    );
  }
}

class _ProgramsGrid extends StatelessWidget {
  const _ProgramsGrid({required this.items});

  final List<InternshipModel> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth < 320 ? 1 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            mainAxisExtent: 214,
          ),
          itemBuilder: (context, index) => _ProgramCard(
            item: items[index],
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    InternshipDetailScreen(internshipId: items[index].id),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProgramCard extends StatelessWidget {
  const _ProgramCard({
    required this.item,
    required this.onTap,
  });

  final InternshipModel item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F0A0F5C),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 82,
                width: double.infinity,
                child: _ProgramArtwork(title: item.title),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Text(
                item.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11.5,
                  height: 1.4,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 32,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text(
                  'View Details',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgramArtwork extends StatelessWidget {
  const _ProgramArtwork({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final isBioinformatics = title.toLowerCase().contains('bio');

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isBioinformatics
              ? const [Color(0xFFDDF2FF), Color(0xFFEFF8FF)]
              : const [Color(0xFFD7ECFF), Color(0xFFEDF7FF)],
        ),
      ),
      child: isBioinformatics
          ? Stack(
              children: [
                const Positioned.fill(
                  child: Center(
                    child: Icon(
                      Icons.biotech_outlined,
                      size: 46,
                      color: Color(0xFF3A7FC9),
                    ),
                  ),
                ),
                for (final offset in const [-26.0, -10.0, 10.0, 26.0])
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 41 + offset,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 28),
                      height: 1.2,
                      color: const Color(0xFF9ED0F7),
                    ),
                  ),
              ],
            )
          : Stack(
              children: const [
                Positioned(
                  top: 18,
                  left: 22,
                  child: Icon(
                    Icons.folder_shared_outlined,
                    size: 20,
                    color: Color(0xFF3A7FC9),
                  ),
                ),
                Positioned(
                  top: 18,
                  right: 24,
                  child: Icon(
                    Icons.verified_user_outlined,
                    size: 20,
                    color: Color(0xFF3A7FC9),
                  ),
                ),
                Positioned(
                  bottom: 18,
                  left: 20,
                  child: Icon(
                    Icons.medical_information_outlined,
                    size: 22,
                    color: Color(0xFF3A7FC9),
                  ),
                ),
                Positioned(
                  bottom: 18,
                  right: 22,
                  child: Icon(
                    Icons.monitor_heart_outlined,
                    size: 22,
                    color: Color(0xFF3A7FC9),
                  ),
                ),
                Center(
                  child: Icon(
                    Icons.shield_outlined,
                    size: 40,
                    color: Color(0xFF3A7FC9),
                  ),
                ),
              ],
            ),
    );
  }
}

class _CareerPathCard extends StatelessWidget {
  const _CareerPathCard({
    required this.career,
    required this.onTap,
  });

  final CareerPathModel career;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isBio = career.title.toLowerCase().contains('bio');
    return Container(
      width: 172,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5FAFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDCE9F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFF8DD2FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isBio ? Icons.biotech_outlined : Icons.medical_services_outlined,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            career.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Text(
              career.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                height: 1.35,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: onTap,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Explore Path',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 6),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 11,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContinueLearningCard extends StatelessWidget {
  const _ContinueLearningCard({required this.data});

  final ContinueLearningModel data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.courseTitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  data.currentModule,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${(data.progress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: data.progress,
              minHeight: 6,
              backgroundColor: const Color(0xFFDCEBFB),
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 88,
              height: 34,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MyLearningScreen()),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: EdgeInsets.zero,
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
