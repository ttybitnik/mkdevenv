# MKDEVENV 0.1.0 (x-release-please-version)
# See <https://github.com/ttybitnik/mkdevenv> for more information.

OMNI_NAME = changeme
CONTAINER_ENGINE = changeme

__USER = $(or $(USER),$(shell whoami))
__AFFIX = omni-$(OMNI_NAME)

# Host targets/commands
.PHONY: devenv start stop clean serestore

devenv:
	$(info Building development container image...)

	$(CONTAINER_ENGINE) build \
	--build-arg USERNAME=$(__USER) \
	-f .mkdevenv/Containerfile \
	-t localhost/mkdevenv/$(__AFFIX) \
	.

start:
	$(info Starting development container...)

	$(CONTAINER_ENGINE) run -it -d --replace \
	$(if $(filter podman,$(CONTAINER_ENGINE)),--userns=keep-id) \
	--name mkdevenv-$(__AFFIX) \
	--volume .:/home/$(__USER)/workspace:Z \
	--volume mkdevenv-$(__AFFIX)-cache:/home/$(__USER)/.local \
	localhost/mkdevenv/$(__AFFIX):latest

	@# $(CONTAINER_ENGINE) compose .mkdevenv/compose.yaml up -d

stop:
	$(info Stopping development container...)

	$(CONTAINER_ENGINE) stop mkdevenv-$(__AFFIX)

	@# $(CONTAINER_ENGINE) compose .mkdevenv/compose.yaml down

clean: distclean
	$(info Removing development container and image...)

	-$(CONTAINER_ENGINE) rm mkdevenv-$(__AFFIX)
	-$(CONTAINER_ENGINE) image rm localhost/mkdevenv/$(__AFFIX)
	-$(CONTAINER_ENGINE) volume rm mkdevenv-$(__AFFIX)-cache

	@# $(CONTAINER_ENGINE) image prune

serestore:
	$(info Restoring project SELinux context and permissions...)

	chcon -Rv unconfined_u:object_r:user_home_t:s0 .
	# find . -type d -exec chmod 700 {} \;
	# find . -type f -exec chmod 600 {} \;

# Container targets/commands
.PHONY: lint test build run deploy debug distclean

lint:
	$(info Running linters...)

test: lint
	$(info Running tests...)

build: test
	$(info Building...)

run: build
	$(info Running...)

deploy: build
	$(info Deploying...)

debug: test
	$(info Debugging tasks...)

distclean:
	$(info Cleaning artifacts...)
