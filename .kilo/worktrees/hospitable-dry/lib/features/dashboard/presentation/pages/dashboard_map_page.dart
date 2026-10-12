import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:fixa/core/constants/endpoint_constant.dart';
import 'package:fixa/core/di/service_locator.dart';
import 'package:fixa/core/network/app_error.dart';
import 'package:fixa/core/routing/app_routes.dart';
import 'package:fixa/core/theme/app_colors.dart';
import 'package:fixa/core/theme/app_typography.dart';
import 'package:fixa/core/theme/tokens/app_scale.dart';
import 'package:fixa/core/theme/tokens/app_sizes.dart';
import 'package:fixa/core/theme/tokens/app_spacing.dart';
import 'package:fixa/core/utils/app_sound.dart';
import 'package:fixa/core/storage/app_preference_service.dart';
import 'package:fixa/features/auth/domain/repositories/auth_repository.dart';
import 'package:fixa/features/auth/domain/entities/user_profile_result.dart';
import 'package:fixa/features/auth/presentation/cubit/user_profile_cubit.dart';
import 'package:fixa/features/dashboard/domain/entities/property_feed_result.dart';
import 'package:fixa/features/dashboard/domain/entities/notification_result.dart';
import 'package:fixa/features/dashboard/domain/entities/property_map_pins_result.dart';
import 'package:fixa/features/dashboard/presentation/cubit/property_detail_cubit.dart';
import 'package:fixa/features/dashboard/presentation/cubit/notification_cubit.dart';
import 'package:fixa/features/dashboard/presentation/cubit/property_favorite_cubit.dart';
import 'package:fixa/features/dashboard/presentation/cubit/property_favorites_cubit.dart';
import 'package:fixa/features/dashboard/presentation/cubit/property_feed_cubit.dart';
import 'package:fixa/features/dashboard/presentation/cubit/property_map_pins_cubit.dart';
import 'package:fixa/features/dashboard/presentation/cubit/property_places_cubit.dart';
import 'package:fixa/shared/widgets/app_loading_overlay.dart';
import 'package:fixa/shared/widgets/app_response_modal.dart';
import 'package:fixa/features/subscription/presentation/cubit/subscription_cubit.dart';

part 'dashboard_home_page.dart';
part 'dashboard_favorites_page.dart';
part 'dashboard_profile_page.dart';
part 'dashboard_house_details_page.dart';

class DashboardMapPage extends StatefulWidget {
  const DashboardMapPage({super.key});

  @override
  State<DashboardMapPage> createState() => _DashboardMapPageState();
}

