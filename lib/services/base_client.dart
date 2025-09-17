import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dio/dio.dart' as dio show LogInterceptor;
import 'package:jnk_app/controllers/base_controller.dart';
import 'package:get_storage/get_storage.dart';

import '../utils/authorization_interceptor.dart';
import '../views/dialogs/dialog_helper.dart';

class BaseClient {
  final isLoggedIn = GetStorage();

  final Dio _dio;
  BaseClient()
    : _dio = Dio(
        BaseOptions(
          baseUrl: BaseController.baseUrl,
          connectTimeout: const Duration(seconds: 120), // 2 minutes
          receiveTimeout: const Duration(seconds: 120), // 2 minutes
          responseType: ResponseType.json,
          contentType: 'application/json',
        ),
      ) {
    _dio.interceptors.add(AuthorizationInterceptor());

    // 📝 Logging Interceptor
    _dio.interceptors.add(
      dio.LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
        logPrint: (obj) => print("🔍 DIO LOG: $obj"),
      ),
    );
  }

  //GET
  // Future<dynamic> get(String api) async {
  //   try {
  //     final response = await _dio.get(api);
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       var responseJson = json.decode(response.data);
  //       return responseJson;
  //     }
  //   } on DioError catch (err) {
  //     final errorMessage = DioException.fromDioError(err).toString();
  //     throw errorMessage;
  //   } catch (e) {
  //     print(e);
  //     throw e.toString();
  //   }
  // }

  //POST
  Future<dynamic> dioPost(
    String api,
    dynamic payload, [
    bool isRefresh = false,
    bool noToken = false,
  ]) async {
    dynamic response;
    dynamic responseJson;
    try {
      if (isRefresh) {
        response = await _dio.post(
          api,
          data: payload,
          options: Options(
            headers: {'refreshToken': true, 'Accept': 'application/json'},
          ),
        );
      } else {
        if (noToken) {
          response = await _dio.post(
            api,
            data: payload,
            options: Options(
              headers: {
                'noToken': true,
                'Accept': 'application/json',
                'Content-Type': 'application/json',
              },
            ),
          );
        } else {
          response = await _dio.post(
            api,
            data: payload,
            options: Options(
              headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
              },
            ),
          );
        }
      }

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 206) {
        responseJson = json.decode(response.toString());
        return responseJson;
      }
    } on DioException catch (err) {
      if (response != null && response.statusCode == 400) {
        responseJson = json.decode(response.toString());
        return responseJson;
      }
      DialogHelper.showErrorToast(description: err.toString());
    } catch (e) {
      DialogHelper.showErrorToast(description: e.toString());
    }
  }
}
