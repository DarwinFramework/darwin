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

import 'package:darwin_eventbus/darwin_eventbus.dart';

class EventBus {

  final Map<Type, SyncEventLine> _syncLines = {};
  final Map<Type, AsyncEventLine> _asyncLines = {};

  /// Gets or creates a [SyncEventLine] for the type [T].
  SyncEventLine<T> getLine<T>() {
    var line = _syncLines[T];
    if (line != null) return line as SyncEventLine<T>;
    var newLine = SyncEventLine<T>();
    _syncLines[T] = newLine;
    return newLine;
  }

  /// Gets or creates a [AsyncEventLine] for the type [T].
  AsyncEventLine<T> getAsyncLine<T>(){
    var line = _asyncLines[T];
    if (line != null) return line as AsyncEventLine<T>;
    var newLine = AsyncEventLine<T>();
    _asyncLines[T] = newLine;
    return newLine;
  }

}