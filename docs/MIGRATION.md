# Migration Guide: RDF/XML 1.0 to RDF-XSimple

This guide helps you migrate existing RDF/XML 1.0 documents to the modernized RDF-XSimple format.

## Table of Contents

1. [Overview](#overview)
2. [Automated Migration](#automated-migration)
3. [Manual Migration Steps](#manual-migration-steps)
4. [Common Patterns](#common-patterns)
5. [Validation](#validation)
6. [Rollback](#rollback)
7. [Best Practices](#best-practices)

## Overview

### What Changes?

**Syntax changes:**
- Namespace declarations → Context block with CURIEs
- `rdf:datatype="xsd:integer"` → `type="integer"`
- `xml:lang="en"` → `lang="en"`
- Full URIs → CURIEs (e.g., `ex:alice`)
- Normalized structure → Denormalized (single-ref resources inlined)

**What stays the same:**
- RDF data model (identical triples)
- XML structure and validation
- XSLT compatibility
- Tool support (via transformation)

### Migration Strategy

```
RDF/XML 1.0 → XSLT Transform → RDF-XSimple → Validate → Deploy
                                      ↓
                              Round-trip test
```

## Automated Migration

### Using XSLT

The easiest migration path uses the provided XSLT transformation:

```bash
# Install Saxon (recommended)
# macOS: brew install saxon
# Ubuntu: apt-get install libsaxonhe-java
# Windows: Download from https://www.saxonica.com/

# Transform single file
saxon -s:input.rdf -xsl:xslt/rdfxml1-to-rdfxml2.xsl -o:output.rdf

# Transform with options
saxon -s:input.rdf -xsl:xslt/rdfxml1-to-rdfxml2.xsl -o:output.rdf \
  max-inline-depth=5 \
  inline-single-refs=true \
  use-curies=true
```

### Batch Processing

Transform multiple files:

```bash
#!/bin/bash
# migrate-all.sh

for file in ./old-rdf/*.rdf; do
  basename=$(basename "$file")
  saxon -s:"$file" \
        -xsl:xslt/rdfxml1-to-rdfxml2.xsl \
        -o:"./new-rdf/$basename"
  echo "Converted: $basename"
done
```

### Node.js Integration

```javascript
const { transform } = require('saxon-js');
const fs = require('fs').promises;
const path = require('path');

async function migrateFile(inputPath, outputPath) {
  const result = await transform({
    stylesheetFileName: 'xslt/rdfxml1-to-rdfxml2.xsl',
    sourceFileName: inputPath,
    destination: 'serialized',
    stylesheetParams: {
      'max-inline-depth': 3,
      'inline-single-refs': true,
      'use-curies': true
    }
  });
  
  await fs.writeFile(outputPath, result.principalResult);
  console.log(`Migrated: ${inputPath} → ${outputPath}`);
}

// Migrate directory
async function migrateDirectory(inputDir, outputDir) {
  const files = await fs.readdir(inputDir);
  
  for (const file of files) {
    if (file.endsWith('.rdf') || file.endsWith('.xml')) {
      const inputPath = path.join(inputDir, file);
      const outputPath = path.join(outputDir, file);
      await migrateFile(inputPath, outputPath);
    }
  }
}

migrateDirectory('./old-rdf', './new-rdf');
```

### Python Integration

```python
from lxml import etree
import os
import glob

def migrate_file(input_path, output_path, options=None):
    # Load XSLT
    xslt_doc = etree.parse('xslt/rdfxml1-to-rdfxml2.xsl')
    transform = etree.XSLT(xslt_doc)
    
    # Load input
    doc = etree.parse(input_path)
    
    # Transform with options
    params = options or {
        'max-inline-depth': '3',
        'inline-single-refs': 'true()',
        'use-curies': 'true()'
    }
    
    result = transform(doc, **params)
    
    # Write output
    with open(output_path, 'wb') as f:
        f.write(etree.tostring(result, pretty_print=True, encoding='UTF-8'))
    
    print(f"Migrated: {input_path} → {output_path}")

# Migrate directory
def migrate_directory(input_dir, output_dir):
    os.makedirs(output_dir, exist_ok=True)
    
    for input_path in glob.glob(f"{input_dir}/*.rdf"):
        filename = os.path.basename(input_path)
        output_path = os.path.join(output_dir, filename)
        migrate_file(input_path, output_path)

migrate_directory('./old-rdf', './new-rdf')
```

## Manual Migration Steps

If you need to manually update RDF/XML:

### Step 1: Add Context Block

**Before:**
```xml
<rdf:RDF 
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:schema="http://schema.org/"
  xmlns:ex="http://example.org/">
```

**After:**
```xml
<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
  <rdf:context>
    <rdf:prefix name="schema" uri="http://schema.org/"/>
    <rdf:prefix name="ex" uri="http://example.org/"/>
  </rdf:context>
```

### Step 2: Convert to CURIEs

**Before:**
```xml
<rdf:Description rdf:about="http://example.org/alice">
  <schema:knows rdf:resource="http://example.org/bob"/>
</rdf:Description>
```

**After:**
```xml
<rdf:Description rdf:about="ex:alice">
  <schema:knows rdf:resource="ex:bob"/>
</rdf:Description>
```

### Step 3: Simplify Datatypes

**Before:**
```xml
<schema:age rdf:datatype="http://www.w3.org/2001/XMLSchema#integer">30</schema:age>
<schema:name xml:lang="en">Alice</schema:name>
```

**After:**
```xml
<schema:age type="integer">30</schema:age>
<schema:name lang="en">Alice</schema:name>
```

### Step 4: Use Type-Based Element Names

**Before:**
```xml
<rdf:Description rdf:about="ex:alice">
  <rdf:type rdf:resource="schema:Person"/>
  <schema:name>Alice</schema:name>
</rdf:Description>
```

**After:**
```xml
<schema:Person rdf:about="ex:alice">
  <schema:name>Alice</schema:name>
</schema:Person>
```

### Step 5: Inline Single-Reference Resources

**Before:**
```xml
<schema:Person rdf:about="ex:alice">
  <schema:address rdf:resource="ex:addr1"/>
</schema:Person>

<schema:PostalAddress rdf:about="ex:addr1">
  <schema:streetAddress>123 Main St</schema:streetAddress>
</schema:PostalAddress>
```

**After:**
```xml
<schema:Person rdf:about="ex:alice">
  <schema:address>
    <schema:PostalAddress rdf:about="ex:addr1">
      <schema:streetAddress>123 Main St</schema:streetAddress>
    </schema:PostalAddress>
  </schema:address>
</schema:Person>
```

⚠️ **Important**: Keep `rdf:about` on inlined resources!

## Common Patterns

### Pattern 1: Simple Datatype Properties

```xml
<!-- RDF/XML 1.0 -->
<schema:age rdf:datatype="http://www.w3.org/2001/XMLSchema#integer">30</schema:age>
<schema:height rdf:datatype="http://www.w3.org/2001/XMLSchema#decimal">1.75</schema:height>
<schema:active rdf:datatype="http://www.w3.org/2001/XMLSchema#boolean">true</schema:active>

<!-- RDF-XSimple -->
<schema:age type="integer">30</schema:age>
<schema:height type="decimal">1.75</schema:height>
<schema:active type="boolean">true</schema:active>
```

### Pattern 2: Language-Tagged Literals

```xml
<!-- RDF/XML 1.0 -->
<schema:name xml:lang="en">Alice</schema:name>
<schema:name xml:lang="fr">Alice</schema:name>

<!-- RDF-XSimple -->
<schema:name lang="en">Alice</schema:name>
<schema:name lang="fr">Alice</schema:name>
```

### Pattern 3: Nested Structures

```xml
<!-- RDF/XML 1.0 (normalized) -->
<schema:Person rdf:about="http://example.org/alice">
  <schema:address rdf:resource="http://example.org/addr1"/>
</schema:Person>
<schema:PostalAddress rdf:about="http://example.org/addr1">
  <schema:streetAddress>123 Main St</schema:streetAddress>
</schema:PostalAddress>

<!-- RDF-XSimple (denormalized) -->
<schema:Person rdf:about="ex:alice">
  <schema:address>
    <schema:PostalAddress rdf:about="ex:addr1">
      <schema:streetAddress>123 Main St</schema:streetAddress>
    </schema:PostalAddress>
  </schema:address>
</schema:Person>
```

### Pattern 4: Multiple References

```xml
<!-- RDF-XSimple - Keep as reference when multiple subjects reference it -->
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

## Validation

### Round-Trip Test

Verify semantic equivalence:

```bash
# 1. Convert to RDF-XSimple
saxon -s:original.rdf -xsl:xslt/rdfxml1-to-rdfxml2.xsl -o:converted.rdf

# 2. Convert back to RDF/XML 1.0
saxon -s:converted.rdf -xsl:xslt/rdfxml2-to-rdfxml1.xsl -o:roundtrip.rdf

# 3. Parse both and compare triples
rapper -i rdfxml original.rdf -o ntriples | sort > original.nt
rapper -i rdfxml roundtrip.rdf -o ntriples | sort > roundtrip.nt
diff original.nt roundtrip.nt
```

### Using RDF Libraries

**Python (rdflib):**
```python
from rdflib import Graph

# Load both versions
g1 = Graph().parse('original.rdf', format='xml')
g2 = Graph().parse('converted.rdf', format='xml')

# Compare
print(f"Original triples: {len(g1)}")
print(f"Converted triples: {len(g2)}")
print(f"Graphs equal: {g1.isomorphic(g2)}")
```

**JavaScript (N3.js):**
```javascript
const N3 = require('n3');
const fs = require('fs');

async function compareGraphs(file1, file2) {
  const parser = new N3.Parser({ format: 'application/rdf+xml' });
  
  const triples1 = parser.parse(fs.readFileSync(file1, 'utf8'));
  const triples2 = parser.parse(fs.readFileSync(file2, 'utf8'));
  
  console.log(`File 1 triples: ${triples1.length}`);
  console.log(`File 2 triples: ${triples2.length}`);
  console.log(`Equal: ${JSON.stringify(triples1) === JSON.stringify(triples2)}`);
}

compareGraphs('original.rdf', 'converted.rdf');
```

## Rollback

If you need to revert to RDF/XML 1.0:

```bash
# Convert back to RDF/XML 1.0
saxon -s:rdfxml2-file.rdf \
      -xsl:xslt/rdfxml2-to-rdfxml1.xsl \
      -o:rdfxml1-file.rdf
```

This is **lossless** - you'll get back semantically identical RDF/XML 1.0.

## Best Practices

### 1. **Test Before Deploying**

Always validate migrations in a test environment:

```bash
# Run comprehensive tests
./test-migration.sh input-files/ output-files/
```

### 2. **Keep Backups**

```bash
# Backup before migration
tar -czf rdf-backup-$(date +%Y%m%d).tar.gz ./rdf-files/
```

### 3. **Gradual Migration**

Migrate incrementally:
- Start with simple files
- Test thoroughly
- Migrate complex files
- Update applications
- Monitor production

### 4. **Document Custom Patterns**

Document any project-specific patterns or conventions:

```markdown
# Our Migration Notes
- All product IDs use `prod:` prefix
- Addresses always inlined (single-ref rule)
- Prices in USD unless specified
```

### 5. **Update Application Code**

Update SPARQL queries and code that generates RDF/XML:

```python
# Old code
def generate_rdf(data):
    return f'''
    <rdf:Description rdf:about="http://example.org/{data.id}">
      <schema:age rdf:datatype="http://www.w3.org/2001/XMLSchema#integer">{data.age}</schema:age>
    </rdf:Description>
    '''

# New code
def generate_rdf(data):
    return f'''
    <schema:Person rdf:about="ex:{data.id}">
      <schema:age type="integer">{data.age}</schema:age>
    </schema:Person>
    '''
```

## Troubleshooting

### Issue: CURIEs Not Expanding

**Problem**: References like `ex:alice` not being recognized

**Solution**: Verify context block is first child of `<rdf:RDF>`:

```xml
<rdf:RDF>
  <rdf:context>
    <rdf:prefix name="ex" uri="http://example.org/"/>
  </rdf:context>
  <!-- resources -->
</rdf:RDF>
```

### Issue: Over-Inlining

**Problem**: Too much nesting makes file hard to read

**Solution**: Adjust `max-inline-depth` parameter:

```bash
saxon -s:input.rdf -xsl:xslt/rdfxml1-to-rdfxml2.xsl -o:output.rdf \
  max-inline-depth=2
```

### Issue: Lost Type Information

**Problem**: `rdf:type` statements disappearing

**Solution**: Check if types are being converted to element names (this is correct):

```xml
<!-- Both are equivalent -->
<rdf:Description rdf:about="ex:alice">
  <rdf:type rdf:resource="schema:Person"/>
</rdf:Description>

<schema:Person rdf:about="ex:alice">
  <!-- type is in element name -->
</schema:Person>
```

## Support

For migration issues:
- 📖 Check [SPECIFICATION.md](../SPECIFICATION.md)
- 💬 Ask in [GitHub Discussions](https://github.com/yourusername/rdfxsimple-spec/discussions)
- 🐛 Report bugs in [GitHub Issues](https://github.com/yourusername/rdfxsimple-spec/issues)

---

**Next Steps**: See [Best Practices](BEST_PRACTICES.md) for writing optimal RDF-XSimple.
