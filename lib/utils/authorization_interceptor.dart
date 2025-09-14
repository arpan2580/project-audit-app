import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jnk_app/services/dio_exceptions.dart';

import '../controllers/base_controller.dart';
import '../views/dialogs/dialog_helper.dart';

class AuthorizationInterceptor extends Interceptor {
  final isLoggedIn = GetStorage();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    var token = isLoggedIn.read('token');
    var refreshToken = isLoggedIn.read('refreshToken');

    if (_needAuthorizationHeader(options) == 1) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    if (_needAuthorizationHeader(options) == 2) {
      options.headers['Authorization'] = 'Bearer $refreshToken';
    }
    super.onRequest(options, handler);
  }

  int _needAuthorizationHeader(RequestOptions options) {
    if (options.method == 'GET' || options.headers.containsKey('noToken')) {
      options.headers.remove('noToken');
      return 0;
    }
    if (options.headers.containsKey('refreshToken')) {
      // options.headers.remove('refreshToken');
      return 2;
    } else {
      return 1;
    }
  }

  @override
  void onError(DioException err, handler) async {
    dynamic token;
    Dio dio = Dio();
    //  || err.response?.statusCode == 403
    // print(err.response?.statusCode);
    // print(err.response?.data);
    if (err.response != null && err.response?.statusCode == 400) {
      if (err.response?.data['status'] == false) {
        BaseController.hideLoading();
        DialogHelper.showErrorToast(
          description: err.response!.data['message'].toString(),
        );
        return;
      }
    } else if (err.response?.statusCode == 401 &&
        err.response?.data.containsKey('detail') &&
        (err.response?.data['detail'] != null ||
            err.response?.data['detail'] != '')) {
      if ((err.response?.data['code'] != null ||
              err.response?.data['code'] != '') &&
          (err.response?.data['code'] == 'token_not_valid')) {
        if (err.response?.data['detail'] == 'Token is invalid' ||
            err.response?.data['detail'] == 'Token is blacklisted' ||
            err.response?.data['detail'] == 'Token is expired') {
          BaseController.sessionExpired();
          return;
        }
        try {
          await BaseController.tokenGeneration().then((value) async {
            if (value) {
              token = isLoggedIn.read('token');

              err.requestOptions.headers["Authorization"] = 'Bearer $token';

              final opts = Options(
                method: err.requestOptions.method,
                headers: err.requestOptions.headers,
              );

              final cloneReq = await dio.request(
                BaseController.baseUrl + err.requestOptions.path,
                options: opts,
                data: err.requestOptions.data,
              );
              return handler.resolve(cloneReq);
            }
          });
          // return _dio;

          // } catch (e) {
          //   print('test: ' + e.toString());
          // }
        } on DioException catch (e) {
          final errorMessage = DioExceptions.fromDioError(e).toString();
          print(errorMessage.toString());
        }
      } else {
        BaseController.hideLoading();
        DialogHelper.showErrorToast(description: err.response?.data['detail']);
      }
    } else if (err.response?.statusCode == 401 &&
        err.response?.data.containsKey('message') &&
        err.response?.data['message'] != '') {
      BaseController.hideLoading();
      DialogHelper.showErrorToast(
        description: err.response!.data['message'].toString(),
      );
      return;
    } else {
      final errorMessage = DioExceptions.fromDioError(err).toString();
      BaseController.hideLoading();
      DialogHelper.showErrorToast(description: errorMessage);
    }
  }
}
