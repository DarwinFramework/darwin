import 'package:darwin_eventbus/darwin_eventbus.dart';
import 'package:test/test.dart';

void main() {
  group('Sync', () {
    test('Priority', () {
      var bus = EventBus();
      var line = bus.getLine<TestEvent>();
      line.subscribe((p0) => p0.value = 5, priority: 1);
      line.subscribe((p0) => p0.value = 10, priority: 0);
      line.subscribe((p0) => p0.value = 15, priority: 0);
      var event = TestEvent();
      line.dispatch(event);
      expect(event.value, 5);
    });
  });

  group('Async', () {
    test('Priority', () {
      var bus = EventBus();
      var line = bus.getLine<TestEvent>();
      line.subscribe((p0) => p0.value = 5, priority: 1);
      line.subscribe((p0) async {
        await Future.delayed(Duration(milliseconds: 100));
        p0.value = 10;
      });
      line.subscribe((p0) => p0.value = 15);
      var event = TestEvent();
      line.dispatch(event);
      expect(event.value, 5);
    });
  });
}

class TestEvent {
  int value = 0;
}
