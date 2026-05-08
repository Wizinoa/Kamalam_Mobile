import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_app/Models/users_model.dart';
import 'package:my_app/Providers/user_provider.dart';
import 'package:provider/provider.dart';

class ProfileDetailsScreen extends StatefulWidget {
  const ProfileDetailsScreen({super.key});

  @override
  State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen> {
  TextStyle _poppins(double size, FontWeight weight, Color color) {
    return GoogleFonts.poppins(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: 1.2,
    );
  }

  bool isBasicEditing = false;
  bool isAddressEditing = false;
  bool isSaving = false;
  bool isAddressSaving = false;
  bool isUserDataSet = false;
  bool isAddressDataSet = false;

  // Basic fields
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();

  // Address fields
  final address1Controller = TextEditingController();
  final address2Controller = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final pincodeController = TextEditingController();

  // Identity proof files (kept in parent so we can submit them)
  File? _aadharFront;
  File? _aadharBack;
  File? _panImage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).fetchUser();
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    address1Controller.dispose();
    cityController.dispose();
    stateController.dispose();
    pincodeController.dispose();
    super.dispose();
  }

  void setUserData(UserModel user) {
    nameController.text = user.fullName;
    mobileController.text = user.mobile;
    emailController.text = user.email;
  }
  

void setAddressData(UserModel user) {
  final addr = user.address;
  if (addr != null) {
    address1Controller.text = addr['street'] ?? ''; // ✅ street directly
    cityController.text     = addr['city']    ?? '';
    stateController.text    = addr['state']   ?? '';
    pincodeController.text  = addr['pincode'] ?? '';
  }
}

  // ── Save Basic Details ────────────────────────────────────
Future<void> _saveBasicDetails(UserProvider userProvider) async {
  final name = nameController.text.trim();
  final email = emailController.text.trim();
  final mobile = mobileController.text.trim();

  if (name.isEmpty || email.isEmpty || mobile.isEmpty) {
    _showSnackBar('Please fill all fields', isError: true);
    return;
  }

  setState(() => isSaving = true);

  final success = await userProvider.updateUser(
    fullName: name,
    email: email,
    mobile: mobile,
  );

  setState(() => isSaving = false);

  if (success) {
    await userProvider.fetchUser();   // 🔥 refresh latest data
    isUserDataSet = false;            // 🔥 rebind controllers
    setState(() => isBasicEditing = false);
    _showSnackBar('Profile updated successfully!');
  } else {
    _showSnackBar('Update failed', isError: true);
  }
}

  // ── Save Address ──────────────────────────────────────────
