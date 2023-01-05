import 'package:darwin_eventbus/darwin_eventbus.dart';
import 'package:darwin_injector/darwin_injector.dart';
import 'package:darwin_sdk/darwin_sdk.dart';
import 'package:logging/logging.dart';

import 'service_b.dart';

@Service(ServiceA)
class ServiceAImpl extends ServiceA {

  static final Logger _logger = Logger("Service A");

  ServiceB b;
  String myBean;

  ServiceAImpl(this.b, @Named("helloBean") this.myBean);

  @Start()
  void start() {
    _logger.info("Started A!");
    _logger.config("Bean has value: $myBean");
  }

  @Stop()
  void stop() {
    _logger.info("Stopped A!");
  }

  @Subscribe()
  @AlwaysCondition()
  void onStartup(LateStartupEvent event) {
    _logger.info("Received Startup Event!");
  }
}

abstract class ServiceA {}