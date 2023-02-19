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

class DIParameterFactory extends HttpParameterFactory<_DiParameterEntry> {
  @override
  createCacheEntry(HttpHandlerVisitorArgs args) {
    return _DiParameterEntry(args.parameter!.typeArgument);
  }

  @override
  createParameter(_DiParameterEntry cached, RequestContext context) {
    return context.injector.get(cached.type);
  }
}

class _DiParameterEntry {
  final Type type;
  _DiParameterEntry(this.type);
}