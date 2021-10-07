library smartiiqrcodesdk;

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class SmartiiQrSDK {
  static String _apiKey = "";
  static var _url = "https://apiv2.forms.smartii.io/dev";
  static StreamController _smartiiController = StreamController.broadcast();
  static String _qrKey = "";
  static Timer? _timer;

  static Future<String> initialize(apiKey, List<String> requiedParams) async {
    _apiKey = apiKey;
    var _dio = Dio();
    var options = Options(headers: {"api-key": apiKey});
    var qrKey = await _dio.post(_url + "/getqrcode",
        data: {"data": requiedParams}, options: options);
    _qrKey = qrKey.data["code"];
    return _qrKey;
  }

  static Widget SmartiiQRView(qrKey, {size: 200.0}) {
    if (qrKey == '' || qrKey == null) {
      return Container();
    }
    _isQRScanned(qrKey);
    return QrImage(
      data: qrKey,
      version: QrVersions.auto,
      size: size,
    );
  }

  static _isQRScanned(qrKey) {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 5), (_) async {
      var _dio = Dio();
      var options = Options(headers: {"api-key": _apiKey});
      var result = await _dio.post(_url + "/checkfordata",
          data: {"code": qrKey}, options: options);
      if (result.data["status"] == 1) {
        _timer?.cancel();
        _smartiiController
            .add({"message": "success", "fields": result.data["data"]});
        // i will get data
      }
      if (result.data["status"] == 2) {
        _timer?.cancel();
        _smartiiController.add({
          "message": "QR already used",
        });

        // Used
      }
      if (result.data["status"] == 3) {
        _timer?.cancel();
        _smartiiController.add({
          "message": "QR didnt exists",
        });
        // didnt exists
      }
    });
  }

  static Stream get smartiiSDK => _smartiiController.stream;
}
