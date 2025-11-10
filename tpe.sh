#!/bin/bash

PREFIX="$1"
SAXON="saxon/saxon-he-12.9.jar"
DATA="data"

if [ -z "$PREFIX" ]; then
  echo "Uso: $0 \"<prefijo del indicador>\""
  exit 1
fi

mkdir -p "$DATA"

echo "Descargando indicators.json..."
curl -f -k -X GET \
  "https://api-cepalstat.cepal.org/cepalstat/api/v1/thematic-tree?lang=en&format=json" \
  -H 'accept: application/json' -o "$DATA/indicators.json" || {
  echo "Error: No se pudo descargar indicators.json"
  exit 1
}

echo "Buscando ID para: '$PREFIX'"
ID=$(java -cp "$SAXON" net.sf.saxon.Query \
  -q:extract_indicator_id.xq \
  prefix="$PREFIX" 2>/dev/null | tr -d '[:space:]')

if [ -z "$ID" ] || [ "$ID" = "" ]; then
  echo "Error: No se encontró indicador con prefijo '$PREFIX'"
  echo '<indicator_data><error>No indicator found</error></indicator_data>' > "$DATA/indicator_data.xml"
  exit 1
fi

echo "ID encontrado: $ID"

echo "Descargando dimensions.xml..."
curl -f -k -X GET \
  "https://api-cepalstat.cepal.org/cepalstat/api/v1/indicator/${ID}/dimensions?lang=en&format=xml&in=1&path=0" \
  -o "$DATA/dimensions.xml" || exit 1

echo "Descargando records.xml..."
curl -f -k -X GET \
  "https://api-cepalstat.cepal.org/cepalstat/api/v1/indicator/${ID}/records?lang=en&format=xml" \
  -o "$DATA/records.xml" || exit 1

echo "Generando indicator_data.xml..."
java -cp "$SAXON" net.sf.saxon.Query \
  -q:extract_indicator_data.xq \
  indicator_id="$ID" > "$DATA/indicator_data.xml"

echo "Generando indicator_page.md..."
java -cp "$SAXON" net.sf.saxon.Transform \
  -s:"$DATA/indicator_data.xml" \
  -xsl:generate_markdown.xsl \
  -o:"$DATA/indicator_page.md"

echo "¡Listo! Revisa: $DATA/indicator_page.md"