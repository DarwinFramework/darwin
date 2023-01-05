import 'package:darwin_marshal/darwin_marshal.dart';
import 'package:darwin_marshal/src/adapters.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

class TestType {
  String name;
  int age;

  static Map<String, dynamic> toMap(TestType obj) {
    return {
      'name': obj.name,
      'age': obj.age,
    };
  }

  factory TestType.fromMap(Map<String, dynamic> map) {
    return TestType(
      name: map['name'] as String,
      age: map['age'] as int,
    );
  }

  TestType({
    required this.name,
    required this.age,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TestType &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          age == other.age;

  @override
  int get hashCode => name.hashCode ^ age.hashCode;
}

void main() {
  group("Adapter Tests", () {
    var marshal = DarwinMarshal();
    DarwinMarshalJson.register(marshal);

    var adapter = JsonMapAdapter(toMap: TestType.toMap, fromMap: TestType.fromMap);
    marshal.registerTypeMapperWithCollections<TestType>(adapter);

    test("Simple Map", () {
      var dataIn = TestType(name: "Christoph", age: 19);
      var contextIn = SerializationContext(TestType, "application/json", {}, marshal);
      var data = marshal.findSerializer(contextIn)!.serialize(dataIn, contextIn);
      var contextOut = DeserializationContext("application/json", TestType, {}, marshal);
      var dataOut = marshal.findDeserializer(contextOut)!.deserialize(data, contextOut);
      expect(dataOut, dataIn);
    });
    test("Simple List", () {
      var dataIn = [TestType(name: "Christoph", age: 19), TestType(name: "Alex", age: 20)];
      var contextIn = SerializationContext(List<TestType>, "application/json", {}, marshal);
      var data = marshal.findSerializer(contextIn)!.serialize(dataIn, contextIn);
      var contextOut = DeserializationContext("application/json", List<TestType>, {}, marshal);
      var dataOut = marshal.findDeserializer(contextOut)!.deserialize(data, contextOut);
      expect(dataOut, dataIn);
    });
    test("Simple Set", () {
      var dataIn = {TestType(name: "Christoph", age: 19), TestType(name: "Alex", age: 20)};
      var contextIn = SerializationContext(Set<TestType>, "application/json", {}, marshal);
      var data = marshal.findSerializer(contextIn)!.serialize(dataIn, contextIn);
      var contextOut = DeserializationContext("application/json", Set<TestType>, {}, marshal);
      var dataOut = marshal.findDeserializer(contextOut)!.deserialize(data, contextOut);
      expect(dataOut, dataIn);
    });
    test("Simple Iterable", () {
      var dataIn = {TestType(name: "Christoph", age: 19), TestType(name: "Alex", age: 20)};
      var contextIn = SerializationContext(Iterable<TestType>, "application/json", {}, marshal);
      var data = marshal.findSerializer(contextIn)!.serialize(dataIn, contextIn);
      var contextOut = DeserializationContext("application/json", Iterable<TestType>, {}, marshal);
      var dataOut = marshal.findDeserializer(contextOut)!.deserialize(data, contextOut);
      expect(dataOut, dataIn);
    });
    test("Simple Mixed Types", () {
      var dataIn = {TestType(name: "Christoph", age: 19), TestType(name: "Alex", age: 20)};
      var contextIn = SerializationContext(Set<TestType>, "application/json", {}, marshal);
      var data = marshal.findSerializer(contextIn)!.serialize(dataIn, contextIn);
      var contextOut = DeserializationContext("application/json", List<TestType>, {}, marshal);
      var dataOut = marshal.findDeserializer(contextOut)!.deserialize(data, contextOut);
      expect(dataOut.toList(), dataIn.toList());
    });
  });
}