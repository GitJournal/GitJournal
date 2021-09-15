keys:
	mkdir -p /tmp/codegen
	yq -o=json eval assets/langs/en.yaml -P > /tmp/codegen/en.json
	./flutterw pub run easy_localization:generate -S /tmp/codegen -f keys -o locale_keys.g.dart
	./flutterw format lib/generated
	./flutterw pub run import_sorter:main lib/generated/*

protos:
	protoc --dart_out=grpc:lib/analytics/generated -Ilib/analytics/ lib/analytics/analytics.proto
	protoc --dart_out=grpc:lib/generated -Iprotos protos/shared_preferences.proto
	./flutterw format lib/generated
	./flutterw pub run import_sorter:main lib/generated/*

unused:
	./flutterw pub run dart_code_metrics:metrics check-unused-files lib

fmt:
	./flutterw pub run import_sorter:main

lint:
	./flutterw pub run dart_code_metrics:metrics lib

build_env:
	./flutterw scripts/setup_env.dart gen

build_runner:
	./flutterw packages pub run build_runner build --delete-conflicting-outputs

test:
	./flutterw test

# https://stackoverflow.com/a/26339924/147435
.PHONY: list test
list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'
help: list
