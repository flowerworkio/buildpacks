# buildpacks

# 🌸 Flowerwork buildpacks

These should be treated as alpha to beta level at the moment. We are not yet using them in a customer-facing production application, but if you give it a go and leave us feedback at https://github.com/flowerworkio/buildpacks we can work to get issues addressed quickly.

## The ASDF buildpack

This looks for a .tools-version file in your repository and will install the right versions of erlang, elixir, golang, ruby, and nodejs. It will cache and restore cache based on a SHA of the `.tool-versions` file. If you are building with pack you should know that buildpack caches are isolated to builds with the same tag. So something like `orgname/reponame:branchname` works pretty well in CI while something like `orgname/reponame:gitsha` does not because every time you commit you change the SHA and bust the cache. It is a good workaround however to re-tag your images afterward via something like `docker tag orgname/reponame:branch orgname/reponame:gitsha` then `docker push orgname/reponame:gitsha`. The cache is prety important because installing erlang is _slow_.

## The Phoenix buildpack

This uses the very latest in phoenix including elixir releases and esbuild. Roughly what it does is pretty well documented in the log output, but generally here's an outline:
1. Sets MIX_ENV, MIX_HOME, HEX_HOME
2. Sets LANG, LANGUAGE, LC_ALL
3. Cleans up build and dependency directories
4. Install hex
5. Install rebar
6. Get and compile deps
7. Install npm packages via npm or yarn
8. Install tailwind binary
9. Install esbuild binary
10. Extract appname (first line of app.tree)
11. Compile release
12. Export buildpack processes default is "start"

## Usage

Everything is packaged into a builder `flowerworkio/builder:focal` for the latest focal builder. Run with:

```
pack build orgname/reponame:branchname \
    --path . \
    --builder flowerworkio/builder:focal \
    --trust-builder
```

## Putting it altogether

Below you'll find `deploy.sh` and `functions.sh`. You'll want to replace `orgname` and `reponame` and `imagename` with meaningful values for your project. 

### bin/deploy.sh

```shell
#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
source functions.sh

buildpacks_package
buildpacks_publish
k8s_set_image my-kubecontext-name my-kube-namespace
```

### bin/functions.sh

```shell
describe() {
  echo "--- $1…"
}

git_branch_name() {
  set +u
  if [ -n "$CI" ]; then
    local branch=$BUILDKITE_BRANCH
  else
    local branch=$(git rev-parse --abbrev-ref HEAD)
  fi
  set -u
  printf "$branch"
}

buildpacks_package() {
  local shortsha=$(git rev-parse --short HEAD)
  local longsha=$(git rev-parse HEAD)
  local branch=$(git_branch_name)
  describe "Packaging via buildpacks"
  pack build orgname/reponame:${branch} \
    --path . \
    --builder flowerworkio/builder:focal \
    --trust-builder
  docker tag orgname/reponame:${branch} orgname/reponame:${shortsha}
  docker tag orgname/reponame:${branch} orgname/reponame:${longsha}
}

buildpacks_publish() {
  local shortsha=$(git rev-parse --short HEAD)
  local longsha=$(git rev-parse HEAD)
  describe "Publishing OCI images"
  docker push orgname/reponame:${longsha}
  docker push orgname/reponame:${shortsha}
}

k8s_set_image() {
  local kubecontext=$1
  local kubenamespace=$2
  local longsha=$(git rev-parse HEAD)

  describe "Setting new image on APPNAME deployment :k8s:"
  kubectl --context ${kubecontext} --namespace ${kubenamespace} set image deploy/reponame imagename=orgname/repooname:${longsha}
}
```

# Reporting issues

You can file issues online at https://github.com/flowerworkio/buildpacks or [email Patrick](mailto:patrick@flowerwork.io) with questions/issues or open a pull request.

## Known issues

### Database migrations

The phoenix buildpack does not run your migrations. After you deploy you'll need to exec into one of the pods in your deployment and run those migrations through your release. The command will be roughly akin to:

```
kubectl exec -it deploy/REPONAME -- /layers/flowerworkio_phoenix/phoenix/bin/APPNAME eval "AppName.Release.migrate"
```
