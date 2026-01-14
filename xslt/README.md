# XSLT Transformations

This directory contains XSLT 2.0 stylesheets for converting between RDF/XML 1.0 and RDF-XSimple formats.

## Files

### rdfxml1-to-rdfxml2.xsl

Converts standard RDF/XML 1.0 to modernized RDF-XSimple format.

**Features:**
- Context-based namespace management
- CURIE generation
- Simplified datatype syntax
- RDF Lists and Collections (`rdf:list`, `rdf:bag`, `rdf:seq`)
- Intelligent denormalization (single-reference inlining)
- Type-based element naming

**Parameters:**
- `max-inline-depth` (default: 3) - Maximum nesting depth for inlining
- `inline-single-refs` (default: true) - Enable denormalization
- `use-curies` (default: true) - Use CURIEs instead of full URIs

**Usage:**
```bash
# Basic conversion
saxon -s:input.rdf -xsl:rdfxml1-to-rdfxml2.xsl -o:output.rdf

# With custom parameters
saxon -s:input.rdf -xsl:rdfxml1-to-rdfxml2.xsl -o:output.rdf \
  max-inline-depth=5 \
  inline-single-refs=true \
  use-curies=true
```

### rdfxml2-to-rdfxml1.xsl

Converts RDF-XSimple back to standard RDF/XML 1.0 format.

**Features:**
- CURIE expansion to full URIs
- Context to namespace declarations conversion
- Datatype expansion
- Resource flattening (denormalization reversal)

**Usage:**
```bash
saxon -s:input.rdf -xsl:rdfxml2-to-rdfxml1.xsl -o:output.rdf
```

## Requirements

### Recommended: Saxon HE/PE/EE

**Installation:**

macOS:
```bash
brew install saxon
```

Ubuntu/Debian:
```bash
sudo apt-get install libsaxonhe-java
```

Windows:
- Download from https://www.saxonica.com/
- Extract and add to PATH

### Alternative: Xalan

Limited XSLT 1.0 support (some features may not work).

### Alternative: libxslt (xsltproc)

Basic XSLT 1.0 support.

```bash
xsltproc rdfxml1-to-rdfxml2.xsl input.rdf > output.rdf
```

## Examples

### Simple Conversion

```bash
# Convert to RDF-XSimple
saxon -s:person.rdf -xsl:rdfxml1-to-rdfxml2.xsl -o:person-v2.rdf

# Convert back to RDF/XML 1.0
saxon -s:person-v2.rdf -xsl:rdfxml2-to-rdfxml1.xsl -o:person-v1.rdf
```

### Batch Processing

```bash
#!/bin/bash
for file in ./input/*.rdf; do
  basename=$(basename "$file")
  saxon -s:"$file" \
        -xsl:rdfxml1-to-rdfxml2.xsl \
        -o:"./output/$basename"
done
```

### Python Integration

```python
from lxml import etree

# Load XSLT
xslt = etree.parse('rdfxml1-to-rdfxml2.xsl')
transform = etree.XSLT(xslt)

# Transform
doc = etree.parse('input.rdf')
result = transform(doc, 
                   max_inline_depth=etree.XSLT.strparam('3'),
                   use_curies=etree.XSLT.strparam('true()'))

# Save
with open('output.rdf', 'wb') as f:
    f.write(etree.tostring(result, pretty_print=True))
```

### JavaScript Integration

```javascript
const saxon = require('saxon-js');

saxon.transform({
  stylesheetFileName: 'rdfxml1-to-rdfxml2.xsl',
  sourceFileName: 'input.rdf',
  destination: 'serialized',
  stylesheetParams: {
    'max-inline-depth': 3,
    'inline-single-refs': true,
    'use-curies': true
  }
}).then(output => {
  console.log(output.principalResult);
});
```

### Java Integration

```java
import javax.xml.transform.*;
import javax.xml.transform.stream.*;

TransformerFactory factory = TransformerFactory.newInstance();
Transformer transformer = factory.newTransformer(
    new StreamSource("rdfxml1-to-rdfxml2.xsl"));

// Set parameters
transformer.setParameter("max-inline-depth", "3");
transformer.setParameter("use-curies", "true");

// Transform
transformer.transform(
    new StreamSource("input.rdf"),
    new StreamResult("output.rdf"));
```

## Validation

### Round-Trip Test

Verify semantic equivalence:

```bash
# 1. Convert to RDF-XSimple
saxon -s:original.rdf -xsl:rdfxml1-to-rdfxml2.xsl -o:converted.rdf

# 2. Convert back to RDF/XML 1.0  
saxon -s:converted.rdf -xsl:rdfxml2-to-rdfxml1.xsl -o:roundtrip.rdf

# 3. Compare triples (should be identical)
rapper -i rdfxml original.rdf -o ntriples | sort > original.nt
rapper -i rdfxml roundtrip.rdf -o ntriples | sort > roundtrip.nt
diff original.nt roundtrip.nt
```

## Troubleshooting

### Error: Cannot find Saxon

Ensure Saxon is installed and in your PATH:

```bash
# Test Saxon installation
saxon -?

# Or specify full path
java -jar /path/to/saxon-he-12.x.jar -s:input.rdf -xsl:transform.xsl -o:output.rdf
```

### Error: XSLT 2.0 features not supported

You're using an XSLT 1.0 processor. Install Saxon for full XSLT 2.0 support.

### Error: Namespace prefix not bound

Check that the context block defines all prefixes used in CURIEs:

```xml
<rdf:context>
  <rdf:prefix name="ex" uri="http://example.org/"/>
  <!-- Add missing prefixes here -->
</rdf:context>
```

## Performance

### Optimization Tips

1. **Batch processing**: Process multiple files in parallel
2. **Streaming**: Use Saxon's streaming mode for large files
3. **Parameters**: Adjust `max-inline-depth` for performance vs. readability

### Benchmarks

Approximate processing times (Saxon HE):

| File Size | Triples | Time |
|-----------|---------|------|
| 10 KB | 100 | <1s |
| 100 KB | 1,000 | ~2s |
| 1 MB | 10,000 | ~15s |
| 10 MB | 100,000 | ~2min |

*Times may vary based on hardware and nesting complexity.*

## Contributing

Improvements to the XSLT stylesheets are welcome! See [CONTRIBUTING.md](../CONTRIBUTING.md).

## License

MIT License - See [LICENSE](../LICENSE)
