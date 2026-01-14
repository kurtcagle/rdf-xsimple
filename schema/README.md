# RDF-XSimple Schema

This directory contains validation schemas for RDF-XSimple documents.

## Files

### rdfxml2.xsd

XML Schema Definition (XSD) for structural validation of RDF-XSimple documents.

**Validates:**
- Document structure (rdf:RDF, rdf:context, resources, properties)
- Attribute types and constraints
- Element ordering (context must be first)
- Basic datatype values
- RDF-star quoted triple structure

**Does not validate:**
- CURIE expansion correctness
- Semantic RDF triple validity
- Complex constraints (use Schematron for these)

### rdfxml2.sch (Schematron)

Advanced validation rules for constraints that XSD cannot express.

**Validates:**
- Context block is first child of rdf:RDF
- No conflicting attributes (type + lang, multiple collection types)
- CURIE references have defined prefixes
- rdf:resources used correctly (not with nested elements)

## Usage

### Validating with xmllint (XSD)

```bash
# Basic validation
xmllint --noout --schema schema/rdfxml2.xsd examples/simple-person.rdf

# Validate with error output
xmllint --schema schema/rdfxml2.xsd examples/simple-person.rdf
```

**Output:**
```
examples/simple-person.rdf validates
```

### Validating with Saxon (XSD)

```bash
java -jar saxon-he.jar -xsd:schema/rdfxml2.xsd -s:examples/simple-person.rdf
```

### Validating with Python (lxml)

```python
from lxml import etree

# Load schema
with open('schema/rdfxml2.xsd') as f:
    schema_root = etree.XML(f.read())
    schema = etree.XMLSchema(schema_root)

# Validate document
doc = etree.parse('examples/simple-person.rdf')
is_valid = schema.validate(doc)

if is_valid:
    print("Document is valid!")
else:
    print("Validation errors:")
    for error in schema.error_log:
        print(f"  Line {error.line}: {error.message}")
```

### Validating with Java (javax.xml)

```java
import javax.xml.XMLConstants;
import javax.xml.transform.stream.StreamSource;
import javax.xml.validation.*;
import java.io.File;

SchemaFactory factory = SchemaFactory.newInstance(XMLConstants.W3C_XML_SCHEMA_NS_URI);
Schema schema = factory.newSchema(new File("schema/rdfxml2.xsd"));
Validator validator = schema.newValidator();

try {
    validator.validate(new StreamSource(new File("examples/simple-person.rdf")));
    System.out.println("Document is valid!");
} catch (Exception e) {
    System.out.println("Validation error: " + e.getMessage());
}
```

### Validating with Schematron

```bash
# Using Saxon with Schematron
java -jar saxon-he.jar \
  -xsl:schematron/iso-schematron-xslt2.xsl \
  -s:schema/rdfxml2.sch \
  -o:rdfxml2-validator.xsl

# Apply generated validator
java -jar saxon-he.jar \
  -xsl:rdfxml2-validator.xsl \
  -s:examples/simple-person.rdf
```

## Common Validation Errors

### Error: Element not allowed

```
Error: element schema:Person not allowed here
```

**Cause**: Element from wrong namespace or invalid structure.

**Solution**: Check namespace declarations in context block.

### Error: Invalid attribute value

```
Error: attribute 'type' has invalid value 'int32'
```

**Cause**: Datatype not in XSD enumeration.

**Solution**: Use standard XSD type names (integer, decimal, etc.)

### Error: Missing required attribute

```
Error: element rdf:prefix missing required attribute 'name'
```

**Cause**: Incomplete prefix definition in context.

**Solution**: Add both name and uri attributes.

## Validation Levels

### Level 1: Well-Formed XML

```bash
xmllint --noout examples/simple-person.rdf
```

Checks:
- Valid XML syntax
- Balanced tags
- Proper encoding

### Level 2: Schema Valid (XSD)

```bash
xmllint --schema schema/rdfxml2.xsd examples/simple-person.rdf
```

