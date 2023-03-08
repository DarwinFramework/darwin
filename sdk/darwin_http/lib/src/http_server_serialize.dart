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
  Future<dynamic> deserializeBody(RequestContext context, TypeCapture typeCapture, [String? contentType]) async {
    var type = typeCapture.typeArgument;
    assert(type != dynamic, "Body parameters must specify explicit types.");

    // Read request fully
    var data = <int>[];
    await context.request.read().listen((event) {
      data.addAll(event);
    }).asFuture();
    context[DarwinHttpServer.requestDrainedKey] = true;

    var requestContentType = context.request.mimeType;
    if (contentType != null && requestContentType != contentType) {
      throw RequestException.badRequest();
    }

    // Handle primitive body types
    if (type == List<int>) return data;
    if (type == String) return utf8.decode(data);
    var decoderContentType = requestContentType ?? "text/plain";
    var deserializationContext = DeserializationContext(decoderContentType, MarshalTarget(typeCapture), {}, marshal);
    var mapper = marshal.findDeserializer(deserializationContext);
    if (mapper == null) throw Exception("No mapper found");
    var value = mapper.deserialize(data, deserializationContext);
    return value;
  }

  Future<Response> serializeResponse(FutureOr<dynamic> valueOrFuture, TypeCapture typeCapture,
      String? explicitContentType) async {
    var type = typeCapture.typeArgument;
    if (type == dynamic) {
      type = (const TypeToken<void>()).typeArgument;
      assert((){
        logger.warning("Rewriting 'dynamic' response type to 'void'.");
        return true;
      }());
    }

    var value = await valueOrFuture;
    if (type == Response || (type == dynamic && value is Response)) {
      return value;
    }
    if ((type == List<int>) || (type == dynamic && value is List<int>)) {
      return Response.ok(value, headers: {
        "Content-Type": "application/octet-stream"
      });
    }
    if (value is Stream) value = await value.toList();
    var context =
        SerializationContext(MarshalTarget(typeCapture), explicitContentType, {}, marshal);
    var serializer = marshal.findSerializer(context);
    if (serializer == null) {
      throw Exception("Didn't find matching serializer for ${typeCapture.typeArgument}");
    }
    context.mime ??= serializer.outputMime;
    var data = serializer.serialize(value, context);
    assert((){
      if (serializer.outputMime == null) {
        logger.warning("The converter $serializer for ${typeCapture.typeArgument} "
            "doesn't specify an outputMime type so text/plain will be used. "
            "Consider explicitly defining a content type.");
      }
      return true;
    }());
    return Response.ok(data, headers: {"Content-Type": context.mime ?? "text/plain"});
  }
}
