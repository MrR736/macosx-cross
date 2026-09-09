#!/usr/bin/env bash

set -u

MACOSX_CROSS="${MACOSX_CROSS:-macosx-cross}"

PASSED=0
FAILED=0

pass()
{
    printf 'PASS  %s\n' "$1"
    PASSED=$((PASSED + 1))
}

fail()
{
    printf 'FAIL  %s\n' "$1"
    FAILED=$((FAILED + 1))
}

assert_success()
{
    local NAME="$1"
    shift

    if "$@" >/dev/null 2>&1; then
        pass "$NAME"
    else
        fail "$NAME"
    fi
}

assert_output()
{
    local NAME="$1"
    local EXPECTED="$2"
    shift 2

    local OUTPUT
    OUTPUT="$("$@" 2>&1)"

    if grep -Fq "$EXPECTED" <<< "$OUTPUT"; then
        pass "$NAME"
    else
        fail "$NAME"
        printf '      expected: %s\n' "$EXPECTED"
        printf '      output:\n%s\n' "$OUTPUT"
    fi
}


echo "macosx-cross tests"
printf '%s\n' "────────────────────────────────────────────"


#
# Command exists
#

if command -v "$MACOSX_CROSS" >/dev/null 2>&1; then
    pass "macosx-cross command exists"
else
    fail "macosx-cross command exists"
    exit 1
fi


#
# Version
#

assert_success \
    "version" \
    "$MACOSX_CROSS" --version


#
# Help
#

assert_success \
    "help" \
    "$MACOSX_CROSS" --help

assert_output \
    "help contains install" \
    "install" \
    "$MACOSX_CROSS" --help

assert_output \
    "help contains remove" \
    "remove" \
    "$MACOSX_CROSS" --help

assert_output \
    "help contains list" \
    "list" \
    "$MACOSX_CROSS" --help

assert_output \
    "help contains clean" \
    "clean" \
    "$MACOSX_CROSS" --help


#
# SDK list
#

assert_success \
    "list" \
    "$MACOSX_CROSS" list

assert_output \
    "list contains SDK 14.5" \
    "14.5" \
    "$MACOSX_CROSS" list

assert_output \
    "list contains Darwin 23.5.0" \
    "23.5.0" \
    "$MACOSX_CROSS" list


#
# Invalid SDK
#

if "$MACOSX_CROSS" install 999.999 >/dev/null 2>&1; then
    fail "invalid SDK rejected"
else
    pass "invalid SDK rejected"
fi


#
# Invalid command
#

if "$MACOSX_CROSS" invalid-command >/dev/null 2>&1; then
    fail "invalid command rejected"
else
    pass "invalid command rejected"
fi


#
# Summary
#

echo
printf '%s\n' "────────────────────────────────────────────"
printf 'Passed: %d\n' "$PASSED"
printf 'Failed: %d\n' "$FAILED"

if (( FAILED != 0 )); then
    echo "Tests failed."
    exit 1
fi

echo "All tests passed."
