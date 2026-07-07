import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Theo dõi trạng thái user hiện tại
  Rx<User?> firebaseUser = Rx<User?>(null);
  RxString userName = ''.obs;
  RxString userPhone = ''.obs;

  User? get currentUser => firebaseUser.value;

  @override
  void onInit() {
    super.onInit();
    // Lắng nghe sự thay đổi trạng thái đăng nhập
    firebaseUser.bindStream(_auth.authStateChanges());
    
    // Khi user thay đổi, lấy lại tên người dùng từ Firestore
    ever(firebaseUser, (User? user) {
      if (user != null) {
        _fetchUserProfile(user.uid);
      } else {
        userName.value = '';
        userPhone.value = '';
      }
    });
  }

  Future<void> _fetchUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        userName.value = doc.data()?['name'] ?? '';
        userPhone.value = doc.data()?['phone'] ?? '';
      }
    } catch (e) {
      print('Lỗi tải profile: $e');
    }
  }

  // Đăng ký (Register)
  Future<String?> registerWithEmail(
      String name, String phone, String email, String password) async {
    try {
      // 1. Tạo user trên Firebase Auth
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Lưu thông tin phụ (tên, sđt, role) vào Firestore
      if (cred.user != null) {
        await _firestore.collection('users').doc(cred.user!.uid).set({
          'id': cred.user!.uid,
          'name': name,
          'phone': phone,
          'email': email,
          'role': 'customer', // Mặc định là khách hàng
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return null; // Thành công (không có lỗi)
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'Mật khẩu quá yếu (cần ít nhất 6 ký tự).';
      } else if (e.code == 'email-already-in-use') {
        return 'Email này đã được sử dụng.';
      }
      return e.message;
    } catch (e) {
      return 'Có lỗi xảy ra: $e';
    }
  }

  // Đăng nhập bằng Email HOẶC Số điện thoại
  Future<String?> loginWithEmailOrPhone(String identifier, String password) async {
    String emailToLogin = identifier.trim();

    // Kiểm tra nếu người dùng nhập số điện thoại (chỉ có chữ số, độ dài 10)
    final isPhone = RegExp(r'^\d{10,11}$').hasMatch(identifier.trim());
    if (isPhone) {
      // Tra Firestore để tìm email tương ứng với số điện thoại này
      try {
        final query = await _firestore
            .collection('users')
            .where('phone', isEqualTo: identifier.trim())
            .limit(1)
            .get();

        if (query.docs.isEmpty) {
          return 'Không tìm thấy tài khoản với số điện thoại này.';
        }
        emailToLogin = query.docs.first.data()['email'] ?? '';
      } catch (e) {
        return 'Lỗi kết nối mạng. Vui lòng thử lại.';
      }
    }

    // Đăng nhập bằng email (dù người dùng nhập SĐT hay email)
    try {
      await _auth.signInWithEmailAndPassword(
          email: emailToLogin, password: password);
      return null; // Thành công
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuth Error Code: ${e.code}');
      switch (e.code) {
        case 'user-not-found':
          return 'Không tìm thấy tài khoản.';
        case 'wrong-password':
        case 'invalid-credential':
          return 'Thông tin đăng nhập không đúng.';
        case 'invalid-email':
          return 'Địa chỉ email không hợp lệ.';
        case 'user-disabled':
          return 'Tài khoản này đã bị vô hiệu hoá.';
        case 'too-many-requests':
          return 'Quá nhiều lần thử. Vui lòng đợi vài phút rồi thử lại.';
        case 'network-request-failed':
          return 'Lỗi kết nối mạng. Vui lòng kiểm tra lại.';
        default:
          return 'Lỗi đăng nhập (${e.code}).';
      }
    } catch (e) {
      return 'Có lỗi xảy ra: $e';
    }
  }

  // Cập nhật Profile (Tên, SĐT)
  Future<String?> updateUserProfile(String name, String phone) async {
    try {
      if (currentUser == null) return 'Lỗi: Chưa đăng nhập';
      
      await _firestore.collection('users').doc(currentUser!.uid).update({
        'name': name,
        'phone': phone,
      });
      
      // Cập nhật lại state cục bộ ngay lập tức
      userName.value = name;
      userPhone.value = phone;
      return null; // Thành công
    } catch (e) {
      return 'Có lỗi xảy ra khi cập nhật hồ sơ: $e';
    }
  }

  // Đổi mật khẩu (yêu cầu mật khẩu hiện tại để re-authenticate)
  Future<String?> changePassword(String currentPassword, String newPassword) async {
    try {
      if (currentUser == null || currentUser!.email == null) {
        return 'Lỗi: Không tìm thấy thông tin đăng nhập.';
      }
      
      // 1. Re-authenticate
      AuthCredential credential = EmailAuthProvider.credential(
        email: currentUser!.email!,
        password: currentPassword,
      );
      
      await currentUser!.reauthenticateWithCredential(credential);
      
      // 2. Update Password
      await currentUser!.updatePassword(newPassword);
      
      return null; // Thành công
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return 'Mật khẩu hiện tại không chính xác.';
      } else if (e.code == 'weak-password') {
        return 'Mật khẩu mới quá yếu (cần ít nhất 6 ký tự).';
      }
      return 'Lỗi đổi mật khẩu: ${e.message}';
    } catch (e) {
      return 'Có lỗi xảy ra: $e';
    }
  }

  // Đăng xuất (Logout)
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Quên mật khẩu — Firebase tự gửi email đặt lại mật khẩu
  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null; // Thành công
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
        case 'invalid-credential':
          return 'Không tìm thấy tài khoản với email này.';
        case 'invalid-email':
          return 'Địa chỉ email không hợp lệ.';
        case 'network-request-failed':
          return 'Lỗi kết nối mạng. Vui lòng kiểm tra lại.';
        default:
          return 'Có lỗi xảy ra (${e.code}).';
      }
    } catch (e) {
      return 'Có lỗi xảy ra: $e';
    }
  }

  // Lấy role (vai trò) của user hiện tại từ Firestore
  Future<String> getUserRole() async {
    if (_auth.currentUser == null) return 'customer';

    DocumentSnapshot doc = await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .get();
    if (doc.exists && doc.data() != null) {
      final data = doc.data() as Map<String, dynamic>;
      return data['role'] ?? 'customer';
    }
    return 'customer';
  }
}
