# RDF-XSimple Examples

This directory contains example documents demonstrating various features of RDF-XSimple.

## Files

### comparison-rdfxml-vs-xsimple.rdf

**Demonstrates:**
- Side-by-side comparison of traditional RDF/XML vs. modern RDF-XSimple
- Identical RDF data serialized both ways in one document
- All major feature differences highlighted
- 43% file size reduction (1850 bytes vs. 1050 bytes)

**Key Comparisons:**
- Namespace declarations: `xmlns` vs. context block
- Resource identifiers: Full URIs vs. CURIEs
- Datatypes: Verbose URIs vs. `type="integer"`
- Language tags: `xml:lang` vs. `lang`
- Type declarations: `rdf:Description + rdf:type` vs. `<schema:Person>`
- Structure: Normalized vs. denormalized
- Lists: `parseType="Collection"` vs. `rdf:list="true"`
- RDF-star: Not supported vs. native support

**Use Case:** Understanding migration benefits, teaching RDF-XSimple, documentation

---

### simple-person.rdf

**Demonstrates:**
- Basic resource structure
- Context-based namespace declarations
- CURIEs for resource identifiers
- Simplified datatype syntax
- Type-based element names

**Key Features:**
```xml
<schema:Person rdf:about="ex:alice">
  <schema:name>Alice Smith</schema:name>
  <schema:age type="integer">30</schema:age>
  <schema:height type="decimal">1.75</schema:height>
  <schema:birthDate type="date">1995-03-15</schema:birthDate>
</schema:Person>
```

**Use Case:** Basic entity representation

---

### nested-resources.rdf

**Demonstrates:**
- Resource denormalization (inlining)
- Preservation of resource identity with `rdf:about`
- Multi-level nesting (up to 3 levels)
- Mixed inlining and references
- Shared vs. unique resources

**Key Features:**
```xml
<schema:Person rdf:about="ex:alice">
  <schema:address>
    <schema:PostalAddress rdf:about="ex:addr1">
      <schema:streetAddress>123 Main Street</schema:streetAddress>
      <schema:addressCountry>
        <schema:Country rdf:about="ex:usa">
          <schema:name>United States</schema:name>
        </schema:Country>
      </schema:addressCountry>
    </schema:PostalAddress>
  </schema:address>
  <schema:worksFor rdf:resource="ex:acme"/>
</schema:Person>
```

**Use Case:** Hierarchical data, organizational structures

---

### rdf-star-example.rdf

**Demonstrates:**
- RDF-star quoted triples
- Statement annotations
- Provenance tracking
- Confidence scores
- Temporal validity

**Key Features:**
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
  <ex:reportedDate type="dateTime">2024-12-01T10:30:00Z</ex:reportedDate>
</ex:Claim>
```

**Use Case:** Data provenance, metadata about statements, knowledge graphs with confidence

---

### multilingual.rdf

**Demonstrates:**
- Language-tagged literals with `lang` attribute
- Multiple language variants
- Mixed language content
- International organization data

**Key Features:**
```xml
<schema:Book rdf:about="ex:book1">
  <schema:name lang="en">The Great Gatsby</schema:name>
  <schema:name lang="fr">Gatsby le Magnifique</schema:name>
  <schema:name lang="de">Der große Gatsby</schema:name>
  <schema:name lang="es">El Gran Gatsby</schema:name>
  <schema:name lang="ja">グレート・ギャツビー</schema:name>
</schema:Book>
```

**Use Case:** International applications, multilingual content, localization

---

### lists-and-collections.rdf

**Demonstrates:**
- Ordered lists with `rdf:list="true"`
- Unordered bags with `rdf:bag="true"`
- Ordered sequences with `rdf:seq="true"`
- Lists vs. multiple properties
- Lists of resources vs. literals
- `rdf:resources` shorthand for reference lists

**Key Features:**
```xml
<!-- Ordered list -->
<ex:Recipe rdf:about="ex:cookies">
  <schema:recipeInstructions rdf:list="true">
    <ex:step>Preheat oven</ex:step>
    <ex:step>Mix ingredients</ex:step>
    <ex:step>Bake</ex:step>
  </schema:recipeInstructions>
  
  <!-- Unordered bag -->
  <schema:ingredients rdf:bag="true">
    <ex:ingredient>flour</ex:ingredient>
    <ex:ingredient>sugar</ex:ingredient>
    <ex:ingredient>eggs</ex:ingredient>
  </schema:ingredients>
</ex:Recipe>
```

**Use Case:** Recipes, playlists, ordered instructions, unordered collections

---

### complex-organization.rdf

**Demonstrates:**
- Real-world organizational structures
- Multiple entity relationships
- Shared resources with multiple references
- Department hierarchies
- Employee-organization relationships

**Key Features:**
```xml
<schema:Organization rdf:about="ex:acme">
  <schema:name>Acme Corporation</schema:name>
  <schema:employee rdf:resource="ex:alice"/>
  <schema:employee rdf:resource="ex:bob"/>
  <schema:employee rdf:resource="ex:carol"/>
  <schema:department rdf:resource="ex:engineering"/>
  <schema:department rdf:resource="ex:sales"/>
