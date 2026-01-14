<?xml version="1.0" encoding="UTF-8"?>
<!--
  RDF-XSimple to RDF/XML 1.0 Transformation
  
  Converts modernized RDF-XSimple back to standard RDF/XML 1.0 format:
  - Expands CURIEs to full URIs
  - Converts context to namespace declarations
  - Expands simplified datatypes
  - Flattens nested resources (denormalization reversal)
  
  Version: 1.0.0
  License: MIT
-->
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/02/XSL/Transform"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:local="http://local.functions">

  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
  
  <!-- Build prefix map from context -->
  <xsl:variable name="prefix-map">
    <prefixes>
      <xsl:for-each select="/rdf:RDF/rdf:context/rdf:prefix">
        <prefix name="{@name}" uri="{@uri}"/>
      </xsl:for-each>
    </prefixes>
  </xsl:variable>
  
  <!-- Expand CURIE to full URI -->
  <xsl:function name="local:expand-curie">
    <xsl:param name="curie"/>
    <xsl:param name="prefix-map"/>
    
    <xsl:choose>
      <!-- Check if it's a CURIE -->
      <xsl:when test="contains($curie, ':') and 
                      not(starts-with($curie, 'http://')) and
                      not(starts-with($curie, 'https://')) and
                      not(starts-with($curie, 'urn:'))">
        <xsl:variable name="prefix" select="substring-before($curie, ':')"/>
        <xsl:variable name="local" select="substring-after($curie, ':')"/>
        <xsl:variable name="namespace" select="$prefix-map//prefix[@name=$prefix]/@uri"/>
        
        <xsl:choose>
          <xsl:when test="$namespace">
            <xsl:value-of select="concat($namespace, $local)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$curie"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      
      <!-- Already a full URI -->
      <xsl:otherwise>
        <xsl:value-of select="$curie"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!-- Root template -->
  <xsl:template match="/rdf:RDF">
    <rdf:RDF>
      <!-- Reconstruct namespace declarations from context -->
      <xsl:namespace name="rdf">http://www.w3.org/1999/02/22-rdf-syntax-ns#</xsl:namespace>
      <xsl:for-each select="rdf:context/rdf:prefix">
        <xsl:namespace name="{@name}" select="@uri"/>
      </xsl:for-each>
      
      <!-- Process all resources (skip context) -->
      <xsl:apply-templates select="*[not(self::rdf:context)]" mode="flatten"/>
    </rdf:RDF>
  </xsl:template>
  
  <!-- Flatten resources (extract nested resources) -->
  <xsl:template match="*[@rdf:about]" mode="flatten">
    <xsl:variable name="current-resource" select="."/>
    
    <!-- Output this resource -->
    <xsl:element name="rdf:Description">
      <xsl:attribute name="rdf:about">
        <xsl:value-of select="local:expand-curie(@rdf:about, $prefix-map)"/>
      </xsl:attribute>
      
      <!-- Add rdf:type if element is not rdf:Description -->
      <xsl:if test="not(local-name() = 'Description' and namespace-uri() = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#')">
        <rdf:type>
          <xsl:attribute name="rdf:resource">
            <xsl:value-of select="concat(namespace-uri(), local-name())"/>
          </xsl:attribute>
        </rdf:type>
      </xsl:if>
      
      <!-- Process properties -->
      <xsl:apply-templates select="*" mode="property-flatten"/>
    </xsl:element>
    
    <!-- Extract and output nested resources -->
    <xsl:apply-templates select=".//node()[@rdf:about and ancestor::*[@rdf:about][1] = $current-resource]" mode="extract-nested"/>
  </xsl:template>
  
  <!-- Process properties during flattening -->
  <xsl:template match="*" mode="property-flatten">
    <xsl:element name="{concat(namespace-uri(), local-name())}">
      <xsl:choose>
        <!-- RDF List - convert to parseType="Collection" -->
        <xsl:when test="@rdf:list='true'">
          <xsl:attribute name="rdf:parseType">Collection</xsl:attribute>
          <xsl:apply-templates select="*" mode="blank-node"/>
        </xsl:when>
        
        <!-- RDF Bag - convert to rdf:Bag structure -->
        <xsl:when test="@rdf:bag='true'">
          <rdf:Bag>
            <xsl:for-each select="*">
              <rdf:li>
                <xsl:choose>
                  <xsl:when test="@rdf:resource">
                    <xsl:attribute name="rdf:resource">
                      <xsl:value-of select="local:expand-curie(@rdf:resource, $prefix-map)"/>
                    </xsl:attribute>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="text()"/>
                  </xsl:otherwise>
                </xsl:choose>
              </rdf:li>
            </xsl:for-each>
          </rdf:Bag>
        </xsl:when>
        
        <!-- RDF Seq - convert to rdf:Seq structure -->
        <xsl:when test="@rdf:seq='true'">
          <rdf:Seq>
            <xsl:for-each select="*">
              <rdf:li>
                <xsl:choose>
                  <xsl:when test="@rdf:resource">
                    <xsl:attribute name="rdf:resource">
                      <xsl:value-of select="local:expand-curie(@rdf:resource, $prefix-map)"/>
                    </xsl:attribute>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="text()"/>
                  </xsl:otherwise>
                </xsl:choose>
              </rdf:li>
            </xsl:for-each>
          </rdf:Seq>
        </xsl:when>
        
        <!-- Nested resource with rdf:about - convert to reference -->
        <xsl:when test="*[@rdf:about]">
          <xsl:attribute name="rdf:resource">
            <xsl:value-of select="local:expand-curie(*/@rdf:about, $prefix-map)"/>
          </xsl:attribute>
        </xsl:when>
        
        <!-- Resource reference -->
        <xsl:when test="@rdf:resource">
          <xsl:attribute name="rdf:resource">
            <xsl:value-of select="local:expand-curie(@rdf:resource, $prefix-map)"/>
          </xsl:attribute>
        </xsl:when>
        
        <!-- Nested blank node -->
        <xsl:when test="*[not(@rdf:about)]">
          <xsl:apply-templates select="*" mode="blank-node"/>
        </xsl:when>
        
        <!-- Typed literal with simplified type attribute -->
        <xsl:when test="@type">
          <xsl:attribute name="rdf:datatype">
            <xsl:value-of select="concat('http://www.w3.org/2001/XMLSchema#', @type)"/>
          </xsl:attribute>
          <xsl:value-of select="text()"/>
        </xsl:when>
        
        <!-- Typed literal with rdf:type attribute -->
        <xsl:when test="@rdf:type">
          <xsl:attribute name="rdf:datatype">
            <xsl:value-of select="local:expand-curie(@rdf:type, $prefix-map)"/>
          </xsl:attribute>
          <xsl:value-of select="text()"/>
        </xsl:when>
        
        <!-- Language-tagged literal -->
        <xsl:when test="@lang">
          <xsl:attribute name="xml:lang">
            <xsl:value-of select="@lang"/>
          </xsl:attribute>
          <xsl:value-of select="text()"/>
        </xsl:when>
        
        <!-- Simple literal -->
        <xsl:otherwise>
          <xsl:value-of select="text()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>
  
  <!-- Process blank nodes -->
  <xsl:template match="*" mode="blank-node">
    <xsl:element name="rdf:Description">
      <!-- Add rdf:type if element is not rdf:Description -->
      <xsl:if test="not(local-name() = 'Description' and namespace-uri() = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#')">
        <rdf:type>
          <xsl:attribute name="rdf:resource">
            <xsl:value-of select="concat(namespace-uri(), local-name())"/>
          </xsl:attribute>
        </rdf:type>
      </xsl:if>
      
      <!-- Process properties -->
      <xsl:apply-templates select="*" mode="property-flatten"/>
    </xsl:element>
  </xsl:template>
  
  <!-- Extract nested resources and output them at top level -->
  <xsl:template match="*[@rdf:about]" mode="extract-nested">
    <xsl:element name="rdf:Description">
      <xsl:attribute name="rdf:about">
        <xsl:value-of select="local:expand-curie(@rdf:about, $prefix-map)"/>
      </xsl:attribute>
      
      <!-- Add rdf:type -->
      <xsl:if test="not(local-name() = 'Description' and namespace-uri() = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#')">
        <rdf:type>
          <xsl:attribute name="rdf:resource">
            <xsl:value-of select="concat(namespace-uri(), local-name())"/>
          </xsl:attribute>
        </rdf:type>
      </xsl:if>
      
      <!-- Process properties -->
      <xsl:apply-templates select="*" mode="property-flatten"/>
    </xsl:element>
    
    <!-- Recursively extract nested resources -->
    <xsl:apply-templates select=".//node()[@rdf:about and ancestor::*[@rdf:about][1] = current()]" mode="extract-nested"/>
  </xsl:template>
  
  <!-- RDF-star support: QuotedTriple -->
  <xsl:template match="rdf:QuotedTriple" mode="property-flatten">
    <xsl:copy>
      <xsl:apply-templates select="rdf:subject" mode="quoted-component"/>
      <xsl:apply-templates select="rdf:predicate" mode="quoted-component"/>
      <xsl:apply-templates select="rdf:object" mode="quoted-component"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="rdf:subject | rdf:predicate | rdf:object" mode="quoted-component">
    <xsl:copy>
      <xsl:if test="@rdf:resource">
        <xsl:attribute name="rdf:resource">
          <xsl:value-of select="local:expand-curie(@rdf:resource, $prefix-map)"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates mode="property-flatten"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- Default: ignore text nodes in flatten mode -->
  <xsl:template match="text()" mode="flatten"/>
  
</xsl:stylesheet>
