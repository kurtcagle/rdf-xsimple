# RDF-XSimple Specification

**A Modern, Simplified XML Serialization for RDF**

**Version:** 1.0.0-draft  
**Date:** January 2026  
**Editors:** Community-driven specification  
**Status:** Draft Specification  
**Format Name:** RDF-XSimple (RDF XML Simplified)  
**Former Name:** RDF/XML 2.0

## Abstract

RDF-XSimple (RDF XML Simplified) is a modernized serialization format for RDF (Resource Description Framework) that addresses limitations of the original RDF/XML specification while incorporating lessons learned from JSON-LD and contemporary RDF usage patterns. This specification defines a more readable, maintainable, and feature-rich XML serialization that supports RDF 1.2, RDF-star, and SHACL-informed practices.

RDF-XSimple maintains full compatibility with RDF/XML while offering significant improvements in conciseness (40-50% smaller files), readability, and developer experience.

## Table of Contents

1. [Introduction](#1-introduction)
2. [Design Goals](#2-design-goals)
3. [Namespace and Context Management](#3-namespace-and-context-management)
4. [Resource Representation](#4-resource-representation)
5. [Property Representation](#5-property-representation)
6. [Literal Values and Datatypes](#6-literal-values-and-datatypes)
7. [Denormalization and Inlining](#7-denormalization-and-inlining)
8. [Collections and Lists](#8-collections-and-lists)
9. [RDF-star Support](#9-rdf-star-support)
10. [CURIE Support](#10-curie-support)
11. [Compatibility and Migration](#11-compatibility-and-migration)
12. [Grammar](#12-grammar)
13. [Examples](#13-examples)

## 1. Introduction

### 1.1 Background

RDF/XML has been the primary XML serialization for RDF since 1999. While widely deployed, it has several limitations:

- Verbose namespace declarations scattered throughout documents
- Heavy reliance on RDFS constructs for basic features
- Limited support for modern RDF features (RDF-star, property paths)
- Unnecessarily normalized representations that reduce readability
- Inconsistent datatype handling

RDF-XSimple addresses these issues while maintaining the core strengths of XML: validation, streaming processing, and XSLT transformability.

### 1.2 Relationship to Other Specifications

RDF-XSimple is:
- **Compatible with**: RDF 1.2, RDF-star, SHACL
- **Inspired by**: JSON-LD (context management, framing), Turtle (CURIE syntax)
- **Transforms to/from**: Standard RDF/XML, Turtle, JSON-LD
- **Independent of**: RDFS (no required RDFS constructs)

### 1.3 Namespace

The RDF-XSimple namespace is:
```
http://www.w3.org/1999/02/22-rdf-syntax-ns#
```

Note: RDF-XSimple uses the same namespace as RDF/XML 1.0, with new optional elements and attributes for enhanced features.

## 2. Design Goals

### 2.1 Primary Goals

1. **Readability**: Human-readable documents without sacrificing machine processability
2. **Conciseness**: Reduce verbosity through intelligent defaults and modern syntax
3. **Denormalization**: Support hierarchical nesting for single-reference resources
4. **Modern RDF**: First-class support for RDF-star and contemporary patterns
5. **Backward Compatibility**: Lossless round-trip conversion with RDF/XML 1.0

### 2.2 Non-Goals

- Replacing JSON-LD or Turtle (complementary formats)
- Breaking compatibility with XML tools and processors
- Introducing non-RDF semantics

## 3. Namespace and Context Management

### 3.1 Context Block

RDF-XSimple introduces an explicit context block for namespace declarations:

```xml
<rdf:RDF>
  <rdf:context>
    <rdf:prefix name="schema" uri="http://schema.org/"/>
    <rdf:prefix name="ex" uri="http://example.org/"/>
    <rdf:prefix name="foaf" uri="http://xmlns.com/foaf/0.1/"/>
  </rdf:context>
  
  <!-- Resources follow -->
</rdf:RDF>
```

### 3.2 Context Properties

**Element**: `rdf:context`  
**Parent**: `rdf:RDF` (must be first child if present)  
**Children**: One or more `rdf:prefix` elements

**Element**: `rdf:prefix`  
**Attributes**:
- `name` (required): Prefix identifier (NCName)
- `uri` (required): Namespace URI

### 3.3 Traditional Namespace Declarations

Traditional XML namespace declarations remain valid:

```xml
<rdf:RDF 
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:schema="http://schema.org/">
  <!-- No rdf:context needed -->
</rdf:RDF>
```

Processors MUST support both mechanisms. When both are present, `rdf:context` takes precedence for CURIE expansion.

## 4. Resource Representation

### 4.1 Named Resources

Named resources use `rdf:about` to specify their IRI:

```xml
<schema:Person rdf:about="ex:alice">
  <schema:name>Alice Smith</schema:name>
</schema:Person>
```

### 4.2 Type-Based Element Names

When a resource has an `rdf:type`, the element name SHOULD use the type's QName:

```xml
<!-- Preferred -->
<schema:Person rdf:about="ex:alice">
  <!-- properties -->
</schema:Person>

<!-- Instead of -->
<rdf:Description rdf:about="ex:alice">
  <rdf:type rdf:resource="schema:Person"/>
  <!-- properties -->
</rdf:Description>
```

### 4.3 Blank Nodes

Resources without `rdf:about` are blank nodes:

```xml
<schema:Person>
  <schema:name>Anonymous</schema:name>
</schema:Person>
```

Blank node identifiers MAY be assigned by processors but are not required in the serialization.

## 5. Property Representation

### 5.1 Resource Properties

Properties with resource values use `rdf:resource`:

```xml
<schema:Person rdf:about="ex:alice">
  <schema:knows rdf:resource="ex:bob"/>
  <schema:employer rdf:resource="ex:acme"/>
</schema:Person>
```

### 5.2 Nested Resources

Resources MAY be nested directly as property values:

```xml
<schema:Person rdf:about="ex:alice">
  <schema:address>
    <schema:PostalAddress rdf:about="ex:addr1">
      <schema:streetAddress>123 Main St</schema:streetAddress>
    </schema:PostalAddress>
  </schema:address>
</schema:Person>
```

This creates the triples:
```turtle
ex:alice schema:address ex:addr1 .
ex:addr1 a schema:PostalAddress .
ex:addr1 schema:streetAddress "123 Main St" .
```

### 5.3 Multi-Value Properties

Multiple values are expressed through repeated properties:

```xml
<schema:Person rdf:about="ex:alice">
  <schema:knows rdf:resource="ex:bob"/>
  <schema:knows rdf:resource="ex:carol"/>
  <schema:knows rdf:resource="ex:dave"/>
</schema:Person>
```

**Optional shorthand** for multiple resource references:

```xml
<schema:Person rdf:about="ex:alice">
  <schema:knows rdf:resources="ex:bob ex:carol ex:dave"/>
</schema:Person>
```

## 6. Literal Values and Datatypes

### 6.1 Simple Literals

Text content represents simple string literals:

```xml
<schema:name>Alice Smith</schema:name>
```

### 6.2 Typed Literals - XSD Types

XSD datatypes use the simplified `type` attribute:

```xml
<schema:age type="integer">30</schema:age>
<schema:height type="decimal">1.75</schema:height>
<schema:active type="boolean">true</schema:active>
<schema:birthDate type="date">1995-03-15</schema:birthDate>
```

This is equivalent to:
```xml
<schema:age rdf:datatype="http://www.w3.org/2001/XMLSchema#integer">30</schema:age>
```

### 6.3 Typed Literals - Other Types

Non-XSD datatypes use `rdf:type` with CURIE or full URI:

```xml
<ex:coordinate rdf:type="geo:wktLiteral">POINT(-122.4194 37.7749)</ex:coordinate>
```

### 6.4 Language-Tagged Literals

Language tags use the `lang` attribute:

```xml
<schema:name lang="en">Alice Smith</schema:name>
<schema:name lang="fr">Alice Dupont</schema:name>
```

This is equivalent to:
```xml
<schema:name xml:lang="en">Alice Smith</schema:name>
```

### 6.5 Datatype Precedence

If both `type` and `lang` are present, `type` takes precedence (language is ignored).

## 7. Denormalization and Inlining

### 7.1 Single-Reference Optimization

Resources referenced exactly once in a dataset SHOULD be inlined at the point of reference:

**Normalized (separate resources):**
```xml
<schema:Person rdf:about="ex:alice">
  <schema:address rdf:resource="ex:addr1"/>
</schema:Person>

<schema:PostalAddress rdf:about="ex:addr1">
  <schema:streetAddress>123 Main St</schema:streetAddress>
</schema:PostalAddress>
```

**Denormalized (inlined):**
```xml
<schema:Person rdf:about="ex:alice">
  <schema:address>
    <schema:PostalAddress rdf:about="ex:addr1">
      <schema:streetAddress>123 Main St</schema:streetAddress>
    </schema:PostalAddress>
  </schema:address>
</schema:Person>
```

### 7.2 Preservation of Identity

**CRITICAL**: When inlining named resources, the `rdf:about` attribute MUST be preserved to maintain resource identity.

### 7.3 Inlining Constraints

Processors SHOULD NOT inline resources when:
1. Referenced by multiple subjects (reference count > 1)
2. Inlining would exceed a depth limit (recommended: 3 levels)
3. Resource is involved in circular references
4. Resource type is marked as non-inlinable by SHACL hints

### 7.4 SHACL Inlining Hints

Shapes MAY provide inlining guidance:

```turtle
ex:PersonShape a sh:NodeShape ;
  sh:property [
    sh:path schema:address ;
    sh:inline true ;  # Prefer inlining
  ] ;
  sh:property [
    sh:path schema:employer ;
    sh:inline false ;  # Keep as reference
  ] .
```

## 8. Collections and Lists

### 8.1 RDF Lists

RDF Lists (ordered sequences) use the `rdf:list` attribute:

```xml
<ex:shoppingList rdf:list="true">
  <ex:item>Milk</ex:item>
  <ex:item>Eggs</ex:item>
  <ex:item>Bread</ex:item>
</ex:shoppingList>
```

This creates an `rdf:List` structure:
```turtle
ex:shoppingList rdf:first "Milk" ;
  rdf:rest [ rdf:first "Eggs" ;
    rdf:rest [ rdf:first "Bread" ;
      rdf:rest rdf:nil ] ] .
```

### 8.2 Lists of Resources

Lists can contain resources:

```xml
<ex:authors rdf:list="true">
  <schema:Person rdf:about="ex:alice"/>
  <schema:Person rdf:about="ex:bob"/>
  <schema:Person rdf:about="ex:carol"/>
</ex:authors>
```

Or references:

```xml
<ex:authors rdf:list="true" rdf:resources="ex:alice ex:bob ex:carol"/>
```

### 8.3 Bags and Sequences

**Unordered Bags** use `rdf:bag="true"`:

```xml
<ex:keywords rdf:bag="true">
  <ex:keyword>RDF</ex:keyword>
  <ex:keyword>XML</ex:keyword>
  <ex:keyword>Semantic Web</ex:keyword>
</ex:keywords>
```

**Ordered Sequences** use `rdf:seq="true"`:

```xml
<ex:steps rdf:seq="true">
  <ex:step>Preheat oven</ex:step>
  <ex:step>Mix ingredients</ex:step>
  <ex:step>Bake for 30 minutes</ex:step>
</ex:steps>
```

### 8.4 List vs. Multiple Properties

**Multiple properties** (default behavior):
```xml
<ex:person rdf:about="ex:alice">
  <ex:skill>Python</ex:skill>
  <ex:skill>JavaScript</ex:skill>
  <ex:skill>Java</ex:skill>
</ex:person>
```

Creates three separate triples (unordered):
```turtle
ex:alice ex:skill "Python" .
ex:alice ex:skill "JavaScript" .
ex:alice ex:skill "Java" .
```

**RDF List** (ordered):
```xml
<ex:person rdf:about="ex:alice">
  <ex:skills rdf:list="true">
    <ex:skill>Python</ex:skill>
    <ex:skill>JavaScript</ex:skill>
    <ex:skill>Java</ex:skill>
  </ex:skills>
</ex:person>
```

Creates an ordered list structure.

### 8.5 List Compatibility

The `rdf:list` attribute replaces RDF/XML 1.0's `rdf:parseType="Collection"`:

```xml
<!-- RDF/XML 1.0 -->
<ex:items rdf:parseType="Collection">
  <rdf:Description rdf:about="ex:item1"/>
  <rdf:Description rdf:about="ex:item2"/>
</ex:items>

<!-- RDF-XSimple -->
<ex:items rdf:list="true">
  <rdf:Description rdf:about="ex:item1"/>
  <rdf:Description rdf:about="ex:item2"/>
</ex:items>
```

## 9. RDF-star Support

### 9.1 Quoted Triples

RDF-star quoted triples use the `rdf:QuotedTriple` element:

```xml
<ex:Statement rdf:about="ex:claim1">
  <rdf:quotes>
    <rdf:QuotedTriple>
      <rdf:subject rdf:resource="ex:alice"/>
      <rdf:predicate rdf:resource="schema:knows"/>
      <rdf:object rdf:resource="ex:bob"/>
    </rdf:QuotedTriple>
  </rdf:quotes>
  <ex:certainty type="decimal">0.85</ex:certainty>
  <ex:source rdf:resource="ex:survey2024"/>
</ex:Statement>
```

This represents:
```turtle
<<ex:alice schema:knows ex:bob>> ex:certainty 0.85 .
<<ex:alice schema:knows ex:bob>> ex:source ex:survey2024 .
```

### 9.2 Nested Quoted Triples

Quoted triples MAY be nested for complex annotations:

```xml
<rdf:QuotedTriple>
  <rdf:subject>
    <schema:Person rdf:about="ex:alice">
      <schema:name>Alice</schema:name>
    </schema:Person>
  </rdf:subject>
  <rdf:predicate rdf:resource="schema:knows"/>
  <rdf:object rdf:resource="ex:bob"/>
</rdf:QuotedTriple>
```

### 9.3 Compact Quoted Triple Syntax (Optional)

Processors MAY support a compact form:

```xml
<ex:claim rdf:quotedTriple="ex:alice schema:knows ex:bob" 
          ex:certainty="0.85"/>
```

## 10. CURIE Support

### 10.1 CURIE Syntax

CURIEs (Compact URIs) use the form `prefix:localName`:

```xml
<schema:Person rdf:about="ex:alice">
  <schema:knows rdf:resource="ex:bob"/>
</schema:Person>
```

### 10.2 CURIE Expansion

CURIEs are expanded using the context prefixes:
- `ex:alice` → `http://example.org/alice`
- `schema:Person` → `http://schema.org/Person`

### 10.3 Full URI Support

Full URIs remain valid and MAY be used:

```xml
<schema:Person rdf:about="http://example.org/alice">
  <schema:knows rdf:resource="http://example.org/bob"/>
</schema:Person>
```

### 10.4 CURIE Constraints

Valid CURIEs:
- MUST contain exactly one colon
- Prefix MUST be an NCName
- Local name MUST NOT contain characters requiring percent-encoding
- MUST NOT start with `http://`, `https://`, or `urn:`

Invalid as CURIEs (treated as full URIs):
- `http://example.org/alice` (full URI)
- `urn:isbn:1234567890` (URN scheme)
- `ex:name:with:colons` (multiple colons)

## 11. Compatibility and Migration

### 11.1 Forward Compatibility

RDF-XSimple documents are valid RDF/XML 1.0 documents with the following caveats:
- New elements (`rdf:context`, `rdf:QuotedTriple`) may not be recognized
- New attributes (`rdf:list`, `rdf:bag`, `rdf:seq`) may not be recognized
- CURIEs in `rdf:about` and `rdf:resource` require expansion

### 11.2 Backward Compatibility

RDF/XML 1.0 documents can be transformed to RDF-XSimple losslessly using XSLT transformations (see migration tools).

### 11.3 Triple Preservation

The transformation is **semantically lossless**: the set of RDF triples extracted from an RDF-XSimple document MUST be identical to those extracted from its RDF/XML 1.0 equivalent.

### 11.4 Migration Path

1. Parse existing RDF/XML 1.0 → RDF triples
2. Apply denormalization (optional)
3. Generate RDF-XSimple with CURIEs
4. Validate round-trip equivalence

## 12. Grammar

### 12.1 Document Structure

```ebnf
RDFXMLDoc ::= XMLDecl? RDF
RDF ::= '<rdf:RDF' NamespaceDecls? '>' Context? Resource* '</rdf:RDF>'
Context ::= '<rdf:context>' Prefix+ '</rdf:context>'
Prefix ::= '<rdf:prefix' 'name="' NCName '"' 'uri="' URI '"' '/>'
```

### 12.2 Resources

```ebnf
Resource ::= '<' QName About? '>' Property* '</' QName '>'
About ::= 'rdf:about="' (CURIE | URI) '"'
Property ::= LiteralProperty | ResourceProperty | NestedProperty | ListProperty
```

### 12.3 Properties

```ebnf
LiteralProperty ::= '<' QName TypeAttr? LangAttr? '>' Text '</' QName '>'
ResourceProperty ::= '<' QName ResourceAttr '/>'
NestedProperty ::= '<' QName '>' Resource '</' QName '>'
ListProperty ::= '<' QName ListAttr '>' Item+ '</' QName '>'

TypeAttr ::= 'type="' XSDType '"' | 'rdf:type="' (CURIE | URI) '"'
LangAttr ::= 'lang="' LanguageTag '"'
ResourceAttr ::= 'rdf:resource="' (CURIE | URI) '"'
ListAttr ::= 'rdf:list="true"' | 'rdf:bag="true"' | 'rdf:seq="true"'
```

### 12.4 Terminals

```ebnf
CURIE ::= NCName ':' LocalPart
NCName ::= [A-Za-z_][A-Za-z0-9_-]*
LocalPart ::= [A-Za-z0-9_\-\.]+
URI ::= /* Valid IRI per RFC 3987 */
XSDType ::= 'string' | 'integer' | 'decimal' | 'boolean' | 'date' | ...
LanguageTag ::= /* Valid BCP 47 language tag */
```

## 13. Examples

### 13.1 Simple Person

```xml
<?xml version="1.0" encoding="UTF-8"?>
<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
  <rdf:context>
    <rdf:prefix name="schema" uri="http://schema.org/"/>
    <rdf:prefix name="ex" uri="http://example.org/"/>
  </rdf:context>
  
  <schema:Person rdf:about="ex:alice">
    <schema:name>Alice Smith</schema:name>
    <schema:email>alice@example.com</schema:email>
    <schema:age type="integer">30</schema:age>
  </schema:Person>
</rdf:RDF>
```

### 13.2 Nested Resources

```xml
<?xml version="1.0" encoding="UTF-8"?>
<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
  <rdf:context>
    <rdf:prefix name="schema" uri="http://schema.org/"/>
    <rdf:prefix name="ex" uri="http://example.org/"/>
  </rdf:context>
  
  <schema:Person rdf:about="ex:alice">
    <schema:name>Alice Smith</schema:name>
    <schema:address>
      <schema:PostalAddress rdf:about="ex:addr1">
        <schema:streetAddress>123 Main St</schema:streetAddress>
        <schema:addressLocality>Portland</schema:addressLocality>
        <schema:postalCode>97201</schema:postalCode>
      </schema:PostalAddress>
    </schema:address>
  </schema:Person>
</rdf:RDF>
```

### 13.3 RDF Lists

```xml
<?xml version="1.0" encoding="UTF-8"?>
<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
  <rdf:context>
    <rdf:prefix name="ex" uri="http://example.org/"/>
  </rdf:context>
  
  <ex:Recipe rdf:about="ex:recipe1">
    <ex:name>Chocolate Chip Cookies</ex:name>
    
    <!-- Ordered list of steps -->
    <ex:steps rdf:list="true">
      <ex:step>Preheat oven to 375°F</ex:step>
      <ex:step>Mix dry ingredients</ex:step>
      <ex:step>Cream butter and sugar</ex:step>
      <ex:step>Combine wet and dry ingredients</ex:step>
      <ex:step>Bake for 10-12 minutes</ex:step>
    </ex:steps>
    
    <!-- Unordered bag of ingredients -->
    <ex:ingredients rdf:bag="true">
      <ex:ingredient>2 cups flour</ex:ingredient>
      <ex:ingredient>1 cup butter</ex:ingredient>
      <ex:ingredient>2 eggs</ex:ingredient>
      <ex:ingredient>1 cup chocolate chips</ex:ingredient>
    </ex:ingredients>
  </ex:Recipe>
</rdf:RDF>
```

### 13.4 RDF-star Example

```xml
<?xml version="1.0" encoding="UTF-8"?>
<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
  <rdf:context>
    <rdf:prefix name="schema" uri="http://schema.org/"/>
    <rdf:prefix name="ex" uri="http://example.org/"/>
  </rdf:context>
  
  <ex:Claim rdf:about="ex:claim1">
    <rdf:quotes>
      <rdf:QuotedTriple>
        <rdf:subject rdf:resource="ex:alice"/>
        <rdf:predicate rdf:resource="schema:knows"/>
        <rdf:object rdf:resource="ex:bob"/>
      </rdf:QuotedTriple>
    </rdf:quotes>
    <ex:confidence type="decimal">0.95</ex:confidence>
    <ex:source rdf:resource="ex:survey2024"/>
    <ex:reportedBy rdf:resource="ex:carol"/>
  </ex:Claim>
</rdf:RDF>
```

### 13.5 Multi-lingual Content

```xml
<?xml version="1.0" encoding="UTF-8"?>
<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
  <rdf:context>
    <rdf:prefix name="schema" uri="http://schema.org/"/>
    <rdf:prefix name="ex" uri="http://example.org/"/>
  </rdf:context>
  
  <schema:Book rdf:about="ex:book1">
    <schema:name lang="en">The Great Gatsby</schema:name>
    <schema:name lang="fr">Gatsby le Magnifique</schema:name>
    <schema:name lang="de">Der große Gatsby</schema:name>
    <schema:author rdf:resource="ex:fitzgerald"/>
    <schema:datePublished type="date">1925-04-10</schema:datePublished>
  </schema:Book>
</rdf:RDF>
```

## Appendices

### A. MIME Type

The MIME type for RDF-XSimple is:
```
application/rdf+xml
```

The same as RDF/XML 1.0, with optional version parameter:
```
application/rdf+xml; version=2.0
```

### B. File Extension

Recommended file extension: `.rdf`

### C. Change Log

**Version 1.0.0-draft (January 2026)**
- Initial specification
- Context-based namespace management
- CURIE support
- Simplified datatype syntax
- RDF-star integration
- Denormalization guidelines

### D. Acknowledgments

This specification builds on the work of the RDF Working Group and incorporates lessons learned from JSON-LD, Turtle, and years of RDF/XML usage in production systems.

### E. References

- **[RDF 1.1]** RDF 1.1 Concepts and Abstract Syntax, W3C Recommendation
- **[RDF-STAR]** RDF-star and SPARQL-star, W3C Community Group Report
- **[JSON-LD]** JSON-LD 1.1, W3C Recommendation
- **[TURTLE]** RDF 1.1 Turtle, W3C Recommendation
- **[SHACL]** Shapes Constraint Language (SHACL), W3C Recommendation
- **[RFC 3987]** Internationalized Resource Identifiers (IRIs)
- **[BCP 47]** Tags for Identifying Languages

---

**Copyright © 2026. This document is available under the W3C Document License.**
