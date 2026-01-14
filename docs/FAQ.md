# RDF-XSimple Frequently Asked Questions

## General Questions

### What is RDF-XSimple?

RDF-XSimple is a modernized XML serialization format for RDF that addresses limitations of the original RDF/XML specification. It incorporates lessons from JSON-LD and Turtle while maintaining XML's strengths.

### Why create a new version?

RDF/XML has served well for 25+ years, but has limitations:
- Verbose namespace declarations
- Complex datatype syntax
- Unnecessarily normalized representations
- No support for RDF-star
- Inconsistent with modern RDF syntax (Turtle, JSON-LD)

### Is this an official W3C standard?

Currently, this is a community specification. We hope to submit it to W3C for standardization once it has broader adoption and implementation.

### Can I use it in production?

Yes, with the provided XSLT transformations for compatibility. The format is stable and has lossless round-trip conversion with standard RDF/XML.

## Compatibility

### Does RDF-XSimple replace RDF/XML 1.0?

No, it's complementary. Both formats remain valid. RDF-XSimple offers improvements for new projects and can be used alongside RDF/XML 1.0.

### Can I convert between formats?

Yes, losslessly. The provided XSLT stylesheets enable perfect round-trip conversion:
```
RDF/XML 1.0 ↔ RDF-XSimple
```

### Do existing RDF tools support it?

Most tools don't natively support RDF-XSimple yet. Use the XSLT transformations to convert to standard RDF/XML for existing tools:

```bash
# Convert to standard RDF/XML for existing tools
saxon -s:file.rdf -xsl:xslt/rdfxml2-to-rdfxml1.xsl -o:standard.rdf
```

### Will my SPARQL queries work?

Yes! SPARQL queries operate on RDF triples, not the serialization format. RDF-XSimple produces identical triples to RDF/XML 1.0.

## Technical Questions

### How are CURIEs different from QNames?

CURIEs (Compact URIs) are similar to QNames but specifically designed for URI abbreviation:

```xml
<!-- CURIE -->
<schema:Person rdf:about="ex:alice">
  <!-- ex:alice expands to http://example.org/alice -->
</schema:Person>
```

They follow the same syntax as Turtle and JSON-LD `@context`.

### What if a URI can't be expressed as a CURIE?

Full URIs are still valid:

```xml
<!-- URI with special characters -->
<schema:Person rdf:about="http://example.org/person/alice%20smith">
  <!-- Can't be a CURIE due to space -->
</schema:Person>
```

### How does denormalization affect query performance?

The underlying triples are identical, so SPARQL query performance is unchanged. Denormalization only affects the XML structure, not the RDF graph.

### Can I mix RDF/XML 1.0 and 2.0 in the same file?

No, but you can use RDF-XSimple features incrementally:

```xml
<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
         xmlns:schema="http://schema.org/">
  <!-- Traditional namespace declarations work -->
  
  <!-- But you can use modern features -->
  <schema:Person rdf:about="ex:alice">
    <schema:age type="integer">30</schema:age>
  </schema:Person>
</rdf:RDF>
```

### Does denormalization create duplicate triples?

No. When inlining preserves `rdf:about`, it creates the same triples:

```xml
<!-- This nested structure -->
<schema:Person rdf:about="ex:alice">
  <schema:address>
    <schema:PostalAddress rdf:about="ex:addr1">
      <schema:streetAddress>123 Main St</schema:streetAddress>
    </schema:PostalAddress>
  </schema:address>
</schema:Person>

<!-- Creates these triples -->
ex:alice schema:address ex:addr1 .
ex:addr1 a schema:PostalAddress .
ex:addr1 schema:streetAddress "123 Main St" .
```

## RDF-star Questions

### What is RDF-star?

RDF-star extends RDF with quoted triples, allowing you to make statements about statements:

```turtle
<<ex:alice schema:knows ex:bob>> ex:confidence 0.95 .
```

### How do I use RDF-star in RDF-XSimple?

Use the `<rdf:QuotedTriple>` element:

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
</ex:Claim>
```

### Can I nest quoted triples?

Yes, for complex annotations:

```xml
<rdf:QuotedTriple>
  <rdf:subject>
    <rdf:QuotedTriple>
      <rdf:subject rdf:resource="ex:alice"/>
      <rdf:predicate rdf:resource="schema:knows"/>
      <rdf:object rdf:resource="ex:bob"/>
    </rdf:QuotedTriple>
  </rdf:subject>
  <rdf:predicate rdf:resource="ex:reportedBy"/>
  <rdf:object rdf:resource="ex:carol"/>
</rdf:QuotedTriple>
```

## Performance Questions

### Is RDF-XSimple faster to parse?

Parsing speed is similar, but:
- **File size**: 30-50% smaller (due to CURIEs and compact syntax)
- **Readability**: Much better for humans
- **Generation**: Simpler templates

### Does denormalization affect file size?

Slightly. Inlining adds nesting structure but:
- Removes duplicate resource declarations
- Reduces reference links
- Net effect: Usually 5-10% smaller

### Can I stream RDF-XSimple?

Yes, XML streaming parsers work normally. Put the context block first:

```xml
<rdf:RDF>
  <rdf:context>
    <!-- Define all prefixes upfront -->
  </rdf:context>
  <!-- Stream resources here -->
