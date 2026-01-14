# Changelog

All notable changes to the RDF-XSimple (RDF XML Simplified) specification and tools will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

> **Note on Naming**: This format was initially developed as "RDF/XML 2.0" but has been renamed to "RDF-XSimple" (RDF XML Simplified) to better reflect its goals: simplifying RDF/XML while maintaining full compatibility.

## [1.0.0] - 2026-01-13

### Added

#### Specification
- Complete RDF-XSimple specification with formal grammar
- Context-based namespace management with `<rdf:context>` element
- CURIE support for compact URI representation
- Simplified datatype syntax (`type="integer"` instead of `rdf:datatype="xsd:integer"`)
- Simplified language tag syntax (`lang="en"` instead of `xml:lang="en"`)
- Type-based element names (use `<schema:Person>` instead of `<rdf:Description>`)
- RDF Lists and Collections support with `rdf:list`, `rdf:bag`, and `rdf:seq` attributes
- Denormalization guidelines for intelligent resource inlining
- RDF-star support with `<rdf:QuotedTriple>` element
- Backward compatibility guarantees with RDF/XML 1.0

#### XSLT Transformations
- `rdfxml1-to-rdfxml2.xsl` - Converts RDF/XML 1.0 to RDF-XSimple
- `rdfxml2-to-rdfxml1.xsl` - Converts RDF-XSimple back to RDF/XML 1.0
- Configurable parameters: `max-inline-depth`, `inline-single-refs`, `use-curies`
- Lossless round-trip conversion support
- Reference counting for smart denormalization
- Namespace-to-prefix mapping

#### Validation Schemas
- `rdfxml2.xsd` - Complete XML Schema Definition for structural validation
- `rdfxml2.sch` - Schematron rules for advanced validation constraints
- `validate-examples.sh` - Automated validation script for all examples
- Schema documentation with usage examples in multiple languages

#### Examples
- `simple-person.rdf` - Basic person with datatypes
- `nested-resources.rdf` - Demonstrates denormalization
- `rdf-star-example.rdf` - RDF-star quoted triples
- `multilingual.rdf` - Language-tagged literals
- `lists-and-collections.rdf` - Lists, bags, and sequences
- `complex-organization.rdf` - Real-world organizational data
- `comparison-rdfxml-vs-xsimple.rdf` - Side-by-side comparison with traditional RDF/XML

#### Documentation
- Complete README with quick start guide
- Migration guide from RDF/XML 1.0
- Best practices for writing RDF-XSimple
- Comprehensive FAQ
- Contributing guidelines
- MIT License

#### Project Infrastructure
- GitHub-ready project structure
- `.gitignore` for common artifacts
- CHANGELOG.md (this file)

### Technical Details

#### Features
- Namespace context blocks reduce verbosity by 30-50%
- CURIE support matches Turtle and JSON-LD syntax
- Simplified datatypes improve readability
- Single-reference resource inlining reduces file size
- RDF-star integration for statement annotations
- Preserved XML streaming and validation capabilities

#### Compatibility
- Lossless round-trip with RDF/XML 1.0
- Identical RDF triple output
- Works with existing XSLT processors (Saxon, Xalan, libxslt)
- Compatible with standard RDF libraries via transformation
- Maintains XML Schema validation support

### Known Limitations

- Native parser support in RDF libraries not yet available (use XSLT transformations)
- XSLT 2.0 required for full functionality (XSLT 1.0 has limited support)
- Maximum recommended nesting depth: 3 levels

## [Unreleased]

### Planned for Future Releases

#### Version 1.1
- [ ] Python parser implementation
- [ ] JavaScript parser implementation  
- [ ] Java parser implementation (Apache Jena)
- [ ] Standalone validator tool
- [ ] Performance benchmarks
- [ ] Additional examples (scientific data, geospatial, provenance)

#### Version 1.2
- [ ] Streaming parser support
- [ ] SHACL-aware optimization hints
- [ ] Schema-driven serialization
- [ ] Performance profiling tools

#### Version 2.0
- [ ] Binary RDF/XML encoding option
- [ ] Advanced compression strategies
- [ ] Native graph database integration

### Community Requests

Track feature requests at: https://github.com/yourusername/rdfxsimple-spec/issues

---

## Version History

- **1.0.0** (2026-01-13) - Initial release
  - Complete specification
  - XSLT transformations
  - Documentation and examples

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on proposing changes and additions.

## Links

- [Specification](SPECIFICATION.md)
- [Migration Guide](docs/MIGRATION.md)
- [Best Practices](docs/BEST_PRACTICES.md)
- [FAQ](docs/FAQ.md)
- [GitHub Repository](https://github.com/yourusername/rdfxsimple-spec)
