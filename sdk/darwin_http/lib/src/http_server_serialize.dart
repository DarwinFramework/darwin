/*
 *    Copyright 2022, the Darwin Framework authors
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */

part of 'http_server.dart';

extension HttpServerSerialize on DarwinHttpServer {
  Future<dynamic> deserializeBody(RequestContext context, Type type) async {
    var data = <int>[];
    await context.request.read().listen((event) {
      data.addAll(event);
    }).asFuture();
    context[DarwinHttpServer.requestDrainedKey] = true;

    if (type == List<int>) return data;
    if (type == String) return utf8.decode(data);

    var contentType = context.request.headers["Content-Type"] ?? "text/plain";
    var deserializationContext =
        DeserializationContext(contentType, type, {}, marshal);
    var mapper = marshal.findDeserializer(deserializationContext);
    if (mapper == null) throw Exception("No mapper found");
    var value = mapper.deserialize(data, deserializationContext);
    return value;
  }

  Future<Response> serializeResponse(FutureOr<dynamic> valueOrFuture, Type type,
      String? explicitContentType) async {
    var value = await valueOrFuture;
    if (type == Response || (type == dynamic && value is Response)) {
      return value;
    }
    if ((type == List<int>) || (type == dynamic && value is List<int>)) {
      return Response.ok(value);
    }
    if (value is Stream) value = await value.toList();
    var isPrimitive =
        (type == String || type == int || type == double || type == bool);
    var contentType = explicitContentType ??
        (isPrimitive ? "text/plain" : "application/json");
    var serializationContext =
        SerializationContext(type, contentType, {}, marshal);
    var serializer = marshal.findSerializer(serializationContext);
    var data = serializer!.serialize(value, serializationContext);
    return Response.ok(data, headers: {"Content-Type": contentType});
  }
}