Future<void> _saveAddress(UserProvider userProvider) async {
  final street  = address1Controller.text.trim();
  final city    = cityController.text.trim();
  final state   = stateController.text.trim();
  final pincode = pincodeController.text.trim();

  if (street.isEmpty || city.isEmpty || state.isEmpty || pincode.isEmpty) {
    _showSnackBar('Please fill required address fields', isError: true);
    return;
  }

  setState(() => isAddressSaving = true);

  final user = userProvider.user;

  final success = await userProvider.updateUser(
    fullName: user?.fullName ?? '',
    email:    user?.email ?? '',
    mobile:   user?.mobile ?? '',
    address: {
      "street": street,
      "city": city,
      "state": state,
      "pincode": pincode,
      "country": "India",
    },
  );

  setState(() => isAddressSaving = false);

  if (success) {
    await userProvider.fetchUser();   // 🔥 refresh
    isAddressDataSet = false;         // 🔥 rebind
    setState(() => isAddressEditing = false);
    _showSnackBar('Address updated successfully!');
  } else {
    _showSnackBar('Address update failed', isError: true);
  }
}
  // ── Upload Identity Proof ─────────────────────────────────
 Future<void> _uploadIdentityProof(UserProvider userProvider) async {
  if (_aadharFront == null && _aadharBack == null && _panImage == null) {
    _showSnackBar('No documents to upload', isError: true);
    return;
  }

  setState(() => isSaving = true);

  final user = userProvider.user;

  final success = await userProvider.updateUser(
    fullName: user?.fullName ?? '',
    email: user?.email ?? '',
    mobile: user?.mobile ?? '',
    aadharFront: _aadharFront,
    aadharBack: _aadharBack,
    panImage: _panImage,
  );

  setState(() => isSaving = false);

  if (success) {
    await userProvider.fetchUser();   // 🔥 refresh documents
    _showSnackBar('Documents uploaded successfully!');
  } else {
    _showSnackBar('Document upload failed', isError: true);
  }
}

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: _poppins(13, FontWeight.w500, Colors.white),
        ),
        backgroundColor:
            isError ? const Color(0xFFC6003A) : const Color(0xFF13A64A),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(88),
        child: AppBar(
          toolbarHeight: 120,
          elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xFF3A0A13), Color(0xFFC6003A)],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 20, 14, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Profile',
                      style: _poppins(16, FontWeight.w700, Colors.white),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.help,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.isLoading && !isSaving && !isAddressSaving) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = userProvider.user;

          if (user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(
                    'Failed to load user data',
                    style: _poppins(14, FontWeight.w500, Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => userProvider.fetchUser(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

     if (!isUserDataSet) {
  setUserData(user);
  isUserDataSet = true;
}

if (!isAddressDataSet) {
  setAddressData(user);
  isAddressDataSet = true;
}

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _basicDetailsCard(user, userProvider),
                  const SizedBox(height: 20),
                  _addressCard(userProvider),
                  const SizedBox(height: 20),
                  _identityProofCard(userProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Basic Details Card ────────────────────────────────────
  Widget _basicDetailsCard(UserModel user, UserProvider userProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFD4AF37),
                ),
                child: const Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('User Details',
                      style: _poppins(
                          12, FontWeight.w400, const Color(0xFF717171))),
                  Text('Basic Details',
                      style: _poppins(
                          15, FontWeight.w700, const Color(0xFF212121))),
                ],
              ),
              const Spacer(),
              isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFFC6003A),
                      ),
                    )
                  : GestureDetector(
                      onTap: () {
                        if (isBasicEditing) {
                          _saveBasicDetails(userProvider);
                        } else {
                          setState(() => isBasicEditing = true);
                        }
                      },
                      child: Icon(
                        isBasicEditing
                            ? Icons.check_circle_rounded
                            : Icons.edit,
                        size: 22,
                        color: isBasicEditing
                            ? const Color(0xFF13A64A)
                            : const Color(0xFF555555),
                      ),
                    ),
              if (isBasicEditing && !isSaving) ...[
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    setUserData(user);
                    setState(() => isBasicEditing = false);
                  },
                  child: const Icon(Icons.close_rounded,
                      size: 22, color: Color(0xFFC6003A)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          _label('Full Name'),
          const SizedBox(height: 5),
          isBasicEditing
              ? _editField(
                  controller: nameController, hint: 'Enter full name')
              : _value(user.fullName),
          const SizedBox(height: 10),
          _label('Mobile Number'),
          const SizedBox(height: 5),
          isBasicEditing
              ? _editField(
                  controller: mobileController,
                  hint: 'Enter mobile number',
                  keyboardType: TextInputType.phone,
                )
              : Row(
                  children: [
                    Expanded(child: _value(user.mobile)),
                    _verifiedBadge(),
                  ],
                ),
          const SizedBox(height: 10),
          _label('Email'),
          const SizedBox(height: 5),
          isBasicEditing
              ? _editField(
                  controller: emailController,
                  hint: 'Enter email',
                  keyboardType: TextInputType.emailAddress,
                )
              : _value(user.email),
        ],
      ),
    );
  }

  // ── Address Card ──────────────────────────────────────────
  Widget _addressCard(UserProvider userProvider) {
    final user = userProvider.user;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFD4AF37),
                ),
                child: const Icon(Icons.home_rounded,
                    size: 18, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Location',
                      style: _poppins(
                          12, FontWeight.w400, const Color(0xFF717171))),
                  Text('Address',
                      style: _poppins(
                          15, FontWeight.w700, const Color(0xFF121212))),
                ],
              ),
              const Spacer(),
              isAddressSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFFC6003A),
                      ),
                    )
                  : GestureDetector(
                      onTap: () {
                        if (isAddressEditing) {
                          _saveAddress(userProvider);
                        } else {
                          setState(() => isAddressEditing = true);
                        }
                      },
                      child: Icon(
                        isAddressEditing
                            ? Icons.check_circle_rounded
                            : Icons.edit,
                        size: 22,
                        color: isAddressEditing
                            ? const Color(0xFF13A64A)
                            : const Color(0xFF555555),
                      ),
                    ),
              if (isAddressEditing && !isAddressSaving) ...[
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    if (user != null) setAddressData(user);
                    setState(() => isAddressEditing = false);
                  },
                  child: const Icon(Icons.close_rounded,
                      size: 22, color: Color(0xFFC6003A)),
                ),
              ],
            ],
          ),

          const SizedBox(height: 12),

          // Address Line 1
          _inputLabel('Address Line *'),
          const SizedBox(height: 6),
          isAddressEditing
              ? _editField(
                  controller: address1Controller,
                  hint: 'Enter address line 1')
              : _displayField(address1Controller.text),

          const SizedBox(height: 10),
          // City + Pincode
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _inputLabel('City *'),
                    const SizedBox(height: 6),
                    isAddressEditing
                        ? _editField(
                            controller: cityController, hint: 'City')
                        : _displayField(cityController.text),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _inputLabel('Pincode *'),
                    const SizedBox(height: 6),
                    isAddressEditing
                        ? _editField(
                            controller: pincodeController,
                            hint: 'Pincode',
                            keyboardType: TextInputType.number,
                          )
                        : _displayField(pincodeController.text),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // State
          _inputLabel('State *'),
          const SizedBox(height: 6),
          isAddressEditing
              ? _editField(controller: stateController, hint: 'Enter state')
              : _displayField(stateController.text),
        ],
      ),
    );
  }

  // ── Identity Proof Card ───────────────────────────────────
  Widget _identityProofCard(UserProvider userProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFD4AF37),
                ),
                child: const Icon(Icons.fingerprint_rounded,
                    size: 18, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Verification Required',
                      style: _poppins(
                          12, FontWeight.w400, const Color(0xFF717171))),
                  Text('Identity Proof',
                      style: _poppins(
                          15, FontWeight.w700, const Color(0xFF121212))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Link your identity documents for secure verification',
            style: _poppins(11, FontWeight.w400, const Color(0xFF7A879B)),
          ),
          const SizedBox(height: 10),

          // Aadhaar row
          _proofRow(
            title: 'Aadhaar Card',
            subtitle: (_aadharFront != null && _aadharBack != null)
                ? 'Ready to upload'
                : 'Not Linked',
            icon: Icons.credit_card,
            iconColor: const Color(0xFF2E6AE6),
            isAttached: _aadharFront != null && _aadharBack != null,
            onUpload: () async {
              final result = await showDialog<Map<String, File?>>(
                context: context,
                barrierColor: Colors.black.withOpacity(0.45),
                barrierDismissible: true,
                builder: (_) => Dialog(
                  backgroundColor: Colors.transparent,
                  insetPadding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 40),
                  child:
                      UploadDocumentDialog(docType: 'Aadhaar Card'),
                ),
              );
              if (result != null) {
                setState(() {
                  _aadharFront = result['front'];
                  _aadharBack = result['back'];
                });
                // Auto-submit after picking
                await _uploadIdentityProof(userProvider);
              }
            },
          ),

          const Divider(height: 18, color: Color(0xFFE6E6E6)),

          // PAN row
          _proofRow(
            title: 'PAN Card',
            subtitle: _panImage != null ? 'Ready to upload' : 'Not Linked',
            icon: Icons.badge_outlined,
            iconColor: const Color(0xFF1C9C4D),
            isAttached: _panImage != null,
            onUpload: () async {
              final result = await showDialog<Map<String, File?>>(
                context: context,
                barrierColor: Colors.black.withOpacity(0.45),
                barrierDismissible: true,
                builder: (_) => Dialog(
                  backgroundColor: Colors.transparent,
                  insetPadding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 40),
                  child: UploadDocumentDialog(
                      docType: 'PAN Card', isSingleSide: true),
                ),
              );
              if (result != null) {
                setState(() {
                  _panImage = result['front'];
                });
                // Auto-submit after picking
                await _uploadIdentityProof(userProvider);
              }
            },
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────

  Widget _editField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: _poppins(14, FontWeight.w500, const Color(0xFF1F1F1F)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            _poppins(13, FontWeight.w400, const Color(0xFFAAAAAA)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        filled: true,
        fillColor: const Color(0xFFF8F8F8),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD5D5D5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              const BorderSide(color: Color(0xFFC6003A), width: 1.5),
        ),
      ),
    );
  }

  /// Read-only display box (replaces the old dashes placeholder)
  Widget _displayField(String value) {
    return Container(
      width: double.infinity,
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: const Color(0xFFE6E6E8),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFD5D5D5)),
      ),
      child: Text(
        value.isEmpty ? '—' : value,
        style: _poppins(
          12,
          FontWeight.w400,
          value.isEmpty
              ? const Color(0xFFA4A4A4)
              : const Color(0xFF1F1F1F),
        ),
      ),
    );
  }

  Widget _verifiedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F6EC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified_rounded,
              size: 12, color: Color(0xFF13A64A)),
          const SizedBox(width: 4),
          Text('Verified',
              style: _poppins(
                  11, FontWeight.w500, const Color(0xFF13A64A))),
        ],
      ),
    );
  }

  Widget _inputLabel(String text) =>
      Text(text,
          style: _poppins(12, FontWeight.w400, const Color(0xFF5F5F5F)));

  Widget _label(String text) =>
      Text(text,
          style: _poppins(10, FontWeight.w400, const Color(0xFF7C8798)));

  Widget _value(String text) =>
      Text(text,
          style: _poppins(14, FontWeight.w500, const Color(0xFF1F1F1F)));

  Widget _miniButton(String text, {VoidCallback? onTap, bool active = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: active
                ? [const Color(0xFF0A3A0F), const Color(0xFF13A64A)]
                : [const Color(0xFF3A0013), const Color(0xFFD1004C)],
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child:
            Text(text, style: _poppins(12, FontWeight.w600, Colors.white)),
      ),
    );
  }

  Widget _proofRow({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool isAttached,
    VoidCallback? onUpload,
  }) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: _poppins(
                      33 / 2, FontWeight.w500, const Color(0xFF2A2A2A))),
              Text(subtitle,
                  style: _poppins(
                    11,
                    FontWeight.w400,
                    isAttached
                        ? const Color(0xFF13A64A)
                        : const Color(0xFF7D7D7D),
                  )),
            ],
          ),
        ),
        _miniButton(
          isAttached ? 'Uploaded ✓' : 'Upload',
          onTap: onUpload,
          active: isAttached,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  UPLOAD DOCUMENT DIALOG  — now returns Map<String, File?>
// ─────────────────────────────────────────────────────────────

class UploadDocumentDialog extends StatefulWidget {
  final String docType;

  /// PAN only needs one side; Aadhaar needs front + back
  final bool isSingleSide;

  const UploadDocumentDialog({
    super.key,
    required this.docType,
    this.isSingleSide = false,
  });

  @override
  State<UploadDocumentDialog> createState() => _UploadDocumentDialogState();
}

class _UploadDocumentDialogState extends State<UploadDocumentDialog> {
  TextStyle _poppins(double size, FontWeight weight, Color color) {
    return GoogleFonts.poppins(
        fontSize: size, fontWeight: weight, color: color, height: 1.2);
  }

  File? frontImage;
  File? backImage;

  Future<void> _pickFile(String side) async {
    final ImagePicker picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image =
                      await picker.pickImage(source: ImageSource.camera);
                  if (image != null) {
                    setState(() {
                      if (side == 'front') {
                        frontImage = File(image.path);
                      } else {
                        backImage = File(image.path);
                      }
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image =
                      await picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    setState(() {
                      if (side == 'front') {
                        frontImage = File(image.path);
                      } else {
                        backImage = File(image.path);
                      }
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // For single-side (PAN), only front is required
    final bool canAttach = widget.isSingleSide
        ? frontImage != null
        : frontImage != null && backImage != null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Gradient header
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xFF3A0A13), Color(0xFFC6003A)],
              ),
            ),
            padding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  widget.docType,
                  style: _poppins(
                      13, FontWeight.w700, const Color(0xFFC6003A)),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Front
                _uploadZone(
                  docLabel: widget.docType,
                  pageLabel: widget.isSingleSide ? 'front page' : 'front page',
                  imageFile: frontImage,
                  onTap: () => _pickFile('front'),
                ),

                // Back — only for Aadhaar
                if (!widget.isSingleSide) ...[
                  const SizedBox(height: 12),
                  _uploadZone(
                    docLabel: widget.docType,
                    pageLabel: 'back page',
                    imageFile: backImage,
                    onTap: () => _pickFile('back'),
                  ),
                ],

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFC01D51)),
                          backgroundColor: const Color(0xFFF8F8F8),
                          minimumSize: const Size.fromHeight(44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: _poppins(14, FontWeight.w500,
                              const Color(0xFF5B0E24)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: canAttach
                                ? [
                                    const Color(0xFF3A0A13),
                                    const Color(0xFFC6003A)
                                  ]
                                : [
                                    const Color(0xFFCCCCCC),
                                    const Color(0xFFCCCCCC)
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: ElevatedButton(
                          // ✅ Return files as a Map so parent can consume them
                          onPressed: canAttach
                              ? () => Navigator.pop(context, {
                                    'front': frontImage,
                                    'back': backImage,
                                  })
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            disabledBackgroundColor: Colors.transparent,
                            minimumSize: const Size.fromHeight(44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: Text(
                            'Attach File',
                            style:
                                _poppins(14, FontWeight.w500, Colors.white),
                          ),
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
    );
  }

  Widget _uploadZone({
    required String docLabel,
    required String pageLabel,
    required File? imageFile,
    required VoidCallback onTap,
  }) {
    final bool uploaded = imageFile != null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: uploaded
              ? const Color(0xFFF0FAF4)
              : const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: uploaded
                ? const Color(0xFF13A64A)
                : const Color(0xFFCCCCCC),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (uploaded)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(imageFile,
                    height: 80, width: 120, fit: BoxFit.cover),
              )
            else
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFF0F0F0),
                ),
                child: const Icon(Icons.credit_card_outlined,
                    size: 24, color: Color(0xFFAAAAAA)),
              ),
            const SizedBox(height: 10),
            Text(docLabel,
                style:
                    _poppins(13, FontWeight.w500, const Color(0xFF555555))),
            const SizedBox(height: 4),
            Text(
              uploaded ? "Uploaded ✓" : pageLabel,
              style: _poppins(
                11,
                FontWeight.w400,
                uploaded
                    ? const Color(0xFF13A64A)
                    : const Color(0xFFAAAAAA),
              ),
            ),
          ],
        ),
      ),
    );
  }
}