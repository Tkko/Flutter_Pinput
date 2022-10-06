# Publishing the package on pub.dev
function fail {
  printf '%s\n' "$1" >&2
  exit "${2-1}"
}

cd ../
flutter format .
flutter analyze || fail "flutter analyze failed"
flutter test || fail "flutter test failed"
flutter pub global activate dartdoc
export FLUTTER_ROOT=~/fvm/default
dart doc . || fail "dart doc failed"
flutter pub global activate pana
flutter packages pub global run pana --exit-code-threshold=0 --no-warning --source path ./ || fail "run pana failed"
flutter packages pub publish --dry-run || fail "pub publish failed"
flutter packages pub publish

# run docs in the browser
# dhttpd --path doc/api
