# Publishing the package on pub.dev

cd ../

flutter format --set-exit-if-changed .
if [ $? -ne 0 ]; then
  exit 1
fi

flutter analyze
if [ $? -ne 0 ]; then
  exit 1
fi

flutter test
if [ $? -ne 0 ]; then
  exit 1
fi

flutter pub global activate pana

if flutter packages pub global run pana --exit-code-threshold=0 --no-warning --source path ./; then
  echo "run pana succeeded"
else
  echo "run pana failed"
  exit 1
fi

if flutter packages pub publish --dry-run; then
  echo "pub publish succeeded"
else
  echo "pub publish failed"
  exit 1
fi

flutter packages pub publish
