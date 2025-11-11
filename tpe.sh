#!/bin/bash

PREFIX="$1"
SAXON="saxon/saxon-he-12.9.jar"
DATA="data"

if [ -z "$PREFIX" ]; then
  echo "Use: $0 \"<indicator prefix>\""
  exit 1
fi

mkdir -p "$DATA"

echo "Downloading indicators.json..."
curl -f -k -X GET \
  "https://api-cepalstat.cepal.org/cepalstat/api/v1/thematic-tree?lang=en&format=json" \
  -H 'accept: application/json' -o "$DATA/indicators.json" || {
  echo "Error: Can't download indicators.json"
  exit 1
}

echo ""

echo "Searching ID for: '$PREFIX'"
ID=$(java -cp "$SAXON" net.sf.saxon.Query \
  -q:extract_indicator_id.xq \
  prefix="$PREFIX" 2>/dev/null | tr -d '[:space:]')

if [ -z "$ID" ] || [ "$ID" = "" ]; then
  echo "Error: Indicator with prefix '$PREFIX' not found"
  echo '<indicator_data><error>No indicator found</error></indicator_data>' > "$DATA/indicator_data.xml"
  exit 1
fi

echo "ID found: $ID"
echo ""

echo "Downloading metadata.xml..."
curl -s "https://api-cepalstat.cepal.org/cepalstat/api/v1/indicator/${ID}/metadata?lang=en&format=xml" \
  -o "$DATA/metadata.xml"

echo "Downloading dimensions.xml..."
curl -f -k -X GET \
  "https://api-cepalstat.cepal.org/cepalstat/api/v1/indicator/${ID}/dimensions?lang=en&format=xml&in=1&path=0" \
  -o "$DATA/dimensions.xml" || exit 1

echo "Downloading records.xml..."
curl -f -k -X GET \
  "https://api-cepalstat.cepal.org/cepalstat/api/v1/indicator/${ID}/records?lang=en&format=xml" \
  -o "$DATA/records.xml" || exit 1

echo ""

echo "Generating indicator_data.xml..."
java -cp "$SAXON" net.sf.saxon.Query \
  -q:extract_indicator_data.xq \
  indicator_id="$ID" \
  !method=xml \
  !indent=yes \
  !omit-xml-declaration=no > "$DATA/indicator_data.xml"

echo "Generating indicator_page.md..."
java -cp "$SAXON" net.sf.saxon.Transform \
  -s:"$DATA/indicator_data.xml" \
  -xsl:generate_markdown.xsl \
  -o:"$DATA/indicator_page.md"

echo "Ready! Go to: $DATA/indicator_page.md"