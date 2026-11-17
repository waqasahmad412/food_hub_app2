import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

/// Profile tab: user identity, profile editing, saved delivery addresses
/// (Firestore subcollection users/{uid}/addresses) and simple menu links.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _loggingOut = false;

  User? get _user => FirebaseAuth.instance.currentUser;

  void _toast(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _logout() async {
    setState(() => _loggingOut = true);
    try {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } catch (_) {
      if (!mounted) return;
      setState(() => _loggingOut = false);
      _toast('Could not log out. Please try again.', isError: true);
    }
  }

  // ------------------------------------------------------------------
  // Edit Profile — updates Firebase Auth displayName + users doc.
  // ------------------------------------------------------------------
  Future<void> _editProfile() async {
    final nameCtrl = TextEditingController(text: _user?.displayName ?? '');
    final phoneCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    // Pre-fill stored phone number from the users document, if any.
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .get();
      phoneCtrl.text = (doc.data()?['phone'] ?? '') as String;
    } catch (_) {}
    if (!mounted) return;

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Edit Profile',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) =>
                    (v ?? '').trim().length < 3 ? 'Enter your full name' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (v) {
                  final digits = (v ?? '').replaceAll(RegExp(r'[\s\-+()]'), '');
                  if (digits.isEmpty) return null; // optional
                  if (digits.length < 10 || int.tryParse(digits) == null) {
                    return 'Enter a valid phone number';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () =>
                Navigator.pop(dialogContext, formKey.currentState!.validate()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (saved != true || !mounted) return;
    try {
      final name = nameCtrl.text.trim();
      final phone = phoneCtrl.text.trim();
      await _user!.updateDisplayName(name);
      await _user!.reload();
      await FirebaseFirestore.instance.collection('users').doc(_user!.uid).set({
        'name': name,
        'phone': phone,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (!mounted) return;
      setState(() {});
      _toast('Profile updated');
    } catch (_) {
      _toast('Could not update profile. Please try again.', isError: true);
    }
  }

  // ------------------------------------------------------------------
  // Delivery Addresses — users/{uid}/addresses subcollection.
  // ------------------------------------------------------------------
  Future<void> _addAddress() async {
    final labelCtrl = TextEditingController(text: 'Home');
    final addressCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Text('Add New Address',
              style: TextStyle(fontWeight: FontWeight.w800)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  spacing: 8,
                  children: ['Home', 'Work', 'Other'].map((label) {
                    final selected = labelCtrl.text == label;
                    return ChoiceChip(
                      label: Text(label),
                      selected: selected,
                      selectedColor: AppColors.primary.withValues(alpha: 0.18),
                      labelStyle: TextStyle(
                        color: selected ? AppColors.primary : AppColors.body,
                        fontWeight: FontWeight.w700,
                      ),
                      onSelected: (_) =>
                          setDialogState(() => labelCtrl.text = label),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: addressCtrl,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Full Address',
                    prefixIcon: Icon(Icons.location_on_outlined),
                    alignLabelWithHint: true,
                  ),
                  validator: (v) => (v ?? '').trim().length < 10
                      ? 'Address must be at least 10 characters'
                      : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () => Navigator.pop(
                  dialogContext, formKey.currentState!.validate()),
              child: const Text('Save Address'),
            ),
          ],
        ),
      ),
    );

    if (saved != true || !mounted) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .collection('addresses')
          .add({
        'label': labelCtrl.text.trim(),
        'address': addressCtrl.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      _toast('Address saved');
    } catch (_) {
      _toast('Could not save address. Please try again.', isError: true);
    }
  }

  Future<void> _deleteAddress(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .collection('addresses')
          .doc(docId)
          .delete();
      if (!mounted) return;
      _toast('Address removed');
    } catch (_) {
      _toast('Could not remove address.', isError: true);
    }
  }

  void _comingSoon(String feature) => _toast('$feature — coming soon!');

  @override
  Widget build(BuildContext context) {
    final user = _user;
    final name = user?.displayName ?? user?.email?.split('@').first ?? 'Guest';
    final email = user?.email ?? 'Not signed in';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile',
            style: TextStyle(
                fontWeight: FontWeight.w800, color: AppColors.heading)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            tooltip: 'Edit Profile',
            icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
            onPressed: _editProfile,
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                // ---------------- Identity header ----------------
                Column(
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person,
                          size: 52, color: AppColors.primary),
                    ),
                    const SizedBox(height: 16),
                    Text(name,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                                color: AppColors.heading,
                                fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(email,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.body)),
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _editProfile,
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Edit Profile'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(),

                // ---------------- Delivery Addresses ----------------
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 20, color: AppColors.primary),
                    const SizedBox(width: 8),
                    const Text('Delivery Addresses',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.heading)),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Add New Address',
                      icon: const Icon(Icons.add_circle,
                          color: AppColors.primary),
                      onPressed: _addAddress,
                    ),
                  ],
                ),
                _buildAddresses(),
                TextButton.icon(
                  onPressed: _addAddress,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add New Address'),
                  style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      textStyle: const TextStyle(fontWeight: FontWeight.w700)),
                ),
                const Divider(),

                // ---------------- Menu links ----------------
                _menuTile(Icons.favorite_outline, 'My Favorites'),
                _menuTile(Icons.help_outline, 'Help & Support'),
                _menuTile(Icons.info_outline, 'About FoodDash'),
                const Divider(),
                const SizedBox(height: 8),

                // ---------------- Logout ----------------
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _loggingOut ? null : _logout,
                    icon: _loggingOut
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.logout),
                    label: Text(_loggingOut ? 'Logging out...' : 'Logout'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _menuTile(IconData icon, String title) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.fieldBorder),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.w700, color: AppColors.heading)),
        trailing:
            const Icon(Icons.chevron_right, color: AppColors.body, size: 22),
        onTap: () => _comingSoon(title),
      ),
    );
  }

  Widget _buildAddresses() {
    final stream = FirebaseFirestore.instance
        .collection('users')
        .doc(_user!.uid)
        .collection('addresses')
        .orderBy('createdAt', descending: true)
        .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('Could not load addresses.',
                style: TextStyle(color: AppColors.body)),
          );
        }
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
                child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2))),
          );
        }
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text('No saved addresses yet. Add one for faster checkout.',
                style: TextStyle(color: AppColors.body, fontSize: 13)),
          );
        }
        return Column(
          children: docs.map((doc) {
            final label = (doc.data()['label'] ?? 'Address') as String;
            final address = (doc.data()['address'] ?? '') as String;
            final icon = switch (label.toLowerCase()) {
              'home' => Icons.home_outlined,
              'work' => Icons.work_outline,
              _ => Icons.location_on_outlined,
            };
            return Dismissible(
              key: ValueKey(doc.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 18),
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.shade400,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.delete_outline, color: Colors.white),
              ),
              onDismissed: (_) => _deleteAddress(doc.id),
              child: Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: AppColors.fieldBorder),
                ),
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 20, color: AppColors.primary),
                  ),
                  title: Text(label,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.heading)),
                  subtitle: Text(address,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style:
                          const TextStyle(color: AppColors.body, fontSize: 13)),
                  trailing: IconButton(
                    tooltip: 'Delete address',
                    icon: Icon(Icons.delete_outline,
                        color: Colors.red.shade400, size: 20),
                    onPressed: () => _deleteAddress(doc.id),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
