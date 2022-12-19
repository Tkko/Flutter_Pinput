# Publishing the package on pub.dev
function fail {
  printf '%s\n' "$1" >&2
  exit "${2-1}"
}

function run_dart_doc {
  flutter pub global activate dartdoc
  export FLUTTER_ROOT=~/fvm/default
  dart doc . || fail "dart doc failed"

  run_docs_in_browser=$1
  if $run_docs_in_browser; then
    dhttpd --path doc/api
  fi
}

function run_pana {
  flutter pub global activate pana
  flutter packages pub global run pana --exit-code-threshold=0 --no-warning --source path ./ || fail "run pana failed"
}

function publish {
  flutter packages pub publish --dry-run || fail "pub publish failed"
  flutter packages pub publish || fail "pub publish failed"
}

function format_and_analyze {
  flutter format .
  flutter analyze || fail "flutter analyze failed"
  flutter test || fail "flutter test failed"
}

cd ../
format_and_analyze
run_dart_doc false
run_pana
publish
