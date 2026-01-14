# RDF-XSimple Best Practices

Guidelines for writing clear, maintainable, and efficient RDF-XSimple documents.

## Table of Contents

1. [General Principles](#general-principles)
2. [Namespace Management](#namespace-management)
3. [Resource Naming](#resource-naming)
4. [Datatype Usage](#datatype-usage)
5. [Denormalization Strategy](#denormalization-strategy)
6. [Lists and Collections](#lists-and-collections)
7. [RDF-star Patterns](#rdf-star-patterns)
8. [Performance Optimization](#performance-optimization)
9. [Readability](#readability)

## General Principles

### Keep It Simple

✅ **Good** - Clear and concise:
```xml
<schema:Person rdf:about="ex:alice">
  <schema:name>Alice Smith</schema:name>
  <schema:age type="integer">30</schema:age>
</schema:Person>
```

❌ **Avoid** - Unnecessary complexity:
```xml
<rdf:Description rdf:about="ex:alice">
  <rdf:type rdf:resource="schema:Person"/>
  <schema:name rdf:datatype="http://www.w3.org/2001/XMLSchema#string">Alice Smith</schema:name>
</rdf:Description>
```

### Be Consistent

Choose conventions and stick to them:
- CURIE prefixes (`ex:`, `schema:`)
- Inlining depth
- Blank node vs. named resource decisions

## Namespace Management

### Use Context Block

✅ **Preferred** - Centralized context:
```xml
<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
  <rdf:context>
    <rdf:prefix name="schema" uri="http://schema.org/"/>
    <rdf:prefix name="ex" uri="http://example.org/"/>
    <rdf:prefix name="foaf" uri="http://xmlns.com/foaf/0.1/"/>
  </rdf:context>
  <!-- resources -->
</rdf:RDF>
```

### Choose Meaningful Prefixes

| ✅ Good | ❌ Avoid |
|---------|----------|
| `schema:` | `s:` |
| `ex:` | `x:` |
| `foaf:` | `f:` |
| `org:` | `o:` |

### Common Prefixes

Standard prefixes for common vocabularies:

```xml
<rdf:context>
  <!-- Schema.org -->
  <rdf:prefix name="schema" uri="http://schema.org/"/>
  
  <!-- FOAF -->
  <rdf:prefix name="foaf" uri="http://xmlns.com/foaf/0.1/"/>
  
  <!-- Dublin Core -->
  <rdf:prefix name="dc" uri="http://purl.org/dc/elements/1.1/"/>
  <rdf:prefix name="dcterms" uri="http://purl.org/dc/terms/"/>
  
  <!-- SKOS -->
  <rdf:prefix name="skos" uri="http://www.w3.org/2004/02/skos/core#"/>
  
  <!-- OWL -->
  <rdf:prefix name="owl" uri="http://www.w3.org/2002/07/owl#"/>
  
  <!-- Your domain -->
  <rdf:prefix name="ex" uri="http://example.org/"/>
</rdf:context>
```

## Resource Naming

### Use Type-Based Element Names

✅ **Preferred**:
```xml
<schema:Person rdf:about="ex:alice">
  <schema:name>Alice</schema:name>
</schema:Person>
```

❌ **Avoid** (unless type is unknown):
```xml
<rdf:Description rdf:about="ex:alice">
  <rdf:type rdf:resource="schema:Person"/>
  <schema:name>Alice</schema:name>
</rdf:Description>
```

### URI Design

Good URI patterns:

```xml
<!-- People -->
<schema:Person rdf:about="ex:people/alice-smith">

<!-- Organizations -->
<schema:Organization rdf:about="ex:orgs/acme-corp">

<!-- Products -->
<schema:Product rdf:about="ex:products/widget-2000">

<!-- Hierarchical -->
<schema:PostalAddress rdf:about="ex:locations/usa/ca/san-francisco/addr-123">
```

### Use Meaningful IDs

| ✅ Good | ❌ Avoid |
|---------|----------|
| `ex:alice-smith` | `ex:person1` |
| `ex:acme-corp` | `ex:org-42` |
| `ex:2024-report` | `ex:doc_xyz` |

## Datatype Usage

### Prefer Simplified Types

✅ **Good** - Clean XSD types:
```xml
<schema:age type="integer">30</schema:age>
<schema:height type="decimal">1.75</schema:height>
<schema:active type="boolean">true</schema:active>
<schema:birthDate type="date">1995-03-15</schema:birthDate>
<schema:lastModified type="dateTime">2024-01-15T10:30:00Z</schema:lastModified>
```

❌ **Avoid** - Verbose full URIs:
```xml
<schema:age rdf:datatype="http://www.w3.org/2001/XMLSchema#integer">30</schema:age>
```

### Common XSD Types

| Type | Usage | Example |
|------|-------|---------|
| `integer` | Whole numbers | `42`, `-17`, `0` |
| `decimal` | Precise decimals | `3.14159`, `0.01` |
| `float` | Floating point | `1.23e5` |
| `boolean` | True/false | `true`, `false` |
| `date` | Calendar date | `2024-01-15` |
| `dateTime` | Date and time | `2024-01-15T10:30:00Z` |
| `time` | Time of day | `14:30:00` |
| `string` | Text (default) | `Hello World` |
| `anyURI` | URIs | `https://example.com` |

### String Literals

Simple strings don't need a datatype:

✅ **Good**:
```xml
<schema:name>Alice Smith</schema:name>
<schema:description>A software engineer</schema:description>
```

❌ **Avoid**:
```xml
<schema:name type="string">Alice Smith</schema:name>
```

### Language Tags

Use `lang` for multilingual content:

```xml
<schema:name lang="en">Alice Smith</schema:name>
<schema:name lang="fr">Alice Dupont</schema:name>
<schema:name lang="de">Alice Schmidt</schema:name>
```

## Denormalization Strategy

### When to Inline

✅ **Inline when:**
- Resource has exactly one incoming reference
- Nesting depth < 3 levels
- Resource is a "value object" (address, contact point)
- Improves readability

```xml
<schema:Person rdf:about="ex:alice">
  <schema:address>
    <schema:PostalAddress rdf:about="ex:addr1">
      <schema:streetAddress>123 Main St</schema:streetAddress>
    </schema:PostalAddress>
  </schema:address>
</schema:Person>
```

### When to Reference

❌ **Keep as reference when:**
- Resource has multiple incoming references
- Resource is reused across the dataset
- Would create deep nesting (>3 levels)
- Resource is a "shared entity" (person, organization)

```xml
<schema:Person rdf:about="ex:alice">
  <schema:worksFor rdf:resource="ex:acme"/>
</schema:Person>

<schema:Person rdf:about="ex:bob">
  <schema:worksFor rdf:resource="ex:acme"/>
</schema:Person>

<schema:Organization rdf:about="ex:acme">
  <schema:name>Acme Corp</schema:name>
</schema:Organization>
```

### Preserve Identity

**CRITICAL**: Always include `rdf:about` when inlining named resources:

✅ **Correct**:
```xml
<schema:Person rdf:about="ex:alice">
  <schema:address>
    <schema:PostalAddress rdf:about="ex:addr1">
      <schema:streetAddress>123 Main St</schema:streetAddress>
    </schema:PostalAddress>
  </schema:address>
</schema:Person>
```

❌ **Wrong** (loses resource identity):
```xml
<schema:Person rdf:about="ex:alice">
  <schema:address>
    <schema:PostalAddress>  <!-- Missing rdf:about! -->
      <schema:streetAddress>123 Main St</schema:streetAddress>
    </schema:PostalAddress>
  </schema:address>
</schema:Person>
```

### Depth Limits

Recommended maximum nesting depth: **3 levels**

```xml
<!-- Level 1: Person -->
<schema:Person rdf:about="ex:alice">
  <!-- Level 2: Address -->
  <schema:address>
    <schema:PostalAddress rdf:about="ex:addr1">
      <!-- Level 3: Country -->
      <schema:addressCountry>
        <schema:Country rdf:about="ex:usa">
          <schema:name>USA</schema:name>
          <!-- Stop here - don't go deeper -->
        </schema:Country>
      </schema:addressCountry>
    </schema:PostalAddress>
  </schema:address>
</schema:Person>
```

## Lists and Collections

### When to Use Lists

Use `rdf:list="true"` for **ordered sequences** where order matters:

✅ **Good use cases:**
- Step-by-step instructions
- Ranked preferences
- Dependencies (build order, prerequisites)
- Chronological sequences
- Playlists

```xml
<ex:Recipe rdf:about="ex:cookies">
  <schema:recipeInstructions rdf:list="true">
    <ex:step>Preheat oven to 375°F</ex:step>
    <ex:step>Mix dry ingredients</ex:step>
    <ex:step>Cream butter and sugar</ex:step>
    <ex:step>Bake for 10-12 minutes</ex:step>
  </schema:recipeInstructions>
</ex:Recipe>
```

### When to Use Bags

Use `rdf:bag="true"` for **unordered collections** where order doesn't matter:

✅ **Good use cases:**
- Tags/keywords
- Ingredients (when order doesn't matter)
- Sets of options
- Unranked items

```xml
<ex:Article rdf:about="ex:article1">
  <schema:keywords rdf:bag="true">
    <schema:keyword>RDF</schema:keyword>
    <schema:keyword>Semantic Web</schema:keyword>
    <schema:keyword>XML</schema:keyword>
  </schema:keywords>
</ex:Article>
```

### When to Use Sequences

Use `rdf:seq="true"` for **explicitly ordered collections**:

```xml
<schema:MusicPlaylist rdf:about="ex:playlist1">
  <schema:track rdf:seq="true">
    <schema:MusicRecording rdf:about="ex:song1"/>
    <schema:MusicRecording rdf:about="ex:song2"/>
    <schema:MusicRecording rdf:about="ex:song3"/>
  </schema:track>
</schema:MusicPlaylist>
```

### Lists vs. Multiple Properties

**Multiple properties** (default):
```xml
<schema:Person rdf:about="ex:alice">
  <ex:skill>Python</ex:skill>
  <ex:skill>JavaScript</ex:skill>
  <ex:skill>Java</ex:skill>
</schema:Person>
```

Creates separate triples (no inherent order):
```turtle
ex:alice ex:skill "Python" .
ex:alice ex:skill "JavaScript" .
ex:alice ex:skill "Java" .
```

**RDF List** (ordered):
```xml
<schema:Person rdf:about="ex:alice">
  <ex:skillsRanked rdf:list="true">
    <ex:skill>Python</ex:skill>
    <ex:skill>JavaScript</ex:skill>
    <ex:skill>Java</ex:skill>
  </ex:skillsRanked>
</schema:Person>
```

Creates linked list structure (order preserved):
```turtle
ex:alice ex:skillsRanked _:list1 .
_:list1 rdf:first "Python" ;
  rdf:rest _:list2 .
_:list2 rdf:first "JavaScript" ;
  rdf:rest _:list3 .
_:list3 rdf:first "Java" ;
  rdf:rest rdf:nil .
```

### List Shorthand

For lists of resources, use `rdf:resources` shorthand:

```xml
<!-- Long form -->
<ex:authors rdf:list="true">
  <schema:Person rdf:resource="ex:alice"/>
  <schema:Person rdf:resource="ex:bob"/>
  <schema:Person rdf:resource="ex:carol"/>
</ex:authors>

<!-- Shorthand -->
<ex:authors rdf:list="true" rdf:resources="ex:alice ex:bob ex:carol"/>
```

### List Guidelines

1. **Use lists sparingly** - Only when order truly matters
2. **Prefer multiple properties** - For unordered, independent values
3. **Consider maintenance** - Lists are harder to update than separate properties
4. **Document intent** - Comment why a list is needed

## RDF-star Patterns

### Statement Annotations

Use quoted triples for metadata about statements:

```xml
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
  <ex:reportedDate type="dateTime">2024-01-15T10:30:00Z</ex:reportedDate>
</ex:Claim>
```

### Provenance Tracking

```xml
<ex:Measurement rdf:about="ex:m1">
  <rdf:quotes>
    <rdf:QuotedTriple>
      <rdf:subject rdf:resource="ex:sensor123"/>
      <rdf:predicate rdf:resource="ex:temperature"/>
      <rdf:object>23.5</rdf:object>
    </rdf:QuotedTriple>
  </rdf:quotes>
  <ex:measuredAt type="dateTime">2024-01-15T14:30:00Z</ex:measuredAt>
  <ex:accuracy type="decimal">0.1</ex:accuracy>
  <ex:unit>celsius</ex:unit>
</ex:Measurement>
```

### Temporal Validity

```xml
<ex:TemporalFact rdf:about="ex:fact1">
  <rdf:quotes>
    <rdf:QuotedTriple>
      <rdf:subject rdf:resource="ex:alice"/>
      <rdf:predicate rdf:resource="schema:worksFor"/>
      <rdf:object rdf:resource="ex:acme"/>
    </rdf:QuotedTriple>
  </rdf:quotes>
  <ex:validFrom type="date">2020-01-15</ex:validFrom>
  <ex:validUntil type="date">2025-12-31</ex:validUntil>
</ex:TemporalFact>
```

## Performance Optimization

### File Size

Minimize file size:

```xml
<!-- Compact: ~200 bytes -->
<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
  <rdf:context>
    <rdf:prefix name="schema" uri="http://schema.org/"/>
    <rdf:prefix name="ex" uri="http://example.org/"/>
  </rdf:context>
  <schema:Person rdf:about="ex:alice">
    <schema:name>Alice</schema:name>
  </schema:Person>
</rdf:RDF>

<!-- Verbose: ~350 bytes -->
<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
         xmlns:schema="http://schema.org/">
  <rdf:Description rdf:about="http://example.org/alice">
    <rdf:type rdf:resource="http://schema.org/Person"/>
    <schema:name rdf:datatype="http://www.w3.org/2001/XMLSchema#string">Alice</schema:name>
  </rdf:Description>
</rdf:RDF>
```

Savings: **43% smaller**

### Streaming

Structure for streaming parsers:

```xml
<rdf:RDF>
  <rdf:context>
    <!-- All prefixes upfront -->
  </rdf:context>
  
  <!-- Resources in logical order -->
  <!-- Most important first -->
  <schema:Person rdf:about="ex:alice">...</schema:Person>
  <schema:Person rdf:about="ex:bob">...</schema:Person>
  <!-- Supporting entities last -->
  <schema:Organization rdf:about="ex:acme">...</schema:Organization>
</rdf:RDF>
```

### Batch Processing

Group related resources:

```xml
<rdf:RDF>
  <rdf:context>...</rdf:context>
  
  <!-- All people together -->
  <schema:Person rdf:about="ex:alice">...</schema:Person>
  <schema:Person rdf:about="ex:bob">...</schema:Person>
  
  <!-- All organizations together -->
  <schema:Organization rdf:about="ex:acme">...</schema:Organization>
  <schema:Organization rdf:about="ex:globex">...</schema:Organization>
</rdf:RDF>
```

## Readability

### Indentation

Use consistent 2-space indentation:

```xml
<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
  <rdf:context>
    <rdf:prefix name="schema" uri="http://schema.org/"/>
  </rdf:context>
  
  <schema:Person rdf:about="ex:alice">
    <schema:name>Alice Smith</schema:name>
    <schema:address>
      <schema:PostalAddress rdf:about="ex:addr1">
        <schema:streetAddress>123 Main St</schema:streetAddress>
      </schema:PostalAddress>
    </schema:address>
  </schema:Person>
</rdf:RDF>
```

### Comments

Add comments for complex structures:

```xml
<!-- Employee records -->
<schema:Person rdf:about="ex:alice">
  <schema:name>Alice Smith</schema:name>
  
  <!-- Primary work location -->
  <schema:workLocation>
    <schema:PostalAddress rdf:about="ex:addr1">
      <schema:streetAddress>123 Main St</schema:streetAddress>
    </schema:PostalAddress>
  </schema:workLocation>
  
  <!-- Shared organization (referenced by 500+ employees) -->
  <schema:worksFor rdf:resource="ex:acme"/>
</schema:Person>
```

### Blank Lines

Use blank lines to separate logical groups:

```xml
<rdf:RDF>
  <rdf:context>
    <rdf:prefix name="schema" uri="http://schema.org/"/>
  </rdf:context>
  
  <!-- Group 1: Core team -->
  <schema:Person rdf:about="ex:alice">...</schema:Person>
  <schema:Person rdf:about="ex:bob">...</schema:Person>
  
  <!-- Group 2: Organizations -->
  <schema:Organization rdf:about="ex:acme">...</schema:Organization>
  
  <!-- Group 3: Locations -->
  <schema:Country rdf:about="ex:usa">...</schema:Country>
</rdf:RDF>
```

### Property Ordering

Order properties logically:

1. Name/title (most important)
2. Type-specific properties
3. Relationships
4. Metadata (dates, IDs)

```xml
<schema:Person rdf:about="ex:alice">
  <!-- 1. Name -->
  <schema:name>Alice Smith</schema:name>
  <schema:givenName>Alice</schema:givenName>
  <schema:familyName>Smith</schema:familyName>
  
  <!-- 2. Person-specific -->
  <schema:email>alice@example.com</schema:email>
  <schema:telephone>+1-555-0123</schema:telephone>
  <schema:birthDate type="date">1995-03-15</schema:birthDate>
  
  <!-- 3. Relationships -->
  <schema:worksFor rdf:resource="ex:acme"/>
  <schema:knows rdf:resource="ex:bob"/>
  
  <!-- 4. Metadata -->
  <schema:identifier>EMP-12345</schema:identifier>
  <schema:dateCreated type="dateTime">2024-01-15T10:00:00Z</schema:dateTime>
</schema:Person>
```

## Validation Checklist

Before publishing RDF-XSimple:

- [ ] Context block is first child of `<rdf:RDF>`
- [ ] All CURIEs have defined prefixes
- [ ] XSD datatypes use `type` attribute
- [ ] Language tags use `lang` attribute  
- [ ] Named resources preserve `rdf:about` when inlined
- [ ] Nesting depth ≤ 3 levels
- [ ] Round-trip test passes
- [ ] File validates against schema
- [ ] Comments explain complex patterns

## Tools

Recommended tools for RDF-XSimple:

- **XSLT Processor**: Saxon HE (free) or PE/EE
- **XML Editor**: Oxygen XML, VS Code with XML extension
- **Validation**: Rapper, RDF4J, Apache Jena
- **Diff**: xmldiff, Beyond Compare
- **Version Control**: Git with XML-aware diff

## Further Reading

- [SPECIFICATION.md](../SPECIFICATION.md) - Complete specification
- [MIGRATION.md](MIGRATION.md) - Migration guide
- [FAQ.md](FAQ.md) - Frequently asked questions
- [Examples](../examples/) - Sample documents

---

**Questions?** Open an issue on [GitHub](https://github.com/yourusername/rdfxml2-spec/issues).
