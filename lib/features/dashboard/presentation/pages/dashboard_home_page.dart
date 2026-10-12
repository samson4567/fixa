part of 'dashboard_map_page.dart';

class _ListingsDashboardPage extends StatefulWidget {
  const _ListingsDashboardPage();

  @override
  State<_ListingsDashboardPage> createState() => _ListingsDashboardPageState();
}

class _ListingsDashboardPageState extends State<_ListingsDashboardPage> {
  _ListingsDashboardPageState()
    : _propertyFeedCubit = getIt<PropertyFeedCubit>(),
      _propertyFavoriteCubit = getIt<PropertyFavoriteCubit>();

  final PropertyFeedCubit _propertyFeedCubit;
  final PropertyFavoriteCubit _propertyFavoriteCubit;
  final Set<String> _favoritePropertyIds = <String>{};
  int _selectedNavIndex = 0;
  int _selectedChipIndex = 0;
  String _dashboardSearchText = 'services, properties, or professionals';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPropertyFeed();
      if (!mounted || !_propertyFeedCubit.state.isLoading) return;
      AppLoadingOverlay.show(
        context,
        title: 'Preparing your home',
        subtitle: 'Loading the latest properties',
      );
    });
  }

  @override
  void dispose() {
    _propertyFeedCubit.close();
    _propertyFavoriteCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PropertyFeedCubit>.value(value: _propertyFeedCubit),
        BlocProvider<PropertyFavoriteCubit>.value(
          value: _propertyFavoriteCubit,
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<PropertyFeedCubit, PropertyFeedState>(
            listener: (context, state) {
              if (state.status != PropertyFeedStatus.loading) {
                AppLoadingOverlay.hide();
              }
            },
          ),
          BlocListener<PropertyFavoriteCubit, PropertyFavoriteState>(
            listener: (context, state) {
              if (state.status == PropertyFavoriteStatus.success &&
                  state.propertyId != null &&
                  state.isFavorite != null) {
                setState(() {
                  if (state.isFavorite == true) {
                    _favoritePropertyIds.add(state.propertyId!);
                  } else {
                    _favoritePropertyIds.remove(state.propertyId!);
                  }
                });
              }

              if (state.status == PropertyFavoriteStatus.failure &&
                  state.errorMessage != null &&
                  state.errorMessage!.trim().isNotEmpty) {
                showAppResponseModal(
                  context,
                  message: state.errorMessage!,
                  isError: true,
                );
              }

              if (state.status == PropertyFavoriteStatus.success &&
                  state.message != null &&
                  state.message!.trim().isNotEmpty) {
                showAppResponseModal(context, message: state.message!);
              }
            },
          ),
        ],
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.xl(context),
                    AppSpacing.lg(context),
                    AppSpacing.xl(context),
                    AppSpacing.md(context),
                  ),
                  child: _ListingsDashboardHeader(
                    onBack: () => Navigator.of(context).pop(),
                    onNotificationTap: _openNotificationPage,
                    onSearchTap: _openDashboardSearch,
                    searchText: _dashboardSearchText,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.xl(context),
                    0,
                    AppSpacing.xl(context),
                    AppSpacing.md(context),
                  ),
                  child: Row(
                    children: [
                      _DashboardFilterChip(
                        label: 'See all',
                        selected: _selectedChipIndex == 0,
                        onTap: () => _selectChip(0),
                      ),
                      SizedBox(width: AppSpacing.sm(context)),
                      _DashboardFilterChip(
                        label: 'For Sale',
                        selected: _selectedChipIndex == 1,
                        onTap: () => _selectChip(1),
                      ),
                      SizedBox(width: AppSpacing.sm(context)),
                      _DashboardFilterChip(
                        label: 'For Rent',
                        selected: _selectedChipIndex == 2,
                        onTap: () => _selectChip(2),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: AppScale.size(context, 42),
                        height: AppScale.size(context, 38),
                        child: IconButton(
                          onPressed: () {
                            Navigator.of(context).push<void>(
                              MaterialPageRoute<void>(
                                builder: (_) => const _MapFilterPage(
                                  initialFilter: _MapFilterResult(),
                                  homes: <_MapHome>[],
                                ),
                              ),
                            );
                          },
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppScale.radius(context, 12),
                              ),
                            ),
                          ),
                          icon: Icon(
                            Icons.filter_alt_outlined,
                            color: Colors.white,
                            size: AppSizes.iconMd(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: BlocBuilder<PropertyFeedCubit, PropertyFeedState>(
                    builder: (context, state) {
                      final sections =
                          state.result?.sections ??
                          const <PropertyFeedSection>[];
                      final populatedSections = sections
                          .where((section) => section.properties.isNotEmpty)
                          .toList();

                      if (state.isLoading && populatedSections.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      if (state.status == PropertyFeedStatus.failure &&
                          populatedSections.isEmpty) {
                        return _DashboardFeedErrorState(
                          message: state.errorMessage,
                          onRetry: () => _loadPropertyFeed(forceRefresh: true),
                        );
                      }

                      if (populatedSections.isEmpty) {
                        return const _DashboardFeedEmptyState();
                      }

                      final topSections = populatedSections.take(3).toList();
                      final moreListings = populatedSections
                          .skip(3)
                          .expand((section) => section.properties)
                          .map(_mapPropertyToListing)
                          .toList();

                      return RefreshIndicator(
                        onRefresh: () => _loadPropertyFeed(forceRefresh: true),
                        child: ListView(
                          padding: EdgeInsets.only(
                            top: AppSpacing.sm(context),
                            bottom: AppScale.size(context, 96),
                          ),
                          children: [
                            ...topSections.asMap().entries.map(
                              (entry) => _DashboardReveal(
                                key: ValueKey<String>(entry.value.title),
                                delay: Duration(milliseconds: entry.key * 90),
                                child: _ListingHorizontalSection(
                                  title: _dashboardSectionTitle(
                                    entry.value,
                                    isFirstSection: entry.key == 0,
                                  ),
                                  listings: entry.value.properties
                                      .map(_mapPropertyToListing)
                                      .toList(),
                                  onOpen: () => _openPopularApartments(
                                    context,
                                    entry.value,
                                  ),
                                  onListingTap: _openListingDetails,
                                  onFavoriteTap: _toggleFavorite,
                                ),
                              ),
                            ),
                            if (moreListings.isNotEmpty) ...[
                              const _MoreOnFixaDivider(),
                              ...moreListings.asMap().entries.map(
                                (entry) => _DashboardReveal(
                                  key: ValueKey<String>(
                                    entry.value.id ??
                                        '${entry.value.subtitle}-${entry.key}',
                                  ),
                                  delay: Duration(
                                    milliseconds:
                                        (entry.key > 4 ? 4 : entry.key) * 70,
                                  ),
                                  horizontalOffset: entry.key.isEven
                                      ? -0.035
                                      : 0.035,
                                  verticalOffset: 0.025,
                                  child: _LargeListingCard(
                                    listing: entry.value,
                                    onTap: () =>
                                        _openListingDetails(entry.value),
                                    onFavoriteTap: () =>
                                        _toggleFavorite(entry.value),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: _DashboardBottomNav(
            selectedIndex: _selectedNavIndex,
            onItemSelected: _handleBottomNavSelection,
          ),
        ),
      ),
    );
  }

  String? get _selectedType {
    if (_selectedChipIndex == 1) {
      return 'sale';
    }

    if (_selectedChipIndex == 2) {
      return 'rent';
    }

    return null;
  }

  String _dashboardSectionTitle(
    PropertyFeedSection section, {
    required bool isFirstSection,
  }) {
    if (!isFirstSection) {
      return section.title;
    }

    if (_selectedChipIndex == 1) {
      return 'Buy Homes Near You';
    }

    if (_selectedChipIndex == 2) {
      return 'Rental Homes Near You';
    }

    return section.title;
  }

  Future<void> _selectChip(int index) async {
    if (index == 0 || index == 2) {
      final hasAccess = await _showRentalUnlockModal(context);
      if (!hasAccess || !mounted) {
        return;
      }
    }

    if (_selectedChipIndex == index) {
      return;
    }

    setState(() {
      _selectedChipIndex = index;
    });
    _loadPropertyFeed();
  }

  Future<void> _loadPropertyFeed({bool forceRefresh = false}) {
    return _propertyFeedCubit.fetchPropertyFeed(
      type: _selectedType,
      page: 1,
      limit: 20,
      forceRefresh: forceRefresh,
    );
  }

  void _handleBottomNavSelection(int index) {
    if (index == 1) {
      AppLoadingOverlay.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (_) => const _DashboardFavoritesPage(),
        ),
        destinationKey: 'favorites',
      );
      return;
    }

    if (index == 0) {
      setState(() {
        _selectedNavIndex = index;
      });
      return;
    }

    if (index == 2) {
      AppLoadingOverlay.push<void>(
        context,
        MaterialPageRoute<void>(builder: (_) => const _DashboardProfilePage()),
        destinationKey: 'profile',
      );
      return;
    }

    setState(() {
      _selectedNavIndex = index;
    });
  }

  void _openPopularApartments(
    BuildContext context,
    PropertyFeedSection section,
  ) {
    final listings = section.properties.map(_mapPropertyToListing).toList();
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => _PopularApartmentsPage(
          title: section.title,
          listings: listings,
          onFavoriteTap: _toggleFavorite,
        ),
      ),
    );
  }

  _DashboardListing _mapPropertyToListing(PropertyFeedProperty property) {
    final locationParts = <String>[
      property.city,
      property.state,
    ].where((value) => value.trim().isNotEmpty).toList();
    final location = locationParts.isEmpty
        ? property.address
        : '${locationParts.join(', ')}.';
    final isRent = property.type.toLowerCase() == 'rent';

    return _DashboardListing(
      id: property.id,
      imagePath: property.images.isNotEmpty
          ? property.images.first
          : 'assets/icons/house.png',
      imageCount: property.images.length,
      price: '${_formatNaira(property.price)}${isRent ? '/mo' : ''}',
      location: location,
      tag: isRent ? 'Rental' : 'For Sale',
      subtitle: property.title,
      description: property.description,
      address: property.address,
      bedrooms: property.bedrooms,
      bathrooms: property.bathrooms,
      listingType: property.type,
      category: property.category,
      isFavorite: _favoritePropertyIds.contains(property.id),
    );
  }

  String _formatNaira(int value) {
    final text = value.toString();
    final withCommas = text.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
    return '₦$withCommas';
  }

  Future<void> _toggleFavorite(_DashboardListing listing) async {
    final propertyId = listing.id?.trim();
    if (propertyId == null || propertyId.isEmpty) {
      showAppResponseModal(
        context,
        message: 'Property ID is unavailable.',
        isError: true,
      );
      return;
    }

    final nextState = !_favoritePropertyIds.contains(propertyId);
    await _propertyFavoriteCubit.setFavorite(
      propertyId: propertyId,
      isFavorite: nextState,
    );
  }

  Future<void> _openListingDetails(_DashboardListing listing) async {
    if (_isRentalListing(listing)) {
      final hasAccess = await _showRentalUnlockModal(context);
      if (!hasAccess || !mounted) {
        return;
      }
    }

    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => _PropertyDetailPage(
          listing: listing,
          onFavoriteChanged: (propertyId, isFavorite) {
            setState(() {
              if (isFavorite) {
                _favoritePropertyIds.add(propertyId);
              } else {
                _favoritePropertyIds.remove(propertyId);
              }
            });
          },
        ),
      ),
    );
  }

  bool _isRentalListing(_DashboardListing listing) {
    final type = listing.listingType?.trim().toLowerCase() ?? '';
    final tag = listing.tag.trim().toLowerCase();

    return type.contains('rent') || tag.contains('rental');
  }

  Future<void> _openDashboardSearch() async {
    final result = await Navigator.of(context).push<_MapSearchResult>(
      MaterialPageRoute<_MapSearchResult>(
        builder: (_) => _MapSearchPage(initialQuery: _dashboardSearchText),
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    final selection = result.useCurrentLocation
        ? 'Current location'
        : result.query.trim();
    if (selection.isEmpty) {
      return;
    }

    setState(() {
      _dashboardSearchText = selection;
    });
  }

  Future<void> _openNotificationPage() {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const _NotificationCenterPage()),
    );
  }
}

class _ListingsDashboardHeader extends StatelessWidget {
  const _ListingsDashboardHeader({
    required this.onBack,
    required this.onNotificationTap,
    required this.onSearchTap,
    required this.searchText,
  });

  final VoidCallback onBack;
  final VoidCallback onNotificationTap;
  final VoidCallback onSearchTap;
  final String searchText;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _HeaderRoundButton(
          assetPath: 'assets/icons/notification-2.svg',
          onTap: onNotificationTap,
        ),
        SizedBox(width: AppSpacing.md(context)),
        Expanded(
          child: Container(
            height: AppScale.size(context, 52),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                AppScale.radius(context, 999),
              ),
              border: Border.all(color: const Color(0xFFE4E4E4)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.14),
                  blurRadius: 12,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(
                AppScale.radius(context, 999),
              ),
              child: InkWell(
                onTap: onSearchTap,
                borderRadius: BorderRadius.circular(
                  AppScale.radius(context, 999),
                ),
                child: Row(
                  children: [
                    SizedBox(width: AppSpacing.lg(context)),
                    Icon(
                      Icons.search,
                      color: const Color(0xFF5F6260),
                      size: AppSizes.iconMd(context),
                    ),
                    SizedBox(width: AppSpacing.md(context)),
                    Expanded(
                      child: Text(
                        searchText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.authBody.copyWith(
                          color: const Color(0xFFB8B8B8),
                          fontSize: AppScale.text(context, 16),
                          fontWeight: FontWeight.w400,
                          height: 1.2,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                    SizedBox(width: AppSpacing.md(context)),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: AppSpacing.md(context)),
        _HeaderRoundButton(icon: Icons.map_outlined, onTap: onBack),
      ],
    );
  }
}

class _HeaderRoundButton extends StatelessWidget {
  const _HeaderRoundButton({required this.onTap, this.icon, this.assetPath})
    : assert(icon != null || assetPath != null);

  final VoidCallback onTap;
  final IconData? icon;
  final String? assetPath;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: AppScale.size(context, 40),
          height: AppScale.size(context, 40),
          child: Center(
            child: assetPath != null
                ? SvgPicture.asset(
                    assetPath!,
                    width: AppSizes.iconSm(context),
                    height: AppSizes.iconSm(context),
                    colorFilter: const ColorFilter.mode(
                      AppColors.authText,
                      BlendMode.srcIn,
                    ),
                  )
                : Icon(
                    icon,
                    color: AppColors.authText,
                    size: AppSizes.iconMd(context),
                  ),
          ),
        ),
      ),
    );
  }
}

class _DashboardFilterChip extends StatelessWidget {
  const _DashboardFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? Colors.white : AppColors.ink;

    return Material(
      color: selected ? AppColors.ink : Colors.white,
      borderRadius: BorderRadius.circular(AppScale.radius(context, 999)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppScale.radius(context, 999)),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          height: AppScale.size(context, 36),
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md(context)),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppScale.radius(context, 999)),
            border: Border.all(
              color: selected ? AppColors.ink : const Color(0xFFE1E6DE),
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.ink.withValues(alpha: 0.16),
                      blurRadius: 14,
                      offset: const Offset(0, 7),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: AppTypography.authBody.copyWith(
              color: foreground,
              fontSize: AppScale.text(context, 12),
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              height: 1.2,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }
}

class _ListingHorizontalSection extends StatelessWidget {
  const _ListingHorizontalSection({
    required this.title,
    required this.listings,
    required this.onOpen,
    required this.onListingTap,
    required this.onFavoriteTap,
  });

  final String title;
  final List<_DashboardListing> listings;
  final VoidCallback onOpen;
  final ValueChanged<_DashboardListing> onListingTap;
  final ValueChanged<_DashboardListing> onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.section(context)),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl(context)),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.authBody.copyWith(
                      color: AppColors.authText,
                      fontSize: AppScale.text(context, 19),
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                _SectionArrowButton(onTap: onOpen),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.md(context)),
          SizedBox(
            height: AppScale.size(context, 286),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl(context)),
              itemCount: listings.length,
              separatorBuilder: (_, _) =>
                  SizedBox(width: AppSpacing.md(context)),
              itemBuilder: (context, index) => _DashboardReveal(
                key: ValueKey<String>(
                  listings[index].id ?? '${listings[index].subtitle}-$index',
                ),
                delay: Duration(milliseconds: (index > 5 ? 5 : index) * 65),
                horizontalOffset: 0.08,
                verticalOffset: 0,
                child: _SmallListingCard(
                  listing: listings[index],
                  onTap: () => onListingTap(listings[index]),
                  onFavoriteTap: () => onFavoriteTap(listings[index]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardReveal extends StatefulWidget {
  const _DashboardReveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.horizontalOffset = 0,
    this.verticalOffset = 0.045,
  });

  final Widget child;
  final Duration delay;
  final double horizontalOffset;
  final double verticalOffset;

  @override
  State<_DashboardReveal> createState() => _DashboardRevealState();
}

class _DashboardRevealState extends State<_DashboardReveal> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(widget.delay, () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: _visible
          ? Offset.zero
          : Offset(widget.horizontalOffset, widget.verticalOffset),
      duration: const Duration(milliseconds: 460),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: _visible ? 1 : 0,
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeOut,
        child: AnimatedScale(
          scale: _visible ? 1 : 0.965,
          duration: const Duration(milliseconds: 520),
          curve: Curves.easeOutBack,
          child: widget.child,
        ),
      ),
    );
  }
}

