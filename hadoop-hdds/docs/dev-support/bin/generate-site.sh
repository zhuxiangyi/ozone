#!/usr/bin/env bash
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -eu

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOCDIR="$DIR/../.."

if [ ! "$(which hugo)" ]; then
   echo "Hugo is not yet installed. Doc generation is skipped."
   exit 0
fi

export OZONE_VERSION=$(mvn help:evaluate -Dexpression=ozone.version -q -DforceStdout)

ENABLE_GIT_INFO=
if git -C $(pwd) status >& /dev/null; then
  ENABLE_GIT_INFO="--enableGitInfo"
fi

# Copy docs files to a temporary directory inside target
# for pre-processing the markdown files.
TMPDIR="$DOCDIR/target/tmp"
mkdir -p "$TMPDIR"
rsync -a --exclude="target" --exclude="public" "$DOCDIR/" "$TMPDIR"

# Replace all markdown images with a hugo shortcode to make them responsive.
python3 $DIR/make_images_responsive.py $TMPDIR

DESTDIR="$DOCDIR/target/classes/docs"
mkdir -p "$DESTDIR"
# We want to build the processed files inside the $DOCDIR/target/tmp
cd "$TMPDIR"
hugo "${ENABLE_GIT_INFO}" -d "$DESTDIR" "$@"
cd -
