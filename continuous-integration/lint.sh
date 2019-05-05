#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT_DIR=$(realpath "$SCRIPT_DIR/..")

pythonFiles=$(find "$ROOT_DIR" -name '*.py')
bashFiles=$(find "$ROOT_DIR" -name '*.sh')

echo Running pylint on:
echo "$pythonFiles"
pylint --rcfile "$ROOT_DIR/.pylintrc" "$pythonFiles" || exit $?

echo Running flake8 on:
echo "$pythonFiles"
flake8 --config="$ROOT_DIR/.flake8" "$pythonFiles" || exit $?

echo Running black on:
echo "$pythonFiles"
black --check --diff "$pythonFiles" || exit $?

echo Running shellcheck on:
echo "$bashFiles"
shellcheck -e SC1090,SC2086,SC2046 $bashFiles || exit $?

echo Success! ["$0"]