class _SectionArrowButton extends StatelessWidget {
  const _SectionArrowButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: AppScale.size(context, 34),
        height: AppScale.size(context, 34),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE1E6DE)),
        ),
        child: Icon(
          Icons.arrow_forward_rounded,
          color: AppColors.ink,
          size: AppSizes.iconMd(context),
        ),
      ),
    );
  }
}

class _SmallListingCard extends StatelessWidget {
  const _SmallListingCard({
    required this.listing,
    required this.onTap,
    required this.onFavoriteTap,
  });

  final _DashboardListing listing;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppScale.size(context, 180),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(AppScale.radius(context, 16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: AppScale.size(context, 180),
              height: AppScale.size(context, 180),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  AppScale.radius(context, 16),
                ),
                border: Border.all(color: const Color(0xFFE8ECE8)),
              ),
              child: _ListingImageFrame(
                imagePath: listing.imagePath,
                imageCount: listing.imageCount,
                showFavorite: true,
                isFavorite: listing.isFavorite,
                borderRadius: 16,
                onFavoriteTap: onFavoriteTap,
              ),
            ),
            SizedBox(height: AppSpacing.sm(context)),
            Text(
              listing.subtitle ?? listing.location,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.authBody.copyWith(
                color: AppColors.authText,
                fontSize: AppScale.text(context, 13),
                fontWeight: FontWeight.w500,
                height: 1.4,
                letterSpacing: 0,
              ),
            ),
            SizedBox(height: AppSpacing.xs(context)),
            _ListingPrice(price: listing.price, compact: true),
            SizedBox(height: AppSpacing.xs(context)),
            Text(
              listing.location,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.authBody.copyWith(
                color: AppColors.mutedInk,
                fontSize: AppScale.text(context, 11),
                fontWeight: FontWeight.w500,
                height: 1.35,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LargeListingCard extends StatelessWidget {
  const _LargeListingCard({
    required this.listing,
    required this.onTap,
    required this.onFavoriteTap,
  });

  final _DashboardListing listing;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl(context),
        0,
        AppSpacing.xl(context),
        AppSpacing.xxl(context),
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppScale.radius(context, 18)),
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          borderRadius: BorderRadius.circular(AppScale.radius(context, 18)),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.xs(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: AppScale.size(context, 238),
                  child: _ListingImageFrame(
                    imagePath: listing.imagePath,
                    tag: listing.tag,
                    imageCount: listing.imageCount,
                    showFavorite: true,
                    showDots: true,
                    isFavorite: listing.isFavorite,
                    onFavoriteTap: onFavoriteTap,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(AppSpacing.sm(context)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ListingPrice(price: listing.price),
                      SizedBox(height: AppSpacing.xs(context)),
                      Text(
                        listing.subtitle ?? '2 Plots of land at Adron Estate',
                        style: AppTypography.authBody.copyWith(
                          color: AppColors.mutedInk,
                          fontSize: AppScale.text(context, 13),
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                          letterSpacing: 0,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs(context)),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: AppColors.ink,
                            size: AppSizes.iconSm(context),
                          ),
                          SizedBox(width: AppSpacing.xs(context)),
                          Expanded(
                            child: Text(
                              listing.location,
                              style: AppTypography.authBody.copyWith(
                                color: AppColors.mutedInk,
                                fontSize: AppScale.text(context, 13),
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                                letterSpacing: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MoreOnFixaDivider extends StatelessWidget {
  const _MoreOnFixaDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl(context),
        0,
        AppSpacing.xl(context),
        AppSpacing.xl(context),
      ),
      child: Row(
        children: [
          const Expanded(child: Divider(color: Color(0xFFE2E2E2))),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md(context)),
            child: Text(
              'More on AMASS',
              style: AppTypography.authBody.copyWith(
                color: const Color(0xFFB4B4B4),
                fontSize: AppScale.text(context, 12),
                fontWeight: FontWeight.w400,
                height: 1.4,
                letterSpacing: 0,
              ),
            ),
          ),
          const Expanded(child: Divider(color: Color(0xFFE2E2E2))),
        ],
      ),
    );
  }
}

class _ListingImageFrame extends StatelessWidget {
  const _ListingImageFrame({
    required this.imagePath,
    this.imageCount = 1,
    required this.showFavorite,
    required this.isFavorite,
    this.tag,
    this.showDots = false,
    this.onFavoriteTap,
    this.borderRadius = 14,
  });

  final String imagePath;
  final int imageCount;
  final bool showFavorite;
  final bool isFavorite;
  final String? tag;
  final bool showDots;
  final VoidCallback? onFavoriteTap;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final dotCount = imageCount.clamp(1, 5);

    return ClipRRect(
      borderRadius: BorderRadius.circular(
        AppScale.radius(context, borderRadius),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _DashboardListingImage(path: imagePath),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x33000000),
                  Color(0x00000000),
                  Color(0x22000000),
                ],
              ),
            ),
          ),
          if (tag != null)
            Positioned(
              left: AppSpacing.md(context),
              top: AppSpacing.md(context),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm(context),
                  vertical: AppSpacing.xs(context),
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(
                    AppScale.radius(context, 999),
                  ),
                ),
                child: Text(
                  tag!,
                  style: AppTypography.authBody.copyWith(
                    color: Colors.black,
                    fontSize: AppScale.text(context, 10),
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
          if (showFavorite)
            Positioned(
              right: AppSpacing.sm(context),
              top: AppSpacing.sm(context),
              child: Container(
                width: AppScale.size(context, 36),
                height: AppScale.size(context, 36),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.26),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.46),
                  ),
                ),
                child: IconButton(
                  onPressed: onFavoriteTap,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: Colors.white,
                    shadows: const [
                      Shadow(color: Colors.black54, blurRadius: 4),
                    ],
                    size: AppSizes.iconMd(context),
                  ),
                ),
              ),
            ),
          if (showDots && dotCount > 1)
            Positioned(
              bottom: AppSpacing.sm(context),
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  dotCount,
                  (index) => Container(
                    width: AppScale.size(context, 6),
                    height: AppScale.size(context, 6),
                    margin: EdgeInsets.symmetric(
                      horizontal: AppSpacing.xxs(context),
                    ),
                    decoration: BoxDecoration(
                      color: index == 1
                          ? AppColors.primary
                          : Colors.white.withValues(alpha: 0.82),
                      shape: BoxShape.circle,
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

class _DashboardListingImage extends StatelessWidget {
  const _DashboardListingImage({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(color: const Color(0xFFEDEDED)),
      );
    }

    if (path.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(path, fit: BoxFit.cover);
    }

    return Image.asset(path, fit: BoxFit.cover);
  }
}

class _ListingPrice extends StatelessWidget {
  const _ListingPrice({required this.price, this.compact = false});

  final String price;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.local_offer,
          color: AppColors.primary,
          size: compact ? AppScale.size(context, 14) : AppSizes.iconSm(context),
        ),
        SizedBox(width: AppSpacing.xs(context)),
        Expanded(
          child: Text(
            price,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.authBody.copyWith(
              color: Colors.black,
              fontSize: AppScale.text(context, compact ? 12 : 16),
              fontWeight: FontWeight.w700,
              height: 1.4,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
}

class _PopularApartmentsPage extends StatelessWidget {
  const _PopularApartmentsPage({
    required this.title,
    required this.listings,
    required this.onFavoriteTap,
  });

  final String title;
  final List<_DashboardListing> listings;
  final ValueChanged<_DashboardListing> onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.xl(context),
                AppSpacing.lg(context),
                AppSpacing.xl(context),
                AppSpacing.lg(context),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints.tight(
                      Size(
                        AppSizes.interactiveTouchTarget(context),
                        AppSizes.interactiveTouchTarget(context),
                      ),
                    ),
                    icon: Icon(
                      Icons.arrow_back,
                      size: AppSizes.iconLg(context),
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm(context)),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.authBody.copyWith(
                        color: Colors.black,
                        fontSize: AppScale.text(context, 17),
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.only(bottom: AppSpacing.xxl(context)),
                children: listings
                    .map(
                      (listing) => _LargeListingCard(
                        listing: listing,
                        onTap: () {
                          Navigator.of(context).push<void>(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  _PropertyDetailPage(listing: listing),
                            ),
                          );
                        },
                        onFavoriteTap: () => onFavoriteTap(listing),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardListing {
  const _DashboardListing({
    this.id,
    required this.imagePath,
    this.imageCount = 1,
    required this.price,
    required this.location,
    required this.tag,
    this.subtitle,
    this.description,
    this.address,
    this.bedrooms,
    this.bathrooms,
    this.listingType,
    this.category,
    this.isFavorite = false,
  });

  final String? id;
  final String imagePath;
  final int imageCount;
  final String price;
  final String location;
  final String tag;
  final String? subtitle;
  final String? description;
  final String? address;
  final int? bedrooms;
  final int? bathrooms;
  final String? listingType;
  final String? category;
  final bool isFavorite;
}

class _DashboardFeedErrorState extends StatelessWidget {
  const _DashboardFeedErrorState({required this.onRetry, this.message});

  final VoidCallback onRetry;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl(context)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message ?? 'Unable to load properties right now.',
              textAlign: TextAlign.center,
              style: AppTypography.authBody.copyWith(
                color: Colors.black,
                fontSize: AppScale.text(context, 14),
                fontWeight: FontWeight.w400,
                height: 1.4,
                letterSpacing: 0,
              ),
            ),
            SizedBox(height: AppSpacing.md(context)),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardFeedEmptyState extends StatelessWidget {
  const _DashboardFeedEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl(context)),
        child: Text(
          'No properties found for this filter.',
          textAlign: TextAlign.center,
          style: AppTypography.authBody.copyWith(
            color: Colors.black,
            fontSize: AppScale.text(context, 14),
            fontWeight: FontWeight.w400,
            height: 1.4,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}
