// ignore_for_file: library_private_types_in_public_api

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

part of '../parameters.dart';

class Context extends HandlerAnnotation implements HttpParameterFactory<_ContextEntry> {
  final String? key;
  const Context([this.key]);

  @override
  createParameter(_ContextEntry cached, RequestContext context) {
    return context[cached.key];
  }

  @override
  _ContextEntry createCacheEntry(HttpHandlerVisitorArgs args) {
    var finalKey = key ?? args.parameter!.name;
    return _ContextEntry(finalKey);
  }
}

class _ContextEntry {
  final String key;
  _ContextEntry(this.key);
}