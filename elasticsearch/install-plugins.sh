#!/bin/sh
set -e

PLUGINS="analysis-icu analysis-kuromoji analysis-smartcn analysis-stempel"

for PLUGIN in $PLUGINS; do
  if /usr/share/elasticsearch/bin/elasticsearch-plugin list | grep -q "$PLUGIN"; then
    echo "Plugin $PLUGIN já está instalado."
  else
    echo "Instalando plugin: $PLUGIN"
    /usr/share/elasticsearch/bin/elasticsearch-plugin install --batch "$PLUGIN"
  fi
done

exec /usr/local/bin/docker-entrypoint.sh
