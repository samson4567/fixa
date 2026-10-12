part of 'dashboard_map_page.dart';

class _PropertyDetailPage extends StatefulWidget {
  const _PropertyDetailPage({required this.listing, this.onFavoriteChanged});

  final _DashboardListing listing;
  final void Function(String propertyId, bool isFavorite)? onFavoriteChanged;

  @override
  State<_PropertyDetailPage> createState() => _PropertyDetailPageState();
}

class _PropertyDetailPageState extends State<_PropertyDetailPage> {
  late final PropertyDetailCubit _propertyDetailCubit;
  late final PropertyFavoriteCubit _propertyFavoriteCubit;
  bool _isFavorite = false;
  final GlobalKey _shareThumbnailKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _propertyDetailCubit = getIt<PropertyDetailCubit>();
    _propertyFavoriteCubit = getIt<PropertyFavoriteCubit>();
    _isFavorite = widget.listing.isFavorite;
    _RecentlyViewedStore.record(widget.listing);

    final id = widget.listing.id?.trim();
    if (id != null && id.isNotEmpty) {
      _propertyDetailCubit.fetchPropertyById(id);
    }
  }

  @override
  void dispose() {
    _propertyDetailCubit.close();
    _propertyFavoriteCubit.close();
    super.dispose();
  }

  Future<void> _toggleFavorite() async {
    final propertyId = widget.listing.id?.trim();
    if (propertyId == null || propertyId.isEmpty) {
      showAppResponseModal(
        context,
        message: 'Property ID is unavailable.',
        isError: true,
      );
      return;
    }

    final nextState = !_isFavorite;
    await _propertyFavoriteCubit.setFavorite(
      propertyId: propertyId,
      isFavorite: nextState,
    );

    final latest = _propertyFavoriteCubit.state;
    if (!mounted) {
      return;
    }

    if (latest.status == PropertyFavoriteStatus.success) {
      setState(() {
        _isFavorite = nextState;
      });
      widget.onFavoriteChanged?.call(propertyId, nextState);
      if (latest.message != null && latest.message!.trim().isNotEmpty) {
        showAppResponseModal(context, message: latest.message!);
      }
      return;
    }

    if (latest.errorMessage != null && latest.errorMessage!.trim().isNotEmpty) {
      showAppResponseModal(
        context,
        message: latest.errorMessage!,
        isError: true,
      );
    }
  }

  bool _isSale(PropertyFeedProperty? property) {
    final type = property?.type ?? widget.listing.listingType ?? '';
    return type.toLowerCase() == 'sale' || widget.listing.tag == 'For Sale';
  }

  bool _isLand(PropertyFeedProperty? property) {
    final category = (property?.category ?? widget.listing.category ?? '')
        .trim()
        .toLowerCase();
    if (category.isNotEmpty) return category.contains('land');

    final title = (property?.title ?? widget.listing.subtitle ?? '')
        .toLowerCase();
    return RegExp(r'\b(land|plot|plots)\b').hasMatch(title);
  }

  String _propertyAddress(PropertyFeedProperty? property) {
    if (property == null) {
      final address = widget.listing.address?.trim() ?? '';
      return address.isNotEmpty ? address : widget.listing.location.trim();
    }

    final parts = <String>[property.address, property.city, property.state]
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toSet()
        .toList();
    return parts.isEmpty ? 'Address unavailable' : parts.join(', ');
  }

  String _formatNaira(int value) {
    final text = value.toString();
    final withCommas = text.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
    return '₦$withCommas';
  }

  Future<void> _callAgent(PropertyAgent? agent) async {
    final phone = agent?.phone.trim() ?? '';
    if (phone.isEmpty) {
      showAppResponseModal(
        context,
        message: 'Agent phone number is unavailable.',
        isError: true,
      );
      return;
    }

    final dialablePhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    var didLaunch = false;
    try {
      didLaunch = await launchUrl(Uri(scheme: 'tel', path: dialablePhone));
    } catch (_) {
      didLaunch = false;
    }
    if (!didLaunch && mounted) {
      showAppResponseModal(
        context,
        message: 'Unable to open the phone app.',
        isError: true,
      );
    }
  }

  Future<void> _shareProperty({
    required String title,
    required String price,
    required String address,
  }) async {
    final shareText =
        '$title\n$price\n$address\n\nDiscover this property on AMASS.';

    try {
      // Allow the share-button ink animation to finish painting before the
      // RepaintBoundary is converted into the branded thumbnail.
      await WidgetsBinding.instance.endOfFrame;
      final boundary = _shareThumbnailKey.currentContext?.findRenderObject();
      if (boundary is! RenderRepaintBoundary) {
        throw StateError('Property thumbnail is unavailable.');
      }

      final image = await boundary.toImage(pixelRatio: 2.5);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) {
        throw StateError('Unable to create property thumbnail.');
      }

      final directory = await getTemporaryDirectory();
      final safeId = (widget.listing.id ?? 'property').replaceAll(
        RegExp(r'[^a-zA-Z0-9_-]'),
        '_',
      );
      final thumbnail = File('${directory.path}/amass_$safeId.png');
      await thumbnail.writeAsBytes(bytes.buffer.asUint8List(), flush: true);

      if (!mounted) return;
      final box = context.findRenderObject() as RenderBox?;
      await Share.shareXFiles(
        [XFile(thumbnail.path, mimeType: 'image/png')],
        text: shareText,
        subject: '$title on AMASS',
        sharePositionOrigin: box == null
            ? null
            : box.localToGlobal(Offset.zero) & box.size,
      );
    } catch (error) {
      debugPrint('AMASS property image share failed: $error');
      if (!mounted) return;
      try {
        final box = context.findRenderObject() as RenderBox?;
        await Share.share(
          shareText,
          subject: '$title on AMASS',
          sharePositionOrigin: box == null
              ? null
              : box.localToGlobal(Offset.zero) & box.size,
        );
      } catch (fallbackError) {
        debugPrint('AMASS property text share failed: $fallbackError');
        if (!mounted) return;
        showAppResponseModal(
          context,
          message:
              'Sharing is unavailable. Please fully restart the app and try again.',
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PropertyDetailCubit>.value(
      value: _propertyDetailCubit,
      child: BlocBuilder<PropertyDetailCubit, PropertyDetailState>(
        builder: (context, state) {
          final property = state.property;
          final isSale = _isSale(property);
          final isLand = _isLand(property);
          final title =
              property?.title ?? widget.listing.subtitle ?? 'Property details';
          final imagePath = property?.images.isNotEmpty == true
              ? property!.images.first
              : widget.listing.imagePath;
          final imageCount =
              property?.images.length ?? widget.listing.imageCount;
          final price = property != null
              ? '${_formatNaira(property.price)}${isSale ? '' : '/month'}'
              : widget.listing.price;
          final status = isSale ? 'For Sale' : 'For Rent';
          final statusColor = isSale
              ? const Color(0xFFE9A100)
              : const Color(0xFF1687D9);
          final locationText = _propertyAddress(property);
          final description =
              property?.description ??
              widget.listing.description ??
              'No description available for this property.';

          return Scaffold(
            backgroundColor: Colors.white,
            body: Stack(
              children: [
                Scrollbar(
                  thumbVisibility: true,
                  thickness: AppScale.size(context, 4),
                  radius: Radius.circular(AppScale.radius(context, 999)),
                  child: CustomScrollView(
                    primary: true,
                    slivers: [
                      SliverToBoxAdapter(
                        child: RepaintBoundary(
                          key: _shareThumbnailKey,
                          child: _PropertyDetailHero(
                            imagePath: imagePath,
                            isFavorite: _isFavorite,
                            onToggleFavorite: _toggleFavorite,
                            onShare: () => _shareProperty(
                              title: title,
                              price: price,
                              address: locationText,
                            ),
                            imageCount: imageCount,
                            pageCount: property != null
                                ? '1/${property.images.length.clamp(1, 99)}'
                                : '1/${imageCount.clamp(1, 99)}',
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            AppSpacing.xl(context),
                            AppSpacing.md(context),
                            AppSpacing.xl(context),
                            AppScale.size(context, 116),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _DetailTags(
                                tags:
                                    (property?.category.trim().isNotEmpty ==
                                        true)
                                    ? [property!.category]
                                    : const [],
                              ),
                              SizedBox(height: AppSpacing.xl(context)),
                              Text(
                                price,
                                style: AppTypography.authBody.copyWith(
                                  color: Colors.black,
                                  fontSize: AppScale.text(context, 23),
                                  fontWeight: FontWeight.w700,
                                  height: 1.4,
                                  letterSpacing: 0,
                                ),
                              ),
                              SizedBox(height: AppSpacing.md(context)),
                              _StatusPill(label: status, dotColor: statusColor),
                              if (!isLand) ...[
                                SizedBox(height: AppSpacing.md(context)),
                                Text(
                                  '${property?.bedrooms ?? widget.listing.bedrooms ?? 0} bd . ${property?.bathrooms ?? widget.listing.bathrooms ?? 0}ba',
                                  style: AppTypography.authBody.copyWith(
                                    color: const Color(0xFF5C5D5D),
                                    fontSize: AppScale.text(context, 18),
                                    fontWeight: FontWeight.w500,
                                    height: 1.4,
                                    letterSpacing: 0,
                                  ),
                                ),
                              ],
                              SizedBox(height: AppSpacing.md(context)),
                              Text(
                                title,
                                style: AppTypography.authBody.copyWith(
                                  color: const Color(0xFF4A4A4A),
                                  fontSize: AppScale.text(context, 19),
                                  fontWeight: FontWeight.w500,
                                  height: 1.4,
                                  letterSpacing: 0,
                                ),
                              ),
                              SizedBox(height: AppSpacing.md(context)),
                              _DetailIconText(
                                icon: Icons.location_on,
                                text: locationText,
                              ),
                              SizedBox(height: AppSpacing.sm(context)),
                              const _VerifiedListingRow(),
                              const _SectionDivider(),
                              const _DetailSectionTitle('Description'),
                              SizedBox(height: AppSpacing.md(context)),
                              Text(
                                description,
                                style: AppTypography.authBody.copyWith(
                                  color: Colors.black,
                                  fontSize: AppScale.text(context, 16),
                                  fontWeight: FontWeight.w400,
                                  height: 1.4,
                                  letterSpacing: 0,
                                ),
                              ),
                              Text(
                                'Read more',
                                style: AppTypography.authBody.copyWith(
                                  color: AppColors.primary,
                                  fontSize: AppScale.text(context, 16),
                                  fontWeight: FontWeight.w500,
                                  height: 1.4,
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppColors.primary,
                                  letterSpacing: 0,
                                ),
                              ),
                              const _SectionDivider(),
                              if (isLand)
                                const _LandDetailsContent()
                              else
                                _HouseOffersContent(
                                  bedrooms:
                                      property?.bedrooms ??
                                      widget.listing.bedrooms ??
                                      0,
                                  bathrooms:
                                      property?.bathrooms ??
                                      widget.listing.bathrooms ??
                                      0,
                                ),
                              const _SectionDivider(),
                              _LocationPreviewSection(
                                address: locationText,
                                lat: property?.lat ?? 0,
                                lng: property?.lng ?? 0,
                                onOpenMap: () {
                                  Navigator.of(context).push<void>(
                                    MaterialPageRoute<void>(
                                      builder: (_) => _PropertyLocationMapPage(
                                        address: locationText,
                                        lat: property?.lat ?? 0,
                                        lng: property?.lng ?? 0,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: AppSpacing.xl(context)),
                              _AgentInformationCard(
                                agent: property?.agent,
                                isLoading:
                                    state.status ==
                                    PropertyDetailStatus.loading,
                              ),
                              SizedBox(height: AppSpacing.xl(context)),
                              Text(
                                'Additional note',
                                style: AppTypography.authBody.copyWith(
                                  color: const Color(0xFF6A6A6A),
                                  fontSize: AppScale.text(context, 19),
                                  fontWeight: FontWeight.w500,
                                  height: 1.4,
                                  letterSpacing: 0,
                                ),
                              ),
                              SizedBox(height: AppSpacing.sm(context)),
                              Text(
                                property?.agent?.note.trim().isNotEmpty == true
                                    ? property!.agent!.note
                                    : 'No additional note provided.',
                                style: AppTypography.authBody.copyWith(
                                  color: Colors.black,
                                  fontSize: AppScale.text(context, 16),
                                  fontWeight: FontWeight.w400,
                                  height: 1.4,
                                  letterSpacing: 0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (state.status == PropertyDetailStatus.loading)
                  const Positioned(
                    top: 12,
                    right: 12,
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _CallAgentBar(
                    onTap: () => _callAgent(property?.agent),
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

class _PropertyDetailHero extends StatelessWidget {
  const _PropertyDetailHero({
    required this.imagePath,
    required this.pageCount,
    required this.imageCount,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onShare,
  });

  final String imagePath;
  final String pageCount;
  final int imageCount;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppScale.size(context, 386),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _DashboardListingImage(path: imagePath),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.12),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.16),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: AppSpacing.xl(context),
            top: AppScale.size(context, 52),
            child: _HeroCircleButton(
              icon: Icons.arrow_back,
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
          Positioned(
            right: AppSpacing.xl(context),
            top: AppScale.size(context, 52),
            child: Row(
              children: [
                _HeroCircleButton(icon: Icons.share_outlined, onTap: onShare),
                SizedBox(width: AppSpacing.sm(context)),
                _HeroCircleButton(
                  icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                  onTap: onToggleFavorite,
                ),
              ],
            ),
          ),
          Positioned(
            left: AppSpacing.xl(context),
            bottom: AppScale.size(context, 20),
            child: const _AmassPropertyWatermark(),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: AppScale.size(context, 22),
            child: _HeroDots(imageCount: imageCount),
          ),
          Positioned(
            right: AppSpacing.xl(context),
            bottom: AppScale.size(context, 22),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md(context),
                vertical: AppSpacing.xs(context),
              ),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(
                  AppScale.radius(context, 999),
                ),
              ),
              child: Text(
                pageCount,
                style: AppTypography.authBody.copyWith(
                  color: Colors.white,
                  fontSize: AppScale.text(context, 13),
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AmassPropertyWatermark extends StatelessWidget {
  const _AmassPropertyWatermark();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppScale.size(context, 38),
      padding: EdgeInsets.symmetric(
        horizontal: AppScale.size(context, 10),
        vertical: AppScale.size(context, 5),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(AppScale.radius(context, 10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/icons/AMASS  4.png',
            width: AppScale.size(context, 21),
            height: AppScale.size(context, 28),
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
          SizedBox(width: AppScale.size(context, 4)),
          Text(
            'AMASS',
            style: AppTypography.authBody.copyWith(
              color: const Color(0xFF151719),
              fontSize: AppScale.text(context, 18),
              fontWeight: FontWeight.w800,
              height: 1,
              letterSpacing: -1,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCircleButton extends StatelessWidget {
  const _HeroCircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.92),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: AppScale.size(context, 42),
          height: AppScale.size(context, 42),
          child: Icon(
            icon,
            color: const Color(0xFF4A4A4A),
            size: AppSizes.iconLg(context),
          ),
        ),
      ),
    );
  }
}

class _HeroDots extends StatelessWidget {
  const _HeroDots({required this.imageCount});

  final int imageCount;

  @override
  Widget build(BuildContext context) {
    final dotCount = imageCount.clamp(1, 5);

    if (dotCount <= 1) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        dotCount,
        (index) => Container(
          width: AppScale.size(context, 7),
          height: AppScale.size(context, 7),
          margin: EdgeInsets.symmetric(horizontal: AppSpacing.xxs(context)),
          decoration: BoxDecoration(
            color: index == 0 ? AppColors.primary : Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _DetailTags extends StatelessWidget {
  const _DetailTags({required this.tags});

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm(context),
      runSpacing: AppSpacing.sm(context),
      children: tags
          .map(
            (tag) => Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md(context),
                vertical: AppSpacing.xs(context),
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFECECEC),
                borderRadius: BorderRadius.circular(
                  AppScale.radius(context, 999),
                ),
              ),
              child: Text(
                tag,
                style: AppTypography.authBody.copyWith(
                  color: const Color(0xFF6A6A6A),
                  fontSize: AppScale.text(context, 13),
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                  letterSpacing: 0,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.dotColor});

  final String label;
  final Color dotColor;

  @override
  Widget build(BuildContext context) {
    final isForRent = label == 'For Rent';

    return Container(
      width: isForRent ? AppScale.size(context, 93) : null,
      height: isForRent ? AppScale.size(context, 26) : null,
      padding: EdgeInsets.fromLTRB(
        AppScale.size(context, 12),
        AppScale.size(context, 4),
        AppScale.size(context, 12),
        AppScale.size(context, 4),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFECECEC),
        borderRadius: BorderRadius.circular(AppScale.radius(context, 999)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: AppScale.size(context, 8),
            height: AppScale.size(context, 8),
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          SizedBox(width: AppScale.size(context, 10)),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                style: AppTypography.authBody.copyWith(
                  color: Colors.black,
                  fontSize: AppScale.text(context, 13),
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailIconText extends StatelessWidget {
  const _DetailIconText({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFF5C5D5D),
          size: AppSizes.iconLg(context),
        ),
        SizedBox(width: AppSpacing.xs(context)),
        Expanded(
          child: Text(
            text,
            style: AppTypography.authBody.copyWith(
              color: const Color(0xFF4A4A4A),
              fontSize: AppScale.text(context, 16),
              fontWeight: FontWeight.w600,
              height: 1.4,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
}

class _VerifiedListingRow extends StatelessWidget {
  const _VerifiedListingRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(
          'assets/icons/verify.svg',
          width: AppScale.size(context, 26),
          height: AppScale.size(context, 26),
        ),
        SizedBox(width: AppSpacing.xs(context)),
        Text(
          'Verified listing',
          style: AppTypography.authBody.copyWith(
            color: const Color(0xFF4A4A4A),
            fontSize: AppScale.text(context, 16),
            fontWeight: FontWeight.w600,
            height: 1.4,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xl(context)),
      child: const Divider(color: Color(0xFFE2E2E2), height: 1),
    );
  }
}

class _DetailSectionTitle extends StatelessWidget {
  const _DetailSectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.authBody.copyWith(
        color: Colors.black,
        fontSize: AppScale.text(context, 19),
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: 0,
      ),
    );
  }
}

class _HouseOffersContent extends StatelessWidget {
  const _HouseOffersContent({required this.bedrooms, required this.bathrooms});

  final int bedrooms;
  final int bathrooms;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _DetailSectionTitle('Property details'),
        const SizedBox(height: 16),
        if (bedrooms > 0)
          _OfferRow(
            assetPath: 'assets/icons/bed-single.svg',
            label: '$bedrooms ${bedrooms == 1 ? 'Bedroom' : 'Bedrooms'}',
          ),
        if (bathrooms > 0)
          _OfferRow(
            icon: Icons.bathtub_outlined,
            label: '$bathrooms ${bathrooms == 1 ? 'Bathroom' : 'Bathrooms'}',
          ),
        if (bedrooms == 0 && bathrooms == 0)
          const Text('Property specifications unavailable.'),
      ],
    );
  }
}

class _LandDetailsContent extends StatelessWidget {
  const _LandDetailsContent();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DetailSectionTitle('Key Land Details'),
        SizedBox(height: 12),
        _LandDetailRow(label: 'Land Size', value: '600 sqm'),
        _LandDetailRow(label: 'Price per sqm', value: '₦25,000'),
        _LandDetailRow(label: 'Title:', value: 'Certificate of ownership'),
        _LandDetailRow(label: 'Purpose:', value: 'Residential'),
        SizedBox(height: 20),
        _DetailSectionTitle('What this site offers'),
        SizedBox(height: 12),
        _OfferRow(icon: Icons.add_road_outlined, label: 'Road Access: Yes'),
        _OfferRow(
          icon: Icons.campaign_outlined,
          label: 'Survey Available: Yes',
        ),
        SizedBox(height: 20),
        _LandDocuments(),
      ],
    );
  }
}

class _LandDetailRow extends StatelessWidget {
  const _LandDetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md(context)),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md(context),
              vertical: AppSpacing.xs(context),
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFECECEC),
              borderRadius: BorderRadius.circular(
                AppScale.radius(context, 999),
              ),
            ),
            child: Text(
              label,
              style: AppTypography.authBody.copyWith(
                color: const Color(0xFF4A4A4A),
                fontSize: AppScale.text(context, 16),
                fontWeight: FontWeight.w500,
                height: 1.4,
                letterSpacing: 0,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.md(context)),
          Expanded(
            child: Text(
              value,
              style: AppTypography.authBody.copyWith(
                color: Colors.black,
                fontSize: AppScale.text(context, 16),
                fontWeight: FontWeight.w400,
                height: 1.4,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OfferRow extends StatelessWidget {
  const _OfferRow({required this.label, this.assetPath, this.icon});

  final String label;
  final String? assetPath;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final leading = _OfferIcon(assetPath: assetPath, icon: icon);

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.lg(context)),
      child: Row(
        children: [
          SizedBox(
            width: AppScale.size(context, 30),
            child: Center(child: leading),
          ),
          SizedBox(width: AppSpacing.lg(context)),
          Expanded(
            child: Text(
              label,
              style: AppTypography.authBody.copyWith(
                color: Colors.black,
                fontSize: AppScale.text(context, 16),
                fontWeight: FontWeight.w400,
                height: 1.4,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OfferIcon extends StatelessWidget {
  const _OfferIcon({this.assetPath, this.icon});

  final String? assetPath;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    if (assetPath != null && assetPath!.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(
        assetPath!,
        width: AppSizes.iconLg(context),
        height: AppSizes.iconLg(context),
        colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
      );
    }

    if (assetPath != null) {
      return Image.asset(
        assetPath!,
        width: AppSizes.iconLg(context),
        height: AppSizes.iconLg(context),
        color: Colors.black,
      );
    }

    return Icon(icon, color: Colors.black, size: AppSizes.iconLg(context));
  }
}

class _LandDocuments extends StatelessWidget {
  const _LandDocuments();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.description_outlined, size: AppSizes.iconLg(context)),
            SizedBox(width: AppSpacing.sm(context)),
            const _DetailSectionTitle('Land Documents'),
          ],
        ),
        SizedBox(height: AppSpacing.sm(context)),
        const _DocumentBullet('Certificate of Occupancy (C of O)'),
        const _DocumentBullet('Registered Survey Plan'),
        const _DocumentBullet('Deed of Assignment'),
      ],
    );
  }
}

class _DocumentBullet extends StatelessWidget {
  const _DocumentBullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm(context)),
      child: Text(
        '-  $text',
        style: AppTypography.authBody.copyWith(
          color: Colors.black,
          fontSize: AppScale.text(context, 16),
          fontWeight: FontWeight.w400,
          height: 1.4,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _LocationPreviewSection extends StatelessWidget {
  const _LocationPreviewSection({
    required this.onOpenMap,
    required this.address,
    required this.lat,
    required this.lng,
  });

  final VoidCallback onOpenMap;
  final String address;
  final double lat;
  final double lng;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _DetailSectionTitle("Where you'll be"),
        SizedBox(height: AppSpacing.md(context)),
        Text(
          address,
          style: AppTypography.authBody.copyWith(
            color: const Color(0xFF4A4A4A),
            fontSize: AppScale.text(context, 16),
            fontWeight: FontWeight.w600,
            height: 1.4,
            letterSpacing: 0,
          ),
        ),
        SizedBox(height: AppSpacing.lg(context)),
        _StaticMapPreview(onTap: onOpenMap, lat: lat, lng: lng),
      ],
    );
  }
}

class _StaticMapPreview extends StatelessWidget {
  const _StaticMapPreview({
    required this.onTap,
    required this.lat,
    required this.lng,
  });

  final VoidCallback onTap;
  final double lat;
  final double lng;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppScale.size(context, 182),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(AppScale.radius(context, 14)),
        border: Border.all(color: const Color(0xFFD0D0D0)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          if (lat != 0 || lng != 0)
            Positioned.fill(
              child: IgnorePointer(
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(lat, lng),
                    zoom: 15,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId('property-location'),
                      position: LatLng(lat, lng),
                    ),
                  },
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  compassEnabled: false,
                ),
              ),
            )
          else
            const Positioned.fill(child: ColoredBox(color: Color(0xFFF1F3F5))),
          Center(
            child: Material(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(
                AppScale.radius(context, 999),
              ),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(
                  AppScale.radius(context, 999),
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg(context),
                    vertical: AppSpacing.sm(context),
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      AppScale.radius(context, 999),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View on map',
                        style: AppTypography.authBody.copyWith(
                          color: Colors.white,
                          fontSize: AppScale.text(context, 13),
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                          letterSpacing: 0,
                        ),
                      ),
                      SizedBox(width: AppSpacing.sm(context)),
                      const Icon(Icons.map, color: Colors.white, size: 20),
                    ],
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

class _PropertyLocationMapPage extends StatelessWidget {
  const _PropertyLocationMapPage({
    required this.address,
    required this.lat,
    required this.lng,
  });

  final String address;
  final double lat;
  final double lng;

  @override
  Widget build(BuildContext context) {
    final hasCoordinates = lat != 0 || lng != 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Text(
          address,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.authBody.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: hasCoordinates
          ? GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(lat, lng),
                zoom: 16,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('property-location'),
                  position: LatLng(lat, lng),
                  infoWindow: InfoWindow(title: address),
                ),
              },
              myLocationButtonEnabled: false,
              mapToolbarEnabled: false,
            )
          : Center(
              child: Text(
                'Map coordinates unavailable.',
                style: AppTypography.authBody.copyWith(color: Colors.black),
              ),
            ),
    );
  }
}

class _AgentInformationCard extends StatelessWidget {
  const _AgentInformationCard({required this.agent, required this.isLoading});

  final PropertyAgent? agent;
  final bool isLoading;

  String _display(String value) {
    if (isLoading) return 'Loading...';
    return value.trim().isEmpty ? 'Unavailable' : value.trim();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _DetailSectionTitle('Agent information'),
        SizedBox(height: AppSpacing.md(context)),
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: AppScale.size(context, 400)),
            child: Container(
              height: AppScale.size(context, 184),
              padding: EdgeInsets.all(AppScale.size(context, 16)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  AppScale.radius(context, 16),
                ),
                border: Border.all(color: const Color(0xFFE8E8E8), width: 1),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      ClipOval(
                        child: SizedBox(
                          width: AppScale.size(context, 84),
                          height: AppScale.size(context, 84),
                          child: ColoredBox(
                            color: const Color(0xFFE8E8E8),
                            child: agent?.imageUrl.trim().isNotEmpty == true
                                ? Image.network(
                                    agent!.imageUrl,
                                    fit: BoxFit.cover,
                                    filterQuality: FilterQuality.high,
                                    errorBuilder: (_, _, _) => Icon(
                                      Icons.person,
                                      color: const Color(0xFF6A6A6A),
                                      size: AppScale.size(context, 46),
                                    ),
                                  )
                                : Icon(
                                    Icons.person,
                                    color: const Color(0xFF6A6A6A),
                                    size: AppScale.size(context, 46),
                                  ),
                          ),
                        ),
                      ),
                      SizedBox(height: AppSpacing.sm(context)),
                      if (agent?.isVerified == true)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/agent_verify.svg',
                              width: AppScale.size(context, 16),
                              height: AppScale.size(context, 16),
                            ),
                            SizedBox(width: AppSpacing.xs(context)),
                            Text(
                              'Amass Verified',
                              style: AppTypography.authBody.copyWith(
                                color: AppColors.primary,
                                fontSize: AppScale.text(context, 11),
                                fontWeight: FontWeight.w700,
                                height: 1.4,
                                letterSpacing: 0,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  SizedBox(width: AppScale.size(context, 8)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _AgentInfoLine(
                          label: 'Name',
                          value: _display(agent?.name ?? ''),
                        ),
                        _AgentInfoLine(
                          label: 'Phone number',
                          value: _display(agent?.phone ?? ''),
                        ),
                        _AgentInfoLine(
                          label: 'Location',
                          value: _display(agent?.location ?? ''),
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AgentInfoLine extends StatelessWidget {
  const _AgentInfoLine({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.sm(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.authBody.copyWith(
              color: Colors.black,
              fontSize: AppScale.text(context, 13),
              fontWeight: FontWeight.w400,
              height: 1.4,
              letterSpacing: 0,
            ),
          ),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.authBody.copyWith(
              color: Colors.black,
              fontSize: AppScale.text(context, 16),
              fontWeight: FontWeight.w500,
              height: 1.4,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _CallAgentBar extends StatelessWidget {
  const _CallAgentBar({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl(context),
        AppSpacing.md(context),
        AppSpacing.xl(context),
        AppSpacing.xl(context),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: AppScale.size(context, 52),
          child: ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md(context),
                vertical: AppSpacing.sm(context),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppScale.radius(context, 7),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.call_rounded,
                  color: Colors.white,
                  size: AppSizes.iconLg(context),
                ),
                SizedBox(width: AppScale.size(context, 16)),
                Text(
                  'Call Agent',
                  textAlign: TextAlign.center,
                  style: AppTypography.authButtonLabel.copyWith(
                    color: Colors.white,
                    fontSize: AppScale.text(context, 19),
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                    letterSpacing: 0,
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
