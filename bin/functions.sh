describe() {
  echo "--- $1…"
}

package_stacks() {
  local rfc3339_release_date="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  local stack_version="$(cat ./STACK_VERSION | xargs)"
  describe "Packaging stack version=$stack_version release_date=$rfc3339_release_date"
  docker buildx build \
    --tag flowerworkio/base:focal \
    --tag flowerworkio/base:$stack_version \
    --label io.buildpacks.stack.version=$stack_version \
    --label io.buildpacks.stack.released=$rfc3339_release_date \
    --platform=linux/amd64,linux/arm64 \
    --target base \
    ./stacks/focal
  docker buildx build \
    --tag flowerworkio/run:focal \
    --tag flowerworkio/run:$stack_version \
    --label io.buildpacks.stack.version=$stack_version \
    --label io.buildpacks.stack.released=$rfc3339_release_date \
    --platform=linux/amd64,linux/arm64 \
    --target run \
    ./stacks/focal
  docker buildx build \
    --tag flowerworkio/build:focal \
    --tag flowerworkio/build:$stack_version \
    --label io.buildpacks.stack.version=$stack_version \
    --label io.buildpacks.stack.released=$rfc3339_release_date \
    --platform=linux/amd64,linux/arm64 \
    --target build \
    ./stacks/focal
}

publish_stacks(){
  describe "Publishing stacks"
  local rfc3339_release_date="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  local stack_version="$(cat ./STACK_VERSION | xargs)"
  docker buildx build \
    --tag flowerworkio/base:focal \
    --tag flowerworkio/base:$stack_version \
    --label io.buildpacks.stack.version=$stack_version \
    --label io.buildpacks.stack.released=$rfc3339_release_date \
    --platform=linux/amd64,linux/arm64 \
    --target base \
    --push \
    ./stacks/focal
  docker buildx build \
    --tag flowerworkio/run:focal \
    --tag flowerworkio/run:$stack_version \
    --label io.buildpacks.stack.version=$stack_version \
    --label io.buildpacks.stack.released=$rfc3339_release_date \
    --platform=linux/amd64,linux/arm64 \
    --target run \
    --push \
    ./stacks/focal
  docker buildx build \
    --tag flowerworkio/build:focal \
    --tag flowerworkio/build:$stack_version \
    --label io.buildpacks.stack.version=$stack_version \
    --label io.buildpacks.stack.released=$rfc3339_release_date \
    --platform=linux/amd64,linux/arm64 \
    --target build \
    --push \
    ./stacks/focal
}

package_builder(){
  describe "Packaging builder"
  pack builder create flowerworkio/builder:focal --config ./builder.toml
}

publish_builder(){
  describe "Publishing builder"
  docker push flowerworkio/builder:focal
}

package_buildpacks(){
  describe "Packaging buildpacks"
  local flowerworkio_asdf_version=$(cat asdf/buildpack.toml | yj -tj | jq -r '.buildpack.version')
  local flowerworkio_phoenix_version=$(cat phoenix/buildpack.toml | yj -tj | jq -r '.buildpack.version')
  pack buildpack package flowerworkio/asdf:$flowerworkio_asdf_version --config asdf/package.toml
  pack buildpack package flowerworkio/phoenix:$flowerworkio_phoenix_version --config phoenix/package.toml
}

publish_buildpacks(){
  describe "Publishing buildpacks"
  local flowerworkio_asdf_version=$(cat asdf/buildpack.toml | yj -tj | jq -r '.buildpack.version')
  local flowerworkio_phoenix_version=$(cat phoenix/buildpack.toml | yj -tj | jq -r '.buildpack.version')
  pack buildpack package flowerworkio/asdf:$flowerworkio_asdf_version --config asdf/package.toml --publish
  pack buildpack package flowerworkio/phoenix:$flowerworkio_phoenix_version --config phoenix/package.toml --publish
  docker push flowerworkio/asdf:$flowerworkio_asdf_version
  docker push flowerworkio/phoenix:$flowerworkio_phoenix_version
}
