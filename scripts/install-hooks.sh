#!/usr/bin/env bash
#
#  scripts/install-hooks.sh
#  Requests
#
#  Copyright 2026 Peter Entwistle
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
#  Installs the shared SwiftLint pre-commit hook and ensures swiftlint is
#  available. Run this once after cloning the repository:
#
#      ./scripts/install-hooks.sh
#
#  It points git at the tracked `.githooks/` directory so every clone shares the
#  same hook, and installs swiftlint via Homebrew if it is missing.
#  To disable:  git config --unset core.hooksPath
#

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT}"

# Use the tracked hook directory so the hook is shared across clones.
git config core.hooksPath .githooks
echo "==> Set core.hooksPath -> .githooks"

# Ensure the swiftlint binary is present so the hook can actually run.
if ! command -v swiftlint >/dev/null 2>&1; then
    echo "==> swiftlint not found. Trying to install via Homebrew…"
    if command -v brew >/dev/null 2>&1; then
        brew install swiftlint
    else
        echo "==> Homebrew not found on PATH. Install SwiftLint manually, e.g.:"
        echo "      brew install swiftlint   (https://github.com/realm/SwiftLint)"
        exit 1
    fi
fi

echo "==> Done. The SwiftLint pre-commit hook is now active (.githooks/pre-commit)."
