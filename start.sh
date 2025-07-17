#!/bin/bash
set -e

echo "[INFO] Starting setup script..."

DATA_DIR="/data"
TEMPLATE_FILE="/config/ServerConfig.toml.template"
CONFIG_FILE="${DATA_DIR}/ServerConfig.toml"

# Create the data directory if it doesn't exist
mkdir -p "$DATA_DIR"

# Download or update BeamMP-Server executable
echo "[INFO] Checking version and downloading the server if needed..."

LATEST_TAG=$(wget -qO- https://api.github.com/repos/BeamMP/BeamMP-Server/releases/latest | jq -r '.tag_name' 2>/dev/null)
CURRENT_VERSION=$(find "$DATA_DIR" -maxdepth 1 -type f -name "beamngmp_v*" 2>/dev/null | head -n1 | cut -d'_' -f2)

if [ -z "$LATEST_TAG" ] || [[ "$LATEST_TAG" == "null" ]]; then
  echo "[WARNING] Could not retrieve the latest version from GitHub API (maybe rate-limited)."
  if [ -z "$CURRENT_VERSION" ]; then
    echo "[ERROR] No local version found. Cannot proceed without a tag. Aborting."
    exit 1
  else
    echo "[INFO] Using existing local version: $CURRENT_VERSION"
    LATEST_TAG="$CURRENT_VERSION"
  fi
fi

if [ "$CURRENT_VERSION" != "$LATEST_TAG" ]; then
  echo "[INFO] Downloading BeamMP server version $LATEST_TAG..."

  API_RESPONSE=$(wget -qO- "https://api.github.com/repos/BeamMP/BeamMP-Server/releases/tags/${LATEST_TAG}")
  DL_URL=$(echo "$API_RESPONSE" | jq -r '.assets[] | select(.name | test("BeamMP-Server\\.debian\\.12\\.arm64$")) | .browser_download_url')

  if [ -z "$DL_URL" ]; then
    echo "[ERROR] Could not find download URL for BeamMP-Server ARM64."
    exit 1
  fi

  wget -q --show-progress -O "$DATA_DIR/BeamMP-Server" "$DL_URL"
  chmod +x "$DATA_DIR/BeamMP-Server"
  touch "$DATA_DIR/beamngmp_${LATEST_TAG}"
else
  echo "[INFO] BeamMP server is already up-to-date (v$LATEST_TAG)."
fi

# Create config file from template if it doesn't exist
if [ ! -f "$CONFIG_FILE" ]; then
  echo "[INFO] No config file found. Creating one from template..."
  cp "$TEMPLATE_FILE" "$CONFIG_FILE"

  # Inject environment variables into the config file
  sed -i "s|ImScaredOfUpdates = .*|ImScaredOfUpdates = ${NOT_SHOW_IF_UPDATE_AVAILABLE}|" "$CONFIG_FILE"
  sed -i "s|Name = .*|Name = \"${SERVER_NAME}\"|" "$CONFIG_FILE"
  sed -i "s|AuthKey = .*|AuthKey = \"${AUTH_KEY}\"|" "$CONFIG_FILE"
  sed -i "s|MaxPlayers = .*|MaxPlayers = ${MAX_PLAYERS}|" "$CONFIG_FILE"
  sed -i "s|Description = .*|Description = \"${DESCRIPTION}\"|" "$CONFIG_FILE"
  sed -i "s|Tags = .*|Tags = \"${TAGS}\"|" "$CONFIG_FILE"
  sed -i "s|Private = .*|Private = ${PRIVATE}|" "$CONFIG_FILE"
  sed -i "s|Debug = .*|Debug = ${DEBUG}|" "$CONFIG_FILE"
  sed -i "s|Name = .*|Name = \"${NAME}\"|" "$CONFIG_FILE"
  sed -i "s|LogChat = .*|LogChat = ${LOG_CHAT}|" "$CONFIG_FILE"
  sed -i "s|MaxCars = .*|MaxCars = ${MAX_CARS}|" "$CONFIG_FILE"
  sed -i "s|Map = .*|Map = \"${MAP}\"|" "$CONFIG_FILE"

  echo "[INFO] Configuration generated successfully."
else
  echo "[INFO] Existing configuration file detected. Skipping generation."
fi

# Launch the BeamMP server
echo "[INFO] Launching BeamMP server..."
cd "$DATA_DIR"
/data/BeamMP-Server
