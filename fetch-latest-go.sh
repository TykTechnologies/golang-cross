#!/usr/bin/env bash
set -euo pipefail

GO_MAJOR_MINOR="${GO_MAJOR_MINOR:-1.24}"
ARCH="$(dpkg --print-architecture)"
echo "Fetching latest Go ${GO_MAJOR_MINOR}.x version for ${ARCH}..."
TMP_DIR="$(mktemp -d)"
cd "$TMP_DIR"

# Map Debian arch to Go arch
case "$ARCH" in
  amd64) GOARCH="amd64" ;;
  arm64) GOARCH="arm64" ;;
  s390x) GOARCH="s390x" ;;
  *) echo "Unsupported arch: $ARCH" && exit 1 ;;
esac

# Get latest patch release info from Go’s JSON API
JSON=$(curl -s https://go.dev/dl/?mode=json)

# Extract latest version matching our major.minor (1.24.x)
LATEST=$(echo "$JSON" | jq -r --arg ver "go${GO_MAJOR_MINOR}." '
  map(select(.version | startswith($ver))) | first | .version
')

if [ -z "$LATEST" ]; then
  echo "Could not find latest Go version for $GO_MAJOR_MINOR"
  exit 1
fi

echo "Latest Go version found: $LATEST"

# Extract download info
FILENAME=$(echo "$JSON" | jq -r \
  --arg ver "$LATEST" --arg arch "$GOARCH" \
  '.[] | select(.version == $ver) | .files[] | select(.os == "linux" and .arch == $arch and .kind == "archive") | .filename')

SHA256=$(echo "$JSON" | jq -r \
  --arg ver "$LATEST" --arg arch "$GOARCH" \
  '.[] | select(.version == $ver) | .files[] | select(.os == "linux" and .arch == $arch and .kind == "archive") | .sha256')

if [ -z "$FILENAME" ] || [ "$FILENAME" = "null" ]; then
  echo "Could not find filename for $LATEST ($GOARCH)"
  exit 1
fi

URL="https://dl.google.com/go/${FILENAME}"

echo "Downloading $URL ..."
curl -fsSL -o go.tgz "$URL"

echo "$SHA256  go.tgz" | sha256sum -c -

tar -C /usr/local -xzf go.tgz
rm go.tgz
echo "Installed Go $LATEST successfully at /usr/local/go"
