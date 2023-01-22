import 'dart:io';

import 'package:archive/archive.dart';
import 'package:darwin_starter/darwin_starter.dart';

void main() async {
  var archive = await DarwinStarter.initialize(name: "wonderland", dependencies: ["dogs"], type: ProjectType.rest);
  var zipEncoder = ZipEncoder();
  File("out.zip").writeAsBytesSync(zipEncoder.encode(archive)!);
}