Checks:
- Element structure
- Attribute types
- Required elements/attributes
- Basic constraints

### Level 3: Advanced Rules (Schematron)

```bash
java -jar saxon-he.jar -xsl:rdfxml2-validator.xsl -s:examples/simple-person.rdf
```

Checks:
- Context ordering
- CURIE prefix definitions
- Conflicting attributes
- Collection type exclusivity

### Level 4: Semantic Validation (RDF)

```bash
rapper -i rdfxml examples/simple-person.rdf -o ntriples > /dev/null
```

Checks:
- Valid RDF triples
- IRI syntax
- Literal values
- Graph consistency

## Integration with Editors

### Oxygen XML Editor

1. Open document
2. Go to Document > Validate > Validate with...
3. Select `schema/rdfxml2.xsd`
4. Click Validate

### VS Code (with XML extension)

Add to `.vscode/settings.json`:

```json
{
  "xml.validation.schema": [
    {
      "systemId": "schema/rdfxml2.xsd",
      "pattern": "**/*.rdf"
    }
  ]
}
```

### IntelliJ IDEA

1. Open Settings > Languages & Frameworks > Schemas and DTDs
2. Add External Schema
3. Select `rdfxml2.xsd`
4. Map to file pattern `*.rdf`

## Extending the Schema

To add custom validation rules:

1. **For structural constraints**: Extend `rdfxml2.xsd`
2. **For complex rules**: Add to `rdfxml2.sch`
3. **For vocabulary-specific rules**: Create custom schema

### Example: Custom Namespace Schema

```xml
<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema"
           xmlns:ex="http://example.org/"
           targetNamespace="http://example.org/">
  
  <xs:import namespace="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
             schemaLocation="rdfxml2.xsd"/>
  
  <xs:element name="Person" type="rdf:ResourceType"/>
  <xs:element name="name" type="xs:string"/>
  <xs:element name="email" type="xs:string"/>
</xs:schema>
```

## Continuous Integration

### GitHub Actions

```yaml
name: Validate RDF-XSimple

on: [push, pull_request]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Install xmllint
        run: sudo apt-get install -y libxml2-utils
      
      - name: Validate examples
        run: |
          for file in examples/*.rdf; do
            echo "Validating $file"
            xmllint --schema schema/rdfxml2.xsd --noout "$file"
          done
```

### Pre-commit Hook

```bash
#!/bin/bash
# .git/hooks/pre-commit

echo "Validating RDF-XSimple files..."
for file in $(git diff --cached --name-only --diff-filter=ACM | grep '\.rdf$'); do
  xmllint --schema schema/rdfxml2.xsd --noout "$file"
  if [ $? -ne 0 ]; then
    echo "Validation failed for $file"
    exit 1
  fi
done
echo "All files valid!"
```

## Troubleshooting

### xmllint not found

**Ubuntu/Debian:**
```bash
sudo apt-get install libxml2-utils
```

**macOS:**
```bash
brew install libxml2
```

**Windows:**
Download from http://xmlsoft.org/downloads.html

### Schema not found error

Ensure schema path is correct:
```bash
# Use absolute path
xmllint --schema /full/path/to/schema/rdfxml2.xsd file.rdf

# Or relative from project root
xmllint --schema ./schema/rdfxml2.xsd ./examples/file.rdf
```

### Namespace validation failures

Check that namespace URIs match exactly:
- RDF namespace: `http://www.w3.org/1999/02/22-rdf-syntax-ns#`
- Your custom namespaces must match context definitions

## References

- **XML Schema Specification**: https://www.w3.org/TR/xmlschema-1/
- **Schematron**: https://schematron.com/
- **RDF-XSimple Specification**: ../SPECIFICATION.md
- **Examples**: ../examples/

## Contributing

To improve the schema:

1. Test against examples
2. Document new constraints
3. Add test cases
4. Submit pull request

See [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines.

## License

MIT License - see [LICENSE](../LICENSE)
