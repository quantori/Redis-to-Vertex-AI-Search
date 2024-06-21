FROM marketplace.gcr.io/google/debian11 AS build

RUN apt-get update \
    && apt-get install -y --no-install-recommends gettext

ADD redis-to-vertex-ai-search /tmp/chart
RUN cd /tmp \
    && tar -czvf /tmp/redis-to-vertex-ai-search.tar.gz chart
ADD apptest/deployer/redis-to-vertex-ai-search /tmp/test/chart
RUN cd /tmp/test \
    && tar -czvf /tmp/test/redis-to-vertex-ai-search.tar.gz chart/

ADD schema.yaml /tmp/schema.yaml

# Provide registry prefix and tag for default values for images.
# ARG REGISTRY
# ARG TAG
# RUN cat /tmp/schema.yaml \
#     | env -i "REGISTRY=$REGISTRY" "TAG=$TAG" envsubst \
#     > /tmp/schema.yaml.new \
#     && mv /tmp/schema.yaml.new /tmp/schema.yaml

# Provide default value for tester image.
# ARG TESTER_IMAGE
ADD apptest/deployer/schema.yaml /tmp/apptest/schema.yaml
# RUN cat /tmp/apptest/schema.yaml \
#     | env -i "TESTER_IMAGE=$TESTER_IMAGE" envsubst \
#     > /tmp/apptest/schema.yaml.new \
#     && mv /tmp/apptest/schema.yaml.new /tmp/apptest/schema.yaml


FROM gcr.io/cloud-marketplace-tools/k8s/deployer_helm

RUN apt-get update && apt-get upgrade -y
RUN rm -rf /opt/kubectl/*
RUN rm -rf /bin/helm-downloaded/linux-amd64/helm
RUN mkdir -p /opt/kubectl/1.30.2 && wget -q -O /opt/kubectl/1.30.2/kubectl https://storage.googleapis.com/kubernetes-release/release/v1.30.2/bin/linux/amd64/kubectl && chmod 755 /opt/kubectl/1.30.2/kubectl
RUN ln -s /opt/kubectl/1.30.2 /opt/kubectl/default
RUN mkdir -p /bin/helm-downloaded && wget -q -O /bin/helm-downloaded/helm.tar.gz https://get.helm.sh/helm-v3.15.2-linux-amd64.tar.gz && tar -zxvf /bin/helm-downloaded/helm.tar.gz -C /bin/helm-downloaded && mv /bin/helm-downloaded/linux-amd64/helm /bin/ && rm -rf /bin/helm-downloaded

COPY --from=build /tmp/redis-to-vertex-ai-search.tar.gz /data/chart/
COPY --from=build /tmp/test/redis-to-vertex-ai-search.tar.gz /data-test/chart/
COPY apptest/deployer/schema.yaml /data-test/
COPY --from=build /tmp/apptest/schema.yaml /data-test/
COPY --from=build /tmp/schema.yaml /data/