</schema:Organization>
```

**Use Case:** Enterprise systems, org charts, HR data

---

## Usage

### Viewing Examples

Simply open any `.rdf` file in:
- Text editor
- XML editor (Oxygen XML, VS Code)
- Web browser (may need XML viewer plugin)

### Parsing Examples

Using Rapper (part of Raptor RDF Syntax Library):

```bash
# Parse and validate
rapper -i rdfxml simple-person.rdf

# Convert to N-Triples
rapper -i rdfxml simple-person.rdf -o ntriples

# Convert to Turtle
rapper -i rdfxml nested-resources.rdf -o turtle
```

Using Python (rdflib):

```python
from rdflib import Graph

# Load and parse
g = Graph()
g.parse('simple-person.rdf', format='xml')

# Print triples
for s, p, o in g:
    print(f"{s} {p} {o}")

# Serialize to another format
print(g.serialize(format='turtle'))
```

Using JavaScript (N3.js):

```javascript
const N3 = require('n3');
const fs = require('fs');

const parser = new N3.Parser({ format: 'application/rdf+xml' });
const rdf = fs.readFileSync('simple-person.rdf', 'utf8');

parser.parse(rdf, (error, quad) => {
  if (quad)
    console.log(quad);
  else if (error)
    console.error(error);
});
```

### Testing Transformations

Test the XSLT transformations using these examples:

```bash
# Convert example from RDF/XML 1.0 to 2.0
saxon -s:examples/simple-person.rdf \
      -xsl:xslt/rdfxml1-to-rdfxml2.xsl \
      -o:output.rdf

# Convert back
saxon -s:output.rdf \
      -xsl:xslt/rdfxml2-to-rdfxml1.xsl \
      -o:roundtrip.rdf

# Compare (should be semantically equivalent)
diff examples/simple-person.rdf roundtrip.rdf
```

## Creating Your Own Examples

### Template

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!--
  Example Title
  
  Demonstrates: [list features]
  Use Case: [describe use case]
-->
<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
  <rdf:context>
    <rdf:prefix name="schema" uri="http://schema.org/"/>
    <rdf:prefix name="ex" uri="http://example.org/"/>
    <!-- Add other prefixes as needed -->
  </rdf:context>
  
  <!-- Your resources here -->
  
</rdf:RDF>
```

### Guidelines

1. **Add descriptive comments** explaining what the example demonstrates
2. **Use realistic data** (names, dates, values)
3. **Keep it focused** - demonstrate one or two features clearly
4. **Include variety** - different datatypes, structures, patterns
5. **Document edge cases** - special characters, empty values, etc.

### Submitting Examples

We welcome example contributions! To submit:

1. Create your example following the template
2. Add a description to this README
3. Test that it parses correctly
4. Submit a pull request

See [CONTRIBUTING.md](../CONTRIBUTING.md) for details.

## Example Use Cases

### By Industry

| Industry | Example | Key Features |
|----------|---------|--------------|
| Publishing | multilingual.rdf | Language tags, metadata |
| Enterprise | complex-organization.rdf | Hierarchies, relationships |
| Research | rdf-star-example.rdf | Provenance, confidence |
| E-commerce | (needed) | Products, prices, inventory |
| Healthcare | (needed) | Patients, treatments, records |
| Government | (needed) | Legislation, regulations |

### By Pattern

| Pattern | Example | Description |
|---------|---------|-------------|
| Simple entities | simple-person.rdf | Basic resources with properties |
| Hierarchical data | nested-resources.rdf | Nested structures |
| Shared resources | complex-organization.rdf | Multiple references |
| Metadata | rdf-star-example.rdf | Statements about statements |
| Localization | multilingual.rdf | Multiple languages |
| Time series | (needed) | Temporal data |
| Geospatial | (needed) | Location data |

## Learning Path

**Beginner:**
1. Start with `simple-person.rdf` - understand basic structure
2. Review `nested-resources.rdf` - learn about denormalization
3. Explore `multilingual.rdf` - see language handling

**Intermediate:**
4. Study `complex-organization.rdf` - real-world patterns
5. Understand `rdf-star-example.rdf` - statement annotations

**Advanced:**
6. Create your own examples
7. Combine multiple patterns
8. Contribute back to the project

## Validation

All examples are validated to ensure:
- Well-formed XML
- Valid RDF-XSimple syntax
- Correct CURIE expansion
- Semantic equivalence with RDF/XML 1.0

To validate examples:

```bash
# XML well-formedness
xmllint --noout examples/simple-person.rdf

# RDF parsing
rapper -i rdfxml examples/simple-person.rdf -o ntriples > /dev/null

# Round-trip test
./test-roundtrip.sh examples/simple-person.rdf
```

## Additional Resources

- **Specification**: [SPECIFICATION.md](../SPECIFICATION.md)
- **Best Practices**: [docs/BEST_PRACTICES.md](../docs/BEST_PRACTICES.md)
- **Migration Guide**: [docs/MIGRATION.md](../docs/MIGRATION.md)
- **FAQ**: [docs/FAQ.md](../docs/FAQ.md)

## Contributing

Have an example that would help others? Please contribute!

1. Create your example
2. Add it to this directory
3. Update this README
4. Submit a pull request

See [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines.

## License

All examples are released under the MIT License - see [LICENSE](../LICENSE).
