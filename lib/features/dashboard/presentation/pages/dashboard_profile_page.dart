part of 'dashboard_map_page.dart';

void _playProfileTap(VoidCallback? onTap) {
  if (onTap == null) {
    return;
  }

  AppSound.tap();
  onTap();
}

class _DashboardProfilePage extends StatefulWidget {
  const _DashboardProfilePage();

  @override
  State<_DashboardProfilePage> createState() => _DashboardProfilePageState();
}

class _DashboardProfilePageState extends State<_DashboardProfilePage> {
  late final UserProfileCubit _userProfileCubit;

  @override
  void initState() {
    super.initState();
    _userProfileCubit = UserProfileCubit(
      authRepository: getIt<AuthRepository>(),
    );
    _userProfileCubit.fetchUserProfile();
  }

  @override
  void dispose() {
    _userProfileCubit.close();
    super.dispose();
  }

  String _resolveDisplayName(UserProfileState state) {
    final profile = state.profile;
    if (profile == null) {
      return '';
    }

    final fullName = profile.fullName.trim();
    if (fullName.isNotEmpty) {
      return fullName;
    }

    return profile.email.trim().isNotEmpty ? profile.email.trim() : 'Profile';
  }

  String _resolveInitial(UserProfileState state) {
    final profile = state.profile;
    final source = profile?.firstName.trim().isNotEmpty == true
        ? profile!.firstName.trim()
        : _resolveDisplayName(state);

    if (source.isEmpty) {
      return '';
    }

    return source.characters.first.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UserProfileCubit>.value(
      value: _userProfileCubit,
      child: BlocBuilder<UserProfileCubit, UserProfileState>(
        builder: (context, state) {
          final displayName = _resolveDisplayName(state);
          final displayInitial = _resolveInitial(state);
          final isAwaitingProfile =
              state.profile == null &&
              (state.status == UserProfileStatus.initial ||
                  state.status == UserProfileStatus.loading);

          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              bottom: false,
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.xl(context),
                  AppScale.size(context, 48),
                  AppSpacing.xl(context),
                  AppScale.size(context, 112),
                ),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Profile',
                          textAlign: TextAlign.start,
                          style: AppTypography.authBody.copyWith(
                            color: Colors.black,
                            fontSize: AppScale.text(context, 28),
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                      _ProfileNotificationButton(
                        onTap: () {
                          Navigator.of(context).push<void>(
                            MaterialPageRoute<void>(
                              builder: (_) => const _NotificationCenterPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: AppScale.size(context, 38)),
                  Row(
                    children: [
                      Container(
                        width: AppScale.size(context, 112),
                        height: AppScale.size(context, 112),
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: isAwaitingProfile
                            ? SizedBox(
                                width: AppScale.size(context, 28),
                                height: AppScale.size(context, 28),
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : state.profile?.profilePicture.trim().isNotEmpty ==
                                  true
                            ? ClipOval(
                                child: Image.network(
                                  state.profile!.profilePicture.trim(),
                                  width: AppScale.size(context, 112),
                                  height: AppScale.size(context, 112),
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => Center(
                                    child: displayInitial.isNotEmpty
                                        ? Text(
                                            displayInitial,
                                            style: AppTypography.authBody
                                                .copyWith(
                                                  color: Colors.white,
                                                  fontSize: AppScale.text(
                                                    context,
                                                    50,
                                                  ),
                                                  fontWeight: FontWeight.w500,
                                                  height: 1,
                                                  letterSpacing: 0,
                                                ),
                                          )
                                        : Icon(
                                            Icons.person,
                                            color: Colors.white,
                                            size: AppScale.size(context, 48),
                                          ),
                                  ),
                                ),
                              )
                            : displayInitial.isNotEmpty
                            ? Text(
                                displayInitial,
                                style: AppTypography.authBody.copyWith(
                                  color: Colors.white,
                                  fontSize: AppScale.text(context, 50),
                                  fontWeight: FontWeight.w500,
                                  height: 1,
                                  letterSpacing: 0,
                                ),
                              )
                            : Icon(
                                Icons.person,
                                color: Colors.white,
                                size: AppScale.size(context, 48),
                              ),
                      ),
                      SizedBox(width: AppSpacing.xl(context)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isAwaitingProfile
                                  ? 'Loading profile...'
                                  : displayName.isNotEmpty
                                  ? displayName
                                  : 'Profile unavailable',
                              style: AppTypography.authBody.copyWith(
                                color: isAwaitingProfile
                                    ? const Color(0xFF8A8A8A)
                                    : Colors.black,
                                fontSize: AppScale.text(context, 23),
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                                letterSpacing: 0,
                              ),
                            ),
                            SizedBox(height: AppSpacing.xs(context)),
                            Text(
                              'Edit profile',
                              style: AppTypography.authBody.copyWith(
                                color: const Color(0xFF8A8A8A),
                                fontSize: AppScale.text(context, 18),
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
                  SizedBox(height: AppScale.size(context, 62)),
                  _ProfileMenuItem(
                    assetPath: 'assets/icons/eye.png',
                    title: 'Recently viewed',
                    onTap: () {
                      Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(
                          builder: (_) => const _RecentlyViewedPage(),
                        ),
                      );
                    },
                  ),
                  const _ProfileMenuItem(
                    icon: Icons.sell_outlined,
                    title: 'List My Property',
                  ),
                  _ProfileMenuItem(
                    icon: Icons.account_circle_outlined,
                    title: 'Account Settings',
                    onTap: () {
                      Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(
                          builder: (_) => const _AccountSettingsPage(),
                        ),
                      );
                    },
                  ),
                  _ProfileMenuItem(
                    icon: Icons.support_agent_outlined,
                    title: 'AMASS Support',
                    onTap: () {
                      Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(
                          builder: (_) => const _FixaSupportPage(),
                        ),
                      );
                    },
                  ),
                  _ProfileMenuItem(
                    icon: Icons.business_center_outlined,
                    title: 'Manage Subscription',
                    onTap: () {
                      Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(
                          builder: (_) => const _ManageSubscriptionPage(),
                        ),
                      );
                    },
                  ),
                  _ProfileMenuItem(
                    icon: Icons.gavel_outlined,
                    title: 'Legal',
                    onTap: () {
                      Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(
                          builder: (_) => const _LegalPage(),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: AppScale.size(context, 34)),
                  const _ProfileSignOutRow(),
                ],
              ),
            ),
            bottomNavigationBar: _DashboardBottomNav(
              selectedIndex: 2,
              onItemSelected: (index) {
                if (index == 0) {
                  AppLoadingOverlay.replace<void, void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const _ListingsDashboardPage(),
                    ),
                    destinationKey: 'home',
                  );
                  return;
                }

                if (index == 1) {
                  AppLoadingOverlay.replace<void, void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const _DashboardFavoritesPage(),
                    ),
                    destinationKey: 'favorites',
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}

class _ProfileNotificationButton extends StatelessWidget {
  const _ProfileNotificationButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: CircleBorder(side: BorderSide(color: AppColors.primary)),
      child: InkWell(
        onTap: () => _playProfileTap(onTap),
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: AppScale.size(context, 56),
          height: AppScale.size(context, 56),
          child: Center(
            child: SvgPicture.asset(
              'assets/icons/notification-2.svg',
              width: AppScale.size(context, 24),
              height: AppScale.size(context, 24),
              colorFilter: const ColorFilter.mode(
                Colors.black,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem({
    required this.title,
    this.assetPath,
    this.icon,
    this.onTap,
  });

  final String title;
  final String? assetPath;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap == null ? null : () => _playProfileTap(onTap),
        child: Container(
          height: AppScale.size(context, 78),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFE8E8E8))),
          ),
          child: Row(
            children: [
              SizedBox(
                width: AppScale.size(context, 38),
                child: Center(
                  child: _ProfileMenuIcon(assetPath: assetPath, icon: icon),
                ),
              ),
              SizedBox(width: AppSpacing.md(context)),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.authBody.copyWith(
                    color: Colors.black,
                    fontSize: AppScale.text(context, 16),
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                    letterSpacing: 0,
                  ),
                ),
              ),
              SvgPicture.asset(
                'assets/icons/la.svg',
                width: AppScale.size(context, 18),
                height: AppScale.size(context, 18),
                colorFilter: const ColorFilter.mode(
                  Colors.black,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountSettingsPage extends StatefulWidget {
  const _AccountSettingsPage();

  @override
  State<_AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<_AccountSettingsPage> {
  bool _messageNotifications = true;
  bool _specialOffers = true;
  bool _suggestions = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _SettingsHeader(title: 'Account Settings'),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.xl(context),
                  AppScale.size(context, 34),
                  AppSpacing.xl(context),
                  AppScale.size(context, 32),
                ),
                children: [
                  const _SettingsSectionTitle(title: 'Account'),
                  _SettingsNavigationRow(
                    title: 'Personal information',
                    onTap: () {
                      Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(
                          builder: (_) => const _PersonalInfoPage(),
                        ),
                      );
                    },
                  ),
                  _SettingsNavigationRow(
                    title: 'Change Password',
                    onTap: () {
                      Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(
                          builder: (_) => const _ChangePasswordPage(),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: AppScale.size(context, 42)),
                  const _SettingsSectionTitle(title: 'Notifications'),
                  _SettingsSwitchRow(
                    title: 'Message Notification',
                    value: _messageNotifications,
                    onChanged: (value) {
                      setState(() {
                        _messageNotifications = value;
                      });
                    },
                  ),
                  _SettingsSwitchRow(
                    title: 'Special offers',
                    value: _specialOffers,
                    onChanged: (value) {
                      setState(() {
                        _specialOffers = value;
                      });
                    },
                  ),
                  _SettingsSwitchRow(
                    title: 'Suggestions',
                    value: _suggestions,
                    onChanged: (value) {
                      setState(() {
                        _suggestions = value;
                      });
                    },
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

class _ChangePasswordPage extends StatefulWidget {
  const _ChangePasswordPage();

  @override
  State<_ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<_ChangePasswordPage> {
  late final TextEditingController _oldPasswordController;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmPasswordController;

  bool get _canSubmit =>
      _oldPasswordController.text.trim().isNotEmpty &&
      _newPasswordController.text.trim().isNotEmpty &&
      _confirmPasswordController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _oldPasswordController = TextEditingController()
      ..addListener(_handleChanged);
    _newPasswordController = TextEditingController()
      ..addListener(_handleChanged);
    _confirmPasswordController = TextEditingController()
      ..addListener(_handleChanged);
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return _SettingsActionScaffold(
      title: 'Change Password',
      buttonLabel: 'Done',
      canSubmit: _canSubmit,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.xl(context),
          AppScale.size(context, 20),
          AppSpacing.xl(context),
          AppScale.size(context, 24),
        ),
        children: [
          _SettingsGroupLabel(text: 'Enter your old password'),
          SizedBox(height: AppScale.size(context, 22)),
          _SettingsInputField(
            label: 'Old password',
            controller: _oldPasswordController,
            obscureText: true,
          ),
          SizedBox(height: AppScale.size(context, 24)),
          _SettingsGroupLabel(text: 'Enter your new password'),
          SizedBox(height: AppScale.size(context, 22)),
          _SettingsInputField(
            label: 'New password',
            controller: _newPasswordController,
            obscureText: true,
          ),
          SizedBox(height: AppScale.size(context, 20)),
          _SettingsInputField(
            label: 'Confirm new password',
            controller: _confirmPasswordController,
            obscureText: true,
          ),
        ],
      ),
    );
  }
}

class _PersonalInfoPage extends StatefulWidget {
  const _PersonalInfoPage();

  @override
  State<_PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<_PersonalInfoPage> {
  final ImagePicker _imagePicker = ImagePicker();
  late final UserProfileCubit _userProfileCubit;
  late final TextEditingController _emailController;
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _birthdayController;
  late final TextEditingController _addressController;
  XFile? _selectedProfilePicture;
  Uint8List? _selectedProfilePictureBytes;

  @override
  void initState() {
    super.initState();
    _userProfileCubit = UserProfileCubit(
      authRepository: getIt<AuthRepository>(),
    );
    _emailController = TextEditingController();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _phoneController = TextEditingController();
    _birthdayController = TextEditingController();
    _addressController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfile());
  }

  @override
  void dispose() {
    _userProfileCubit.close();
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _birthdayController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  bool get _canSubmit {
    return _firstNameController.text.trim().isNotEmpty &&
        _lastNameController.text.trim().isNotEmpty &&
        _phoneController.text.trim().isNotEmpty &&
        _birthdayController.text.trim().isNotEmpty &&
        _addressController.text.trim().isNotEmpty;
  }

  String _formatBirthday(String iso) {
    final datePart = iso.split('T').first.trim();
    return datePart.isEmpty ? iso : datePart;
  }

  void _fillControllers(UserProfileResult profile) {
    _emailController.text = profile.email;
    _firstNameController.text = profile.firstName;
    _lastNameController.text = profile.lastName;
    _phoneController.text = profile.phone;
    _birthdayController.text = _formatBirthday(profile.birthday);
    _addressController.text = profile.address;
  }

  Future<void> _loadProfile() async {
    await _userProfileCubit.fetchUserProfile();
    if (!mounted) return;
    final profile = _userProfileCubit.state.profile;
    if (profile != null) {
      _fillControllers(profile);
      setState(() {});
    }
  }

  Future<void> _saveProfile() async {
    if (!_canSubmit) {
      return;
    }

    await _userProfileCubit.updateUserProfile(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phone: _phoneController.text.trim(),
      birthday: _birthdayController.text.trim(),
      address: _addressController.text.trim(),
      profilePicture: _selectedProfilePicture,
    );
  }

  Future<void> _pickProfilePicture() async {
    try {
      final pickedImage = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
      );

      if (pickedImage == null) {
        return;
      }

      final bytes = await pickedImage.readAsBytes();
      if (!mounted) {
        return;
      }

      setState(() {
        _selectedProfilePicture = pickedImage;
        _selectedProfilePictureBytes = bytes;
      });
    } on PlatformException {
      if (!mounted) {
        return;
      }

      showAppResponseModal(
        context,
        message: 'Unable to open photo library. Please try again.',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UserProfileCubit>.value(
      value: _userProfileCubit,
      child: BlocConsumer<UserProfileCubit, UserProfileState>(
        listener: (context, state) {
          if (state.profile != null &&
              (state.status == UserProfileStatus.success ||
                  state.status == UserProfileStatus.updateSuccess)) {
            _fillControllers(state.profile!);
          }

          if (state.status == UserProfileStatus.updateSuccess) {
            showAppResponseModal(
              context,
              message: state.message ?? 'Profile updated.',
            );
            Navigator.of(context).pop();
          }

          if (state.status == UserProfileStatus.failure &&
              state.errorMessage != null &&
              state.errorMessage!.trim().isNotEmpty) {
            showAppResponseModal(
              context,
              message: state.errorMessage!,
              isError: true,
            );
          }
        },
        builder: (context, state) {
          return _SettingsActionScaffold(
            title: 'Personal Info',
            buttonLabel: state.status == UserProfileStatus.updating
                ? 'Saving...'
                : 'Done',
            canSubmit: _canSubmit && state.status != UserProfileStatus.updating,
            onSubmit: _saveProfile,
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.xl(context),
                AppScale.size(context, 16),
                AppSpacing.xl(context),
                AppScale.size(context, 24),
              ),
              children: [
                if (state.status == UserProfileStatus.loading)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 18),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                Center(
                  child: GestureDetector(
                    onTap: state.status == UserProfileStatus.updating
                        ? null
                        : _pickProfilePicture,
                    child: SizedBox(
                      width: AppScale.size(context, 104),
                      height: AppScale.size(context, 104),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary.withValues(
                                  alpha: 0.14,
                                ),
                                width: 3,
                              ),
                            ),
                            child: CircleAvatar(
                              backgroundColor: const Color(0xFFF3F6FB),
                              backgroundImage:
                                  _selectedProfilePictureBytes != null
                                  ? MemoryImage(_selectedProfilePictureBytes!)
                                  : (state.profile?.profilePicture
                                                .trim()
                                                .isNotEmpty ==
                                            true
                                        ? NetworkImage(
                                            state.profile!.profilePicture
                                                .trim(),
                                          )
                                        : null),
                              child:
                                  _selectedProfilePictureBytes == null &&
                                      (state.profile?.profilePicture
                                              .trim()
                                              .isEmpty ??
                                          true)
                                  ? Icon(
                                      Icons.person_rounded,
                                      size: AppScale.size(context, 42),
                                      color: AppColors.primary,
                                    )
                                  : null,
                            ),
                          ),
                          Positioned(
                            right: 1,
                            bottom: 1,
                            child: Container(
                              width: AppScale.size(context, 32),
                              height: AppScale.size(context, 32),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                color: AppColors.white,
                                size: 17,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: AppScale.size(context, 20)),
                _SettingsInputField(
                  label: 'Email address',
                  controller: _emailController,
                  readOnly: true,
                ),
                SizedBox(height: AppScale.size(context, 18)),
                _SettingsInputField(
                  label: 'First name',
                  controller: _firstNameController,
                ),
                SizedBox(height: AppScale.size(context, 18)),
                _SettingsInputField(
                  label: 'Last name',
                  controller: _lastNameController,
                ),
                SizedBox(height: AppScale.size(context, 18)),
                _SettingsInputField(
                  label: 'Phone number',
                  controller: _phoneController,
                ),
                SizedBox(height: AppScale.size(context, 18)),
                _SettingsInputField(
                  label: 'Birthday (YYYY-MM-DD)',
                  controller: _birthdayController,
                ),
                SizedBox(height: AppScale.size(context, 10)),
                Text(
                  'To sign up, you need to be at least 18. Other people who use AMASS won\'t see your birthday.',
                  style: AppTypography.authBody.copyWith(
                    color: const Color(0xFF666666),
                    fontSize: AppScale.text(context, 12),
                    fontWeight: FontWeight.w400,
                    height: 1.35,
                    letterSpacing: 0,
                  ),
                ),
                SizedBox(height: AppScale.size(context, 34)),
                _SettingsInputField(
                  label: 'Address',
                  controller: _addressController,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FixaSupportPage extends StatelessWidget {
  const _FixaSupportPage();

  Future<void> _openSupportLink(
    BuildContext context,
    Uri uri,
    String unavailableMessage,
  ) async {
    var didLaunch = false;
    try {
      didLaunch = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      didLaunch = false;
    }

    if (!didLaunch && context.mounted) {
      showAppResponseModal(context, message: unavailableMessage, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SettingsListScaffold(
      title: 'AMASS Support',
      children: [
        _SettingsIconRow(
          assetPath: 'assets/icons/whatsapp.png',
          title: 'WhatsApp',
          subtitle: '+234 813 915 3149',
          onTap: () => _openSupportLink(
            context,
            Uri.parse('https://wa.me/2348139153149'),
            'Unable to open WhatsApp.',
          ),
        ),
        _SettingsIconRow(
          assetPath: 'assets/icons/phone-2.png',
          title: 'Phone',
          subtitle: '+234 813 915 3149',
          onTap: () => _openSupportLink(
            context,
            Uri(scheme: 'tel', path: '+2348139153149'),
            'Unable to open the phone app.',
          ),
        ),
        _SettingsIconRow(
          assetPath: 'assets/icons/mail.png',
          title: 'Email',
          subtitle: 'coinnectar@gmail.com',
          onTap: () => _openSupportLink(
            context,
            Uri(
              scheme: 'mailto',
              path: 'coinnectar@gmail.com',
              queryParameters: const {'subject': 'AMASS Support'},
            ),
            'Unable to open an email app.',
          ),
        ),
      ],
    );
  }
}

class _LegalPage extends StatelessWidget {
  const _LegalPage();

  @override
  Widget build(BuildContext context) {
    return _SettingsListScaffold(
      title: 'Legal',
      children: const [
        _SettingsIconRow(
          icon: Icons.article_outlined,
          title: 'Terms of Use & Policy',
          showDivider: false,
        ),
      ],
    );
  }
}

class _RecentlyViewedStore {
  const _RecentlyViewedStore._();

  static final ValueNotifier<List<_DashboardListing>> listings =
      ValueNotifier<List<_DashboardListing>>(<_DashboardListing>[]);

  static void record(_DashboardListing listing) {
    final key = listing.id?.trim().isNotEmpty == true
        ? listing.id!.trim()
        : '${listing.subtitle}|${listing.location}';
    final updated = List<_DashboardListing>.from(listings.value)
      ..removeWhere((item) {
        final itemKey = item.id?.trim().isNotEmpty == true
            ? item.id!.trim()
            : '${item.subtitle}|${item.location}';
        return itemKey == key;
      })
      ..insert(0, listing);
    listings.value = updated.take(20).toList(growable: false);
  }
}

class _RecentlyViewedPage extends StatelessWidget {
  const _RecentlyViewedPage();

  _FavoriteListing _toRecentListing(_DashboardListing listing) {
    final isRent = listing.tag.toLowerCase().contains('rent');
    return _FavoriteListing(
      imagePath: listing.imagePath,
      imageCount: listing.imageCount,
      status: listing.tag,
      title: listing.subtitle?.trim().isNotEmpty == true
          ? listing.subtitle!.trim()
          : 'Property listing',
      price: listing.price,
      location: listing.location,
      specs: '${listing.bedrooms ?? 0} bd · ${listing.bathrooms ?? 0} ba',
      filter: isRent ? _FavoriteFilter.rentals : _FavoriteFilter.forSale,
      dashboardListing: listing,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<_DashboardListing>>(
      valueListenable: _RecentlyViewedStore.listings,
      builder: (context, viewedListings, _) {
        final recentListings = viewedListings.map(_toRecentListing).toList();
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.xl(context),
                    AppScale.size(context, 20),
                    AppSpacing.xl(context),
                    AppSpacing.lg(context),
                  ),
                  child: _RecentlyViewedHeader(
                    itemCount: recentListings.length,
                  ),
                ),
                Expanded(
                  child: recentListings.isEmpty
                      ? const _RecentlyViewedEmptyState()
                      : ListView.separated(
                          padding: EdgeInsets.fromLTRB(
                            AppSpacing.xl(context),
                            0,
                            AppSpacing.xl(context),
                            AppScale.size(context, 40),
                          ),
                          itemCount: recentListings.length,
                          separatorBuilder: (_, _) =>
                              SizedBox(height: AppSpacing.xl(context)),
                          itemBuilder: (context, index) {
                            final listing = recentListings[index];
                            return _FavoriteListingCard(
                              listing: listing,
                              showFavoriteButton: false,
                              onRemoveFavorite: () {},
                              onTap: () {
                                AppSound.tap();
                                Navigator.of(context).push<void>(
                                  MaterialPageRoute<void>(
                                    builder: (_) => _PropertyDetailPage(
                                      listing: listing.dashboardListing,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RecentlyViewedEmptyState extends StatelessWidget {
  const _RecentlyViewedEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl(context)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.visibility_outlined,
              color: AppColors.primary,
              size: AppScale.size(context, 42),
            ),
            SizedBox(height: AppSpacing.md(context)),
            Text(
              'No recently viewed homes',
              style: AppTypography.authBody.copyWith(
                color: AppColors.authText,
                fontSize: AppScale.text(context, 17),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSpacing.xs(context)),
            Text(
              'Properties you open will appear here.',
              textAlign: TextAlign.center,
              style: AppTypography.authBody.copyWith(
                color: AppColors.mutedInk,
                fontSize: AppScale.text(context, 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentlyViewedHeader extends StatelessWidget {
  const _RecentlyViewedHeader({required this.itemCount});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _SettingsBackButton(onTap: () => Navigator.of(context).pop()),
            const Spacer(),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md(context),
                vertical: AppSpacing.xs(context),
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  AppScale.radius(context, 999),
                ),
                border: Border.all(color: const Color(0xFFE1E6DE)),
              ),
              child: Text(
                '$itemCount homes',
                style: AppTypography.authBody.copyWith(
                  color: AppColors.mutedInk,
                  fontSize: AppScale.text(context, 12),
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                  letterSpacing: 0,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.lg(context)),
        Text(
          'Recently viewed',
          style: AppTypography.authBody.copyWith(
            color: AppColors.authText,
            fontSize: AppScale.text(context, 22),
            fontWeight: FontWeight.w700,
            height: 1.1,
            letterSpacing: 0,
          ),
        ),
        SizedBox(height: AppSpacing.sm(context)),
        Text(
          'Pick up where you left off with homes you opened lately.',
          style: AppTypography.authBody.copyWith(
            color: AppColors.mutedInk,
            fontSize: AppScale.text(context, 14),
            fontWeight: FontWeight.w500,
            height: 1.35,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _ManageSubscriptionPage extends StatelessWidget {
  const _ManageSubscriptionPage();

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SubscriptionCubit>(
      create: (_) => getIt<SubscriptionCubit>()..load(),
      child: const _ManageSubscriptionView(),
    );
  }
}

class _ManageSubscriptionView extends StatelessWidget {
  const _ManageSubscriptionView();

  static const List<String> _benefits = [
    'View available rental properties across Lagos',
    'Explore apartments directly on the Rental Map',
    'Access verified property information',
    'Receive alerts when new apartments become available',
    'Find opportunities before they\'re gone',
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SubscriptionCubit>().state;
    final subscription = state.subscription;
    final config = state.config;
    final benefits = config?.features.isNotEmpty == true
        ? config!.features
        : _benefits;

    if (subscription == null) {
      return const Scaffold(
        backgroundColor: const Color(0xFFF8F8F8),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _SettingsHeader(title: 'Manage Subscription'),
              Expanded(child: SizedBox.shrink()),
            ],
          ),
        ),
      );
    }

    if (!subscription.isActive) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F8F8),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const _SettingsHeader(title: 'Manage Subscription'),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(AppSpacing.xl(context)),
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 390),
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.xl(context),
                        AppScale.size(context, 30),
                        AppSpacing.xl(context),
                        AppSpacing.xl(context),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          AppScale.radius(context, 22),
                        ),
                        border: Border.all(color: const Color(0xFFEEEEEE)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0A000000),
                            blurRadius: 30,
                            offset: Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: AppScale.size(context, 62),
                            height: AppScale.size(context, 62),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFEEEE),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.hourglass_top_rounded,
                              color: AppColors.primary,
                              size: AppScale.size(context, 29),
                            ),
                          ),
                          SizedBox(height: AppSpacing.md(context)),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 11,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF4DD),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(
                              'PENDING CONFIRMATION',
                              style: AppTypography.authBody.copyWith(
                                color: const Color(0xFF9A6208),
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.7,
                              ),
                            ),
                          ),
                          SizedBox(height: AppSpacing.md(context)),
                          Text(
                            'Confirming your payment',
                            textAlign: TextAlign.center,
                            style: AppTypography.authBody.copyWith(
                              color: AppColors.authText,
                              fontSize: AppScale.text(context, 22),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: AppSpacing.sm(context)),
                          Text(
                            'Your request is safely recorded. Rental access unlocks automatically after verification.',
                            textAlign: TextAlign.center,
                            style: AppTypography.authBody.copyWith(
                              color: const Color(0xFF747474),
                              fontSize: AppScale.text(context, 13),
                              height: 1.45,
                            ),
                          ),
                          SizedBox(height: AppSpacing.lg(context)),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.md(context),
                              vertical: AppSpacing.sm(context),
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F7F7),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFECECEC),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  config?.name ?? 'Rental Access',
                                  style: AppTypography.authBody.copyWith(
                                    color: AppColors.authText,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${_formatSubscriptionPrice(subscription.amount)}/${subscription.billingCycle}',
                                  style: AppTypography.authBody.copyWith(
                                    color: AppColors.primary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: AppSpacing.lg(context)),
                          SizedBox(
                            width: double.infinity,
                            height: AppScale.size(context, 46),
                            child: FilledButton.icon(
                              onPressed: state.isBusy
                                  ? null
                                  : () async {
                                      AppLoadingOverlay.show(
                                        context,
                                        title: 'Checking payment status',
                                        subtitle: 'Confirming with Fixa',
                                      );
                                      await context
                                          .read<SubscriptionCubit>()
                                          .refreshSubscription();
                                      AppLoadingOverlay.hide();
                                    },
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              icon: const Icon(Icons.refresh_rounded, size: 19),
                              label: const Text('Refresh Status'),
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
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _SettingsHeader(title: 'Manage Subscription'),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  Image.asset(
                    'assets/images/Frame 1217.png',
                    width: double.infinity,
                    height: AppScale.size(context, 112),
                    fit: BoxFit.cover,
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.xl(context),
                      AppScale.size(context, 28),
                      AppSpacing.xl(context),
                      AppScale.size(context, 32),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${config?.name ?? 'Rental Access'} · ${subscription.status}',
                          style: AppTypography.authBody.copyWith(
                            color: AppColors.primary,
                            fontSize: AppScale.text(context, 29),
                            fontWeight: FontWeight.w700,
                            height: 1.35,
                            letterSpacing: 0,
                          ),
                        ),
                        SizedBox(height: AppScale.size(context, 16)),
                        _SubscriptionPriceRow(
                          amount: subscription.amount,
                          billingCycle: subscription.billingCycle,
                          showAutoRenewal: subscription.isActive,
                        ),
                        SizedBox(height: AppScale.size(context, 58)),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.lock_open,
                              color: AppColors.primary,
                              size: AppScale.size(context, 34),
                            ),
                            SizedBox(width: AppSpacing.md(context)),
                            Expanded(
                              child: Text(
                                'Rental Listings Unlocked',
                                style: AppTypography.authBody.copyWith(
                                  color: Colors.black,
                                  fontSize: AppScale.text(context, 23),
                                  fontWeight: FontWeight.w600,
                                  height: 1.4,
                                  letterSpacing: 0,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppScale.size(context, 22)),
                        Text(
                          'You now have access to view verified apartments, and use the AMASS Rental Map.',
                          style: AppTypography.authBody.copyWith(
                            color: Colors.black,
                            fontSize: AppScale.text(context, 19),
                            fontWeight: FontWeight.w400,
                            height: 1.35,
                            letterSpacing: 0,
                          ),
                        ),
                        SizedBox(height: AppScale.size(context, 24)),
                        Text(
                          'Benefits Include:',
                          style: AppTypography.authBody.copyWith(
                            color: Colors.black,
                            fontSize: AppScale.text(context, 19),
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                            letterSpacing: 0,
                          ),
                        ),
                        SizedBox(height: AppScale.size(context, 20)),
                        ...benefits.map(
                          (benefit) => Padding(
                            padding: EdgeInsets.only(
                              bottom: AppScale.size(context, 16),
                            ),
                            child: _SubscriptionBenefitRow(text: benefit),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.xl(context),
            AppScale.size(context, 24),
            AppSpacing.xl(context),
            AppScale.size(context, 26),
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFE8E8E8))),
          ),
          child: SizedBox(
            width: double.infinity,
            height: AppScale.size(context, 58),
            child: FilledButton(
              onPressed: state.isBusy
                  ? null
                  : () async {
                      AppSound.tap();
                      AppLoadingOverlay.show(
                        context,
                        title: 'Cancelling subscription',
                      );
                      await context.read<SubscriptionCubit>().cancel();
                      AppLoadingOverlay.hide();
                      if (!context.mounted) return;
                      final state = context.read<SubscriptionCubit>().state;
                      _showSubscriptionMessage(
                        context,
                        state.errorMessage ??
                            state.message ??
                            'Subscription cancelled.',
                      );
                    },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppScale.radius(context, 8),
                  ),
                ),
                textStyle: AppTypography.authBody.copyWith(
                  fontSize: AppScale.text(context, 17),
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                  letterSpacing: 0,
                ),
              ),
              child: const Text('Cancel Subscription'),
            ),
          ),
        ),
      ),
    );
  }
}

String _formatSubscriptionPrice(int amount) {
  final value = amount.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  return '₦$value';
}

Future<void> _showSubscriptionMessage(BuildContext context, String message) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<bool> _hasActiveRentalSubscription() async {
  final cubit = getIt<SubscriptionCubit>();
  try {
    await cubit.load(forceRefresh: true);
    return cubit.state.subscription?.isActive == true;
  } finally {
    await cubit.close();
  }
}

Future<bool> _showRentalUnlockModal(BuildContext context) async {
  final hasActiveSubscription = await _hasActiveRentalSubscription();
  if (hasActiveSubscription) {
    return true;
  }

  AppSound.tap();
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      final availableHeight =
          MediaQuery.sizeOf(context).height - MediaQuery.paddingOf(context).top;

      return Align(
        alignment: Alignment.bottomCenter,
        child: SizedBox(
          width: 440,
          height: availableHeight.clamp(0.0, 682.0),
          child: BlocProvider<SubscriptionCubit>(
            create: (_) => getIt<SubscriptionCubit>()..load(),
            child: const _RentalUnlockSheet(),
          ),
        ),
      );
    },
  );

  return false;
}

class _RentalUnlockSheet extends StatelessWidget {
  const _RentalUnlockSheet();

  static const List<String> _benefits = [
    'View available rental properties across Lagos',
    'Explore apartments directly on the Rental Map',
    'Access verified property information',
    'Receive alerts when new apartments become available',
    'Find opportunities before they\'re gone',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SubscriptionCubit, SubscriptionState>(
      listener: _handleState,
      builder: (context, state) {
        final config = state.config;
        final benefits = config?.features.isNotEmpty == true
            ? config!.features
            : _benefits;
        final isActive = state.subscription?.isActive == true;
        final amount = config?.amount ?? 10000;
        final cycle = config?.billingCycle ?? 'monthly';

        return ClipRRect(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppScale.radius(context, 16)),
          ),
          child: Material(
            color: Colors.white,
            child: Column(
              children: [
                Image.asset(
                  'assets/images/Frame 1217-2.png',
                  width: double.infinity,
                  height: AppScale.size(context, 90),
                  fit: BoxFit.cover,
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.all(AppSpacing.xl(context)),
                    children: [
                      Text(
                        config?.name ?? 'Unlock Rental Listings',
                        style: AppTypography.authBody.copyWith(
                          color: AppColors.authText,
                          fontSize: AppScale.text(context, 23),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: AppSpacing.md(context)),
                      ...benefits.map(
                        (benefit) => Padding(
                          padding: EdgeInsets.only(
                            bottom: AppScale.space(context, 10),
                          ),
                          child: _RentalUnlockBenefitRow(text: benefit),
                        ),
                      ),
                      SizedBox(height: AppSpacing.md(context)),
                      Text(
                        isActive ? 'Active Subscription' : 'Monthly Access',
                        style: AppTypography.authBody.copyWith(
                          color: AppColors.primary,
                          fontSize: AppScale.text(context, 23),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${_formatSubscriptionPrice(amount)}/$cycle',
                        style: AppTypography.authBody.copyWith(
                          color: AppColors.authText,
                          fontSize: AppScale.text(context, 15),
                        ),
                      ),
                    ],
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.md(context)),
                    child: _RentalUnlockSubscribeButton(
                      label: isActive ? 'Subscription Active' : 'Subscribe Now',
                      onPressed: isActive || state.isBusy
                          ? null
                          : () => context.read<SubscriptionCubit>().initiate(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleState(
    BuildContext context,
    SubscriptionState state,
  ) async {
    if (state.isBusy) {
      AppLoadingOverlay.show(
        context,
        title: state.status == SubscriptionStatus.initiating
            ? 'Preparing checkout'
            : 'Loading subscription',
      );
      return;
    }
    AppLoadingOverlay.hide();
    if (state.status == SubscriptionStatus.paymentReady) {
      final url = state.payment?.authorizationUrl.trim();
      if (url != null && url.isNotEmpty) {
        final opened = await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        );
        if (!opened && context.mounted) {
          _showSubscriptionMessage(context, 'Unable to open checkout.');
        }
      }
    } else if (state.status == SubscriptionStatus.failure &&
        state.errorMessage != null) {
      _showSubscriptionMessage(context, state.errorMessage!);
    }
  }
}

class _RentalUnlockSubscribeButton extends StatelessWidget {
  const _RentalUnlockSubscribeButton({
    required this.onPressed,
    required this.label,
  });

  final VoidCallback? onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppScale.size(context, 54),
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppScale.radius(context, 7)),
          ),
          textStyle: AppTypography.authButtonLabel.copyWith(
            color: Colors.white,
            fontSize: AppScale.text(context, 16),
            fontWeight: FontWeight.w600,
            height: 1.25,
            letterSpacing: 0,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}

class _RentalUnlockBenefitRow extends StatelessWidget {
  const _RentalUnlockBenefitRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: AppScale.size(context, 24),
          height: AppScale.size(context, 24),
          margin: EdgeInsets.only(top: AppScale.size(context, 1)),
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_rounded,
            color: Colors.white,
            size: AppScale.size(context, 17),
          ),
        ),
        SizedBox(width: AppSpacing.sm(context)),
        Expanded(
          child: Text(
            text,
            style: AppTypography.authBody.copyWith(
              color: AppColors.authText,
              fontSize: AppScale.text(context, 15),
              fontWeight: FontWeight.w400,
              height: 1.35,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
}

class _SubscriptionPriceRow extends StatelessWidget {
  const _SubscriptionPriceRow({
    required this.amount,
    required this.billingCycle,
    required this.showAutoRenewal,
  });

  final int amount;
  final String billingCycle;
  final bool showAutoRenewal;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppSpacing.sm(context),
      runSpacing: AppSpacing.xs(context),
      children: [
        Text(
          '${_formatSubscriptionPrice(amount)}/$billingCycle',
          style: AppTypography.authBody.copyWith(
            color: Colors.black,
            fontSize: AppScale.text(context, 18),
            fontWeight: FontWeight.w400,
            height: 1.4,
            letterSpacing: 0,
          ),
        ),
        if (showAutoRenewal)
          Text(
            '(Auto renewal active)',
            style: AppTypography.authBody.copyWith(
              color: AppColors.primary,
              fontSize: AppScale.text(context, 17),
              fontWeight: FontWeight.w400,
              height: 1.4,
              letterSpacing: 0,
            ),
          ),
      ],
    );
  }
}

class _SubscriptionBenefitRow extends StatelessWidget {
  const _SubscriptionBenefitRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: AppScale.size(context, 24),
          height: AppScale.size(context, 24),
          margin: EdgeInsets.only(top: AppScale.size(context, 2)),
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check,
            color: Colors.white,
            size: AppScale.size(context, 16),
          ),
        ),
        SizedBox(width: AppSpacing.md(context)),
        Expanded(
          child: Text(
            text,
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
    );
  }
}

class _SettingsListScaffold extends StatelessWidget {
  const _SettingsListScaffold({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _SettingsHeader(title: title),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.xl(context),
                  AppScale.size(context, 18),
                  AppSpacing.xl(context),
                  AppScale.size(context, 32),
                ),
                children: children,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsActionScaffold extends StatelessWidget {
  const _SettingsActionScaffold({
    required this.title,
    required this.buttonLabel,
    required this.canSubmit,
    required this.child,
    this.onSubmit,
  });

  final String title;
  final String buttonLabel;
  final bool canSubmit;
  final Widget child;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _SettingsHeader(title: title),
            Expanded(child: child),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.xl(context),
            AppScale.size(context, 24),
            AppSpacing.xl(context),
            AppScale.size(context, 34),
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFF8F8F8F))),
          ),
          child: SizedBox(
            height: AppScale.size(context, 58),
            width: double.infinity,
            child: FilledButton(
              onPressed: canSubmit
                  ? () {
                      AppSound.tap();
                      onSubmit?.call();
                    }
                  : null,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: const Color(0xFF9B9B9B),
                foregroundColor: Colors.white,
                disabledForegroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppScale.radius(context, 7),
                  ),
                ),
                textStyle: AppTypography.authBody.copyWith(
                  fontSize: AppScale.text(context, 20),
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                  letterSpacing: 0,
                ),
              ),
              child: Text(buttonLabel),
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppScale.size(context, 112),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl(context),
        AppScale.size(context, 22),
        AppSpacing.xl(context),
        0,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE7E7E7))),
      ),
      child: Row(
        children: [
          _SettingsBackButton(onTap: () => Navigator.of(context).pop()),
          SizedBox(width: AppScale.size(context, 24)),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.authBody.copyWith(
                color: Colors.black,
                fontSize: AppScale.text(context, 23),
                fontWeight: FontWeight.w600,
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

class _SettingsBackButton extends StatelessWidget {
  const _SettingsBackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _playProfileTap(onTap),
        borderRadius: BorderRadius.circular(AppScale.radius(context, 18)),
        child: SizedBox(
          width: AppScale.size(context, 30),
          height: AppScale.size(context, 42),
          child: Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: AppScale.size(context, 30),
          ),
        ),
      ),
    );
  }
}

class _SettingsSectionTitle extends StatelessWidget {
  const _SettingsSectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppScale.size(context, 58),
      alignment: Alignment.topLeft,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE8E8E8))),
      ),
      child: Text(
        title,
        style: AppTypography.authBody.copyWith(
          color: const Color(0xFFB7B7B7),
          fontSize: AppScale.text(context, 19),
          fontWeight: FontWeight.w500,
          height: 1.4,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _SettingsNavigationRow extends StatelessWidget {
  const _SettingsNavigationRow({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () => _playProfileTap(onTap),
        child: Container(
          height: AppScale.size(context, 74),
          alignment: Alignment.centerLeft,
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFE8E8E8))),
          ),
          child: Text(
            title,
            style: AppTypography.authBody.copyWith(
              color: Colors.black,
              fontSize: AppScale.text(context, 18),
              fontWeight: FontWeight.w400,
              height: 1.3,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsIconRow extends StatelessWidget {
  const _SettingsIconRow({
    this.icon,
    this.assetPath,
    required this.title,
    this.subtitle,
    this.onTap,
    this.showDivider = true,
  }) : assert(icon != null || assetPath != null);

  final IconData? icon;
  final String? assetPath;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap == null ? null : () => _playProfileTap(onTap),
      child: Container(
        height: AppScale.size(context, subtitle == null ? 72 : 82),
        decoration: BoxDecoration(
          border: showDivider
              ? const Border(bottom: BorderSide(color: Color(0xFFE8E8E8)))
              : null,
        ),
        child: Row(
          children: [
            if (assetPath != null)
              Image.asset(
                assetPath!,
                width: AppScale.size(context, 25),
                height: AppScale.size(context, 25),
              )
            else
              Icon(icon, color: Colors.black, size: AppScale.size(context, 25)),
            SizedBox(width: AppSpacing.md(context)),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.authBody.copyWith(
                      color: Colors.black,
                      fontSize: AppScale.text(context, 15),
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                      letterSpacing: 0,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: AppTypography.authBody.copyWith(
                        color: const Color(0xFF6A6A6A),
                        fontSize: AppScale.text(context, 13),
                        fontWeight: FontWeight.w400,
                        height: 1.3,
                      ),
                    ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.chevron_right,
                color: const Color(0xFF8A8A8A),
                size: AppScale.size(context, 24),
              ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSwitchRow extends StatelessWidget {
  const _SettingsSwitchRow({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppScale.size(context, 78),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE8E8E8))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTypography.authBody.copyWith(
                color: Colors.black,
                fontSize: AppScale.text(context, 18),
                fontWeight: FontWeight.w400,
                height: 1.3,
                letterSpacing: 0,
              ),
            ),
          ),
          _SettingsSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _SettingsSwitch extends StatelessWidget {
  const _SettingsSwitch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final width = AppScale.size(context, 58);
    final height = AppScale.size(context, 34);
    final thumbSize = AppScale.size(context, 30);

    return Semantics(
      toggled: value,
      button: true,
      child: GestureDetector(
        onTap: () {
          AppSound.tap();
          onChanged(!value);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: width,
          height: height,
          padding: EdgeInsets.all(AppScale.size(context, 2)),
          decoration: BoxDecoration(
            color: value ? AppColors.primary : const Color(0xFFE4E4E4),
            borderRadius: BorderRadius.circular(AppScale.radius(context, 999)),
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: thumbSize,
              height: thumbSize,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsGroupLabel extends StatelessWidget {
  const _SettingsGroupLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.authBody.copyWith(
        color: Colors.black,
        fontSize: AppScale.text(context, 18),
        fontWeight: FontWeight.w600,
        height: 1.25,
        letterSpacing: 0,
      ),
    );
  }
}

class _SettingsInputField extends StatelessWidget {
  const _SettingsInputField({
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.readOnly = false,
  });

  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.authBody.copyWith(
            color: const Color(0xFF1F2937),
            fontSize: AppScale.text(context, 14),
            fontWeight: FontWeight.w400,
            height: 1.2,
            letterSpacing: 0,
          ),
        ),
        SizedBox(height: AppScale.size(context, 12)),
        TextField(
          controller: controller,
          obscureText: obscureText,
          readOnly: readOnly,
          cursorColor: Colors.black,
          style: AppTypography.authBody.copyWith(
            color: Colors.black,
            fontSize: AppScale.text(context, 18),
            fontWeight: FontWeight.w400,
            height: 1.2,
            letterSpacing: 0,
          ),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: readOnly ? const Color(0xFFF5F5F5) : Colors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppScale.size(context, 18),
              vertical: AppScale.size(context, 24),
            ),
            enabledBorder: _settingsFieldBorder(context),
            focusedBorder: _settingsFieldBorder(context),
            border: _settingsFieldBorder(context),
          ),
        ),
      ],
    );
  }
}

OutlineInputBorder _settingsFieldBorder(BuildContext context) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppScale.radius(context, 8)),
    borderSide: const BorderSide(color: Color(0xFF3F3F3F), width: 1.2),
  );
}

class _ProfileMenuIcon extends StatelessWidget {
  const _ProfileMenuIcon({this.assetPath, this.icon});

  final String? assetPath;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    if (assetPath != null) {
      return Image.asset(
        assetPath!,
        width: AppScale.size(context, 28),
        height: AppScale.size(context, 28),
        color: Colors.black,
      );
    }

    return Icon(icon, color: Colors.black, size: AppScale.size(context, 30));
  }
}

class _ProfileSignOutRow extends StatelessWidget {
  const _ProfileSignOutRow();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _signOut(context),
      borderRadius: BorderRadius.circular(AppScale.radius(context, 8)),
      child: Row(
        children: [
          Image.asset(
            'assets/icons/logout.png',
            width: AppScale.size(context, 30),
            height: AppScale.size(context, 30),
            color: Colors.black,
          ),
          SizedBox(width: AppSpacing.md(context)),
          Text(
            'Sign out',
            style: AppTypography.authBody.copyWith(
              color: Colors.black,
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

  Future<void> _signOut(BuildContext context) async {
    AppSound.tap();
    final confirmed = await _showLogoutConfirmation(context);
    if (!confirmed || !context.mounted) return;

    AppLoadingOverlay.show(
      context,
      title: 'Signing you out',
      subtitle: 'Securing your account',
    );

    try {
      final preferences = getIt<AppPreferenceService>();
      final refreshToken =
          preferences.getValue<String>('refresh_token')?.trim() ?? '';
      if (refreshToken.isEmpty) {
        throw const AppError(
          'Your session is missing its refresh token. Please sign in again.',
        );
      }
      final message = await getIt<AuthRepository>().logout(
        refreshToken: refreshToken,
      );
      await _clearLocalSession(preferences);
      AppLoadingOverlay.hide();

      if (!context.mounted) return;
      await _showLogoutResult(context, message, isSuccess: true);
      if (context.mounted) context.go(AppRoutes.authWelcome);
    } on AppError catch (error) {
      await _clearLocalSession(getIt<AppPreferenceService>());
      AppLoadingOverlay.hide();
      if (context.mounted) {
        await _showLogoutResult(
          context,
          'Signed out on this device. The server did not confirm logout: ${error.message}',
          isSuccess: false,
        );
        if (context.mounted) context.go(AppRoutes.authWelcome);
      }
    } catch (_) {
      await _clearLocalSession(getIt<AppPreferenceService>());
      AppLoadingOverlay.hide();
      if (context.mounted) {
        await _showLogoutResult(
          context,
          'Signed out on this device, but the server did not confirm logout.',
          isSuccess: false,
        );
        if (context.mounted) context.go(AppRoutes.authWelcome);
      }
    }
  }

  Future<void> _clearLocalSession(AppPreferenceService preferences) async {
    await preferences.removeValue('auth_token');
    await preferences.removeValue('refresh_token');
    UserProfileCubit.invalidateCache();
    PropertyFeedCubit.invalidateCache();
    PropertyFavoritesCubit.invalidateCache();
    NotificationCubit.invalidateCache();
    SubscriptionCubit.invalidateCache();
    AppLoadingOverlay.resetNavigationState();
  }

  Future<bool> _showLogoutConfirmation(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 38),
        backgroundColor: Colors.transparent,
        child: Container(
          width: 310,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFEAEA),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(height: 13),
              Text(
                'Ready to leave?',
                style: AppTypography.authBody.copyWith(
                  color: AppColors.authText,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'You’ll need to sign in again to access your saved homes and rental subscription.',
                textAlign: TextAlign.center,
                style: AppTypography.authBody.copyWith(
                  color: AppColors.mutedInk,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.authText,
                        side: const BorderSide(color: AppColors.border),
                        minimumSize: const Size.fromHeight(42),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Stay'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: const Size.fromHeight(42),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Sign out'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return result ?? false;
  }

  Future<void> _showLogoutResult(
    BuildContext context,
    String message, {
    required bool isSuccess,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 48),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Icon(
                isSuccess ? Icons.check_circle_rounded : Icons.error_rounded,
                color: isSuccess ? const Color(0xFF23875B) : AppColors.primary,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: AppTypography.authBody.copyWith(
                    color: AppColors.authText,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                icon: const Icon(Icons.close_rounded, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
