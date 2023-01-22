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

import 'dart:async';
import 'dart:io';

Future<void> runCmd(String cmd, List<String> args, {bool printExitCode = false, bool printOut = false, String? workingDirectory}) async {
  var process = await Process.start(cmd, args, workingDirectory: workingDirectory);
  StreamSubscription? s1;
  StreamSubscription? s2;
  if (printOut) s1 = process.stdout.listen(stdout.add);
  s2 = process.stderr.listen(stderr.add);
  var exc = await process.exitCode;
  if (printOut) await s1!.cancel();
  await s2.cancel();
  if (exc != 0) throw Exception('Process error: $exc');
  /*
  if (printExitCode) TextPen()..setColor(Color.YELLOW)..text("Process '$cmd ${args.join(" ")}' exited with error code $exc\n").print();
   */
}

Future<void> runWrappedCmd(String cmd, List<String> args) async {
  var process = await Process.start(cmd, args, includeParentEnvironment: true);
  var s1 = process.stdout.listen(stdout.add);
  var s2 = process.stderr.listen(stderr.add);
  var s3 = stdin.listen(process.stdin.add);
  var exc = await process.exitCode;
  await s1.cancel();
  await s2.cancel();
  await s3.cancel();
  if (exc != 0) throw Exception('Process error: $exc');
  /*
  TextPen()
    ..setColor(Color.YELLOW)
    ..text("Process '$cmd ${args.join(" ")}' exited with error code $exc\n")
        .print();

   */
}