<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="text"/>

  <xsl:template match="/indicator_data">
    <xsl:if test="error">
      <xsl:value-of select="error"/>
      <xsl:text>&#10;</xsl:text>
    </xsl:if>

    <xsl:if test="data/record">
      <xsl:text># Datos del Indicador&#10;&#10;</xsl:text>

      <xsl:variable name="headers" select="distinct-values(data/record/dimension/name)"/>
      
      <xsl:text>| </xsl:text>
      <xsl:for-each select="$headers">
        <xsl:value-of select="."/>
        <xsl:text> | </xsl:text>
      </xsl:for-each>
      <xsl:text>Value |&#10;</xsl:text>

      <xsl:text>| </xsl:text>
      <xsl:for-each select="$headers">
        <xsl:text>--- | </xsl:text>
      </xsl:for-each>
      <xsl:text>--- |&#10;</xsl:text>

      <xsl:for-each select="data/record">
        <xsl:variable name="current-record" select="."/>
        <xsl:text>| </xsl:text>
        <xsl:for-each select="$headers">
          <xsl:variable name="h" select="."/>
          <xsl:value-of select="$current-record/dimension[name = $h]/value"/>
          <xsl:text> | </xsl:text>
        </xsl:for-each>
        <xsl:value-of select="$current-record/value"/>
        <xsl:text> |&#10;</xsl:text>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>