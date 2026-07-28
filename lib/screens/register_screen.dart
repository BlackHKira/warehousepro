import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main_shell.dart';
import '../theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String _selectedRole = 'Thủ kho';
  String _selectedGender = 'Nam';
  bool _termsAccepted = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_termsAccepted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Bạn phải đồng ý với điều khoản'), backgroundColor: AppColors.red),
      );
      return;
    }
    setState(() => _isLoading = true);

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;

    debugPrint('REGISTER: Starting registration...');
    debugPrint('REGISTER: Name=$name, Email=$email, Phone=$phone');

    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint('REGISTER: Auth success, UID=${cred.user!.uid}');

      await FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'warehousepro-db',
      ).collection('users').doc(cred.user!.uid).set({
            'name': name,
            'email': email,
            'phone': phone,
            'gender': _selectedGender,
            'role': _selectedRole,
            'status': 'Hoạt động',
            'fcmToken': null,
            'termsAccepted': true,
            'lastActive': FieldValue.serverTimestamp(),
          });
      debugPrint('REGISTER: Firestore user saved');

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MainShell(initialRole: _selectedRole),
        ),
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('REGISTER: FirebaseAuthException code=${e.code} msg=${e.message}');
      if (!mounted) return;
      String msg;
      switch (e.code) {
        case 'email-already-in-use':
          msg = 'Email đã được sử dụng';
          break;
        case 'weak-password':
          msg = 'Mật khẩu phải có ít nhất 6 ký tự';
          break;
        case 'invalid-email':
          msg = 'Email không hợp lệ';
          break;
        default:
          msg = e.message ?? 'Lỗi không xác định';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: AppColors.red),
      );
    } catch (e) {
      debugPrint('REGISTER: General error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: AppColors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.15),
                          blurRadius: 20,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.warehouse,
                      color: AppColors.primary,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Tạo tài khoản',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'WarehousePro — Quản lý kho vận',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFFCBD5E1),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Form Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.12),
                          blurRadius: 30,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Họ và tên',
                            prefixIcon: Icon(Icons.person_outline, size: 20, color: AppColors.textSecondary),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.primary),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                          textCapitalization: TextCapitalization.words,
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Nhập họ tên' : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined, size: 20, color: AppColors.textSecondary),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.primary),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Nhập email';
                            final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                            if (!emailRegex.hasMatch(v.trim())) return 'Email không hợp lệ';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _phoneController,
                          decoration: InputDecoration(
                            labelText: 'Số điện thoại',
                            prefixIcon: Icon(Icons.phone_outlined, size: 20, color: AppColors.textSecondary),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.primary),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Nhập số điện thoại';
                            final phone = v.replaceAll(RegExp(r'\s'), '');
                            if (!RegExp(r'^0\d{9}$').hasMatch(phone)) return 'Số điện thoại phải đúng 10 chữ số';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedRole,
                          decoration: InputDecoration(
                            labelText: 'Vai trò',
                            prefixIcon: Icon(Icons.badge_outlined, size: 20, color: AppColors.textSecondary),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.primary),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'Thủ kho', child: Text('Thủ kho')),
                            DropdownMenuItem(value: 'Kế toán', child: Text('Kế toán')),
                            DropdownMenuItem(value: 'Quản lý', child: Text('Quản lý')),
                          ],
                          onChanged: (v) {
                            if (v != null) setState(() => _selectedRole = v);
                          },
                          validator: (v) => v == null || v.isEmpty ? 'Chọn vai trò' : null,
                        ),
                        const SizedBox(height: 14),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 8, top: 8),
                                child: Row(
                                  children: [
                                    Icon(Icons.person_outline, size: 20, color: AppColors.textSecondary),
                                    const SizedBox(width: 8),
                                    Text('Giới tính', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                                  ],
                                ),
                              ),
                              RadioGroup<String>(
                                groupValue: _selectedGender,
                                onChanged: (v) => setState(() => _selectedGender = v!),
                                child: Row(
                                  children: [
                                    Radio<String>(
                                      value: 'Nam',
                                      activeColor: AppColors.primary,
                                    ),
                                    GestureDetector(
                                      onTap: () => setState(() => _selectedGender = 'Nam'),
                                      child: const Text('Nam', style: TextStyle(fontSize: 14)),
                                    ),
                                    const Spacer(),
                                    Radio<String>(
                                      value: 'Nữ',
                                      activeColor: AppColors.primary,
                                    ),
                                    GestureDetector(
                                      onTap: () => setState(() => _selectedGender = 'Nữ'),
                                      child: const Text('Nữ', style: TextStyle(fontSize: 14)),
                                    ),
                                    const Spacer(),
                                    Radio<String>(
                                      value: 'Khác',
                                      activeColor: AppColors.primary,
                                    ),
                                    GestureDetector(
                                      onTap: () => setState(() => _selectedGender = 'Khác'),
                                      child: const Text('Khác', style: TextStyle(fontSize: 14)),
                                    ),
                                    const Spacer(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Mật khẩu',
                            prefixIcon: Icon(Icons.lock_outlined, size: 20, color: AppColors.textSecondary),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                size: 20,
                                color: AppColors.textSecondary,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.primary),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                          validator: (v) => v == null || v.length < 6
                              ? 'Mật khẩu phải có ít nhất 6 ký tự'
                              : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _confirmController,
                          obscureText: _obscureConfirm,
                          decoration: InputDecoration(
                            labelText: 'Nhập lại mật khẩu',
                            prefixIcon: Icon(Icons.lock_outlined, size: 20, color: AppColors.textSecondary),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                                size: 20,
                                color: AppColors.textSecondary,
                              ),
                              onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.primary),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                          validator: (v) => v != _passwordController.text
                              ? 'Mật khẩu không khớp'
                              : null,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _termsAccepted,
                                onChanged: (v) => setState(() => _termsAccepted = v ?? false),
                                activeColor: AppColors.primary,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 4, top: 2),
                                child: GestureDetector(
                                  onTap: () => setState(() => _termsAccepted = !_termsAccepted),
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Tôi đồng ý với ',
                                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                        ),
                                        TextSpan(
                                          text: 'Điều khoản sử dụng',
                                          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13),
                                        ),
                                        TextSpan(
                                          text: ' và ',
                                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                        ),
                                        TextSpan(
                                          text: 'Chính sách bảo mật',
                                          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: FilledButton(
                            onPressed: _isLoading ? null : _register,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              elevation: 0,
                              shadowColor: AppColors.primary.withValues(alpha: 0.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Đăng ký', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Đã có tài khoản? ',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                          ),
                          const TextSpan(
                            text: 'Đăng nhập',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
