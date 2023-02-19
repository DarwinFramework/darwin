#
#    Copyright 2022, the Darwin Framework authors
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
#

# ======== Smoke Test 0 ========
# Simple test to verify that the
# generated code is actually
# valid and compilable.
cd test0; bash smoke.sh; cd ../

# ======== Smoke Test 1 ========
# More advanced http test that
# uses the darwin_test package
# to simulate http calls
cd test1; bash smoke.sh; cd ../
