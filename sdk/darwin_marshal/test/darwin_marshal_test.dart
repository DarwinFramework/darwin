import 'package:darwin_marshal/darwin_marshal.dart';
import 'package:test/test.dart';

void main() {
  group('Marshal Json', () {
    var marshal = DarwinMarshal();
    DarwinMarshalJson.register(marshal, strictMime: true);

    group("Lists", () {
      test("String List", () {
        var dataIn = ["A", "B", "C", "D"];
        var contextIn = SerializationContext(List<String>, "application/json", {}, marshal);
        var data = marshal.findSerializer(contextIn)!.serialize(dataIn, contextIn);
        var contextOut = DeserializationContext("application/json", List<String>, {}, marshal);
        var dataOut = marshal.findDeserializer(contextOut)!.deserialize(data, contextOut);
        expect(dataIn, dataOut);
      });

      test("Dynamic List", () {
        var dataIn = ["A", "B", "C", "D"];
        var contextIn = SerializationContext(List, "application/json", {}, marshal);
        var data = marshal.findSerializer(contextIn)!.serialize(dataIn, contextIn);
        var contextOut = DeserializationContext("application/json", List, {}, marshal);
        var dataOut = marshal.findDeserializer(contextOut)!.deserialize(data, contextOut);
        expect(dataIn, dataOut);
      });
    });

    group("Map", () {
      test("Basic", () {
        var dataIn = {"abc":123,"b":false};
        var contextIn = SerializationContext(Map<String,dynamic>, "application/json", {}, marshal);
        var data = marshal.findSerializer(contextIn)!.serialize(dataIn, contextIn);
        var contextOut = DeserializationContext("application/json", Map<String,dynamic>, {}, marshal);
        var dataOut = marshal.findDeserializer(contextOut)!.deserialize(data, contextOut);
      });
    });
  });
}
