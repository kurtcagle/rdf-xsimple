<?xml version="1.0" encoding="UTF-8"?>
<!--
  RDF-XSimple Schematron Validation Rules
  
  Advanced validation constraints that cannot be expressed in XML Schema.
  
  Version: 1.0.0
  Date: 2026-01-14
  License: MIT
  
  Usage with Saxon:
    1. Compile to XSLT:
       saxon -xsl:iso-schematron-xslt2.xsl -s:rdfxml2.sch -o:rdfxml2-validator.xsl
    
    2. Validate document:
       saxon -xsl:rdfxml2-validator.xsl -s:document.rdf
-->
<schema xmlns="http://purl.oclc.org/dsdl/schematron"
        xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
        queryBinding="xslt2">
  
  <title>RDF-XSimple Advanced Validation Rules</title>
  
  <ns prefix="rdf" uri="http://www.w3.org/1999/02/22-rdf-syntax-ns#"/>
  
  <!-- ================================================================
       CONTEXT BLOCK RULES
       ================================================================ -->
  
  <pattern id="context-ordering">
    <title>Context Block Ordering</title>
    <rule context="rdf:RDF">
      <assert test="not(rdf:context) or rdf:context[1] = *[1]">
        The rdf:context element must be the first child of rdf:RDF if present.
      </assert>
    </rule>
  </pattern>
  
  <pattern id="context-structure">
    <title>Context Block Structure</title>
    <rule context="rdf:context">
      <assert test="count(rdf:prefix) &gt; 0">
        The rdf:context element must contain at least one rdf:prefix element.
      </assert>
      <assert test="parent::rdf:RDF">
        The rdf:context element must be a direct child of rdf:RDF.
      </assert>
    </rule>
  </pattern>
  
  <pattern id="prefix-definitions">
    <title>Prefix Definitions</title>
    <rule context="rdf:prefix">
      <assert test="@name and @uri">
        Each rdf:prefix must have both 'name' and 'uri' attributes.
      </assert>
      <assert test="matches(@name, '^[A-Za-z_][A-Za-z0-9_\-]*$')">
        Prefix name must be a valid NCName (letters, digits, underscore, hyphen).
      </assert>
      <assert test="string-length(@uri) &gt; 0">
        Prefix URI must not be empty.
      </assert>
    </rule>
  </pattern>
  
  <pattern id="unique-prefixes">
    <title>Unique Prefix Names</title>
    <rule context="rdf:context">
      <let name="prefix-names" value="rdf:prefix/@name"/>
      <assert test="count($prefix-names) = count(distinct-values($prefix-names))">
        Each prefix name must be unique within the context block.
        Duplicate prefix: <value-of select="$prefix-names[index-of($prefix-names, .)[2]]"/>
      </assert>
    </rule>
  </pattern>

  <!-- ================================================================
       CURIE VALIDATION
       ================================================================ -->
  
  <pattern id="curie-prefix-defined">
    <title>CURIE Prefix Definition Check</title>
    <rule context="*[@rdf:about[contains(., ':') and 
                                 not(starts-with(., 'http://')) and 
                                 not(starts-with(., 'https://')) and
                                 not(starts-with(., 'urn:'))]]">
      <let name="curie" value="@rdf:about"/>
      <let name="prefix" value="substring-before($curie, ':')"/>
      <let name="defined-prefixes" value="ancestor::rdf:RDF/rdf:context/rdf:prefix/@name"/>
      <assert test="$prefix = $defined-prefixes">
        CURIE prefix '<value-of select="$prefix"/>' in rdf:about="<value-of select="$curie"/>" 
        is not defined in the context block.
      </assert>
    </rule>
    
    <rule context="*[@rdf:resource[contains(., ':') and 
                                   not(starts-with(., 'http://')) and 
                                   not(starts-with(., 'https://')) and
                                   not(starts-with(., 'urn:'))]]">
      <let name="curie" value="@rdf:resource"/>
      <let name="prefix" value="substring-before($curie, ':')"/>
      <let name="defined-prefixes" value="ancestor::rdf:RDF/rdf:context/rdf:prefix/@name"/>
      <assert test="$prefix = $defined-prefixes">
        CURIE prefix '<value-of select="$prefix"/>' in rdf:resource="<value-of select="$curie"/>" 
        is not defined in the context block.
      </assert>
    </rule>
  </pattern>

  <!-- ================================================================
       ATTRIBUTE CONFLICTS
       ================================================================ -->
  
  <pattern id="datatype-conflicts">
    <title>Datatype Attribute Conflicts</title>
    <rule context="*[@type and @rdf:datatype]">
      <assert test="false()">
        Cannot specify both 'type' and 'rdf:datatype' attributes on the same element.
      </assert>
    </rule>
    
    <rule context="*[@type and @lang]">
      <assert test="false()">
        Cannot specify both 'type' (datatype) and 'lang' (language tag) attributes.
        Use either type for typed literals or lang for language-tagged strings.
      </assert>
    </rule>
    
    <rule context="*[@rdf:datatype and @lang]">
      <assert test="false()">
        Cannot specify both 'rdf:datatype' and 'lang' attributes.
        Use either rdf:datatype for typed literals or lang for language-tagged strings.
      </assert>
    </rule>
  </pattern>
  
  <pattern id="collection-conflicts">
    <title>Collection Type Conflicts</title>
    <rule context="*[@rdf:list='true' and @rdf:bag='true']">
      <assert test="false()">
        Cannot specify both rdf:list and rdf:bag. Use only one collection type.
      </assert>
    </rule>
    
    <rule context="*[@rdf:list='true' and @rdf:seq='true']">
      <assert test="false()">
        Cannot specify both rdf:list and rdf:seq. Use only one collection type.
      </assert>
    </rule>
    
    <rule context="*[@rdf:bag='true' and @rdf:seq='true']">
      <assert test="false()">
        Cannot specify both rdf:bag and rdf:seq. Use only one collection type.
      </assert>
    </rule>
  </pattern>
  
  <pattern id="resource-reference-conflicts">
    <title>Resource Reference Conflicts</title>
    <rule context="*[@rdf:resource and *]">
      <assert test="false()">
        Cannot have both rdf:resource attribute and nested elements.
        Use rdf:resource for references or nested elements for inline resources, not both.
      </assert>
    </rule>
    
    <rule context="*[@rdf:resources and *]">
      <assert test="false()">
        Cannot use rdf:resources shorthand with nested elements.
        The rdf:resources attribute is a shorthand; use nested elements instead.
      </assert>
    </rule>
    
    <rule context="*[@rdf:resources and not(@rdf:list='true' or @rdf:bag='true' or @rdf:seq='true')]">
      <report test="true()" role="warning">
        The rdf:resources attribute is typically used with rdf:list, rdf:bag, or rdf:seq.
        Consider adding a collection type attribute.
      </report>
    </rule>
  </pattern>

  <!-- ================================================================
       RESOURCE IDENTITY PRESERVATION
       ================================================================ -->
  
  <pattern id="nested-resource-identity">
    <title>Nested Resource Identity</title>
    <rule context="*[@rdf:about]/*[*[@rdf:about]]">
      <report test="true()" role="info">
        Nested resource with rdf:about="<value-of select="*/@rdf:about"/>" preserves identity.
        This is correct for denormalization - the resource maintains its IRI.
      </report>
    </rule>
  </pattern>

  <!-- ================================================================
       RDF-STAR VALIDATION
       ================================================================ -->
  
  <pattern id="quoted-triple-structure">
    <title>Quoted Triple Structure</title>
    <rule context="rdf:QuotedTriple">
      <assert test="count(rdf:subject) = 1">
        A quoted triple must have exactly one rdf:subject element.
      </assert>
      <assert test="count(rdf:predicate) = 1">
        A quoted triple must have exactly one rdf:predicate element.
      </assert>
      <assert test="count(rdf:object) = 1">
        A quoted triple must have exactly one rdf:object element.
      </assert>
    </rule>
    
    <rule context="rdf:subject | rdf:predicate | rdf:object">
      <assert test="parent::rdf:QuotedTriple">
        Elements rdf:subject, rdf:predicate, and rdf:object can only appear within rdf:QuotedTriple.
      </assert>
    </rule>
  </pattern>

  <!-- ================================================================
       BEST PRACTICES AND RECOMMENDATIONS
       ================================================================ -->
  
  <pattern id="recommended-practices">
    <title>Recommended Best Practices</title>
    
    <rule context="rdf:Description">
      <report test="rdf:type" role="info">
        Consider using typed element name instead of rdf:Description with rdf:type.
        Example: Use &lt;schema:Person&gt; instead of &lt;rdf:Description&gt;&lt;rdf:type rdf:resource="schema:Person"/&gt;
      </report>
    </rule>
    
    <rule context="*[@rdf:about]/*[*[@rdf:about]]">
      <let name="depth" value="count(ancestor::*[@rdf:about])"/>
      <report test="$depth &gt; 3" role="warning">
        Nesting depth of <value-of select="$depth"/> exceeds recommended maximum of 3 levels.
        Consider keeping deeply nested resources as separate top-level resources with references.
      </report>
    </rule>
    
    <rule context="*[@xml:lang]">
      <report test="true()" role="info">
        Using xml:lang attribute. Consider using the simplified 'lang' attribute instead.
      </report>
    </rule>
    
    <rule context="*[@rdf:datatype[starts-with(., 'http://www.w3.org/2001/XMLSchema#')]]">
      <let name="xsd-type" value="substring-after(@rdf:datatype, 'http://www.w3.org/2001/XMLSchema#')"/>
      <report test="true()" role="info">
        Using full XSD datatype URI. Consider using simplified type="<value-of select="$xsd-type"/>" instead.
      </report>
    </rule>
  </pattern>

  <!-- ================================================================
       DATA QUALITY CHECKS
       ================================================================ -->
  
  <pattern id="data-quality">
    <title>Data Quality Checks</title>
    
    <rule context="*[@type='integer']">
      <assert test="matches(., '^\-?\d+$')">
        Value '<value-of select="."/>' is not a valid integer.
      </assert>
    </rule>
    
    <rule context="*[@type='boolean']">
      <assert test=". = 'true' or . = 'false' or . = '1' or . = '0'">
        Boolean value must be 'true', 'false', '1', or '0'.
        Found: '<value-of select="."/>'
      </assert>
    </rule>
    
    <rule context="*[@type='date']">
      <assert test="matches(., '^\d{4}-\d{2}-\d{2}$')">
        Date value '<value-of select="."/>' does not match YYYY-MM-DD format.
      </assert>
    </rule>
    
    <rule context="*[@type='anyURI']">
      <assert test="string-length(normalize-space(.)) &gt; 0">
        URI value cannot be empty.
      </assert>
    </rule>
    
    <rule context="*[@lang]">
      <assert test="matches(@lang, '^[a-z]{2,3}(-[A-Z]{2})?$')">
        Language tag '<value-of select="@lang"/>' should follow BCP 47 format (e.g., 'en', 'en-US', 'fr').
      </assert>
    </rule>
  </pattern>

  <!-- ================================================================
       SUMMARY REPORT
       ================================================================ -->
  
  <pattern id="document-summary">
    <title>Document Summary</title>
    <rule context="rdf:RDF">
      <report test="true()" role="info">
        Document validated: <value-of select="count(.//*[@rdf:about])"/> named resources, 
        <value-of select="count(rdf:context/rdf:prefix)"/> prefix definitions.
      </report>
    </rule>
  </pattern>

</schema>
