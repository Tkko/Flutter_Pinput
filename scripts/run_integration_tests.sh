#!/usr/bin/env bash

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
EXAMPLE_DIR="$PROJECT_ROOT/example"
TEST_TARGET="integration_test/app_test.dart"

echo -e "${BLUE}====================================================${NC}"
echo -e "${BLUE}        Pinput - Cross-Platform Integration Tests   ${NC}"
echo -e "${BLUE}====================================================${NC}\n"

cd "$EXAMPLE_DIR"

# 1. macOS Desktop
run_macos() {
  echo -e "${YELLOW}▶ Running integration tests on macOS Desktop...${NC}"
  flutter test "$TEST_TARGET" -d macos
  echo -e "${GREEN}✓ macOS Desktop tests passed!${NC}\n"
}

# 2. iOS Simulator
run_ios() {
  echo -e "${YELLOW}▶ Preparing iOS Simulator...${NC}"
  UDID=$(xcrun simctl list devices available 'iPhone' | grep -m 1 -E 'iPhone [0-9]+' | awk -F '[()]' '{print $2}')
  if [ -z "$UDID" ]; then
    echo -e "${RED}No available iPhone simulator found.${NC}"
    return 1
  fi

  echo "Booting simulator ($UDID)..."
  xcrun simctl boot "$UDID" 2>/dev/null || true
  open -a Simulator 2>/dev/null || true

  echo -e "${YELLOW}▶ Running integration tests on iOS Simulator...${NC}"
  flutter test "$TEST_TARGET" -d "$UDID"
  echo -e "${GREEN}✓ iOS Simulator tests passed!${NC}\n"
}

# 3. Web (Chrome)
run_web() {
  if ! command -v chromedriver &> /dev/null; then
    echo -e "${YELLOW}⚠ chromedriver not found in PATH. Skipping web test.${NC}"
    echo -e "To run on web, install chromedriver: brew install chromedriver\n"
    return 0
  fi

  echo -e "${YELLOW}▶ Starting Chromedriver on port 4444...${NC}"
  chromedriver --port=4444 &
  CHROMEDRIVER_PID=$!
  sleep 1

  cleanup_chromedriver() {
    kill "$CHROMEDRIVER_PID" 2>/dev/null || true
  }
  trap cleanup_chromedriver EXIT

  echo -e "${YELLOW}▶ Running integration tests on Chrome Web...${NC}"
  flutter drive --driver=test_driver/integration_test.dart --target="$TEST_TARGET" -d chrome
  echo -e "${GREEN}✓ Chrome Web tests passed!${NC}\n"

  cleanup_chromedriver
  trap - EXIT
}

# Parse options or run all
TARGET="${1:---all}"

case "$TARGET" in
  --macos)
    run_macos
    ;;
  --ios)
    run_ios
    ;;
  --web)
    run_web
    ;;
  --all)
    run_macos
    if command -v xcrun &> /dev/null; then
      run_ios || true
    fi
    run_web
    ;;
  *)
    echo "Usage: $0 [--all | --macos | --ios | --web]"
    exit 1
    ;;
esac

echo -e "${GREEN}====================================================${NC}"
echo -e "${GREEN}        All integration tests finished successfully!${NC}"
echo -e "${GREEN}====================================================${NC}"
