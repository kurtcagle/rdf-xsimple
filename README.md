# RDF-XSimple

A modernized XML serialization format for RDF that brings contemporary best practices, improved readability, and support for RDF-star while maintaining full compatibility with the RDF data model.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Specification](https://img.shields.io/badge/Spec-Draft-blue.svg)](SPECIFICATION.md)

## Overview

RDF-XSimple addresses longstanding limitations of RDF/XML by incorporating lessons learned from JSON-LD, Turtle, and 25 years of RDF usage. It provides:

- **🎯 Context-based namespace management** - Centralized, reusable prefix definitions
- **📦 Smart denormalization** - Automatic inlining of single-reference resources  
- **✨ CURIE support** - Compact URIs like `ex:alice` instead of full URIs
- **🔤 Simplified datatypes** - `type="integer"` instead of verbose XSD URIs
- **📋 Clear list syntax** - `rdf:list="true"` for ordered lists, `rdf:bag="true"` for unordered sets
- **⭐ RDF-star ready** - First-class support for quoted triples
- **🔄 Lossless transformation** - Perfect round-trip with RDF/XML 1.0

## Quick Example

**Traditional RDF/XML:**
```xml
<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
         xmlns:schema="http://schema.org/">
  <rdf:Description rdf:about="http://example.org/alice">
    <rdf:type rdf:resource="http://schema.org/Person"/>
    <schema:name>Alice Smith</schema:name>
    <schema:age rdf:datatype="http://www.w3.org/2001/XMLSchema#integer">30</schema:age>
    <schema:address rdf:resource="http://example.org/addr1"/>
  </rdf:Description>
  
  <schema:PostalAddress rdf:about="http://example.org/addr1">
    <schema:streetAddress>123 Main St</schema:streetAddress>
  </schema:PostalAddress>
</rdf:RDF>
```

**RDF-XSimple:**
```xml
<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
  <rdf:context>
    <rdf:prefix name="schema" uri="http://schema.org/"/>
    <rdf:prefix name="ex" uri="http://example.org/"/>
  </rdf:context>
  
  <schema:Person rdf:about="ex:alice">
    <schema:name>Alice Smith</schema:name>
    <schema:age type="integer">30</schema:age>
    <schema:address>
      <schema:PostalAddress rdf:about="ex:addr1">
        <schema:streetAddress>123 Main St</schema:streetAddress>
      </schema:PostalAddress>
    </schema:address>
  </schema:Person>
</rdf:RDF>
```

## Features

### Context-Based Namespaces

Centralized prefix definitions similar to JSON-LD's `@context`:

```xml
<rdf:context>
  <rdf:prefix name="schema" uri="http://schema.org/"/>
  <rdf:prefix name="ex" uri="http://example.org/"/>
  <rdf:prefix name="foaf" uri="http://xmlns.com/foaf/0.1/"/>
</rdf:context>
```

### Side-by-Side Comparison

See [comparison-rdfxml-vs-xsimple.rdf](examples/comparison-rdfxml-vs-xsimple.rdf) for a detailed comparison showing:
- **43% file size reduction** (1850 bytes → 1050 bytes)
- Identical RDF triple output
- All major feature differences illustrated
- Both formats in one document

### CURIE Support

Compact URIs throughout the document:

```xml
<schema:Person rdf:about="ex:alice">
  <schema:knows rdf:resource="ex:bob"/>
</schema:Person>
```

### Simplified Datatypes

Clean syntax for common XSD types:

```xml
<schema:age type="integer">30</schema:age>
<schema:height type="decimal">1.75</schema:height>
<schema:active type="boolean">true</schema:active>
```

### Intelligent Denormalization

Single-reference resources are automatically inlined:

```xml
<schema:Person rdf:about="ex:alice">
  <schema:address>
    <schema:PostalAddress rdf:about="ex:addr1">
      <schema:streetAddress>123 Main St</schema:streetAddress>
    </schema:PostalAddress>
  </schema:address>
</schema:Person>
```

### RDF-star Support

Native support for quoted triples:

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

## Getting Started

### XSLT Transformations

Transform existing RDF/XML to RDF-XSimple:

```bash
# Using Saxon
saxon -s:input.rdf -xsl:xslt/rdfxml1-to-rdfxml2.xsl -o:output.rdf

# Using xsltproc
xsltproc xslt/rdfxml1-to-rdfxml2.xsl input.rdf > output.rdf
```

Transform RDF-XSimple back to standard RDF/XML:

```bash
saxon -s:input.rdf -xsl:xslt/rdfxml2-to-rdfxml1.xsl -o:output.rdf
```

### Schema Validation

Validate documents against the XSD schema:

```bash
# Validate single file
xmllint --schema schema/rdfxml2.xsd examples/simple-person.rdf

# Validate all examples
./validate-examples.sh
```

Using Python:

```python
from lxml import etree

schema = etree.XMLSchema(file='schema/rdfxml2.xsd')
doc = etree.parse('examples/simple-person.rdf')

if schema.validate(doc):
    print("Valid!")
else:
    print(schema.error_log)
```

### Node.js

```javascript
const { transform } = require('saxon-js');
const fs = require('fs');

transform({
  stylesheetFileName: 'xslt/rdfxml1-to-rdfxml2.xsl',
  sourceFileName: 'input.rdf',
  destination: 'serialized'
}).then(output => {
  fs.writeFileSync('output.rdf', output.principalResult);
});
```

### Python

```python
from lxml import etree

# Load XSLT
xslt = etree.parse('xslt/rdfxml1-to-rdfxml2.xsl')
transform = etree.XSLT(xslt)

# Load RDF/XML
doc = etree.parse('input.rdf')

# Transform
result = transform(doc)
print(str(result))
```

## Documentation

- **[Full Specification](SPECIFICATION.md)** - Complete technical specification
- **[Examples](examples/)** - Sample RDF-XSimple documents
- **[XSLT Transformations](xslt/)** - Conversion tools
- **[Migration Guide](docs/MIGRATION.md)** - Upgrading from RDF/XML 1.0
- **[Best Practices](docs/BEST_PRACTICES.md)** - Writing guidelines

## Project Structure

```
rdfxsimple-spec/
├── SPECIFICATION.md          # Complete specification
├── README.md                 # This file
├── LICENSE                   # MIT License
├── CONTRIBUTING.md           # Contribution guidelines
├── examples/                 # Example documents
│   ├── simple-person.rdf
│   ├── nested-resources.rdf
│   ├── rdf-star-example.rdf
│   ├── multilingual.rdf
│   ├── lists-and-collections.rdf
│   └── complex-organization.rdf
├── xslt/                     # Transformation stylesheets
│   ├── rdfxml1-to-rdfxml2.xsl
│   ├── rdfxml2-to-rdfxml1.xsl
│   └── README.md
├── schema/                   # Validation schemas
│   ├── rdfxml2.xsd          # XML Schema Definition
│   ├── rdfxml2.sch          # Schematron rules
│   └── README.md
├── docs/                     # Additional documentation
│   ├── MIGRATION.md
│   ├── BEST_PRACTICES.md
│   └── FAQ.md
├── tests/                    # Test cases
│   ├── input/
│   ├── expected/
│   └── README.md
└── validate-examples.sh      # Schema validation script
```

## Compatibility

### Round-Trip Guarantee

RDF-XSimple maintains perfect semantic equivalence with RDF/XML 1.0:

```
RDF/XML 1.0 → Parse → Triples → Serialize → RDF-XSimple → Parse → Identical Triples ✓
```

### Supported Features

- ✅ RDF 1.1 / 1.2 data model
- ✅ RDF-star (quoted triples)
- ✅ All XSD datatypes
- ✅ Language tags
- ✅ Blank nodes
- ✅ Named graphs (via RDF-star)
- ✅ SHACL integration hints

## Tools and Libraries

### XSLT Processors

- **Saxon HE/PE/EE** (Recommended, XSLT 2.0+)
- **Xalan** (XSLT 1.0 with limitations)
- **libxslt** (via xsltproc)

### RDF Libraries with Support

Libraries that can parse/serialize RDF-XSimple:

- **Planned**: rdflib (Python)
- **Planned**: Apache Jena (Java)
- **Planned**: RDF.js (JavaScript)
- **Planned**: RDFLib.rb (Ruby)

*Note: As this is a new format, library support is being developed. The XSLT transformations provide immediate compatibility.*

## Use Cases

### Enterprise Data Integration

- **Readable exports** for business users
- **Compact representations** reducing storage costs
- **Better diffs** for version control systems

### Semantic Web Applications

- **RDF-star annotations** for provenance and confidence
- **Hierarchical views** matching UI needs
- **Easy XSLT processing** for transformations

### Knowledge Graphs

- **Denormalized views** for query optimization
- **Type-driven serialization** improving clarity
- **SHACL-aligned** structure validation

## Contributing

We welcome contributions! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Ways to Contribute

- 📝 Improve documentation
- 🐛 Report issues and bugs
- 💡 Suggest enhancements
- 🔧 Submit XSLT improvements
- 📚 Add examples
- 🧪 Write test cases

## Roadmap

### Version 1.0 (Current - Draft)

- ✅ Core specification
- ✅ XSLT transformations
- ✅ Example documents
- ✅ Documentation

### Version 1.1 (Planned)

- 🔲 Parser implementations (Python, JavaScript, Java)
- 🔲 Validator tool
- 🔲 W3C Community Group formation
- 🔲 Integration with major RDF libraries

### Version 2.0 (Future)

- 🔲 Streaming parser support
- 🔲 Binary RDF/XML encoding
- 🔲 Schema-driven optimizations

## FAQ

**Q: Is RDF-XSimple a replacement for JSON-LD or Turtle?**  
A: No, they're complementary. RDF-XSimple is for XML-native environments where RDF/XML is already in use.

**Q: Can I use RDF-XSimple with existing RDF tools?**  
A: Use the provided XSLT to convert to standard RDF/XML, which all tools support. Native support is being developed.

**Q: Does this change the RDF data model?**  
A: No, it's purely a serialization format. The underlying triples are identical.

**Q: What about validation?**  
A: XML Schema and SHACL both work. The denormalized structure can be validated against SHACL shapes.

**Q: How does this relate to RDF 1.2?**  
A: RDF-XSimple fully supports RDF 1.2 including RDF-star and all datatype extensions.

## License

This specification and associated tools are released under the MIT License. See [LICENSE](LICENSE) for details.

## Citation

If you use RDF-XSimple in research or production, please cite:

```bibtex
@techreport{rdfxsimple-spec,
  title = {RDF-XSimple: A Modernized XML Serialization for RDF},
  author = {Community Contributors},
  year = {2026},
  url = {https://github.com/yourusername/rdfxsimple-spec},
  note = {Draft Specification v1.0.0}
}
```

## Support

- 📧 Email: support@example.org
- 💬 Discussions: [GitHub Discussions](https://github.com/yourusername/rdfxsimple-spec/discussions)
- 🐛 Issues: [GitHub Issues](https://github.com/yourusername/rdfxsimple-spec/issues)
- 📖 Wiki: [GitHub Wiki](https://github.com/yourusername/rdfxsimple-spec/wiki)

## Acknowledgments

Thanks to the W3C RDF Working Group, the JSON-LD community, and all contributors to the semantic web standards that informed this work.

---

**Status**: Draft Specification  
**Version**: 1.0.0-draft  
**Last Updated**: January 2026
