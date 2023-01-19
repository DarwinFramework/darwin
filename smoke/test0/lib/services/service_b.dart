import 'dart:async';

import 'package:darwin_injector/darwin_injector.dart' as darwin;
import 'package:darwin_sdk/darwin_sdk.dart' as darwin;
import 'package:logging/logging.dart';

@darwin.Service()
@darwin.AlwaysCondition()
class ServiceB extends darwin.ServiceBase {

  static final Logger _logger = Logger("Service B");

  @override
  void start(darwin.DarwinSystem system) {
    _logger.info("Started B!");
  }

  @override
  void stop(darwin.DarwinSystem system) {
    _logger.info("Stopped B!");
  }

  @darwin.Start()
  void enable() {
    _logger.info("Started late B!");
  }

  @darwin.Stop()
  void disable() {
    _logger.info("Stopped pre B!");
  }

  @darwin.Bean()
  @darwin.AlwaysCondition()
  String helloBean() => "Hello World!";

  @darwin.Bean()
  int age = 19;

}