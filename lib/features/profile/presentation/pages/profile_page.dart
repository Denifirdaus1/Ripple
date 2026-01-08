import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:app_settings/app_settings.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../bloc/profile_bloc.dart';
import '../widgets/avatar_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final ProfileBloc _profileBloc;
  final _nameController = TextEditingController();
  bool _isEditingName = false;

  @override
  void initState() {
    super.initState();
    // Use global singleton bloc - data persists across navigation
    _profileBloc = GetIt.I<ProfileBloc>();

    // Only load if not already loaded (state is initial)
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null && _profileBloc.state.status == ProfileStatus.initial) {
      debugPrint('📱 [ProfilePage] First load - fetching profile');
      _profileBloc.add(ProfileLoadRequested(userId));
    } else {
      debugPrint('📱 [ProfilePage] Profile already in cache, skipping fetch');
    }
  }

  @override
  void dispose() {
    // Don't close the bloc - it's a global singleton!
    _nameController.dispose();
    super.dispose();
  }

  void _openNotificationSettings() async {
    debugPrint('⚙️ [ProfilePage] Opening notification settings');
    await AppSettings.openAppSettings(type: AppSettingsType.notification);
  }

  void _handleSignOut() async {
    debugPrint('🚪 [ProfilePage] Signing out');
    await Supabase.instance.client.auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return BlocProvider.value(
      value: _profileBloc,
      child: Scaffold(
        backgroundColor: AppColors.paperWhite,
        appBar: AppBar(
          title: Text(
            'Profile',
            style: AppTypography.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
        ),
        body: BlocConsumer<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state.status == ProfileStatus.error &&
                state.errorMessage != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
            }
          },
          builder: (context, state) {
            final profile = state.profile;
            final isLoading =
                state.status == ProfileStatus.loading ||
                state.status == ProfileStatus.saving;

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Avatar Section
                Center(
                  child: Column(
                    children: [
                      AvatarPicker(
                        currentAvatarUrl: profile?.avatarUrl,
                        fallbackInitial:
                            profile?.initial ??
                            (user?.email?.substring(0, 1).toUpperCase() ?? 'U'),
                        isLoading: state.status == ProfileStatus.saving,
                        onImageSelected: (bytes, fileName) {
                          _profileBloc.add(
                            ProfileAvatarUploadRequested(bytes, fileName),
                          );
                        },
                        onDeleteRequested: () {
                          _profileBloc.add(
                            const ProfileAvatarDeleteRequested(),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Name editing
                      if (_isEditingName)
                        _buildNameEditor(profile?.displayName ?? '')
                      else
                        _buildNameDisplay(
                          profile?.name ?? user?.email ?? 'User',
                        ),

                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? '',
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Settings Section
                Text(
                  'Settings',
                  style: AppTypography.textTheme.titleSmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 16),

                _SettingsTile(
                  icon: PhosphorIconsRegular.bell,
                  label: 'Notifications',
                  subtitle: 'Manage app notification settings',
                  onTap: _openNotificationSettings,
                ),
                _SettingsTile(
                  icon: PhosphorIconsRegular.globe,
                  label: 'Timezone',
                  subtitle: profile?.timezone ?? 'UTC',
                  onTap: () {},
                  showChevron: false,
                ),

                const SizedBox(height: 32),

                // Sign Out Button
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: isLoading ? null : _handleSignOut,
                    icon: const Icon(PhosphorIconsRegular.signOut),
                    label: const Text('Sign Out'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.coralPink,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColors.coralPink.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildNameDisplay(String name) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isEditingName = true;
          _nameController.text = name;
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name,
            style: AppTypography.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            PhosphorIconsRegular.pencilSimple,
            size: 18,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildNameEditor(String currentName) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 200,
          child: TextField(
            controller: _nameController,
            autofocus: true,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: 'Enter your name',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            style: AppTypography.textTheme.titleMedium,
            onSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                _profileBloc.add(ProfileDisplayNameChanged(value.trim()));
              }
              setState(() => _isEditingName = false);
            },
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: Icon(PhosphorIconsRegular.check, color: AppColors.sageGreen),
          onPressed: () {
            final value = _nameController.text.trim();
            if (value.isNotEmpty) {
              _profileBloc.add(ProfileDisplayNameChanged(value));
            }
            setState(() => _isEditingName = false);
          },
        ),
        IconButton(
          icon: Icon(PhosphorIconsRegular.x, color: AppColors.textSecondary),
          onPressed: () {
            setState(() => _isEditingName = false);
          },
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  final bool showChevron;

  const _SettingsTile({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.onTap,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.softGray.withOpacity(0.5)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.softGray.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: AppColors.textPrimary),
        ),
        title: Text(
          label,
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: AppTypography.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              )
            : null,
        trailing: showChevron
            ? Icon(
                PhosphorIconsRegular.caretRight,
                size: 16,
                color: AppColors.textSecondary,
              )
            : null,
      ),
    );
  }
}
