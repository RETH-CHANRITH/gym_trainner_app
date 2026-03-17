import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../../config/glass_ui.dart';
import '../controllers/settings_controller.dart';

// ─── Design Tokens ──────────────────────────────────────────────────────────
const Color ink = Color(0xFF0A0A0F);
const Color surface = Color(0xFF111118);
const Color card = Color(0xFF17171F);
const Color raised = Color(0xFF1E1E28);
const Color stroke = Color(0xFF2A2A36);
const Color neon = Color(0xFFCBFF47);
const Color coral = Color(0xFFFF5C5C);
const Color sky = Color(0xFF5CE8FF);
const Color lilac = Color(0xFFA78BFA);
const Color muted = Color(0xFF6B6B7E);

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  Future<void> _showEditProfileSheet(BuildContext context) async {
    final p = controller.profile;
    final nameCtrl = TextEditingController(text: p.name.value);
    final emailCtrl = TextEditingController(text: p.email.value);
    final currentPasswordCtrl = TextEditingController();
    final hideCurrentPassword = ValueNotifier<bool>(true);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: card,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Change Gmail',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Center(
                      child: Obx(() {
                        final profile = controller.profile;
                        return Column(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [neon, sky],
                                    ),
                                    borderRadius: BorderRadius.circular(44),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(41),
                                    child: SizedBox(
                                      width: 82,
                                      height: 82,
                                      child:
                                          profile.photoUrl.value.isNotEmpty
                                              ? Image.network(
                                                profile.photoUrl.value,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (_, __, ___) => Container(
                                                      color: raised,
                                                      child: const Icon(
                                                        CupertinoIcons
                                                            .person_fill,
                                                        color: muted,
                                                        size: 34,
                                                      ),
                                                    ),
                                              )
                                              : Container(
                                                color: raised,
                                                child: const Icon(
                                                  CupertinoIcons.person_fill,
                                                  color: muted,
                                                  size: 34,
                                                ),
                                              ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: GestureDetector(
                                    onTap:
                                        profile.isUploadingPhoto.value
                                            ? null
                                            : () =>
                                                controller.changeProfileImage(),
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: neon,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: card,
                                          width: 2,
                                        ),
                                      ),
                                      child:
                                          profile.isUploadingPhoto.value
                                              ? const Padding(
                                                padding: EdgeInsets.all(7),
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: ink,
                                                    ),
                                              )
                                              : const Icon(
                                                CupertinoIcons.camera_fill,
                                                size: 15,
                                                color: ink,
                                              ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Change photo',
                              style: TextStyle(
                                color: neon,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                    const SizedBox(height: 14),
                    _sheetField(nameCtrl, 'Full Name', TextInputType.name),
                    const SizedBox(height: 10),
                    _sheetField(
                      emailCtrl,
                      'Gmail Address',
                      TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 10),
                    ValueListenableBuilder<bool>(
                      valueListenable: hideCurrentPassword,
                      builder: (_, hidden, __) {
                        return _sheetField(
                          currentPasswordCtrl,
                          'Current Password (required for Gmail change)',
                          TextInputType.visiblePassword,
                          obscureText: hidden,
                          suffixIcon: IconButton(
                            onPressed: () {
                              hideCurrentPassword.value = !hidden;
                            },
                            icon: Icon(
                              hidden
                                  ? CupertinoIcons.eye
                                  : CupertinoIcons.eye_slash,
                              color: muted,
                              size: 18,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'For instant Gmail update, enter your current password.',
                      style: TextStyle(color: muted, fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: Obx(
                        () => ElevatedButton(
                          onPressed:
                              controller.isSavingProfile.value
                                  ? null
                                  : () async {
                                    final ok = await controller
                                        .saveAccountIdentity(
                                          fullName: nameCtrl.text,
                                          email: emailCtrl.text,
                                          currentPassword:
                                              currentPasswordCtrl.text,
                                        );
                                    if (ok) {
                                      Navigator.pop(context);
                                    }
                                  },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: neon,
                            foregroundColor: ink,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child:
                              controller.isSavingProfile.value
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: ink,
                                    ),
                                  )
                                  : const Text(
                                    'Save Changes',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  Widget _sheetField(
    TextEditingController controller,
    String hint,
    TextInputType type, {
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: type,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: muted),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: raised,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.16)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: neon),
        ),
      ),
    );
  }

  Future<void> _showChangePasswordSheet(BuildContext context) async {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    final hideCurrent = ValueNotifier<bool>(true);
    final hideNew = ValueNotifier<bool>(true);
    final hideConfirm = ValueNotifier<bool>(true);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: card,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Change Password',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ValueListenableBuilder<bool>(
                      valueListenable: hideCurrent,
                      builder: (_, hidden, __) {
                        return _sheetField(
                          currentCtrl,
                          'Current Password',
                          TextInputType.visiblePassword,
                          obscureText: hidden,
                          suffixIcon: IconButton(
                            onPressed: () => hideCurrent.value = !hidden,
                            icon: Icon(
                              hidden
                                  ? CupertinoIcons.eye
                                  : CupertinoIcons.eye_slash,
                              color: muted,
                              size: 18,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    ValueListenableBuilder<bool>(
                      valueListenable: hideNew,
                      builder: (_, hidden, __) {
                        return _sheetField(
                          newCtrl,
                          'New Password',
                          TextInputType.visiblePassword,
                          obscureText: hidden,
                          suffixIcon: IconButton(
                            onPressed: () => hideNew.value = !hidden,
                            icon: Icon(
                              hidden
                                  ? CupertinoIcons.eye
                                  : CupertinoIcons.eye_slash,
                              color: muted,
                              size: 18,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    ValueListenableBuilder<bool>(
                      valueListenable: hideConfirm,
                      builder: (_, hidden, __) {
                        return _sheetField(
                          confirmCtrl,
                          'Confirm New Password',
                          TextInputType.visiblePassword,
                          obscureText: hidden,
                          suffixIcon: IconButton(
                            onPressed: () => hideConfirm.value = !hidden,
                            icon: Icon(
                              hidden
                                  ? CupertinoIcons.eye
                                  : CupertinoIcons.eye_slash,
                              color: muted,
                              size: 18,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: Obx(
                        () => ElevatedButton(
                          onPressed:
                              controller.isSavingPassword.value
                                  ? null
                                  : () async {
                                    final ok = await controller
                                        .updatePasswordRealtime(
                                          currentPassword: currentCtrl.text,
                                          newPassword: newCtrl.text,
                                          confirmPassword: confirmCtrl.text,
                                        );
                                    if (ok) {
                                      Navigator.pop(context);
                                    }
                                  },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: neon,
                            foregroundColor: ink,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child:
                              controller.isSavingPassword.value
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: ink,
                                    ),
                                  )
                                  : const Text(
                                    'Update Password',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ink,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(child: liquidBackground()),
          Positioned(
            top: -160,
            right: -110,
            child: GlowOrb(color: kNeon, radius: 300),
          ),
          Positioned(
            bottom: -140,
            left: -90,
            child: GlowOrb(color: kLilac, radius: 250),
          ),
          Positioned(
            top: 290,
            left: -70,
            child: GlowOrb(color: kSky, radius: 170),
          ),
          ListView(
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.of(context).padding.top + kToolbarHeight + 20,
              20,
              20,
            ),
            physics: const BouncingScrollPhysics(),
            children: [
              // ── Profile section ────────────
              _buildUserCard(context),
              const SizedBox(height: 28),

              // ── Preferences ───────────────
              _buildSectionHeader('Preferences'),
              const SizedBox(height: 10),
              _buildCard(
                children: [
                  Obx(
                    () => _buildToggle(
                      icon: CupertinoIcons.bell_fill,
                      iconColor: sky,
                      label: 'Push Notifications',
                      subtitle: 'Session reminders & updates',
                      value: controller.notificationsEnabled.value,
                      onChanged: controller.toggleNotifications,
                    ),
                  ),
                  _buildDivider(),
                  Obx(
                    () => _buildToggle(
                      icon: CupertinoIcons.envelope_fill,
                      iconColor: lilac,
                      label: 'Email Updates',
                      subtitle: 'Weekly summaries & offers',
                      value: controller.emailUpdatesEnabled.value,
                      onChanged: controller.toggleEmailUpdates,
                    ),
                  ),
                  _buildDivider(),
                  Obx(
                    () => _buildToggle(
                      icon: CupertinoIcons.hand_thumbsup_fill,
                      iconColor: neon,
                      label: 'Biometric Login',
                      subtitle: 'Use Face ID or fingerprint',
                      value: controller.biometricsEnabled.value,
                      onChanged: controller.toggleBiometrics,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Account ───────────────────
              _buildSectionHeader('Account'),
              const SizedBox(height: 10),
              _buildCard(
                children: [
                  _buildArrowRow(
                    icon: CupertinoIcons.pencil,
                    iconColor: sky,
                    label: 'Change Gmail',
                    onTap: () => _showEditProfileSheet(context),
                  ),
                  _buildDivider(),
                  _buildArrowRow(
                    icon: CupertinoIcons.lock_fill,
                    iconColor: lilac,
                    label: 'Change Password',
                    onTap: () => _showChangePasswordSheet(context),
                  ),
                  _buildDivider(),
                  _buildArrowRow(
                    icon: CupertinoIcons.creditcard_fill,
                    iconColor: neon,
                    label: 'Payment Methods',
                    onTap: controller.openPaymentMethods,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── About ─────────────────────
              _buildSectionHeader('About'),
              const SizedBox(height: 10),
              _buildCard(
                children: [
                  _buildArrowRow(
                    icon: CupertinoIcons.info_circle_fill,
                    iconColor: sky,
                    label: 'App Version',
                    trailing: const Text(
                      '1.0.0',
                      style: TextStyle(color: muted, fontSize: 13),
                    ),
                    onTap: controller.openAppVersion,
                  ),
                  _buildDivider(),
                  _buildArrowRow(
                    icon: CupertinoIcons.doc_text_fill,
                    iconColor: lilac,
                    label: 'Privacy Policy',
                    onTap: controller.openPrivacyPolicy,
                  ),
                  _buildDivider(),
                  _buildArrowRow(
                    icon: CupertinoIcons.doc_plaintext,
                    iconColor: muted,
                    label: 'Terms of Service',
                    onTap: controller.openTermsOfService,
                  ),
                  _buildDivider(),
                  _buildArrowRow(
                    icon: CupertinoIcons.question_circle_fill,
                    iconColor: sky,
                    label: 'Help & Support',
                    onTap: controller.openSupportCenter,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Danger Zone ───────────────
              _buildCard(
                children: [
                  _buildArrowRow(
                    icon: CupertinoIcons.square_arrow_right,
                    iconColor: coral,
                    label: 'Log Out',
                    labelColor: coral,
                    showChevron: false,
                    onTap: controller.logout,
                  ),
                  _buildDivider(),
                  _buildArrowRow(
                    icon: CupertinoIcons.trash_fill,
                    iconColor: coral,
                    label: 'Delete Account',
                    labelColor: coral,
                    showChevron: false,
                    onTap: controller.deleteAccount,
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(BuildContext context) {
    return Obx(() {
      final p = controller.profile;
      return GestureDetector(
        onTap: () => _showEditProfileSheet(context),
        child: LiquidTile(
          radius: 16,
          padding: const EdgeInsets.all(16),
          accent: kLilac,
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: lilac.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: lilac.withOpacity(0.3)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child:
                      p.photoUrl.value.isNotEmpty
                          ? Image.network(
                            p.photoUrl.value,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) => const Icon(
                                  CupertinoIcons.person_fill,
                                  color: lilac,
                                  size: 28,
                                ),
                          )
                          : const Icon(
                            CupertinoIcons.person_fill,
                            color: lilac,
                            size: 28,
                          ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.name.value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      p.email.value.isNotEmpty
                          ? p.email.value
                          : 'No email linked',
                      style: TextStyle(color: muted, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Icon(CupertinoIcons.pencil, color: muted, size: 18),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSectionHeader(String label) {
    return Text(
      label,
      style: TextStyle(
        color: muted,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return LiquidTile(
      radius: 16,
      padding: EdgeInsets.zero,
      accent: kSky,
      child: Column(children: children),
    );
  }

  Widget _buildDivider() => Container(
    height: 1,
    margin: const EdgeInsets.only(left: 56),
    color: Colors.white.withOpacity(0.12),
  );

  Widget _buildToggle({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(subtitle, style: TextStyle(color: muted, fontSize: 11)),
              ],
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeColor: neon,
            trackColor: raised,
          ),
        ],
      ),
    );
  }

  Widget _buildArrowRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
    Color labelColor = Colors.white,
    bool showChevron = true,
    Widget? trailing,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: labelColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
            if (trailing != null) trailing,
            if (showChevron)
              Icon(CupertinoIcons.chevron_right, color: muted, size: 16),
          ],
        ),
      ),
    );
  }
}
