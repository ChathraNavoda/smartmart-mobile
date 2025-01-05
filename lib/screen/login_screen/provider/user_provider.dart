import 'package:ecomapp/models/api_response.dart';
import 'package:ecomapp/utility/snack_bar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../core/data/data_provider.dart';
import '../../../models/user.dart';
import '../../../services/http_services.dart';
import '../../../utility/constants.dart';
import '../login_screen.dart';

class UserProvider extends ChangeNotifier {
  HttpService service = HttpService();
  final DataProvider _dataProvider;
  final box = GetStorage();

  UserProvider(this._dataProvider);

  Future<String?> login(LoginData data) async {
    try {
      Map<String, dynamic> loginData = {
        'name': data.name.toLowerCase(),
        'password': data.password
      };
      final response = await service.addItem(
          endpointUrl: 'users/login', itemData: loginData);
      if (response.isOk) {
        final ApiResponse<User> apiResponse = ApiResponse<User>.fromJson(
            response.body,
            (json) => User.fromJson(json as Map<String, dynamic>));
        if (apiResponse.success == true) {
          User? user = apiResponse.data;
          saveLoginInfo(user);
          SnackBarHelper.showSuccessSnackBar(apiResponse.message);
          return null;
        } else {
          SnackBarHelper.showErrorSnackBar(
              'Failed to login: ${apiResponse.message} ');
          return 'Failed to login: ${apiResponse.message} ';
        }
      } else {
        SnackBarHelper.showErrorSnackBar(
            'Error ${response.body?['message'] ?? response.statusText}');
        return 'Error ${response.body?['message'] ?? response.statusText}';
      }
    } catch (e) {
      print(e);
      SnackBarHelper.showErrorSnackBar('An error occurred : $e!');
      return 'An error occurred : $e!';
    }
  }

  Future<String?> register(SignupData data) async {
    try {
      Map<String, dynamic> user = {
        'name': data.name?.toLowerCase(),
        'password': data.password
      };
      final response =
          await service.addItem(endpointUrl: 'users/register', itemData: user);

      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success == true) {
          SnackBarHelper.showSuccessSnackBar(apiResponse.message);
          return null;
        } else {
          SnackBarHelper.showErrorSnackBar(
              'Failed to register: ${apiResponse.message} ');
          return 'Failed to register: ${apiResponse.message} ';
        }
      } else {
        SnackBarHelper.showErrorSnackBar(
            'Error ${response.body?['message'] ?? response.statusText}');
        return 'Error ${response.body?['message'] ?? response.statusText}';
      }
    } catch (e) {
      print(e);
      SnackBarHelper.showErrorSnackBar('An error occurred : $e!');
      return 'An error occurred : $e!';
    }
  }

  Future<void> saveLoginInfo(User? loginUser) async {
    await box.write(USER_INFO_BOX, loginUser?.toJson());
    Map<String, dynamic>? userJson = box.read(USER_INFO_BOX);
  }

  User? getLoginUsr() {
    Map<String, dynamic>? userJson = box.read(USER_INFO_BOX);
    User? userLogged = User.fromJson(userJson ?? {});
    return userLogged;
  }

  logOutUser() {
    box.remove(USER_INFO_BOX);
    Get.offAll(const LoginScreen());
  }
}