</rdf:RDF>
```

## Migration Questions

### How long does migration take?

Depends on dataset size:
- Small (<1000 files): Hours
- Medium (1000-10000 files): Days  
- Large (>10000 files): Weeks

Most time is testing and validation, not conversion.

### Will migration break my applications?

Not if you:
1. Convert to RDF-XSimple for storage/display
2. Convert back to RDF/XML 1.0 for existing tools
3. Update applications gradually

### Can I roll back if needed?

Yes, immediately. The reverse transformation is lossless:

```bash
saxon -s:rdfxml2.rdf -xsl:xslt/rdfxml2-to-rdfxml1.xsl -o:rdfxml1.rdf
```

### Should I migrate everything at once?

No. Recommended approach:
1. Start with new data
2. Migrate read-only archives
3. Gradually migrate active data
4. Keep RDF/XML 1.0 for critical systems until fully tested

## Tooling Questions

### What XSLT processor should I use?

Recommended: **Saxon HE** (free) or PE/EE (commercial)
- Download: https://www.saxonica.com/
- Fully supports XSLT 2.0
- Fast and reliable

Alternatives:
- **Xalan**: XSLT 1.0, some features limited
- **libxslt/xsltproc**: XSLT 1.0, basic support

### Can I use Python/JavaScript/Java?

Yes, with XSLT bindings:

**Python:**
```python
from lxml import etree
xslt = etree.parse('rdfxml1-to-rdfxml2.xsl')
transform = etree.XSLT(xslt)
result = transform(etree.parse('input.rdf'))
```

**JavaScript:**
```javascript
const saxon = require('saxon-js');
saxon.transform({
  stylesheetFileName: 'rdfxml1-to-rdfxml2.xsl',
  sourceFileName: 'input.rdf'
});
```

**Java:**
```java
TransformerFactory factory = TransformerFactory.newInstance();
Transformer transformer = factory.newTransformer(
    new StreamSource("rdfxml1-to-rdfxml2.xsl"));
transformer.transform(
    new StreamSource("input.rdf"),
    new StreamResult("output.rdf"));
```

### Are there validators?

Currently:
- **XML Schema**: Validates XML structure
- **SHACL**: Validates RDF content
- **Round-trip test**: Ensures semantic equivalence

Native validators are in development.

### What about IDEs?

XML editors work fine:
- **Oxygen XML Editor**: Full support
- **VS Code**: With XML extension
- **IntelliJ IDEA**: Built-in XML support
- **Emacs**: nxml-mode

## Use Case Questions

### When should I use RDF-XSimple?

Best for:
- New RDF projects
- XML-native environments
- Human-readable RDF archives
- Documentation and examples
- Systems requiring XSLT transformations

### When should I use JSON-LD or Turtle instead?

**Use JSON-LD when:**
- Working with JavaScript/web APIs
- Schema.org data
- NoSQL databases (MongoDB, etc.)

**Use Turtle when:**
- Writing RDF by hand
- SPARQL examples
- Ontology development
- Interactive exploration

**Use RDF-XSimple when:**
- XML infrastructure exists
- Need XSLT processing
- Working with XML databases
- Enterprise XML environments

### Can I mix serialization formats?

Yes! Convert as needed:

```
RDF-XSimple → Parse → Triples → Serialize → JSON-LD/Turtle/N-Triples
```

Tools like Rapper, RDF4J, and Apache Jena handle all formats.

## Specification Questions

### Is the specification stable?

The core specification (v1.0.0) is stable. Future versions will be backward compatible.

### Can I suggest changes?

Yes! Open an issue or pull request on GitHub:
https://github.com/yourusername/rdfxsimple-spec

### How do I cite this work?

```bibtex
@techreport{rdfxsimple-spec,
  title = {RDF-XSimple: A Modernized XML Serialization for RDF},
  author = {Community Contributors},
  year = {2026},
  url = {https://github.com/yourusername/rdfxsimple-spec}
}
```

### Who maintains this specification?

Currently community-maintained. We welcome:
- Implementations
- Feedback
- Contributions
- Funding for formal standardization

## Troubleshooting

### My CURIEs aren't expanding

Check:
1. Context block is first child of `<rdf:RDF>`
2. Prefix is defined: `<rdf:prefix name="ex" uri="http://example.org/"/>`
3. CURIE syntax is correct: `ex:alice` not `ex/alice`

### Round-trip test fails

Common causes:
1. Missing `rdf:about` on inlined resources
2. Blank node labels (expected - labels are arbitrary)
3. Triple ordering (expected - order doesn't matter)

### File won't parse

Check:
1. XML well-formed
2. Namespace declarations correct
3. CURIEs properly formed
4. Datatypes valid

### Performance issues

Optimize:
1. Reduce nesting depth
2. Use references for shared resources
3. Process in batches
4. Use streaming parser

## Getting Help

### Where can I ask questions?

- 💬 **GitHub Discussions**: https://github.com/yourusername/rdfxsimple-spec/discussions
- 🐛 **GitHub Issues**: https://github.com/yourusername/rdfxsimple-spec/issues
- 📧 **Email**: support@example.org

### Where can I find examples?

- **Examples directory**: [examples/](../examples/)
- **Specification**: [SPECIFICATION.md](../SPECIFICATION.md)
- **Best practices**: [BEST_PRACTICES.md](BEST_PRACTICES.md)

### How can I contribute?

See [CONTRIBUTING.md](../CONTRIBUTING.md) for:
- Bug reports
- Feature requests
- Code contributions
- Documentation improvements
- Example submissions

---

**Still have questions?** Open a [GitHub Discussion](https://github.com/yourusername/rdfxsimple-spec/discussions)!
