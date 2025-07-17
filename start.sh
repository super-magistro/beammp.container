#!/bin/bash
set -e

echo "[INFO] Démarrage du script..."

DATA_DIR="/data"
TEMPLATE_FILE="/config/ServerConfig.toml.template"
CONFIG_FILE="${DATA_DIR}/ServerConfig.toml"

# Créer dossier data s'il n'existe pas
mkdir -p "$DATA_DIR"

# Télécharger ou mettre à jour l'exécutable BeamMP-Server
echo "[INFO] Vérification de la version et téléchargement du serveur..."

LATEST_TAG=$(wget -qO- https://api.github.com/repos/BeamMP/BeamMP-Server/releases/latest | jq -r '.tag_name' 2>/dev/null)
CURRENT_VERSION=$(find "$DATA_DIR" -maxdepth 1 -type f -name "beamngmp_v*" 2>/dev/null | head -n1 | cut -d'_' -f2)

if [ -z "$LATEST_TAG" ] || [[ "$LATEST_TAG" == "null" ]]; then
  echo "[WARNING] Impossible de récupérer la dernière version depuis l'API GitHub (peut-être rate-limité)."
  if [ -z "$CURRENT_VERSION" ]; then
    echo "[ERROR] Aucune version locale trouvée. Téléchargement impossible sans tag. Abandon."
    exit 1
  else
    echo "[INFO] Utilisation de la version locale existante : $CURRENT_VERSION"
    LATEST_TAG="$CURRENT_VERSION"
  fi
fi

if [ "$CURRENT_VERSION" != "$LATEST_TAG" ]; then
  echo "[INFO] Téléchargement de la version $LATEST_TAG du serveur BeamMP..."

  API_RESPONSE=$(wget -qO- "https://api.github.com/repos/BeamMP/BeamMP-Server/releases/tags/${LATEST_TAG}")
  DL_URL=$(echo "$API_RESPONSE" | jq -r '.assets[] | select(.name | test("BeamMP-Server\\.debian\\.12\\.arm64$")) | .browser_download_url')

  if [ -z "$DL_URL" ]; then
    echo "[ERROR] Impossible de trouver l’URL de téléchargement pour BeamMP-Server ARM64."
    exit 1
  fi

  wget -q --show-progress -O "$DATA_DIR/BeamMP-Server" "$DL_URL"
  chmod +x "$DATA_DIR/BeamMP-Server"
  touch "$DATA_DIR/beamngmp_${LATEST_TAG}"
else
  echo "[INFO] Serveur BeamMP à jour ($LATEST_TAG)."
fi

# Créer la config si elle n'existe pas
if [ ! -f "$CONFIG_FILE" ]; then
  echo "[INFO] Aucun fichier de configuration détecté, création à partir du template..."
  cp "$TEMPLATE_FILE" "$CONFIG_FILE"

  # Injection des variables d'environnement dans la config
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

  echo "[INFO] Configuration générée avec succès."
else
  echo "[INFO] Fichier de configuration existant détecté."
fi

echo "[INFO] Lancement du serveur..."
cd "$DATA_DIR"
/data/BeamMP-Server
