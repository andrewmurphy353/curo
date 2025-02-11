# The available make terminal commands are:
#   make deploy-dry-run
# 	make deploy-pub-dev			(https://pub.dev/)

deploy-dry-run: build-setup
	dart format .
	dart test
	dart pub publish --dry-run
	@echo "Build and deploy dry-run complete."

deploy-pub-dev: build-setup
	dart format .
	dart test
	dart pub publish
	@echo "Build and deploy complete."

build-setup:
	@echo "----------------------------------------------------------------"
	@echo "Has the application version number been updated in pubspec.yaml?"
	@echo "----------------------------------------------------------------"
	@echo "1 - Yes"
	@echo "2 - No"
	@read -p "" response; \
	if [ "$$response" != "1" ]; then \
		echo "Build and deploy aborted."; \
		exit 1; \
	else \
		echo "Build and deploy started."; \
	fi