import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Theo dõi trạng thái user hiện tại
  Rx<User?> firebaseUser = Rx<User?>(null);
  RxString userName = ''.obs;

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
      }
    });
  }

  Future<void> _fetchUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        userName.value = doc.data()?['name'] ?? '';
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

  // Đăng nhập (Login)
  Future<String?> loginWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // Thành công
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'Không tìm thấy tài khoản với email này.';
      } else if (e.code == 'wrong-password') {
        return 'Mật khẩu không chính xác.';
      }
      return 'Email hoặc mật khẩu không đúng.';
    } catch (e) {
      return 'Có lỗi xảy ra: $e';
    }
  }

  // Đăng xuất (Logout)
  Future<void> logout() async {
    await _auth.signOut();
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
