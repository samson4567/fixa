part of 'dashboard_map_page.dart';

enum _FavoriteFilter { all, rentals, forSale, shortLets }

class _DashboardFavoritesPage extends StatefulWidget {
  const _DashboardFavoritesPage();

  @override
  State<_DashboardFavoritesPage> createState() =>
      _DashboardFavoritesPageState();
}

class _DashboardFavoritesPageState extends State<_DashboardFavoritesPage> {
  _DashboardFavoritesPageState()
    : _propertyFavoritesCubit = getIt<PropertyFavoritesCubit>(),
      _propertyFavoriteCubit = getIt<PropertyFavoriteCubit>();

  final PropertyFavoritesCubit _propertyFavoritesCubit;
  final PropertyFavoriteCubit _propertyFavoriteCubit;
  _FavoriteFilter _selectedFilter = _FavoriteFilter.all;

  @override
  void initState() {
    super.initState();
    _propertyFavoritesCubit.fetchFavorites();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_propertyFavoritesCubit.state.isLoading) return;
      AppLoadingOverlay.show(
        context,
        title: 'Opening your favorites',
        subtitle: 'Loading your saved properties',
      );
    });
  }

  @override
  void dispose() {
    _propertyFavoritesCubit.close();
    _propertyFavoriteCubit.close();
    super.dispose();
  }

  List<_FavoriteListing> _visibleFavorites(List<_FavoriteListing> favorites) {
    if (_selectedFilter == _FavoriteFilter.all) {
      return favorites;
    }

    return favorites
        .where((listing) => listing.filter == _selectedFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PropertyFavoritesCubit>.value(
          value: _propertyFavoritesCubit,
        ),
        BlocProvider<PropertyFavoriteCubit>.value(
          value: _propertyFavoriteCubit,
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<PropertyFavoritesCubit, PropertyFavoritesState>(
            listener: (context, state) {
              if (state.status != PropertyFavoritesStatus.loading) {
                AppLoadingOverlay.hide();
              }
            },
          ),
          BlocListener<PropertyFavoriteCubit, PropertyFavoriteState>(
            listener: (context, state) {
              if (state.status == PropertyFavoriteStatus.success &&
                  state.isFavorite == false) {
                _propertyFavoritesCubit.fetchFavorites(forceRefresh: true);
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
            },
          ),
        ],
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: AppScale.size(context, 28)),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl(context),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Favorite',
                        style: AppTypography.authBody.copyWith(
                          color: AppColors.authText,
                          fontSize: AppScale.text(context, 33),
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.lg(context)),
                SizedBox(
                  height: AppScale.size(context, 42),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl(context),
                    ),
                    children: [
                      _FavoriteFilterChip(
                        label: 'All favorite',
                        selected: _selectedFilter == _FavoriteFilter.all,
                        onTap: () => _selectFilter(_FavoriteFilter.all),
                      ),
                      _FavoriteFilterChip(
                        label: 'Rentals',
                        selected: _selectedFilter == _FavoriteFilter.rentals,
                        onTap: () => _selectFilter(_FavoriteFilter.rentals),
                      ),
                      _FavoriteFilterChip(
                        label: 'For sale',
                        selected: _selectedFilter == _FavoriteFilter.forSale,
                        onTap: () => _selectFilter(_FavoriteFilter.forSale),
                      ),
                      _FavoriteFilterChip(
                        label: 'Short-lets',
                        selected: _selectedFilter == _FavoriteFilter.shortLets,
                        onTap: () => _selectFilter(_FavoriteFilter.shortLets),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.lg(context)),
                Expanded(
                  child:
                      BlocBuilder<
                        PropertyFavoritesCubit,
                        PropertyFavoritesState
                      >(
                        builder: (context, state) {
                          final favorites = state.properties
                              .map(_mapPropertyToFavoriteListing)
                              .toList();
                          final visibleFavorites = _visibleFavorites(favorites);

                          if (state.isLoading && favorites.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          if (state.status == PropertyFavoritesStatus.failure &&
                              favorites.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppSpacing.xl(context),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      state.errorMessage ??
                                          'Unable to load favorites right now.',
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
                                      onPressed: () => _propertyFavoritesCubit
                                          .fetchFavorites(forceRefresh: true),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                      ),
                                      child: const Text('Retry'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          if (visibleFavorites.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppSpacing.xl(context),
                                ),
                                child: Text(
                                  'No favorites found for this filter.',
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

                          return RefreshIndicator(
                            onRefresh: () => _propertyFavoritesCubit
                                .fetchFavorites(forceRefresh: true),
                            child: ListView.separated(
                              padding: EdgeInsets.fromLTRB(
                                AppSpacing.xl(context),
                                0,
                                AppSpacing.xl(context),
                                AppScale.size(context, 118),
                              ),
                              itemCount: visibleFavorites.length,
                              separatorBuilder: (_, _) =>
                                  SizedBox(height: AppSpacing.xl(context)),
                              itemBuilder: (context, index) {
                                final listing = visibleFavorites[index];
                                return _FavoriteListingCard(
                                  listing: listing,
                                  onTap: () => _openDetails(listing),
                                  onRemoveFavorite: () => _removeFavorite(
                                    listing.dashboardListing.id,
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: _DashboardBottomNav(
            selectedIndex: 1,
            onItemSelected: _handleBottomNavSelection,
          ),
        ),
      ),
    );
  }

  Future<void> _removeFavorite(String? propertyId) async {
    final id = propertyId?.trim();
    if (id == null || id.isEmpty) {
      showAppResponseModal(
        context,
        message: 'Property ID is unavailable.',
        isError: true,
      );
      return;
    }

    await _propertyFavoriteCubit.setFavorite(propertyId: id, isFavorite: false);
  }

  _FavoriteListing _mapPropertyToFavoriteListing(
    PropertyFeedProperty property,
  ) {
    final isRent = property.type.toLowerCase().contains('rent');
    final isShortLet = property.type.toLowerCase().contains('short');

    final status = isShortLet
        ? 'Short-lets'
        : (isRent ? 'Rentals' : 'For sale');
    final filter = isShortLet
        ? _FavoriteFilter.shortLets
        : (isRent ? _FavoriteFilter.rentals : _FavoriteFilter.forSale);
    final locationParts = <String>[
      property.city,
      property.state,
    ].where((value) => value.trim().isNotEmpty).toList();
    final location = locationParts.isEmpty
        ? property.address
        : '${locationParts.join(', ')}.';

    return _FavoriteListing(
      imagePath: property.images.isNotEmpty
          ? property.images.first
          : 'assets/icons/house.png',
      imageCount: property.images.length,
      status: status,
      title: property.title,
      price: _formatPrice(property.price, isRent: isRent),
      location: location,
      specs: '${property.bedrooms} bd . ${property.bathrooms}ba',
      filter: filter,
      dashboardListing: _DashboardListing(
        id: property.id,
        imagePath: property.images.isNotEmpty
            ? property.images.first
            : 'assets/icons/house.png',
        imageCount: property.images.length,
        price: _formatPrice(property.price, isRent: isRent),
        location: location,
        tag: isRent ? 'Rental' : 'For Sale',
        subtitle: property.title,
        description: property.description,
        address: property.address,
        bedrooms: property.bedrooms,
        bathrooms: property.bathrooms,
        listingType: property.type,
        category: property.category,
        isFavorite: true,
      ),
    );
  }

  String _formatPrice(int value, {required bool isRent}) {
    final text = value.toString();
    final withCommas = text.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
    return 'NGN$withCommas${isRent ? '/mo' : ''}';
  }

  void _selectFilter(_FavoriteFilter filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  void _handleBottomNavSelection(int index) {
    if (index == 0) {
      AppLoadingOverlay.replace<void, void>(
        context,
        MaterialPageRoute<void>(builder: (_) => const _ListingsDashboardPage()),
        destinationKey: 'home',
      );
      return;
    }

    if (index == 1) {
      return;
    }

    if (index == 2) {
      AppLoadingOverlay.replace<void, void>(
        context,
        MaterialPageRoute<void>(builder: (_) => const _DashboardProfilePage()),
        destinationKey: 'profile',
      );
    }
  }

  void _openDetails(_FavoriteListing favorite) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => _PropertyDetailPage(listing: favorite.dashboardListing),
      ),
    );
  }
}

class _FavoriteFilterChip extends StatelessWidget {
  const _FavoriteFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: AppSpacing.sm(context)),
      child: Material(
        color: selected ? AppColors.ink : const Color(0xFFEDEDED),
        borderRadius: BorderRadius.circular(AppScale.radius(context, 999)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppScale.radius(context, 999)),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            height: AppScale.size(context, 38),
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg(context)),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                AppScale.radius(context, 999),
              ),
              border: Border.all(
                color: selected ? AppColors.ink : const Color(0xFFEDEDED),
              ),
            ),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.authBody.copyWith(
                color: selected ? Colors.white : AppColors.ink,
                fontSize: AppScale.text(context, 13),
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                height: 1.2,
                letterSpacing: 0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FavoriteListingCard extends StatelessWidget {
  const _FavoriteListingCard({
    required this.listing,
    required this.onTap,
    required this.onRemoveFavorite,
    this.showFavoriteButton = true,
  });

  final _FavoriteListing listing;
  final VoidCallback onTap;
  final VoidCallback onRemoveFavorite;
  final bool showFavoriteButton;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppScale.radius(context, 16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: AppScale.size(context, 280),
            child: _FavoriteImageFrame(
              imagePath: listing.imagePath,
              imageCount: listing.imageCount,
              showFavoriteButton: showFavoriteButton,
              onRemoveFavorite: onRemoveFavorite,
            ),
          ),
          SizedBox(height: AppSpacing.sm(context)),
          _FavoriteStatusChip(label: listing.status),
          SizedBox(height: AppSpacing.xs(context)),
          Text(
            listing.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.authBody.copyWith(
              color: AppColors.authText,
              fontSize: AppScale.text(context, 19),
              fontWeight: FontWeight.w500,
              height: 1.4,
              letterSpacing: 0,
            ),
          ),
          SizedBox(height: AppSpacing.xs(context)),
          _FavoritePriceRow(price: listing.price),
          SizedBox(height: AppSpacing.xs(context)),
          Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                color: AppColors.mutedInk,
                size: AppScale.size(context, 19),
              ),
              SizedBox(width: AppSpacing.xs(context)),
              Expanded(
                child: Text(
                  listing.location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.authBody.copyWith(
                    color: AppColors.mutedInk,
                    fontSize: AppScale.text(context, 16),
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xs(context)),
          _FavoriteSpecsText(specs: listing.specs),
        ],
      ),
    );
  }
}

class _FavoritePriceRow extends StatelessWidget {
  const _FavoritePriceRow({required this.price});

  final String price;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.sell,
          color: AppColors.primary,
          size: AppScale.size(context, 19),
        ),
        SizedBox(width: AppSpacing.sm(context)),
        Expanded(
          child: Text(
            price,
            textAlign: TextAlign.left,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.authBody.copyWith(
              color: AppColors.authText,
              fontSize: AppScale.text(context, 16),
              fontWeight: FontWeight.w500,
              height: 1.4,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
}

class _FavoriteSpecsText extends StatelessWidget {
  const _FavoriteSpecsText({required this.specs});

  final String specs;

  @override
  Widget build(BuildContext context) {
    return Text(
      specs,
      style: AppTypography.authBody.copyWith(
        color: AppColors.mutedInk,
        fontSize: AppScale.text(context, 12),
        fontWeight: FontWeight.w400,
        height: 1.4,
        letterSpacing: 0,
      ),
    );
  }
}

class _FavoriteImageFrame extends StatelessWidget {
  const _FavoriteImageFrame({
    required this.imagePath,
    required this.imageCount,
    required this.showFavoriteButton,
    required this.onRemoveFavorite,
  });

  final String imagePath;
  final int imageCount;
  final bool showFavoriteButton;
  final VoidCallback onRemoveFavorite;

  @override
  Widget build(BuildContext context) {
    final dotCount = imageCount.clamp(1, 5);

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppScale.radius(context, 16)),
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
          if (showFavoriteButton)
            Positioned(
              right: AppSpacing.md(context),
              top: AppSpacing.md(context),
              child: IconButton(
                onPressed: onRemoveFavorite,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints.tightFor(
                  width: AppScale.size(context, 42),
                  height: AppScale.size(context, 42),
                ),
                icon: Icon(
                  Icons.favorite,
                  color: AppColors.primary,
                  size: AppScale.size(context, 31),
                ),
              ),
            ),
          if (dotCount > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: AppSpacing.lg(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  dotCount,
                  (index) => Container(
                    width: AppScale.size(context, 8),
                    height: AppScale.size(context, 8),
                    margin: EdgeInsets.symmetric(
                      horizontal: AppSpacing.xxs(context),
                    ),
                    decoration: BoxDecoration(
                      color: index == 0
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

class _FavoriteStatusChip extends StatelessWidget {
  const _FavoriteStatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm(context),
        vertical: AppSpacing.xxs(context),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEDED),
        borderRadius: BorderRadius.circular(AppScale.radius(context, 2)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTypography.authBody.copyWith(
          color: AppColors.mutedInk,
          fontSize: AppScale.text(context, 14),
          fontWeight: FontWeight.w400,
          height: 1.4,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _FavoriteListing {
  const _FavoriteListing({
    required this.imagePath,
    required this.imageCount,
    required this.status,
    required this.title,
    required this.price,
    required this.location,
    required this.specs,
    required this.filter,
    required this.dashboardListing,
  });

  final String imagePath;
  final int imageCount;
  final String status;
  final String title;
  final String price;
  final String location;
  final String specs;
  final _FavoriteFilter filter;
  final _DashboardListing dashboardListing;
}
