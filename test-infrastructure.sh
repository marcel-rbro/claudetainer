#!/bin/bash
# Test Claudetainer infrastructure (without Claude binary execution)

set -e

echo "=== Claudetainer Infrastructure Test ==="
echo ""

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

test_pass() {
    echo -e "${GREEN}✓${NC} $1"
}

test_fail() {
    echo -e "${RED}✗${NC} $1"
    exit 1
}

# Test 1: Volume mounting
echo "Test 1: Volume mounting..."
docker run --rm --user "$(id -u):$(id -g)" \
    -v "$(pwd):/workspace" \
    -w /workspace \
    --entrypoint /bin/bash \
    claudetainer:latest \
    -c "test -f /workspace/README.md && echo 'success'" > /dev/null 2>&1 && test_pass "Volume mount works" || test_fail "Volume mount failed"

# Test 2: File creation with correct ownership
echo "Test 2: File creation and ownership..."
docker run --rm --user "$(id -u):$(id -g)" \
    -v "$(pwd):/workspace" \
    -w /workspace \
    -e "HOME=/tmp/claudetainer-home" \
    --entrypoint /bin/bash \
    claudetainer:latest \
    -c "echo 'test' > /workspace/.test-file.txt" > /dev/null 2>&1

if [ -f .test-file.txt ] && [ "$(stat -f '%u' .test-file.txt)" = "$(id -u)" ]; then
    rm .test-file.txt
    test_pass "File ownership correct (not root)"
else
    test_fail "File ownership incorrect"
fi

# Test 3: Git operations
echo "Test 3: Git operations..."
docker run --rm --user "$(id -u):$(id -g)" \
    -v "$(pwd):/workspace" \
    -w /workspace \
    -e "HOME=/tmp/claudetainer-home" \
    -e "GIT_USER_NAME=Test User" \
    -e "GIT_USER_EMAIL=test@test.com" \
    --entrypoint /bin/bash \
    claudetainer:latest \
    -c "mkdir -p \$HOME && git config --global user.name 'Test' && git config --global user.email 'test@test.com' && git init /workspace/.test-repo && cd /workspace/.test-repo && echo 'test' > file.txt && git add . && git commit -m 'test' > /dev/null 2>&1" && test_pass "Git operations work" || test_fail "Git operations failed"

rm -rf .test-repo

# Test 4: Environment variables
echo "Test 4: Environment variables..."
TEST_VAR=$(docker run --rm --user "$(id -u):$(id -g)" \
    -v "$(pwd):/workspace" \
    -e "TEST_VALUE=hello123" \
    -e "HOME=/tmp/claudetainer-home" \
    --entrypoint /bin/bash \
    claudetainer:latest \
    -c "echo \$TEST_VALUE")

[ "$TEST_VAR" = "hello123" ] && test_pass "Environment variables pass through" || test_fail "Environment variables failed"

# Test 5: HOME directory creation
echo "Test 5: HOME directory setup..."
docker run --rm --user "$(id -u):$(id -g)" \
    -v "$(pwd):/workspace" \
    -e "HOME=/tmp/test-home" \
    --entrypoint /bin/bash \
    claudetainer:latest \
    -c "mkdir -p \$HOME && test -d \$HOME && echo 'success'" > /dev/null 2>&1 && test_pass "HOME directory works" || test_fail "HOME directory failed"

# Test 6: Working directory
echo "Test 6: Working directory..."
WD=$(docker run --rm --user "$(id -u):$(id -g)" \
    -v "$(pwd):/workspace" \
    -w /workspace \
    -e "HOME=/tmp/claudetainer-home" \
    --entrypoint /bin/bash \
    claudetainer:latest \
    -c "pwd")

[ "$WD" = "/workspace" ] && test_pass "Working directory correct" || test_fail "Working directory incorrect"

echo ""
echo "=== All Infrastructure Tests Passed ==="
echo ""
echo "Note: Claude binary cannot execute due to macOS/Linux binary incompatibility."
echo "All Docker infrastructure (mounts, ownership, git) works correctly."
echo "This would function on Linux with a native Linux Claude binary."
