
import 'package:Eletor/api/action/user_api.dart';
import 'package:Eletor/api/base_model/base_model.dart';
import 'package:Eletor/models/user/login_model.dart';
import 'package:Eletor/models/user/response_login_model.dart';
import 'package:Eletor/models/user/response_register_model.dart';
import 'package:Eletor/models/user/user_id_model.dart';
import 'package:Eletor/models/user/user_info_account.dart';
import 'package:Eletor/models/user/user_info_model.dart';
import 'package:Eletor/utils/googles/authcredential_sign_in.dart';
import 'package:Eletor/utils/shared_preference.dart';
import 'package:Eletor/utils/values.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked/stacked.dart';

class SignInViewModel extends BaseViewModel {
  GoogleSignIn _googleSignIn;
  User _user;
  bool _loginStatus = false;
  bool _isPageLoading = false;

  bool get isPageLoading => _isPageLoading;
  bool _loadingLogin = false;

  bool _authenticated = false;

  final UserApi _userApi = UserApi();

  get isLogin => _loginStatus;

  get loadingLogin => _loadingLogin;

  get isAuthenticated => _authenticated;

  String _name = "";

  String _position = "";

  String _imageUrl;

  get name => _name;

  get position => _position;

  get imageUrl => _imageUrl;

  SignInViewModel() {
    init();
    _checkAuthentication();
  }

  init() async {
    await Firebase.initializeApp();
    _googleSignIn = GoogleSignIn();
    _user = FirebaseAuth.instance.currentUser;
    setCurrentUser();
    notifyListeners();
  }

  setCurrentUser() {
    if (!(_user.isNull)) _loginStatus = true;
    notifyListeners();
  }

  signIn() async {
    GoogleSignInAccount account = await _googleSignIn.signIn();

    AuthenticationGoogleSignIn _auth = AuthenticationGoogleSignIn(account);
    await _auth.initializeAuth();
    _user = await _auth.userInfo;

    _signInSuccess(!(user.isNull));
    notifyListeners();
  }

  _signInSuccess(bool signInSuccess) {
    if (signInSuccess) {
      _loginStatus = true;
      notifyListeners();
      //  Get.offNamed(Routes.HOME);
    }
    notifyListeners();
  }

  signOut() async {
    await _googleSignIn.signOut();
    _user = null;
    _loginStatus = false;
    notifyListeners();
  }
/*
  authenticizedUser(String username, String password) async {

    LoginModel loginModel = LoginModel(username: username, password: password);
    BaseModel<ResponseLoginModel> result = await _userApi.authenticized(loginModel);
    if (result.data.status == 200) {

      String authKey = result.data.data.authenticized;
     await getUserInformation(UserIdModel(userId: authKey));
      // _authenticated = true;
      // notifyListeners();

      saveSharePref(authKey);

    }
  }
*/
  saveSharePref(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(Values.authenicized_key, value);
  }

  _checkAuthentication() async {
    SharedPreferences prefs = await SharedPreferenceUtils.initialize();
    if (prefs.getString(Values.authenicized_key) != null){
      _authenticated = true;
      notifyListeners();
    }
  }
/*
  bool checkTextFieldOrNot(TextEditingController _userController,TextEditingController _passController){
    if(_userController.text.trim().isEmpty) return false;
    if(_passController.text.trim().isEmpty) return false;
    return true;
  }
*/

  saveUserInfo(String displayName ,String image)async{
    SharedPreferenceUtils.setString(Values.displayName, displayName);
    SharedPreferenceUtils.setString(Values.photoURL, image);
  }
  // showLoading() {
  //   log("showLoading Active", name: 'showLoading');
  //   _isPageLoading = true;
  //   log("_isPageLoading = $isPageLoading");
  //   notifyListeners();
  // }
  //
  // dismissLoading() {
  //   log("dismissLoading Active", name: 'dismissLoading');
  //   _isPageLoading = false;
  //   log("_isPageLoading = $isPageLoading");
  //   notifyListeners();
  // }

  Future<bool> registerUser(UserInfo userInfo) async {
    UserInfoAccount infoAcc = UserInfoAccount(
        displayName: userInfo.displayName,
        email: userInfo.email,
        phoneNumber: userInfo.phoneNumber ?? 0,
        photoURL: userInfo.photoURL,
        uid: userInfo.uid);

    print("serInfo.uid: ${userInfo.uid}");
    BaseModel<ResponseRegisterModel> response = await _userApi.register(infoAcc);

    if (response.data.status == 200) return true;
    return false;
  }

  User get user => _user;
}