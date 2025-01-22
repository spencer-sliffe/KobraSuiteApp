import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/general/auth_provider.dart';
import '../../providers/general/user_profile_provider.dart';
import '../../models/general/user_profile.dart';
import '../../services/general/auth_service.dart';
import '../../services/service_locator.dart';
import '../../widgets/buttons/primary_button.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

/// Displays user account info, including profile details, plus logout functionality.
/// Demonstrates a modern UI approach with a personal info card and an editable profile area.
class _AccountScreenState extends State<AccountScreen> {
  bool _editingProfile = false;
  final TextEditingController _addressCtrl = TextEditingController();
  final TextEditingController _profilePictureCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // If this screen is opened, we can attempt to load the user profile.
    final userProfileProvider = context.read<UserProfileProvider>();
    userProfileProvider.loadUserProfile().then((success) {
      if (success && mounted) {
        final profile = userProfileProvider.profile;
        if (profile != null) {
          _addressCtrl.text = profile.address ?? '';
          _profilePictureCtrl.text = profile.profilePicture ?? '';
        }
      }
    });
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    _profilePictureCtrl.dispose();
    super.dispose();
  }

  Future<void> _onLogout() async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.logout();
    if (success && mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    }
  }

  Future<void> _onSaveProfile() async {
    final userProfileProvider = context.read<UserProfileProvider>();
    final updatedData = <String, dynamic>{
      'address': _addressCtrl.text.trim(),
      'profile_picture': _profilePictureCtrl.text.trim(),
      // Add more fields if your backend supports them
    };
    final success = await userProfileProvider.updateUserProfile(updatedData);
    if (!mounted) return;
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userProfileProvider.errorMessage.isEmpty
            ? 'Failed to update profile'
            : userProfileProvider.errorMessage)),
      );
    } else {
      setState(() => _editingProfile = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProfileProvider = context.watch<UserProfileProvider>();
    final profile = userProfileProvider.profile;
    final authProvider = context.watch<AuthProvider>();
    final authService = serviceLocator<AuthService>(); // if you need user data from the service

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Account'),
        centerTitle: true,
      ),
      body: userProfileProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Personal Info Card
            _buildPersonalInfoCard(context, profile, authProvider),
            const SizedBox(height: 24),
            // Profile Edit Section
            _buildProfileEditSection(context, profile),
            const SizedBox(height: 24),
            // Logout Button
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoCard(BuildContext context, UserProfile? profile, AuthProvider authProvider) {
    final userPk = authProvider.userPk;
    final userName = serviceLocator<AuthService>().loggedInUsername ?? 'Unknown';
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Profile avatar
            CircleAvatar(
              radius: 36,
              backgroundImage: (profile?.profilePicture?.isNotEmpty == true)
                  ? NetworkImage(profile!.profilePicture!)
                  : const AssetImage('assets/images/profile_placeholder.png') as ImageProvider,
            ),
            const SizedBox(width: 16),
            // Basic user data
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: $userPk',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  // You can display more info if your backend has it, e.g. email, phone, etc.
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit Profile',
              onPressed: () => setState(() => _editingProfile = true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileEditSection(BuildContext context, UserProfile? profile) {
    if (!_editingProfile) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profile Info',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (profile?.address != null && profile!.address!.isNotEmpty)
              Text(
                'Address: ${profile.address}',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              const Text('Address: (not set)'),
            if (profile?.profilePicture != null && profile!.profilePicture!.isNotEmpty)
              Text(
                'Picture URL: ${profile.profilePicture}',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              const Text('Picture: (not set)'),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.edit),
              label: const Text('Edit'),
              onPressed: () => setState(() => _editingProfile = true),
            ),
          ],
        ),
      );
    } else {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(top: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Edit Profile',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _addressCtrl,
              decoration: const InputDecoration(
                labelText: 'Address',
                prefixIcon: Icon(Icons.home),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _profilePictureCtrl,
              decoration: const InputDecoration(
                labelText: 'Profile Picture URL',
                prefixIcon: Icon(Icons.image),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _onSaveProfile,
                  icon: const Icon(Icons.save),
                  label: const Text('Save'),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () => setState(() => _editingProfile = false),
                  icon: const Icon(Icons.cancel),
                  label: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  Widget _buildLogoutButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: PrimaryButton(
        onPressed: _onLogout,
        text: 'Logout',
      ),
    );
  }
}