class _DashboardMapPageState extends State<DashboardMapPage> {
  static const String _defaultSearchText = 'Ikeja Lagos. Oba-Akran';
  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(6.6018, 3.3515),
    zoom: 15.1,
  );

  final Completer<GoogleMapController> _mapController = Completer();
  final TextEditingController _searchController = TextEditingController();
  final Dio _dio = Dio();
  late final PropertyMapPinsCubit _propertyMapPinsCubit;
  late final PropertyDetailCubit _mapPropertyDetailCubit;
  late final NotificationCubit _notificationCubit;
  final Map<String, PropertyFeedProperty> _mapPropertyDetails =
      <String, PropertyFeedProperty>{};
  MapType _mapType = MapType.normal;
  Set<Marker> _markers = const <Marker>{};
  List<_MapHome> _allMapHomes = const <_MapHome>[];
  List<_MapHome> _mapHomes = const <_MapHome>[];
  _MapFilterResult _activeFilter = const _MapFilterResult();
  int _selectedNavIndex = 0;
  String _selectedMapType = 'sale';
  bool _isSearching = false;
  String? _searchError;
  bool _hasLocationPermission = false;
  Position? _currentUserPosition;
  StreamSubscription<Position>? _locationSubscription;
  bool _followUserLocation = false;
  LatLng? _selectedPlacePosition;
  bool _isInspectingPlace = false;
  _TappedPlaceDetails? _selectedPlaceDetails;
  LatLng? _streetViewPosition;
  bool _isLoadingStreetView = false;
  bool _hasStreetView = false;
  int _streetViewRequestId = 0;

  @override
  void initState() {
    super.initState();
    _propertyMapPinsCubit = getIt<PropertyMapPinsCubit>();
    _mapPropertyDetailCubit = getIt<PropertyDetailCubit>();
    _notificationCubit = getIt<NotificationCubit>();
    _loadMapPins();
    _notificationCubit.fetchNotifications();
    unawaited(_ensureLocationTracking());
  }

  @override
  void dispose() {
    _propertyMapPinsCubit.close();
    _mapPropertyDetailCubit.close();
    _notificationCubit.close();
    _locationSubscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _buildMarkers() async {
    final markerIcon = await _homeMarkerIcon();

    if (!mounted) {
      return;
    }

    setState(() {
      _markers = _mapHomes
          .map(
            (home) => Marker(
              markerId: MarkerId(home.id),
              position: home.position,
              icon: markerIcon,
              anchor: const Offset(0.5, 1),
              zIndexInt: 10,
              infoWindow: InfoWindow(
                title: home.title,
                snippet: _formatMapPrice(home.price),
              ),
              onTap: () {
                unawaited(_selectHome(home));
              },
            ),
          )
          .toSet();
    });
  }

  Future<void> _loadMapPins() {
    return _propertyMapPinsCubit.fetchMapPins(
      type: _selectedMapType,
      page: 1,
      limit: 20,
    );
  }

  void _setPins(PropertyMapPinsResult result) {
    _allMapHomes = result.pins
        .map(
          (pin) => _MapHome(
            id: pin.id,
            position: LatLng(pin.lat, pin.lng),
            title: pin.title,
            price: pin.price,
            type: pin.type,
            category: pin.category,
          ),
        )
        .toList();
    _applyActiveFilter();
  }

  void _applyActiveFilter() {
    _mapHomes = _allMapHomes
        .where((home) => _activeFilter.matches(home))
        .toList();
    unawaited(_buildMarkers());
  }

  Future<void> _selectHome(_MapHome home) async {
    final controller = await _mapController.future;
    await controller.animateCamera(CameraUpdate.newLatLng(home.position));

    if (!mounted) {
      return;
    }

    var property = _mapPropertyDetails[home.id];

    if (property == null) {
      await _mapPropertyDetailCubit.fetchPropertyById(home.id);
      property = _mapPropertyDetailCubit.state.property;
      if (property?.id != home.id) {
        property = null;
      }
      if (property != null) {
        _mapPropertyDetails[home.id] = property;
      }
    }

    if (!mounted) {
      return;
    }

    if (property == null) {
      final message = _mapPropertyDetailCubit.state.errorMessage;
      _showLocationMessage(
        message?.trim().isNotEmpty == true
            ? message!
            : 'Unable to load this property.',
      );
      return;
    }

    final isRent = property.type.toLowerCase() == 'rent';
    final locationParts = <String>[
      property.address,
      property.city,
      property.state,
    ].where((value) => value.trim().isNotEmpty).toSet().toList();
    final listing = _DashboardListing(
      id: property.id,
      imagePath: property.images.isNotEmpty
          ? property.images.first
          : 'assets/icons/house.png',
      imageCount: property.images.length,
      price: '${_formatMapPrice(property.price)}${isRent ? '/mo' : ''}',
      location: locationParts.isEmpty
          ? 'Address unavailable'
          : locationParts.join(', '),
      tag: isRent ? 'Rental' : 'For Sale',
      subtitle: property.title,
      description: property.description,
      address: property.address,
      bedrooms: property.bedrooms,
      bathrooms: property.bathrooms,
      listingType: property.type,
      category: property.category,
    );

    final selectedHome = home.copyWith(
      imagePath: property.images.isNotEmpty ? property.images.first : null,
      address: listing.location,
      bedrooms: property.bedrooms,
      bathrooms: property.bathrooms,
    );
    _showHomeModal(selectedHome, listing);
  }

  Future<BitmapDescriptor> _homeMarkerIcon() {
    return Future<BitmapDescriptor>.value(
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );
  }

  void _showHomeModal(_MapHome home, _DashboardListing listing) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      showDragHandle: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _HomePreviewSheet(
        home: home,
        onOpenDetails: () {
          Navigator.of(context).pop();
          Navigator.of(context).push<void>(
            MaterialPageRoute<void>(
              builder: (_) => _PropertyDetailPage(listing: listing),
            ),
          );
        },
        onOpenStreetView: () {
          Navigator.of(context).pop();
          _openStreetView(home);
        },
      ),
    );
  }

  void _openStreetView(_MapHome home) {
    _openStreetViewAt(home.position);
  }

  void _openStreetViewAt(LatLng position) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _StreetViewPage(position: position),
      ),
    );
  }

  Future<void> _openSearchPage() async {
    final searchResult = await Navigator.of(context).push<_MapSearchResult>(
      MaterialPageRoute<_MapSearchResult>(
        builder: (_) => _MapSearchPage(initialQuery: _searchController.text),
      ),
    );

    if (!mounted || searchResult == null) {
      return;
    }

    if (searchResult.useCurrentLocation) {
      FocusManager.instance.primaryFocus?.unfocus();
      setState(() {
        _searchController.text = 'Current location';
        _searchError = null;
      });
      _followUserLocation = true;
      await _moveNearby();
      return;
    }

    final query = searchResult.query.trim();
    if (query.isEmpty) {
      return;
    }

    _followUserLocation = false;
    _searchController.text = query;
    await _searchLocation();
  }

  Future<void> _openFilterPage() async {
    final filterResult = await Navigator.of(context).push<_MapFilterResult>(
      MaterialPageRoute<_MapFilterResult>(
        builder: (_) =>
            _MapFilterPage(initialFilter: _activeFilter, homes: _allMapHomes),
      ),
    );

    if (!mounted || filterResult == null) {
      return;
    }

    setState(() {
      _activeFilter = filterResult;
      _applyActiveFilter();
    });
  }

  Future<void> _openNotificationPage() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const _NotificationCenterPage()),
    );
    if (mounted) {
      _notificationCubit.fetchNotifications();
    }
  }

  Future<void> _openListingsDashboard() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const _ListingsDashboardPage()),
    );
  }

  Future<void> _ensureLocationTracking({bool centerOnUser = false}) async {
    final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isServiceEnabled) {
      _showLocationMessage('Location services are turned off.');
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    final isGranted =
        permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
    if (!isGranted) {
      if (mounted) {
        setState(() {
          _hasLocationPermission = false;
        });
      }
      _showLocationMessage('Location permission was denied.');
      return;
    }

    if (mounted && !_hasLocationPermission) {
      setState(() {
        _hasLocationPermission = true;
      });
    }

    try {
      final currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
        ),
      );
      _onLocationUpdated(currentPosition, shouldRecenter: centerOnUser);
    } catch (_) {
      _showLocationMessage('Unable to fetch current location.');
    }

    _locationSubscription ??=
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.best,
            distanceFilter: 5,
          ),
        ).listen(
          (position) {
            _onLocationUpdated(position, shouldRecenter: _followUserLocation);
          },
          onError: (_) {
            _showLocationMessage('Unable to track location in real time.');
          },
        );
  }

  void _onLocationUpdated(Position position, {required bool shouldRecenter}) {
    if (!mounted) {
      return;
    }

    setState(() {
      _currentUserPosition = position;
    });

    if (!shouldRecenter) {
      return;
    }

    unawaited(
      _animateToPosition(
        LatLng(position.latitude, position.longitude),
        zoom: 16.8,
      ),
    );
  }

  Future<void> _animateToPosition(LatLng target, {double zoom = 16.8}) async {
    if (!_mapController.isCompleted) {
      return;
    }

    final controller = await _mapController.future;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: zoom),
      ),
    );
  }

  void _showLocationMessage(String message) {
    if (!mounted) {
      return;
    }

    showAppResponseModal(context, message: message, isError: true);
  }

  Future<void> _moveNearby() async {
    _followUserLocation = true;
    await _ensureLocationTracking(centerOnUser: true);

    final userPosition = _currentUserPosition;
    if (userPosition != null) {
      await _animateToPosition(
        LatLng(userPosition.latitude, userPosition.longitude),
      );
      return;
    }

    final controller = await _mapController.future;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(_initialCameraPosition),
    );
  }

  Future<void> _toggleMapType() async {
    final showSatellite = _mapType != MapType.hybrid;
    setState(() {
      _mapType = showSatellite ? MapType.hybrid : MapType.normal;
    });

    if (showSatellite) {
      await _ensureLocationTracking();
    }
  }

  String _formatMapPrice(int value) {
    final formatted = value.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
    return '₦$formatted';
  }

  Future<void> _loadStreetViewPreview(LatLng tappedPosition) async {
    final requestId = ++_streetViewRequestId;
    setState(() {
      _streetViewPosition = tappedPosition;
      _isLoadingStreetView = true;
      _hasStreetView = false;
    });

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        'https://maps.googleapis.com/maps/api/streetview/metadata',
        queryParameters: {
          'location': '${tappedPosition.latitude},${tappedPosition.longitude}',
          'key': EndpointConstant.googleMapsApiKey,
        },
      );
      final data = response.data ?? const <String, dynamic>{};
      final location = data['location'];
      var previewPosition = tappedPosition;
      if (location is Map<String, dynamic> &&
          location['lat'] is num &&
          location['lng'] is num) {
        previewPosition = LatLng(
          (location['lat'] as num).toDouble(),
          (location['lng'] as num).toDouble(),
        );
      }

      if (!mounted || requestId != _streetViewRequestId) return;
      setState(() {
        _streetViewPosition = previewPosition;
        _hasStreetView = data['status'] == 'OK';
      });
    } catch (_) {
      if (!mounted || requestId != _streetViewRequestId) return;
      setState(() {
        _hasStreetView = false;
      });
    } finally {
      if (mounted && requestId == _streetViewRequestId) {
        setState(() {
          _isLoadingStreetView = false;
        });
      }
    }
  }

  Future<void> _inspectMapLocation(LatLng position) async {
    if (_isInspectingPlace) return;

    unawaited(_loadStreetViewPreview(position));

    setState(() {
      _isInspectingPlace = true;
      _selectedPlacePosition = position;
      _selectedPlaceDetails = null;
    });

    try {
      final responses = await Future.wait([
        _dio.get<Map<String, dynamic>>(
          'https://maps.googleapis.com/maps/api/geocode/json',
          queryParameters: {
            'latlng': '${position.latitude},${position.longitude}',
            'key': EndpointConstant.googleMapsApiKey,
          },
        ),
        _dio
            .get<Map<String, dynamic>>(
              'https://maps.googleapis.com/maps/api/place/nearbysearch/json',
              queryParameters: {
                'location': '${position.latitude},${position.longitude}',
                'radius': 50,
                'key': EndpointConstant.googleMapsApiKey,
              },
            )
            .catchError(
              (_) => Response<Map<String, dynamic>>(
                requestOptions: RequestOptions(path: ''),
                data: const <String, dynamic>{},
              ),
            ),
      ]);

      final geocodeData = responses[0].data ?? const <String, dynamic>{};
      final nearbyData = responses[1].data ?? const <String, dynamic>{};
      final details = _TappedPlaceDetails.fromGoogleResponses(
        position: position,
        geocodeData: geocodeData,
        nearbyData: nearbyData,
      );

      if (!mounted || _selectedPlacePosition != position) return;
      setState(() {
        _selectedPlaceDetails = details;
      });
    } catch (_) {
      _showLocationMessage('Unable to load information for this location.');
    } finally {
      if (mounted) {
        setState(() {
          _isInspectingPlace = false;
        });
      }
    }
  }

  Future<void> _showSelectedPlaceDetails() async {
    final details = _selectedPlaceDetails;
    if (details == null) {
      if (_isInspectingPlace) {
        _showLocationMessage('Place information is still loading.');
      }
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _TappedPlaceDetailsSheet(details: details),
    );
  }

  Future<void> _searchLocation() async {
    final query = _searchController.text.trim();
    if (query.isEmpty || _isSearching) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _isSearching = true;
      _searchError = null;
    });

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        'https://maps.googleapis.com/maps/api/geocode/json',
        queryParameters: {
          'address': query,
          'key': EndpointConstant.googleMapsApiKey,
        },
      );
      final results = response.data?['results'] as List<dynamic>? ?? [];
      if (results.isEmpty) {
        throw Exception('No location found');
      }

      final result = results.first as Map<String, dynamic>;
      final geometry = result['geometry'] as Map<String, dynamic>;
      final location = geometry['location'] as Map<String, dynamic>;
      final latLng = LatLng(
        (location['lat'] as num).toDouble(),
        (location['lng'] as num).toDouble(),
      );
      final controller = await _mapController.future;
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: latLng, zoom: 15.6),
        ),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _searchController.text =
            result['formatted_address'] as String? ?? query;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _searchError = 'Location not found';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PropertyMapPinsCubit>.value(value: _propertyMapPinsCubit),
        BlocProvider<NotificationCubit>.value(value: _notificationCubit),
      ],
      child: BlocListener<PropertyMapPinsCubit, PropertyMapPinsState>(
        listener: (context, state) {
          if (state.status == PropertyMapPinsStatus.success &&
              state.result != null) {
            _setPins(state.result!);
          }

          if (state.status == PropertyMapPinsStatus.failure &&
              state.errorMessage != null &&
              state.errorMessage!.trim().isNotEmpty) {
            _showLocationMessage(state.errorMessage!);
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.surface,
          body: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: _initialCameraPosition,
                mapType: _mapType,
                markers: {
                  ..._markers,
                  if (_selectedPlacePosition != null)
                    Marker(
                      markerId: const MarkerId('selected-place'),
                      position: _selectedPlacePosition!,
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueAzure,
                      ),
                      onTap: () => unawaited(_showSelectedPlaceDetails()),
                    ),
                },
                myLocationEnabled: _hasLocationPermission,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                compassEnabled: false,
                mapToolbarEnabled: false,
                onTap: _inspectMapLocation,
                onMapCreated: (controller) {
                  if (!_mapController.isCompleted) {
                    _mapController.complete(controller);
                  }
                },
              ),
              BlocBuilder<NotificationCubit, NotificationState>(
                builder: (context, notificationState) => _DashboardTopControls(
                  controller: _searchController,
                  isSearching: _isSearching,
                  searchError: _searchError,
                  unreadCount: notificationState.result?.unreadCount ?? 0,
                  selectedMapType: _selectedMapType,
                  onTypeSelected: (type) async {
                    if (type == 'rent') {
                      final hasAccess = await _showRentalUnlockModal(context);
                      if (!hasAccess || !context.mounted) {
                        return;
                      }
                    }

                    if (_selectedMapType == type) {
                      return;
                    }

                    setState(() {
                      _selectedMapType = type;
                    });
                    _loadMapPins();
                  },
                  onSubmitted: (_) => _searchLocation(),
                  onSearchTap: _openSearchPage,
                  onSearchFieldTap: _openSearchPage,
                  onFilterTap: _openFilterPage,
                  onNotificationTap: _openNotificationPage,
                  onMenuTap: _openListingsDashboard,
                ),
              ),
              Positioned(
                right: 20,
                bottom: 132,
                child: Column(
                  children: [
                    _MapFloatingButton(
                      icon: _mapType == MapType.normal
                          ? Icons.satellite_alt_outlined
                          : Icons.map_outlined,
                      label: _mapType == MapType.normal ? 'Satellite' : 'Map',
                      onTap: () => unawaited(_toggleMapType()),
                    ),
                    const SizedBox(height: 12),
                    _MapFloatingButton(
                      icon: Icons.my_location,
                      label: 'Nearby',
                      onTap: _moveNearby,
                    ),
                  ],
                ),
              ),
              if (_streetViewPosition != null)
                Positioned(
                  left: 16,
                  bottom: 166,
                  child: _StreetViewPreviewCard(
                    position: _streetViewPosition!,
                    isLoading: _isLoadingStreetView,
                    isAvailable: _hasStreetView,
                    onTap: _hasStreetView
                        ? () => _openStreetViewAt(_streetViewPosition!)
                        : null,
                    onDetails: _showSelectedPlaceDetails,
                    onClose: () {
                      setState(() {
                        _streetViewRequestId++;
                        _streetViewPosition = null;
                        _hasStreetView = false;
                        _selectedPlacePosition = null;
                        _selectedPlaceDetails = null;
                      });
                    },
                  ),
                ),
              Positioned(
                left: 20,
                bottom: 104,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.48),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    child: Text(
                      '${_mapHomes.length} of ${_allMapHomes.length} homes',
                      style: AppTypography.authButtonLabel.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: -AppScale.size(context, 12),
                child: _DashboardBottomNav(
                  selectedIndex: _selectedNavIndex,
                  bottomPadding: AppSpacing.xs(context),
                  onItemSelected: (index) {
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

                    if (index == 2) {
                      AppLoadingOverlay.push<void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const _DashboardProfilePage(),
                        ),
                        destinationKey: 'profile',
                      );
                      return;
                    }

                    setState(() {
                      _selectedNavIndex = index;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StreetViewPreviewCard extends StatelessWidget {
  const _StreetViewPreviewCard({
    required this.position,
    required this.isLoading,
    required this.isAvailable,
    required this.onTap,
    required this.onDetails,
    required this.onClose,
  });

  final LatLng position;
  final bool isLoading;
  final bool isAvailable;
  final VoidCallback? onTap;
  final VoidCallback onDetails;
  final VoidCallback onClose;

  String get _imageUrl =>
      Uri.https('maps.googleapis.com', '/maps/api/streetview', <String, String>{
        'size': '640x480',
        'location': '${position.latitude},${position.longitude}',
        'fov': '90',
        'pitch': '0',
        'key': EndpointConstant.googleMapsApiKey,
      }).toString();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 8,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: AppScale.size(context, 164),
          height: AppScale.size(context, 132),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (isAvailable)
                Image.network(
                  _imageUrl,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                  loadingBuilder: (context, child, progress) => progress == null
                      ? child
                      : const ColoredBox(
                          color: Color(0xFFF1F3F5),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                  errorBuilder: (_, _, _) => const _StreetViewUnavailable(),
                )
              else if (isLoading)
                const ColoredBox(
                  color: Color(0xFFF1F3F5),
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                const _StreetViewUnavailable(),
              if (isAvailable)
                Positioned(
                  left: 8,
                  bottom: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.threesixty, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Street View',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Positioned(
                left: 5,
                top: 5,
                child: Material(
                  color: Colors.black.withValues(alpha: 0.66),
                  borderRadius: BorderRadius.circular(99),
                  child: InkWell(
                    onTap: onDetails,
                    borderRadius: BorderRadius.circular(99),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.white,
                            size: 15,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Details',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 5,
                top: 5,
                child: Material(
                  color: Colors.black.withValues(alpha: 0.66),
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: onClose,
                    customBorder: const CircleBorder(),
                    child: const Padding(
                      padding: EdgeInsets.all(5),
                      child: Icon(Icons.close, color: Colors.white, size: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StreetViewUnavailable extends StatelessWidget {
  const _StreetViewUnavailable();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF1F3F5),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.streetview, color: Color(0xFF6A6A6A), size: 30),
              const SizedBox(height: 6),
              Text(
                'Street View unavailable here',
                textAlign: TextAlign.center,
                style: AppTypography.authBody.copyWith(
                  color: const Color(0xFF4A4A4A),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TappedPlaceDetails {
  const _TappedPlaceDetails({
    required this.name,
    required this.address,
    required this.placeId,
    required this.latitude,
    required this.longitude,
    required this.plusCode,
    required this.types,
    required this.addressParts,
    this.rating,
    this.totalRatings,
    this.isOpen,
  });

  final String name;
  final String address;
  final String placeId;
  final double latitude;
  final double longitude;
  final String plusCode;
  final List<String> types;
  final Map<String, String> addressParts;
  final double? rating;
  final int? totalRatings;
  final bool? isOpen;

  factory _TappedPlaceDetails.fromGoogleResponses({
    required LatLng position,
    required Map<String, dynamic> geocodeData,
    required Map<String, dynamic> nearbyData,
  }) {
    final geocodeResults = geocodeData['results'];
    final geocode = geocodeResults is List && geocodeResults.isNotEmpty
        ? _jsonMap(geocodeResults.first)
        : const <String, dynamic>{};
    final nearbyResults = nearbyData['results'];
    final nearby = nearbyResults is List && nearbyResults.isNotEmpty
        ? _jsonMap(nearbyResults.first)
        : const <String, dynamic>{};
    final openingHours = _jsonMap(nearby['opening_hours']);
    final plusCodeData = _jsonMap(geocodeData['plus_code']);

    final addressParts = <String, String>{};
    final components = geocode['address_components'];
    if (components is List) {
      for (final componentValue in components) {
        final component = _jsonMap(componentValue);
        final types = component['types'];
        final type = types is List && types.isNotEmpty
            ? types.first.toString()
            : '';
        final label = _addressComponentLabel(type);
        final value = component['long_name']?.toString().trim() ?? '';
        if (label.isNotEmpty && value.isNotEmpty) {
          addressParts[label] = value;
        }
      }
    }

    final rawTypes = nearby['types'] ?? geocode['types'];
    final types = rawTypes is List
        ? rawTypes
              .map((type) => _formatPlaceType(type.toString()))
              .where((type) => type.isNotEmpty)
              .toSet()
              .toList()
        : const <String>[];

    return _TappedPlaceDetails(
      name: nearby['name']?.toString().trim() ?? '',
      address:
          geocode['formatted_address']?.toString().trim() ??
          nearby['vicinity']?.toString().trim() ??
          '',
      placeId:
          nearby['place_id']?.toString().trim() ??
          geocode['place_id']?.toString().trim() ??
          '',
      latitude: position.latitude,
      longitude: position.longitude,
      plusCode: plusCodeData['compound_code']?.toString().trim() ?? '',
      types: types,
      addressParts: addressParts,
      rating: nearby['rating'] is num
          ? (nearby['rating'] as num).toDouble()
          : null,
      totalRatings: nearby['user_ratings_total'] is num
          ? (nearby['user_ratings_total'] as num).toInt()
          : null,
      isOpen: openingHours['open_now'] is bool
          ? openingHours['open_now'] as bool
          : null,
    );
  }

  static Map<String, dynamic> _jsonMap(Object? value) {
    return value is Map<String, dynamic> ? value : const <String, dynamic>{};
  }

  static String _addressComponentLabel(String type) {
    return switch (type) {
      'street_number' => 'Street number',
      'route' => 'Street',
      'neighborhood' => 'Neighbourhood',
      'sublocality' || 'sublocality_level_1' => 'Area',
      'locality' => 'City',
      'administrative_area_level_1' => 'State',
      'administrative_area_level_2' => 'Local government',
      'country' => 'Country',
      'postal_code' => 'Postal code',
      _ => '',
    };
  }

  static String _formatPlaceType(String value) {
    if (value.isEmpty) return '';
    return value
        .split('_')
        .where((word) => word.isNotEmpty)
        .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }
}

class _TappedPlaceDetailsSheet extends StatelessWidget {
  const _TappedPlaceDetailsSheet({required this.details});

  final _TappedPlaceDetails details;

  @override
  Widget build(BuildContext context) {
    final rows = <MapEntry<String, String>>[
      if (details.address.isNotEmpty) MapEntry('Address', details.address),
      ...details.addressParts.entries,
      MapEntry(
        'Coordinates',
        '${details.latitude.toStringAsFixed(6)}, ${details.longitude.toStringAsFixed(6)}',
      ),
      if (details.types.isNotEmpty)
        MapEntry('Place type', details.types.join(', ')),
      if (details.plusCode.isNotEmpty) MapEntry('Plus code', details.plusCode),
      if (details.rating != null)
        MapEntry(
          'Rating',
          '${details.rating}${details.totalRatings == null ? '' : ' (${details.totalRatings} reviews)'}',
        ),
      if (details.isOpen != null)
        MapEntry('Open now', details.isOpen! ? 'Yes' : 'No'),
      if (details.placeId.isNotEmpty)
        MapEntry('Google place ID', details.placeId),
    ];

    return SafeArea(
      top: false,
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.58,
        minChildSize: 0.35,
        maxChildSize: 0.9,
        builder: (context, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 28),
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD0D0D0),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on,
                  color: AppColors.primary,
                  size: 30,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    details.name.isEmpty ? 'Selected location' : details.name,
                    style: AppTypography.authBody.copyWith(
                      color: Colors.black,
                      fontSize: AppScale.text(context, 23),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            ...rows.map(
              (row) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.key,
                      style: AppTypography.authBody.copyWith(
                        color: const Color(0xFF6A6A6A),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 3),
                    SelectableText(
                      row.value,
                      style: AppTypography.authBody.copyWith(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardTopControls extends StatelessWidget {
  const _DashboardTopControls({
    required this.controller,
    required this.isSearching,
    required this.searchError,
    required this.unreadCount,
    required this.selectedMapType,
    required this.onTypeSelected,
    required this.onSubmitted,
    required this.onSearchTap,
    required this.onSearchFieldTap,
    required this.onFilterTap,
    required this.onNotificationTap,
    required this.onMenuTap,
  });

  final TextEditingController controller;
  final bool isSearching;
  final String? searchError;
  final int unreadCount;
  final String selectedMapType;
  final ValueChanged<String> onTypeSelected;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onSearchTap;
  final VoidCallback onSearchFieldTap;
  final VoidCallback onFilterTap;
  final VoidCallback onNotificationTap;
  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
        child: Column(
          children: [
            Row(
              children: [
                _TopMapIconButton(
                  assetPath: 'assets/icons/notification-2.svg',
                  iconSize: AppSizes.iconLg(context),
                  badgeCount: unreadCount,
                  onTap: onNotificationTap,
                ),
                const SizedBox(width: 16),
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
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: onSearchTap,
                          padding: EdgeInsets.only(
                            left: AppSpacing.lg(context),
                            right: AppSpacing.md(context),
                          ),
                          constraints: BoxConstraints(
                            minWidth: AppScale.size(context, 48),
                            minHeight: 40,
                          ),
                          icon: isSearching
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                )
                              : const Icon(
                                  Icons.search,
                                  color: Color(0xFF5F6260),
                                  size: 22,
                                ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: controller,
                            readOnly: true,
                            onTap: onSearchFieldTap,
                            onSubmitted: onSubmitted,
                            textInputAction: TextInputAction.search,
                            maxLines: 1,
                            decoration: const InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              isDense: true,
                              hintText: 'Search location',
                              hintStyle: TextStyle(
                                color: Color(0xFFB8B8B8),
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                height: 1.2,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 0,
                              ),
                            ),
                            style: AppTypography.authBody.copyWith(
                              color: const Color(0xFFB8B8B8),
                              fontWeight: FontWeight.w400,
                              fontSize: AppScale.text(context, 16),
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
                const SizedBox(width: 16),
                _TopMapIconButton(
                  assetPath: 'assets/icons/menu.png',
                  iconSize: 24,
                  onTap: onMenuTap,
                ),
              ],
            ),
            if (searchError != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.center,
                child: Text(
                  searchError!,
                  style: AppTypography.authBody.copyWith(
                    color: AppColors.error,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 22),
            Row(
              children: [
                _PillButton(
                  label: 'For Sale',
                  selected: selectedMapType == 'sale',
                  onTap: () => onTypeSelected('sale'),
                ),
                const SizedBox(width: 12),
                _PillButton(
                  label: 'For Rent',
                  selected: selectedMapType == 'rent',
                  onTap: () => onTypeSelected('rent'),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: onFilterTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size(78, 38),
                    fixedSize: const Size(78, 38),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: AppColors.primary),
                    ),
                    textStyle: AppTypography.authButtonLabel.copyWith(
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  icon: const Text('Filter'),
                  label: const Icon(Icons.filter_alt_outlined, size: 18),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MapSearchPage extends StatefulWidget {
  const _MapSearchPage({required this.initialQuery});

  final String initialQuery;

  @override
  State<_MapSearchPage> createState() => _MapSearchPageState();
}

class _MapSearchPageState extends State<_MapSearchPage> {
  late final TextEditingController _controller;
  late final PropertyPlacesCubit _propertyPlacesCubit;
  Timer? _placesDebounce;
  String _query = '';

  static const List<_PlaceSuggestion> _fallbackPlaces = [
    _PlaceSuggestion(
      title: 'Lekki Lagos',
      subtitle: 'Admiralty way',
      queryText: 'Lekki Lagos, Admiralty way',
    ),
    _PlaceSuggestion(
      title: 'Victoria Island',
      subtitle: 'Akin Adesola',
      queryText: 'Victoria Island, Akin Adesola',
    ),
    _PlaceSuggestion(
      title: 'Yaba Lagos',
      subtitle: 'Herbert Macaulay',
      queryText: 'Yaba Lagos, Herbert Macaulay',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _propertyPlacesCubit = getIt<PropertyPlacesCubit>();
    final normalizedQuery = _normalizeInitialQuery(widget.initialQuery);
    _controller = TextEditingController(text: normalizedQuery);
    _query = normalizedQuery;

    if (_query.isNotEmpty) {
      _searchPlaces(_query);
    }
  }

  String _normalizeInitialQuery(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return '';
    }
    if (trimmed == _DashboardMapPageState._defaultSearchText ||
        trimmed.toLowerCase().startsWith('ikeja lagos')) {
      return '';
    }
    return trimmed;
  }

  @override
  void dispose() {
    _placesDebounce?.cancel();
    _propertyPlacesCubit.close();
    _controller.dispose();
    super.dispose();
  }

  void _searchPlaces(String query) {
    _placesDebounce?.cancel();

    _placesDebounce = Timer(const Duration(milliseconds: 320), () {
      _propertyPlacesCubit.searchPlaces(query);
    });
  }

  void _selectLocation(String location) {
    Navigator.of(context).pop(_MapSearchResult.query(location));
  }

  void _selectCurrentLocation() {
    Navigator.of(context).pop(const _MapSearchResult.currentLocation());
  }

  @override
  Widget build(BuildContext context) {
    final pagePadding = AppSpacing.xl(context);
    final topInputHeight = AppScale.size(context, 42);
    final radius = AppScale.radius(context, 999);
    final maxControlWidth = AppScale.size(context, 400);
    final hasQuery = _query.isNotEmpty;

    return BlocProvider<PropertyPlacesCubit>.value(
      value: _propertyPlacesCubit,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  pagePadding,
                  AppSpacing.lg(context),
                  pagePadding,
                  AppSpacing.xl(context),
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
                        color: Colors.black,
                        size: AppSizes.iconLg(context),
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm(context)),
                    Expanded(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxControlWidth),
                        child: SizedBox(
                          height: topInputHeight,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8E8E8),
                              borderRadius: BorderRadius.circular(radius),
                            ),
                            child: Row(
                              children: [
                                SizedBox(width: AppSpacing.lg(context)),
                                Icon(
                                  Icons.search,
                                  color: Colors.white,
                                  size: AppSizes.iconMd(context),
                                ),
                                SizedBox(width: AppSpacing.sm(context)),
                                Expanded(
                                  child: TextField(
                                    controller: _controller,
                                    autofocus: true,
                                    maxLines: 1,
                                    textInputAction: TextInputAction.search,
                                    onChanged: (value) {
                                      setState(() {
                                        _query = value.trim();
                                      });
                                      _searchPlaces(value);
                                    },
                                    onSubmitted: (value) {
                                      final query = value.trim();
                                      if (query.isNotEmpty) {
                                        _selectLocation(query);
                                      }
                                    },
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      errorBorder: InputBorder.none,
                                      focusedErrorBorder: InputBorder.none,
                                      disabledBorder: InputBorder.none,
                                      isDense: true,
                                      hintText: 'Search location',
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    style: AppTypography.authBody.copyWith(
                                      color: AppColors.authText,
                                      fontSize: AppScale.text(context, 15),
                                      fontWeight: FontWeight.w500,
                                      height: 1.4,
                                      letterSpacing: 0,
                                    ),
                                  ),
                                ),
                                if (hasQuery)
                                  IconButton(
                                    onPressed: () {
                                      _controller.clear();
                                      setState(() {
                                        _query = '';
                                      });
                                      _searchPlaces('');
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: BoxConstraints.tight(
                                      Size(
                                        AppScale.size(context, 34),
                                        AppScale.size(context, 34),
                                      ),
                                    ),
                                    icon: Icon(
                                      Icons.cancel_outlined,
                                      color: Colors.black,
                                      size: AppSizes.iconMd(context),
                                    ),
                                  )
                                else
                                  SizedBox(width: AppSpacing.lg(context)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFEDEDED)),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    pagePadding,
                    AppSpacing.xxl(context),
                    pagePadding,
                    AppSpacing.xxl(context),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: maxControlWidth,
                          ),
                          child: const _SearchPurposeToggle(),
                        ),
                      ),
                      SizedBox(height: AppSpacing.section(context)),
                      InkWell(
                        onTap: _selectCurrentLocation,
                        borderRadius: BorderRadius.circular(
                          AppScale.radius(context, 12),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: AppSpacing.sm(context),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.my_location,
                                color: Colors.black,
                                size: AppScale.size(context, 32),
                              ),
                              SizedBox(width: AppSpacing.xl(context)),
                              Text(
                                'Use current location',
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
                        ),
                      ),
                      if (hasQuery)
                        BlocBuilder<PropertyPlacesCubit, PropertyPlacesState>(
                          builder: (context, state) {
                            final liveSuggestions = state.places
                                .map(
                                  (place) => _PlaceSuggestion(
                                    title: place.city,
                                    subtitle: '${place.area}, ${place.state}',
                                    queryText:
                                        '${place.area}, ${place.city}, ${place.state}',
                                  ),
                                )
                                .toList();
                            final suggestions = liveSuggestions.isNotEmpty
                                ? liveSuggestions
                                : _fallbackPlaces;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: AppSpacing.xxl(context)),
                                Text(
                                  'Places',
                                  style: AppTypography.authBody.copyWith(
                                    color: Colors.black,
                                    fontSize: AppScale.text(context, 17),
                                    fontWeight: FontWeight.w700,
                                    height: 1.4,
                                    letterSpacing: 0,
                                  ),
                                ),
                                SizedBox(height: AppSpacing.xl(context)),
                                if (state.status ==
                                    PropertyPlacesStatus.loading)
                                  const Center(
                                    child: Padding(
                                      padding: EdgeInsets.only(bottom: 12),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                ...suggestions.map(
                                  (place) => _PlaceSuggestionTile(
                                    place: place,
                                    onTap: () =>
                                        _selectLocation(place.queryText),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchPurposeToggle extends StatelessWidget {
  const _SearchPurposeToggle();

  @override
  Widget build(BuildContext context) {
    final height = AppScale.size(context, 42);
    final radius = AppScale.radius(context, 999);

    return SizedBox(
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF880101),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: const Color(0xFFE8E8E8)),
        ),
        child: Row(
          children: [
            Expanded(
              child: _SearchPurposeSegment(
                label: 'For Sale',
                backgroundColor: const Color(0xFFE10201),
                borderRadius: BorderRadius.circular(radius),
              ),
            ),
            Expanded(
              child: _SearchPurposeSegment(
                label: 'For Rent',
                backgroundColor: const Color(0xFF880101),
                borderRadius: BorderRadius.circular(radius),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchPurposeSegment extends StatelessWidget {
  const _SearchPurposeSegment({
    required this.label,
    required this.backgroundColor,
    required this.borderRadius,
  });

  final String label;
  final Color backgroundColor;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
      ),
      child: Center(
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.authButtonLabel.copyWith(
            color: Colors.white,
            fontSize: AppScale.text(context, 13),
            fontWeight: FontWeight.w600,
            height: 1.4,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class _PlaceSuggestionTile extends StatelessWidget {
  const _PlaceSuggestionTile({required this.place, required this.onTap});

  final _PlaceSuggestion place;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppScale.radius(context, 12)),
      child: Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.xl(context)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: AppSpacing.xs(context)),
              child: Icon(
                Icons.location_on,
                color: const Color(0xFF5C5D5D),
                size: AppScale.size(context, 34),
              ),
            ),
            SizedBox(width: AppSpacing.xl(context)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.title,
                    style: AppTypography.authBody.copyWith(
                      color: Colors.black,
                      fontSize: AppScale.text(context, 19),
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                      letterSpacing: 0,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs(context)),
                  Text(
                    place.subtitle,
                    style: AppTypography.authBody.copyWith(
                      color: Colors.black,
                      fontSize: AppScale.text(context, 17),
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceSuggestion {
  const _PlaceSuggestion({
    required this.title,
    required this.subtitle,
    required this.queryText,
  });

  final String title;
  final String subtitle;
  final String queryText;
}

class _MapSearchResult {
  const _MapSearchResult.query(this.query) : useCurrentLocation = false;

  const _MapSearchResult.currentLocation()
    : query = '',
      useCurrentLocation = true;

  final String query;
  final bool useCurrentLocation;
}

class _MapFilterResult {
  const _MapFilterResult({this.selectedType, this.minPrice, this.maxPrice});

  final _PropertyFilterType? selectedType;
  final int? minPrice;
  final int? maxPrice;

  bool matches(_MapHome home) {
    if (!_matchesType(home)) {
      return false;
    }

    if (minPrice != null && home.price < minPrice!) {
      return false;
    }

    if (maxPrice != null && home.price > maxPrice!) {
      return false;
    }

    return true;
  }

  bool _matchesType(_MapHome home) {
    if (selectedType == null) {
      return true;
    }

    final typeValue = home.type.toLowerCase();
    final categoryValue = home.category.toLowerCase();

    switch (selectedType!) {
      case _PropertyFilterType.land:
        return typeValue.contains('land') || categoryValue.contains('land');
      case _PropertyFilterType.house:
        final isLand =
            typeValue.contains('land') || categoryValue.contains('land');
        final isShortLet =
            typeValue.contains('short') || categoryValue.contains('short');
        return !isLand && !isShortLet;
      case _PropertyFilterType.shortLet:
        return typeValue.contains('short') || categoryValue.contains('short');
    }
  }
}

class _NotificationCenterPage extends StatefulWidget {
  const _NotificationCenterPage();

  @override
  State<_NotificationCenterPage> createState() =>
      _NotificationCenterPageState();
}

class _NotificationCenterPageState extends State<_NotificationCenterPage> {
  int _selectedIndex = 0;
  late final NotificationCubit _notificationCubit;

  @override
  void initState() {
    super.initState();
    _notificationCubit = getIt<NotificationCubit>();
    _notificationCubit.fetchNotifications();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          _notificationCubit.state.status != NotificationStatus.loading) {
        return;
      }
      AppLoadingOverlay.show(
        context,
        title: 'Opening notifications',
        subtitle: 'Checking for your latest updates',
      );
    });
  }

  @override
  void dispose() {
    _notificationCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NotificationCubit>.value(
      value: _notificationCubit,
      child: BlocConsumer<NotificationCubit, NotificationState>(
        listener: (context, state) {
          if (state.status != NotificationStatus.loading) {
            AppLoadingOverlay.hide();
          }
        },
        builder: (context, state) {
          final notifications = state.result?.notifications ?? const [];
          final unreadCount = state.result?.unreadCount ?? 0;

          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.xxl(context),
                      AppSpacing.xxl(context),
                      AppSpacing.xxl(context),
                      AppSpacing.lg(context),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
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
                          color: const Color(0xFF333333),
                          size: AppSizes.iconLg(context),
                        ),
                      ),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _NotificationTabButton(
                                label: 'Notification',
                                count: unreadCount,
                                selected: _selectedIndex == 0,
                                onTap: () {
                                  setState(() {
                                    _selectedIndex = 0;
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: _NotificationTabButton(
                                label: 'Message',
                                count: 0,
                                selected: _selectedIndex == 1,
                                onTap: () {
                                  setState(() {
                                    _selectedIndex = 1;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                height: AppScale.size(context, 2),
                                color: _selectedIndex == 0
                                    ? const Color(0xFF880101)
                                    : Colors.transparent,
                              ),
                            ),
                            Expanded(
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                height: AppScale.size(context, 2),
                                color: _selectedIndex == 1
                                    ? const Color(0xFF880101)
                                    : Colors.transparent,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _selectedIndex == 1
                        ? const _MessageEmptyState()
                        : _NotificationBody(
                            state: state,
                            notifications: notifications,
                            onRetry: _notificationCubit.fetchNotifications,
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NotificationBody extends StatelessWidget {
  const _NotificationBody({
    required this.state,
    required this.notifications,
    required this.onRetry,
  });

  final NotificationState state;
  final List<AppNotification> notifications;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (state.status == NotificationStatus.loading && notifications.isEmpty) {
      return const SizedBox.shrink();
    }

    if (state.status == NotificationStatus.failure && notifications.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxl(context)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                state.errorMessage ?? 'Unable to load notifications.',
                textAlign: TextAlign.center,
                style: AppTypography.authBody.copyWith(color: Colors.black),
              ),
              SizedBox(height: AppSpacing.lg(context)),
              ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    if (notifications.isEmpty) return const _NotificationEmptyState();

    return RefreshIndicator(
      onRefresh: () async => onRetry(),
      child: ListView.separated(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.xl(context),
          vertical: AppSpacing.lg(context),
        ),
        itemCount: notifications.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) =>
            _NotificationListTile(notification: notifications[index]),
      ),
    );
  }
}

class _NotificationListTile extends StatelessWidget {
  const _NotificationListTile({required this.notification});

  final AppNotification notification;

  String _timeText(DateTime? value) {
    if (value == null) return '';
    final now = DateTime.now();
    final difference = now.difference(value);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return '${value.day}/${value.month}/${value.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: notification.isRead ? Colors.white : const Color(0xFFFFF5F5),
      padding: EdgeInsets.symmetric(vertical: AppSpacing.lg(context)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: AppScale.size(context, 42),
            height: AppScale.size(context, 42),
            decoration: const BoxDecoration(
              color: Color(0xFFFFE8E8),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: AppSpacing.md(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: AppTypography.authBody.copyWith(
                          color: Colors.black,
                          fontSize: AppScale.text(context, 16),
                          fontWeight: notification.isRead
                              ? FontWeight.w500
                              : FontWeight.w700,
                        ),
                      ),
                    ),
                    if (!notification.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                if (notification.message.isNotEmpty) ...[
                  SizedBox(height: AppSpacing.xs(context)),
                  Text(
                    notification.message,
                    style: AppTypography.authBody.copyWith(
                      color: const Color(0xFF5C5D5D),
                      fontSize: AppScale.text(context, 14),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
                if (_timeText(notification.createdAt).isNotEmpty) ...[
                  SizedBox(height: AppSpacing.xs(context)),
                  Text(
                    _timeText(notification.createdAt),
                    style: AppTypography.authBody.copyWith(
                      color: const Color(0xFF8A8A8A),
                      fontSize: AppScale.text(context, 12),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationTabButton extends StatelessWidget {
  const _NotificationTabButton({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: AppScale.size(context, 54),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: AppTypography.authBody.copyWith(
                color: const Color(0xFF17211D),
                fontSize: AppScale.text(context, 17),
                fontWeight: FontWeight.w500,
                height: 1.4,
                letterSpacing: 0,
              ),
            ),
            SizedBox(width: AppSpacing.sm(context)),
            _NotificationCountBadge(count: count),
          ],
        ),
      ),
    );
  }
}

class _NotificationCountBadge extends StatelessWidget {
  const _NotificationCountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppScale.size(context, 20),
      height: AppScale.size(context, 20),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE1E6DE)),
      ),
      child: Text(
        '$count',
        textAlign: TextAlign.center,
        style: AppTypography.authBody.copyWith(
          color: AppColors.primary,
          fontSize: AppScale.text(context, 11),
          fontWeight: FontWeight.w500,
          height: 1,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _NotificationEmptyState extends StatelessWidget {
  const _NotificationEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        'assets/icons/noteicon.png',
        width: AppScale.size(context, 230),
        fit: BoxFit.contain,
      ),
    );
  }
}

class _MessageEmptyState extends StatelessWidget {
  const _MessageEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/icons/mail.svg',
            width: AppScale.size(context, 72),
            height: AppScale.size(context, 72),
            fit: BoxFit.contain,
          ),
          SizedBox(height: AppSpacing.xl(context)),
          Text(
            'No message',
            textAlign: TextAlign.center,
            style: AppTypography.authBody.copyWith(
              color: const Color(0xFF5C5D5D),
              fontSize: AppScale.text(context, 23),
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

enum _PropertyFilterType { land, house, shortLet }

class _MapFilterPage extends StatefulWidget {
  const _MapFilterPage({required this.initialFilter, required this.homes});

  final _MapFilterResult initialFilter;
  final List<_MapHome> homes;

  @override
  State<_MapFilterPage> createState() => _MapFilterPageState();
}

class _MapFilterPageState extends State<_MapFilterPage> {
  _PropertyFilterType? _selectedType;
  String _minPrice = 'No min';
  String _maxPrice = 'No max';

  static const List<String> _minPrices = [
    'No min',
    '₦150k',
    '₦300k',
    '₦500k',
    '₦800k',
    '₦1M',
    '₦1.5M',
    '₦2M',
    '₦2.5M',
    '₦3M',
  ];

  static const List<String> _maxPrices = [
    'No max',
    '₦7M',
    '₦7.5M',
    '₦10M',
    '₦15M',
    '₦20M',
    '₦50M',
    '₦100M',
    '₦150M',
    '₦200M',
  ];

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialFilter.selectedType;
    _minPrice = _labelFromPrice(
      widget.initialFilter.minPrice,
      fallbackLabel: 'No min',
      options: _minPrices,
    );
    _maxPrice = _labelFromPrice(
      widget.initialFilter.maxPrice,
      fallbackLabel: 'No max',
      options: _maxPrices,
    );
  }

  int get _homeCount {
    final filter = _MapFilterResult(
      selectedType: _selectedType,
      minPrice: _priceFromLabel(_minPrice),
      maxPrice: _priceFromLabel(_maxPrice),
    );

    return widget.homes.where(filter.matches).length;
  }

  int? _priceFromLabel(String label) {
    final normalized = label.replaceAll('₦', '').replaceAll(',', '').trim();
    if (normalized == 'No min' || normalized == 'No max') {
      return null;
    }

    if (normalized.endsWith('k')) {
      final value = double.tryParse(
        normalized.substring(0, normalized.length - 1),
      );
      if (value == null) {
        return null;
      }
      return (value * 1000).round();
    }

    if (normalized.endsWith('M')) {
      final value = double.tryParse(
        normalized.substring(0, normalized.length - 1),
      );
      if (value == null) {
        return null;
      }
      return (value * 1000000).round();
    }

    return int.tryParse(normalized);
  }

  String _labelFromPrice(
    int? price, {
    required String fallbackLabel,
    required List<String> options,
  }) {
    if (price == null) {
      return fallbackLabel;
    }

    for (final option in options) {
      if (_priceFromLabel(option) == price) {
        return option;
      }
    }

    return fallbackLabel;
  }

  @override
  Widget build(BuildContext context) {
    final pagePadding = AppSpacing.xl(context);
    final maxControlWidth = AppScale.size(context, 400);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                pagePadding,
                AppSpacing.xl(context),
                pagePadding,
                AppSpacing.xl(context),
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
                      color: Colors.black,
                      size: AppSizes.iconLg(context),
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm(context)),
                  Text(
                    'Filters',
                    style: AppTypography.authBody.copyWith(
                      color: Colors.black,
                      fontSize: AppScale.text(context, 19),
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFEDEDED)),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  pagePadding,
                  AppSpacing.xxl(context),
                  pagePadding,
                  AppSpacing.xxl(context),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxControlWidth),
                        child: const _SearchPurposeToggle(),
                      ),
                    ),
                    SizedBox(height: AppSpacing.xxl(context)),
                    const Divider(height: 1, color: Color(0xFFEDEDED)),
                    SizedBox(height: AppSpacing.xxl(context)),
                    _FilterSectionTitle(label: 'Select Type'),
                    SizedBox(height: AppSpacing.xl(context)),
                    Row(
                      children: [
                        Expanded(
                          child: _FilterTypeCard(
                            label: 'Land',
                            type: _PropertyFilterType.land,
                            selected: _selectedType == _PropertyFilterType.land,
                            onTap: () {
                              setState(() {
                                _selectedType = _PropertyFilterType.land;
                              });
                            },
                          ),
                        ),
                        SizedBox(width: AppSpacing.lg(context)),
                        Expanded(
                          child: _FilterTypeCard(
                            label: 'House',
                            type: _PropertyFilterType.house,
                            selected:
                                _selectedType == _PropertyFilterType.house,
                            onTap: () {
                              setState(() {
                                _selectedType = _PropertyFilterType.house;
                              });
                            },
                          ),
                        ),
                        SizedBox(width: AppSpacing.lg(context)),
                        Expanded(
                          child: _FilterTypeCard(
                            label: 'Short-let',
                            type: _PropertyFilterType.shortLet,
                            selected:
                                _selectedType == _PropertyFilterType.shortLet,
                            onTap: () {
                              setState(() {
                                _selectedType = _PropertyFilterType.shortLet;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.xxl(context)),
                    const Divider(height: 1, color: Color(0xFFEDEDED)),
                    SizedBox(height: AppSpacing.xxl(context)),
                    _FilterSectionTitle(label: 'Price'),
                    SizedBox(height: AppSpacing.xl(context)),
                    Row(
                      children: [
                        Expanded(
                          child: _PricePicker(
                            value: _minPrice,
                            options: _minPrices,
                            onSelected: (value) {
                              setState(() {
                                _minPrice = value;
                              });
                            },
                          ),
                        ),
                        SizedBox(width: AppSpacing.xxl(context)),
                        Expanded(
                          child: _PricePicker(
                            value: _maxPrice,
                            options: _maxPrices,
                            onSelected: (value) {
                              setState(() {
                                _maxPrice = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, color: Color(0xFFEDEDED)),
            SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  pagePadding,
                  AppSpacing.lg(context),
                  pagePadding,
                  AppSpacing.lg(context),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: AppScale.size(context, 56),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(
                        _MapFilterResult(
                          selectedType: _selectedType,
                          minPrice: _priceFromLabel(_minPrice),
                          maxPrice: _priceFromLabel(_maxPrice),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppScale.radius(context, 8),
                        ),
                      ),
                      textStyle: AppTypography.authButtonLabel.copyWith(
                        fontSize: AppScale.text(context, 16),
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                        letterSpacing: 0,
                      ),
                    ),
                    child: Text(
                      'See $_homeCount homes',
                      textAlign: TextAlign.center,
                      style: AppTypography.authButtonLabel.copyWith(
                        color: Colors.black,
                        fontSize: AppScale.text(context, 16),
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                        letterSpacing: 0,
                      ),
                    ),
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

class _FilterSectionTitle extends StatelessWidget {
  const _FilterSectionTitle({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTypography.authBody.copyWith(
        color: Colors.black,
        fontSize: AppScale.text(context, 19),
        fontWeight: FontWeight.w600,
        height: 1.4,
        letterSpacing: 0,
      ),
    );
  }
}

class _FilterTypeCard extends StatelessWidget {
  const _FilterTypeCard({
    required this.label,
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final _PropertyFilterType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : Colors.black;

    return Material(
      color: selected ? const Color(0xFFFFE4E4) : Colors.white,
      borderRadius: BorderRadius.circular(AppScale.radius(context, 8)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppScale.radius(context, 8)),
        child: Container(
          height: AppScale.size(context, 132),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppScale.radius(context, 8)),
            border: Border.all(
              color: selected ? AppColors.primary : const Color(0xFF9B9B9B),
              width: 1.2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PropertyTypeIcon(
                type: type,
                color: color,
                size: AppScale.size(context, 48),
              ),
              SizedBox(height: AppSpacing.sm(context)),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTypography.authBody.copyWith(
                  color: color,
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
    );
  }
}

class _PropertyTypeIcon extends StatelessWidget {
  const _PropertyTypeIcon({
    required this.type,
    required this.color,
    required this.size,
  });

  final _PropertyFilterType type;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _PropertyTypeIconPainter(type: type, color: color),
    );
  }
}

class _PropertyTypeIconPainter extends CustomPainter {
  const _PropertyTypeIconPainter({required this.type, required this.color});

  final _PropertyFilterType type;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.065
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    switch (type) {
      case _PropertyFilterType.land:
        _paintLand(canvas, size, stroke);
      case _PropertyFilterType.house:
        _paintHouse(canvas, size, stroke);
      case _PropertyFilterType.shortLet:
        _paintShortLet(canvas, size, stroke);
    }
  }

  void _paintLand(Canvas canvas, Size size, Paint stroke) {
    final w = size.width;
    final h = size.height;

    canvas.drawLine(
      Offset(w * 0.50, h * 0.12),
      Offset(w * 0.50, h * 0.45),
      stroke,
    );
    final flag = Path()
      ..moveTo(w * 0.50, h * 0.14)
      ..lineTo(w * 0.78, h * 0.24)
      ..lineTo(w * 0.50, h * 0.36)
      ..close();
    canvas.drawPath(flag, stroke);

    final leftTile = Path()
      ..moveTo(w * 0.12, h * 0.66)
      ..lineTo(w * 0.38, h * 0.50)
      ..lineTo(w * 0.62, h * 0.66)
      ..lineTo(w * 0.36, h * 0.84)
      ..close();
    final rightTile = Path()
      ..moveTo(w * 0.62, h * 0.66)
      ..lineTo(w * 0.86, h * 0.50)
      ..lineTo(w * 0.88, h * 0.70)
      ..lineTo(w * 0.60, h * 0.88)
      ..lineTo(w * 0.36, h * 0.84);
    final backTile = Path()
      ..moveTo(w * 0.38, h * 0.50)
      ..lineTo(w * 0.64, h * 0.34)
      ..lineTo(w * 0.86, h * 0.50)
      ..lineTo(w * 0.62, h * 0.66);
    canvas.drawPath(leftTile, stroke);
    canvas.drawPath(rightTile, stroke);
    canvas.drawPath(backTile, stroke);
  }

  void _paintHouse(Canvas canvas, Size size, Paint stroke) {
    final w = size.width;
    final h = size.height;

    final roof = Path()
      ..moveTo(w * 0.18, h * 0.50)
      ..lineTo(w * 0.50, h * 0.22)
      ..lineTo(w * 0.82, h * 0.50);
    final body = Path()
      ..moveTo(w * 0.28, h * 0.46)
      ..lineTo(w * 0.28, h * 0.82)
      ..lineTo(w * 0.72, h * 0.82)
      ..lineTo(w * 0.72, h * 0.46);
    final door = Path()
      ..moveTo(w * 0.44, h * 0.82)
      ..lineTo(w * 0.44, h * 0.60)
      ..lineTo(w * 0.56, h * 0.60)
      ..lineTo(w * 0.56, h * 0.82);
    canvas.drawPath(roof, stroke);
    canvas.drawPath(body, stroke);
    canvas.drawPath(door, stroke);
  }

  void _paintShortLet(Canvas canvas, Size size, Paint stroke) {
    final w = size.width;
    final h = size.height;

    final front = Path()
      ..moveTo(w * 0.24, h * 0.30)
      ..lineTo(w * 0.58, h * 0.16)
      ..lineTo(w * 0.58, h * 0.86)
      ..lineTo(w * 0.24, h * 0.80)
      ..close();
    final side = Path()
      ..moveTo(w * 0.58, h * 0.36)
      ..lineTo(w * 0.82, h * 0.46)
      ..lineTo(w * 0.82, h * 0.82)
      ..lineTo(w * 0.58, h * 0.86);
    canvas.drawPath(front, stroke);
    canvas.drawPath(side, stroke);
    canvas.drawLine(
      Offset(w * 0.70, h * 0.42),
      Offset(w * 0.70, h * 0.30),
      stroke,
    );

    for (final offset in const [
      Offset(0.36, 0.42),
      Offset(0.36, 0.58),
      Offset(0.46, 0.70),
      Offset(0.70, 0.58),
      Offset(0.70, 0.72),
    ]) {
      canvas.drawCircle(
        Offset(w * offset.dx, h * offset.dy),
        w * 0.018,
        stroke,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PropertyTypeIconPainter oldDelegate) {
    return oldDelegate.type != type || oldDelegate.color != color;
  }
}

class _PricePicker extends StatelessWidget {
  const _PricePicker({
    required this.value,
    required this.options,
    required this.onSelected,
  });

  final String value;
  final List<String> options;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onSelected,
      constraints: BoxConstraints(minWidth: AppScale.size(context, 130)),
      itemBuilder: (context) => options
          .map(
            (option) => PopupMenuItem<String>(
              value: option,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    option,
                    style: AppTypography.authBody.copyWith(
                      color: Colors.black,
                      fontSize: AppScale.text(context, 17),
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                      letterSpacing: 0,
                    ),
                  ),
                  if (option == value)
                    Icon(
                      Icons.check,
                      color: Colors.black,
                      size: AppSizes.iconMd(context),
                    ),
                ],
              ),
            ),
          )
          .toList(),
      child: Container(
        height: AppScale.size(context, 48),
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg(context)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppScale.radius(context, 8)),
          border: Border.all(color: const Color(0xFF9B9B9B), width: 1.2),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.authBody.copyWith(
                  color: Colors.black,
                  fontSize: AppScale.text(context, 17),
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                  letterSpacing: 0,
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              color: Colors.black,
              size: AppScale.size(context, 32),
            ),
          ],
        ),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({required this.label, required this.selected, this.onTap});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 83,
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? AppColors.authText : const Color(0xFFE2E2E2),
              width: 1,
            ),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              softWrap: false,
              textAlign: TextAlign.center,
              style: AppTypography.authBody.copyWith(
                color: selected ? AppColors.authText : const Color(0xFF535353),
                fontWeight: FontWeight.w500,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopMapIconButton extends StatelessWidget {
  const _TopMapIconButton({
    this.icon,
    this.assetPath,
    this.iconSize = 20,
    this.badgeCount = 0,
    this.onTap,
  }) : assert(icon != null || assetPath != null);

  final IconData? icon;
  final String? assetPath;
  final double iconSize;
  final int badgeCount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final child = SizedBox(
      width: 34,
      height: 34,
      child: Center(
        child: assetPath != null
            ? _TopMapAssetIcon(assetPath: assetPath!, iconSize: iconSize)
            : Icon(icon, color: AppColors.authText, size: iconSize),
      ),
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: Colors.white,
          shape: const CircleBorder(side: BorderSide(color: Color(0xFFE5E5E5))),
          elevation: 3,
          shadowColor: Colors.black.withValues(alpha: 0.18),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: child,
          ),
        ),
        if (badgeCount > 0)
          Positioned(
            right: -5,
            top: -6,
            child: Container(
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Text(
                badgeCount > 99 ? '99+' : '$badgeCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _TopMapAssetIcon extends StatelessWidget {
  const _TopMapAssetIcon({required this.assetPath, required this.iconSize});

  final String assetPath;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    if (assetPath.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(
        assetPath,
        width: iconSize,
        height: iconSize,
        fit: BoxFit.contain,
      );
    }

    return Image.asset(
      assetPath,
      width: iconSize,
      height: iconSize,
      fit: BoxFit.contain,
    );
  }
}

class _MapFloatingButton extends StatelessWidget {
  const _MapFloatingButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 74,
          height: 76,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.black, size: 27),
              const SizedBox(height: 6),
              Text(
                label,
                style: AppTypography.authBody.copyWith(
                  color: Colors.black,
                  fontSize: 14,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardBottomNav extends StatelessWidget {
  const _DashboardBottomNav({
    required this.selectedIndex,
    required this.onItemSelected,
    this.bottomPadding,
  });

  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final double? bottomPadding;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      constraints: BoxConstraints(minHeight: 80 + bottomInset),
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.xl(context),
            AppSpacing.sm(context),
            AppSpacing.xl(context),
            bottomPadding ?? AppSpacing.md(context),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppScale.radius(context, 22)),
              border: Border.all(color: const Color(0xFFE7ECE7)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm(context),
                vertical: AppSpacing.xs(context),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _BottomNavItem(
                      index: 0,
                      assetPath: 'assets/icons/home.svg',
                      label: 'Home',
                      active: selectedIndex == 0,
                      onTap: onItemSelected,
                    ),
                  ),
                  Expanded(
                    child: _BottomNavItem(
                      index: 1,
                      assetPath: 'assets/icons/heart.svg',
                      label: 'Favorite',
                      active: selectedIndex == 1,
                      onTap: onItemSelected,
                    ),
                  ),
                  Expanded(
                    child: _BottomNavItem(
                      index: 2,
                      assetPath: 'assets/icons/user.svg',
                      label: 'Profile',
                      active: selectedIndex == 2,
                      onTap: onItemSelected,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.index,
    required this.assetPath,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final int index;
  final String assetPath;
  final String label;
  final bool active;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final iconColor = active ? AppColors.primary : AppColors.mutedInk;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: BorderRadius.circular(AppScale.radius(context, 18)),
        child: AnimatedContainer(
          width: double.infinity,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm(context),
            vertical: AppSpacing.sm(context),
          ),
          decoration: BoxDecoration(
            color: active ? const Color(0xFFFFEEEE) : Colors.transparent,
            borderRadius: BorderRadius.circular(AppScale.radius(context, 18)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: AppScale.size(context, 28),
                height: AppScale.size(context, 28),
                child: Center(
                  child: _NavAssetIcon(assetPath: assetPath, color: iconColor),
                ),
              ),
              SizedBox(height: AppSpacing.xs(context)),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.authBody.copyWith(
                  color: active ? AppColors.authText : AppColors.mutedInk,
                  fontSize: AppScale.text(context, 12),
                  fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavAssetIcon extends StatelessWidget {
  const _NavAssetIcon({required this.assetPath, required this.color});

  final String assetPath;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (assetPath.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(
        assetPath,
        width: 28,
        height: 28,
        fit: BoxFit.contain,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      );
    }

    return Image.asset(
      assetPath,
      width: 28,
      height: 28,
      fit: BoxFit.contain,
      color: color,
      colorBlendMode: BlendMode.srcIn,
    );
  }
}

class _HomePreviewSheet extends StatelessWidget {
  const _HomePreviewSheet({
    required this.home,
    required this.onOpenDetails,
    required this.onOpenStreetView,
  });

  final _MapHome home;
  final VoidCallback onOpenDetails;
  final VoidCallback onOpenStreetView;

  String _formatNaira(int value) {
    final text = value.toString();
    final withCommas = text.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
    return '₦$withCommas';
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final edgeOffset = AppSpacing.xl(context);
    final rentPillWidth = AppScale.size(context, 77);
    final rentPillHeight = AppScale.size(context, 34);
    final streetViewButtonWidth = AppScale.size(context, 96);
    final favoriteSize = AppScale.size(context, 32);
    final listingTextStyle = AppTypography.authBody.copyWith(
      color: Colors.white,
      fontSize: AppScale.text(context, 19),
      fontWeight: FontWeight.w700,
      height: 1.4,
      letterSpacing: 0,
    );
    final addressTextStyle = AppTypography.authBody.copyWith(
      color: Colors.white,
      fontSize: AppScale.text(context, 11),
      fontWeight: FontWeight.w500,
      height: 1.4,
      letterSpacing: 0,
    );

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onOpenDetails,
          child: SizedBox(
            width: double.infinity,
            height: 360,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _DashboardListingImage(
                  path: home.imagePath ?? 'assets/icons/house.png',
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x00000000),
                        Color(0x33000000),
                        Color(0xD9000000),
                      ],
                      stops: [0.32, 0.58, 1],
                    ),
                  ),
                ),
                Positioned(
                  left: edgeOffset,
                  top: edgeOffset,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: rentPillWidth,
                        height: rentPillHeight,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                              AppScale.radius(context, 999),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.md(context),
                              vertical: AppSpacing.sm(context),
                            ),
                            child: Center(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  home.type.toLowerCase() == 'sale'
                                      ? 'For Sale'
                                      : 'For Rent',
                                  maxLines: 1,
                                  softWrap: false,
                                  style: AppTypography.authButtonLabel.copyWith(
                                    color: Colors.black,
                                    fontSize: AppScale.text(context, 13),
                                    fontWeight: FontWeight.w600,
                                    height: 1.4,
                                    letterSpacing: 0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: AppSpacing.sm(context)),
                      SizedBox(
                        width: streetViewButtonWidth,
                        height: rentPillHeight,
                        child: Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            AppScale.radius(context, 999),
                          ),
                          child: InkWell(
                            onTap: onOpenStreetView,
                            borderRadius: BorderRadius.circular(
                              AppScale.radius(context, 999),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm(context),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.streetview_outlined,
                                    color: Colors.black,
                                    size: AppSizes.iconSm(context),
                                  ),
                                  SizedBox(width: AppSpacing.xs(context)),
                                  Flexible(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        'Street',
                                        maxLines: 1,
                                        softWrap: false,
                                        style: AppTypography.authButtonLabel
                                            .copyWith(
                                              color: Colors.black,
                                              fontSize: AppScale.text(
                                                context,
                                                13,
                                              ),
                                              fontWeight: FontWeight.w600,
                                              height: 1.4,
                                              letterSpacing: 0,
                                            ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: edgeOffset,
                  top: edgeOffset,
                  child: SvgPicture.asset(
                    'assets/icons/heart-2.svg',
                    width: favoriteSize,
                    height: favoriteSize,
                    fit: BoxFit.contain,
                  ),
                ),
                Positioned(
                  left: edgeOffset,
                  right: edgeOffset,
                  bottom: AppSpacing.xl(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_formatNaira(home.price), style: listingTextStyle),

                      SizedBox(height: AppSpacing.sm(context)),
                      Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/verify.svg',
                            width: AppSizes.iconLg(context),
                            height: AppSizes.iconLg(context),
                            fit: BoxFit.contain,
                          ),
                          SizedBox(width: AppSpacing.sm(context)),
                          Text('Verified listing', style: listingTextStyle),
                        ],
                      ),
                      SizedBox(height: AppSpacing.sm(context)),
                      Text(
                        home.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: listingTextStyle,
                      ),
                      SizedBox(height: AppSpacing.md(context)),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            flex: 6,
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/Vector.svg',
                                  width: AppSizes.iconSm(context),
                                  height: AppScale.size(context, 18),
                                  fit: BoxFit.contain,
                                  colorFilter: const ColorFilter.mode(
                                    Colors.white,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                SizedBox(width: AppSpacing.sm(context)),
                                Expanded(
                                  child: Text(
                                    home.address?.trim().isNotEmpty == true
                                        ? home.address!
                                        : home.category,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: addressTextStyle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: AppSpacing.md(context)),
                          Expanded(
                            flex: 5,
                            child: _HomeStatsRow(
                              bedrooms: home.bedrooms,
                              bathrooms: home.bathrooms,
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

class _HomeStatsRow extends StatelessWidget {
  const _HomeStatsRow({required this.bedrooms, required this.bathrooms});

  final int? bedrooms;
  final int? bathrooms;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (bedrooms != null && bedrooms! > 0)
          _HomeStat(
            assetPath: 'assets/icons/bed-single.svg',
            value: '$bedrooms',
            label: bedrooms == 1 ? 'Bedroom' : 'Bedrooms',
          ),
        if (bathrooms != null && bathrooms! > 0)
          _HomeStat(
            icon: Icons.bathtub_outlined,
            value: '$bathrooms',
            label: bathrooms == 1 ? 'Bathroom' : 'Bathrooms',
          ),
      ],
    );
  }
}

class _HomeStat extends StatelessWidget {
  const _HomeStat({
    this.assetPath,
    this.icon,
    required this.value,
    required this.label,
  }) : assert(assetPath != null || icon != null);

  final String? assetPath;
  final IconData? icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final statIconSize = AppSizes.iconLg(context);

    return Flexible(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (assetPath != null)
            SvgPicture.asset(
              assetPath!,
              width: statIconSize,
              height: statIconSize,
              fit: BoxFit.contain,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            )
          else
            Icon(icon, color: Colors.white, size: statIconSize),
          SizedBox(height: AppSpacing.xs(context)),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '$value $label',
              maxLines: 1,
              softWrap: false,
              style: AppTypography.authBody.copyWith(
                color: Colors.white,
                fontSize: AppScale.text(context, 11),
                fontWeight: FontWeight.w700,
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

class _StreetViewPage extends StatefulWidget {
  const _StreetViewPage({required this.position});

  final LatLng position;

  @override
  State<_StreetViewPage> createState() => _StreetViewPageState();
}

class _StreetViewPageState extends State<_StreetViewPage> {
  late final WebViewController _webViewController;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    final streetViewUrl = Uri.https(
      'www.google.com',
      '/maps/@',
      <String, String>{
        'api': '1',
        'map_action': 'pano',
        'viewpoint': '${widget.position.latitude},${widget.position.longitude}',
      },
    );

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            if (uri == null ||
                (uri.scheme != 'https' && uri.scheme != 'http')) {
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
          onPageStarted: (_) {
            if (!mounted) {
              return;
            }
            setState(() {
              _isLoading = true;
              _errorMessage = null;
            });
          },
          onPageFinished: (_) {
            if (!mounted) {
              return;
            }
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame == false) {
              return;
            }

            if (!mounted) {
              return;
            }
            setState(() {
              _isLoading = false;
              _errorMessage = 'Street View is not available for this location.';
            });
          },
        ),
      )
      ..loadRequest(streetViewUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          WebViewWidget(controller: _webViewController),
          if (_isLoading)
            const ColoredBox(
              color: Color(0x66000000),
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
          if (_errorMessage != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.78),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: AppTypography.authBody.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Material(
                color: Colors.white,
                shape: const CircleBorder(),
                elevation: 3,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapHome {
  const _MapHome({
    required this.id,
    required this.position,
    required this.title,
    required this.price,
    required this.type,
    required this.category,
    this.imagePath,
    this.address,
    this.bedrooms,
    this.bathrooms,
  });

  final String id;
  final LatLng position;
  final String title;
  final int price;
  final String type;
  final String category;
  final String? imagePath;
  final String? address;
  final int? bedrooms;
  final int? bathrooms;

  _MapHome copyWith({
    String? imagePath,
    String? address,
    int? bedrooms,
    int? bathrooms,
  }) {
    return _MapHome(
      id: id,
      position: position,
      title: title,
      price: price,
      type: type,
      category: category,
      imagePath: imagePath ?? this.imagePath,
      address: address ?? this.address,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
    );
  }
}
