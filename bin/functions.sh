describe() {
  echo "--- $1…"
}

package_stacks() {
  describe "Packaging stacks"
  docker buildx build \
    --tag flowerworkio/base:focal \
    --target base \
    --platform=linux/amd64,linux/arm64 \
    ./stacks/focal
  docker buildx build \
    --tag flowerworkio/run:focal \
    --target run \
    --platform=linux/amd64,linux/arm64 \
    ./stacks/focal
  docker buildx build \
    --tag flowerworkio/build:focal \
    --target build \
    --platform=linux/amd64,linux/arm64 \
    ./stacks/focal
}

publish_stacks(){
  describe "Publishing stacks"
  docker buildx build \
    --tag flowerworkio/base:focal \
    --target base \
    --platform=linux/amd64,linux/arm64 \
    --push \
    ./stacks/focal
  docker buildx build \
    --tag flowerworkio/run:focal \
    --target run \
    --platform=linux/amd64,linux/arm64 \
    --push \
    ./stacks/focal
  docker buildx build \
    --tag flowerworkio/build:focal \
    --target build \
    --platform=linux/amd64,linux/arm64 \
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
  docker push flowerworkio/asdf:$flowerworkio_asdf_version
  docker push flowerworkio/phoenix:$flowerworkio_phoenix_version
}
