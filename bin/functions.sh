describe() {
  echo "--- $1…"
}

package_stacks() {
  describe "Packaging stacks"
  docker build ./stacks/focal -t flowerworkio/base:focal --target base
  docker build ./stacks/focal -t flowerworkio/run:focal --target run
  docker build ./stacks/focal -t flowerworkio/build:focal --target build
}

publish_stacks(){
  describe "Publishing stacks"
  docker push flowerworkio/build:focal
  docker push flowerworkio/run:focal
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
  flowerworkio_asdf_version=$(cat asdf/buildpack.toml | yj -tj | jq -r '.buildpack.version')
  flowerworkio_phoenix_version=$(cat phoenix/buildpack.toml | yj -tj | jq -r '.buildpack.version')
  pack buildpack package flowerworkio/asdf:$flowerworkio_asdf_version --config asdf/package.toml
  pack buildpack package flowerworkio/phoenix:$flowerworkio_phoenix_version --config phoenix/package.toml
}

publish_buildpacks(){
  describe "Publishing buildpacks"
  docker push flowerworkio/asdf:$flowerworkio_asdf_version
  docker push flowerworkio/phoenix:$flowerworkio_phoenix_version
}
