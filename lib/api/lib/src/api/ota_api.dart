//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'dart:async';

// ignore: unused_import
import 'dart:convert';
import 'package:plant_nanny_api/src/deserialize.dart';
import 'package:dio/dio.dart';

import 'package:plant_nanny_api/src/model/command.dart';
import 'package:plant_nanny_api/src/model/error.dart';
import 'package:plant_nanny_api/src/model/v1_devices_device_id_ota_post_request.dart';

class OTAApi {

  final Dio _dio;

  const OTAApi(this._dio);

  /// Request OTA check/update
  /// Typiquement, l&#39;app crée une commande ota_check (ou ota_update) via /commands. Cette route est un raccourci possible. 
  ///
  /// Parameters:
  /// * [deviceId] - Unique device identifier (e.g., esp32-1)
  /// * [v1DevicesDeviceIdOtaPostRequest] 
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [Command] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<Command>> v1DevicesDeviceIdOtaPost({ 
    required String deviceId,
    V1DevicesDeviceIdOtaPostRequest? v1DevicesDeviceIdOtaPostRequest,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/devices/{deviceId}/ota'.replaceAll('{' r'deviceId' '}', deviceId.toString());
    final _options = Options(
      method: r'POST',
      headers: <String, dynamic>{
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'http',
            'scheme': 'bearer',
            'name': 'FirebaseJwt',
          },
        ],
        ...?extra,
      },
      contentType: 'application/json',
      validateStatus: validateStatus,
    );

    dynamic _bodyData;

    try {
_bodyData=jsonEncode(v1DevicesDeviceIdOtaPostRequest);
    } catch(error, stackTrace) {
      throw DioException(
         requestOptions: _options.compose(
          _dio.options,
          _path,
        ),
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    final _response = await _dio.request<Object>(
      _path,
      data: _bodyData,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    Command? _responseData;

    try {
final rawData = _response.data;
_responseData = rawData == null ? null : deserialize<Command, Command>(rawData, 'Command', growable: true);

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<Command>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }

}
