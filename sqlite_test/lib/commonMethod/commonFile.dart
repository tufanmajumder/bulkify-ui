import 'dart:convert';

class CommonMethod {
  convertData(String phone, String deviceId, String model, String brand) {
    // 1. Define your source Map
    final Map<String, dynamic> deviceData = {
      "devicetype": phone,
      "deviceid": deviceId,
      "model": model,
      "brand": brand,
    };

    // 2. Format the Map into a pretty-printed JSON string with 2 spaces
    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    final String prettyJsonString = encoder.convert(deviceData);

    // 3. Convert the string to bytes (UTF-8)
    final List<int> jsonBytes = utf8.encode(prettyJsonString);

    // 4. Encode the bytes to Base64
    final String base64Result = base64.encode(jsonBytes);

    print(base64Result);
    return base64Result;
    // Output: ewogICJkZXZpY2V0eXBlIjogIlBob25lIiwKICAiZGV2aWNlaWQiOiAiQlA0QS4yNTEyMDUuMDA2IiwKICAibW9kZWwiOiAiU00tTTA3NUYiLAogICJicmFuZCI6ICJzYW1zdW5nIgp9
  }
}
