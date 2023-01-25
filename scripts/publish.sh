# Publishing the package on pub.dev
function fail {
  printf '%s\n' "$1" >&2
  exit "${2-1}"
}

function run_dart_doc {
  flutter pub global activate dartdoc
  export FLUTTER_ROOT=~/fvm/default
  dart doc . || fail "dart doc failed"
}

function host_docs {
  dhttpd --path doc/api
}

function run_pana {
  flutter pub global activate pana
  flutter packages pub global run pana --exit-code-threshold=0 --no-warning --source path ./ || fail "run pana failed"
}

function publish {
  flutter packages pub publish || fail "pub publish failed"
}

function format_and_analyze {
  dart format .
  flutter analyze || fail "flutter analyze failed"
  flutter test || fail "flutter test failed"
}

cd ../
format_and_analyze
run_dart_doc
run_pana
publish
host_docs
