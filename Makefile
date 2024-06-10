TAG ?= latest

# Convenience makefiles.
include ../gcloud.Makefile
include ../var.Makefile

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/example/redis-to-vertex-ai-search/deployer:$(TAG)
NAME ?= redis-to-vertex-ai-search-1
APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)", \
  "imageredis-to-vertex-ai-search.image": "$(REGISTRY)/example/redis-to-vertex-ai-search:$(TAG)" \
}
TESTER_IMAGE ?= $(REGISTRY)/example/redis-to-vertex-ai-search/tester:$(TAG)


# app.Makefile provides the main targets for installing the
# application.
# It requires several APP_* variables defined above, and thus
# must be included after.
include ../app.Makefile


# Extend the target as defined in app.Makefile to
# include real dependencies.
app/build:: .build/redis-to-vertex-ai-search/deployer \
            .build/redis-to-vertex-ai-search/redis-to-vertex-ai-search \
            .build/redis-to-vertex-ai-search/tester


.build/redis-to-vertex-ai-search: | .build
	mkdir -p "$@"

.build/redis-to-vertex-ai-search/deployer: apptest/deployer/* \
                       apptest/deployer/redis-to-vertex-ai-search/* \
                       apptest/deployer/redis-to-vertex-ai-search/templates/* \
                       deployer/* \
                       redis-to-vertex-ai-search/* \
                       redis-to-vertex-ai-search/templates/* \
                       schema.yaml \
                       .build/var/APP_DEPLOYER_IMAGE \
                       .build/var/MARKETPLACE_TOOLS_TAG \
                       .build/var/REGISTRY \
                       .build/var/TAG \
                       .build/var/TESTER_IMAGE \
                       | .build/redis-to-vertex-ai-search
	$(call print_target, $@)
	docker build \
	    --build-arg REGISTRY="$(REGISTRY)" \
	    --build-arg TAG="$(TAG)" \
	    --build-arg TESTER_IMAGE="$(TESTER_IMAGE)" \
	    --tag "$(APP_DEPLOYER_IMAGE)" \
	    -f deployer/Dockerfile \
	    .
	docker push "$(APP_DEPLOYER_IMAGE)"
	@touch "$@"


.build/redis-to-vertex-ai-search/tester: .build/var/TESTER_IMAGE \
                     | .build/redis-to-vertex-ai-search
	$(call print_target, $@)
	docker pull cosmintitei/bash-curl
	docker tag cosmintitei/bash-curl "$(TESTER_IMAGE)"
	docker push "$(TESTER_IMAGE)"
	@touch "$@"


# Simulate building of primary app image. Actually just copying public image to
# local registry.
.build/redis-to-vertex-ai-search/redis-to-vertex-ai-search: .build/var/REGISTRY \
                    .build/var/TAG \
                    | .build/redis-to-vertex-ai-search
	$(call print_target, $@)
	docker pull launcher.gcr.io/google/redis-to-vertex-ai-search1
	docker tag launcher.gcr.io/google/redis-to-vertex-ai-search1 "$(REGISTRY)/example/redis-to-vertex-ai-search:$(TAG)"
	docker push "$(REGISTRY)/example/redis-to-vertex-ai-search:$(TAG)"
	@touch "$@"
