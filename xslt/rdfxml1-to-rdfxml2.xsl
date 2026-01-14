<?xml version="1.0" encoding="UTF-8"?>
<!--
  RDF/XML 1.0 to RDF-XSimple Transformation
  
  Converts standard RDF/XML to modernized RDF-XSimple format with:
  - Context-based namespace management
  - CURIE support
  - Simplified datatypes
  - Intelligent denormalization
  
  Version: 1.0.0
  License: MIT
-->
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:local="http://local.functions"
    exclude-result-prefixes="fn local rdfs xsd">

  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
  
  <!-- Configuration parameters -->
  <xsl:param name="max-inline-depth" select="3" as="xs:integer"/>
  <xsl:param name="inline-single-refs" select="true()" as="xs:boolean"/>
  <xsl:param name="use-curies" select="true()" as="xs:boolean"/>
  
  <!-- Build namespace/prefix mapping -->
  <xsl:variable name="namespace-map">
    <namespaces>
      <xsl:for-each select="//rdf:RDF/namespace::*[not(local-name() = 'xml')]">
        <ns prefix="{local-name()}" uri="{.}"/>
      </xsl:for-each>
    </namespaces>
  </xsl:variable>
  
  <!-- Function to convert full URI to CURIE -->
  <xsl:function name="local:uri-to-curie" as="xs:string">
    <xsl:param name="uri" as="xs:string"/>
    <xsl:param name="ns-map" as="element()"/>
    
    <xsl:choose>
      <xsl:when test="$ns-map//ns[starts-with($uri, @uri)]">
        <xsl:variable name="matching-ns" 
                      select="$ns-map//ns[starts-with($uri, @uri)]
                              [string-length(@uri) = 
                               max($ns-map//ns[starts-with($uri, @uri)]/string-length(@uri))]"/>
        <xsl:variable name="local-name" 
                      select="substring-after($uri, $matching-ns/@uri)"/>
        
        <xsl:choose>
          <xsl:when test="matches($local-name, '^[A-Za-z0-9_\-\.]+$')">
            <xsl:value-of select="concat($matching-ns/@prefix, ':', $local-name)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$uri"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$uri"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!-- Keys for reference counting -->
  <xsl:key name="resource-refs" match="*[@rdf:resource]" use="@rdf:resource"/>
  <xsl:key name="resource-defs" match="*[@rdf:about]" use="@rdf:about"/>
  
  <!-- Function to count references -->
  <xsl:function name="local:reference-count" as="xs:integer">
    <xsl:param name="resource-uri" as="xs:string"/>
    <xsl:param name="root" as="document-node()"/>
    
    <xsl:variable name="refs" select="$root/key('resource-refs', $resource-uri)"/>
    <xsl:sequence select="count($refs)"/>
  </xsl:function>
  
  <!-- Function to check if should inline -->
  <xsl:function name="local:should-inline" as="xs:boolean">
    <xsl:param name="resource-uri" as="xs:string"/>
    <xsl:param name="depth" as="xs:integer"/>
    <xsl:param name="root" as="document-node()"/>
    
    <xsl:variable name="ref-count" select="local:reference-count($resource-uri, $root)"/>
    
    <xsl:sequence select="$inline-single-refs and 
                          $ref-count = 1 and 
                          $depth &lt; $max-inline-depth and
                          exists($root/key('resource-defs', $resource-uri))"/>
  </xsl:function>
  
  <!-- Root template -->
  <xsl:template match="/">
    <xsl:variable name="doc" select="."/>
    <rdf:RDF>
      <xsl:call-template name="generate-context"/>
      
      <xsl:apply-templates select="//rdf:RDF/*" mode="main">
        <xsl:with-param name="depth" select="0" tunnel="yes"/>
        <xsl:with-param name="doc-root" select="$doc" tunnel="yes"/>
        <xsl:with-param name="ns-map" select="$namespace-map" tunnel="yes"/>
      </xsl:apply-templates>
    </rdf:RDF>
  </xsl:template>
  
  <!-- Generate context block -->
  <xsl:template name="generate-context">
    <xsl:variable name="namespaces" 
                  select="//rdf:RDF/namespace::*[not(local-name() = 'xml') and 
                                                 not(local-name() = 'rdf') and
                                                 not(. = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#')]"/>
    
    <xsl:if test="count($namespaces) &gt; 0">
      <rdf:context>
        <xsl:for-each select="$namespaces">
          <xsl:sort select="local-name()"/>
          <rdf:prefix name="{local-name()}" uri="{.}"/>
        </xsl:for-each>
      </rdf:context>
    </xsl:if>
  </xsl:template>
  
  <!-- Main resource processing -->
  <xsl:template match="*[@rdf:about]" mode="main">
    <xsl:param name="depth" select="0" tunnel="yes"/>
    <xsl:param name="doc-root" tunnel="yes"/>
    <xsl:param name="already-inlined" select="()" tunnel="yes"/>
    <xsl:param name="ns-map" tunnel="yes"/>
    
    <xsl:if test="not(@rdf:about = $already-inlined)">
      <xsl:call-template name="process-resource">
        <xsl:with-param name="depth" select="$depth"/>
        <xsl:with-param name="doc-root" select="$doc-root"/>
        <xsl:with-param name="ns-map" select="$ns-map"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  
  <!-- Process resource -->
  <xsl:template name="process-resource">
    <xsl:param name="depth" select="0"/>
    <xsl:param name="doc-root"/>
    <xsl:param name="ns-map"/>
    
    <xsl:variable name="element-name">
      <xsl:choose>
        <xsl:when test="rdf:type[@rdf:resource]">
          <xsl:value-of select="local:qname-from-uri(rdf:type[1]/@rdf:resource, $ns-map)"/>
        </xsl:when>
        <xsl:when test="not(local-name() = 'Description')">
          <xsl:value-of select="concat(namespace-uri(), local-name())"/>
        </xsl:when>
        <xsl:otherwise>rdf:Description</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:element name="{$element-name}">
      <xsl:attribute name="rdf:about">
        <xsl:choose>
          <xsl:when test="$use-curies">
            <xsl:value-of select="local:uri-to-curie(@rdf:about, $ns-map)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="@rdf:about"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      
      <xsl:apply-templates select="*[not(self::rdf:type[position()=1])]" mode="property">
        <xsl:with-param name="depth" select="$depth + 1" tunnel="yes"/>
        <xsl:with-param name="doc-root" select="$doc-root" tunnel="yes"/>
        <xsl:with-param name="ns-map" select="$ns-map" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:element>
  </xsl:template>
  
  <!-- Property processing -->
  <xsl:template match="*" mode="property">
    <xsl:param name="depth" tunnel="yes"/>
    <xsl:param name="doc-root" tunnel="yes"/>
    <xsl:param name="ns-map" tunnel="yes"/>
    
    <xsl:element name="{concat(namespace-uri(), local-name())}">
      <xsl:choose>
        <!-- Handle parseType="Collection" - convert to rdf:list="true" -->
        <xsl:when test="@rdf:parseType='Collection'">
          <xsl:attribute name="rdf:list">true</xsl:attribute>
          <xsl:apply-templates select="*" mode="nested">
            <xsl:with-param name="depth" select="$depth" tunnel="yes"/>
            <xsl:with-param name="doc-root" select="$doc-root" tunnel="yes"/>
            <xsl:with-param name="ns-map" select="$ns-map" tunnel="yes"/>
          </xsl:apply-templates>
        </xsl:when>
        
        <xsl:when test="@rdf:resource and local:should-inline(@rdf:resource, $depth, $doc-root)">
          <xsl:call-template name="inline-resource">
            <xsl:with-param name="resource-uri" select="@rdf:resource"/>
            <xsl:with-param name="depth" select="$depth"/>
            <xsl:with-param name="doc-root" select="$doc-root"/>
            <xsl:with-param name="ns-map" select="$ns-map"/>
          </xsl:call-template>
        </xsl:when>
        
        <xsl:when test="@rdf:resource">
          <xsl:attribute name="rdf:resource">
            <xsl:choose>
              <xsl:when test="$use-curies">
                <xsl:value-of select="local:uri-to-curie(@rdf:resource, $ns-map)"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="@rdf:resource"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
        </xsl:when>
        
        <xsl:when test="*[@rdf:about or not(@rdf:about)]">
          <xsl:apply-templates select="*" mode="nested">
            <xsl:with-param name="depth" select="$depth" tunnel="yes"/>
            <xsl:with-param name="doc-root" select="$doc-root" tunnel="yes"/>
            <xsl:with-param name="ns-map" select="$ns-map" tunnel="yes"/>
          </xsl:apply-templates>
        </xsl:when>
        
        <xsl:when test="@rdf:datatype">
          <xsl:call-template name="simplify-datatype">
            <xsl:with-param name="datatype" select="@rdf:datatype"/>
            <xsl:with-param name="ns-map" select="$ns-map"/>
          </xsl:call-template>
          <xsl:value-of select="text()"/>
        </xsl:when>
        
        <xsl:when test="@xml:lang">
          <xsl:attribute name="lang">
            <xsl:value-of select="@xml:lang"/>
          </xsl:attribute>
          <xsl:value-of select="text()"/>
        </xsl:when>
        
        <xsl:otherwise>
          <xsl:value-of select="text()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>
  
  <!-- Inline resource -->
  <xsl:template name="inline-resource">
    <xsl:param name="resource-uri"/>
    <xsl:param name="depth"/>
    <xsl:param name="doc-root"/>
    <xsl:param name="ns-map"/>
    
    <xsl:variable name="resource-def" select="$doc-root/key('resource-defs', $resource-uri)"/>
    
    <xsl:if test="$resource-def">
      <xsl:variable name="element-name">
        <xsl:choose>
          <xsl:when test="$resource-def/rdf:type[@rdf:resource]">
            <xsl:value-of select="local:qname-from-uri($resource-def/rdf:type[1]/@rdf:resource, $ns-map)"/>
          </xsl:when>
          <xsl:when test="not(local-name($resource-def) = 'Description')">
            <xsl:value-of select="concat(namespace-uri($resource-def), local-name($resource-def))"/>
          </xsl:when>
          <xsl:otherwise>rdf:Description</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      
      <xsl:element name="{$element-name}">
        <xsl:attribute name="rdf:about">
          <xsl:choose>
            <xsl:when test="$use-curies">
              <xsl:value-of select="local:uri-to-curie($resource-uri, $ns-map)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$resource-uri"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
        
        <xsl:apply-templates select="$resource-def/*[not(self::rdf:type[position()=1])]" mode="property">
          <xsl:with-param name="depth" select="$depth + 1" tunnel="yes"/>
          <xsl:with-param name="doc-root" select="$doc-root" tunnel="yes"/>
          <xsl:with-param name="ns-map" select="$ns-map" tunnel="yes"/>
        </xsl:apply-templates>
      </xsl:element>
    </xsl:if>
  </xsl:template>
  
  <!-- Nested resource -->
  <xsl:template match="*" mode="nested">
    <xsl:param name="depth" tunnel="yes"/>
    <xsl:param name="doc-root" tunnel="yes"/>
    <xsl:param name="ns-map" tunnel="yes"/>
    
    <xsl:call-template name="process-resource">
      <xsl:with-param name="depth" select="$depth"/>
      <xsl:with-param name="doc-root" select="$doc-root"/>
      <xsl:with-param name="ns-map" select="$ns-map"/>
    </xsl:call-template>
  </xsl:template>
  
  <!-- Simplify datatype -->
  <xsl:template name="simplify-datatype">
    <xsl:param name="datatype"/>
    <xsl:param name="ns-map"/>
    
    <xsl:variable name="xsd-prefix" select="'http://www.w3.org/2001/XMLSchema#'"/>
    
    <xsl:choose>
      <xsl:when test="starts-with($datatype, $xsd-prefix)">
        <xsl:attribute name="type">
          <xsl:value-of select="substring-after($datatype, $xsd-prefix)"/>
        </xsl:attribute>
      </xsl:when>
      <xsl:otherwise>
        <xsl:attribute name="rdf:type">
          <xsl:choose>
            <xsl:when test="$use-curies">
              <xsl:value-of select="local:uri-to-curie($datatype, $ns-map)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="local:qname-from-uri($datatype, $ns-map)"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- Convert URI to QName -->
  <xsl:function name="local:qname-from-uri" as="xs:string">
    <xsl:param name="uri" as="xs:string"/>
    <xsl:param name="ns-map" as="element()"/>
    
    <xsl:variable name="namespace-uri">
      <xsl:choose>
        <xsl:when test="contains($uri, '#')">
          <xsl:value-of select="concat(substring-before($uri, '#'), '#')"/>
        </xsl:when>
        <xsl:when test="matches($uri, '.*/[^/]+$')">
          <xsl:value-of select="replace($uri, '(.*/)([^/]+)$', '$1')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$uri"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="local-name">
      <xsl:choose>
        <xsl:when test="contains($uri, '#')">
          <xsl:value-of select="substring-after($uri, '#')"/>
        </xsl:when>
        <xsl:when test="matches($uri, '.*/[^/]+$')">
          <xsl:value-of select="replace($uri, '(.*/)([^/]+)$', '$2')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="''"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="prefix" select="$ns-map//ns[@uri = $namespace-uri]/@prefix"/>
    
    <xsl:choose>
      <xsl:when test="$prefix and $local-name != ''">
        <xsl:value-of select="concat($prefix, ':', $local-name)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$uri"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!-- Default templates -->
  <xsl:template match="text()" mode="main"/>
  
</xsl:stylesheet>
