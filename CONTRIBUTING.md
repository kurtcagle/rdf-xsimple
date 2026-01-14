# Contributing to RDF-XSimple

Thank you for your interest in contributing to RDF-XSimple! This document provides guidelines for contributing to the project.

## Table of Contents

1. [Code of Conduct](#code-of-conduct)
2. [How to Contribute](#how-to-contribute)
3. [Development Setup](#development-setup)
4. [Submission Guidelines](#submission-guidelines)
5. [Style Guidelines](#style-guidelines)
6. [Testing](#testing)

## Code of Conduct

### Our Standards

- Be respectful and inclusive
- Welcome newcomers and beginners
- Focus on constructive feedback
- Accept that people have different opinions and experiences
- Show empathy towards other community members

### Unacceptable Behavior

- Harassment, trolling, or discriminatory comments
- Personal attacks or political arguments
- Publishing others' private information
- Other conduct which could reasonably be considered inappropriate

## How to Contribute

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates.

**Good bug reports include:**
- Clear, descriptive title
- Exact steps to reproduce
- Expected vs. actual behavior
- RDF-XSimple version
- XSLT processor version
- Sample RDF/XML input

**Template:**
```markdown
## Bug Description
[Clear description of the bug]

## Steps to Reproduce
1. 
2. 
3. 

## Expected Behavior
[What should happen]

## Actual Behavior
[What actually happens]

## Environment
- RDF-XSimple version: 
- XSLT processor: 
- OS: 

## Sample Input
```xml
[Minimal RDF/XML that reproduces the issue]
`` `
```

### Suggesting Enhancements

Enhancement suggestions are welcome! Please:
- Use a clear, descriptive title
- Provide detailed description of the proposed functionality
- Explain why this enhancement would be useful
- Provide examples of how it would work

**Template:**
```markdown
## Enhancement Description
[Clear description of the enhancement]

## Motivation
[Why this would be useful]

## Proposed Solution
[How it could work]

## Example
```xml
[Example showing the feature in use]
`` `

## Alternatives Considered
[Other approaches you thought about]
```

### Pull Requests

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Add/update tests as needed
5. Update documentation
6. Commit your changes (`git commit -m 'Add amazing feature'`)
7. Push to the branch (`git push origin feature/amazing-feature`)
8. Open a Pull Request

## Development Setup

### Prerequisites

- Git
- Saxon HE (XSLT 2.0 processor)
- Text editor (VS Code, Oxygen XML, etc.)
- Optional: Python 3.8+ or Node.js 14+ for testing

### Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/rdfxsimple-spec.git
cd rdfxsimple-spec

# Install Saxon (macOS)
brew install saxon

# Install Saxon (Ubuntu)
sudo apt-get install libsaxonhe-java

# Install Saxon (Windows)
# Download from https://www.saxonica.com/
```

### Project Structure

```
rdfxsimple-spec/
├── SPECIFICATION.md          # Core specification
├── README.md                 # Project overview
├── LICENSE                   # MIT License
├── CONTRIBUTING.md           # This file
├── examples/                 # Example RDF-XSimple files
├── xslt/                     # XSLT transformations
│   ├── rdfxml1-to-rdfxml2.xsl
│   └── rdfxml2-to-rdfxml1.xsl
├── docs/                     # Documentation
│   ├── MIGRATION.md
│   ├── BEST_PRACTICES.md
│   └── FAQ.md
└── tests/                    # Test files
    ├── input/
    ├── expected/
    └── README.md
```

## Submission Guidelines

### Commit Messages

Follow conventional commits:

```
type(scope): subject

body

footer
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding/updating tests
- `chore`: Maintenance tasks

**Examples:**
```
feat(xslt): add support for nested quoted triples

Add ability to handle nested RDF-star quoted triples in the
transformation stylesheet.

Closes #123
```

```
docs(examples): add multilingual example

Add example demonstrating language-tagged literals across
multiple languages.
```

### Pull Request Process

1. **Update Documentation**: Ensure README, specification, or other docs are updated
2. **Add Tests**: Include test cases for new features
3. **Update Changelog**: Add entry to CHANGELOG.md
4. **Pass CI**: Ensure all tests pass
5. **Review**: Address review comments promptly
6. **Merge**: Maintainers will merge once approved

### Review Process

Pull requests are reviewed for:
- Correctness and completeness
- Code quality and style
- Documentation updates
- Test coverage
- Backward compatibility

## Style Guidelines

### XSLT Style

```xml
<!-- Use 2-space indentation -->
<xsl:template match="*" mode="process">
  <xsl:choose>
    <xsl:when test="@rdf:resource">
      <!-- Handle resource reference -->
    </xsl:when>
  </xsl:choose>
</xsl:template>

<!-- Use descriptive names -->
<xsl:function name="local:uri-to-curie">  <!-- Good -->
<xsl:function name="local:conv">          <!-- Avoid -->

<!-- Comment complex logic -->
<!-- Convert full URI to CURIE if namespace is defined -->
<xsl:variable name="curie" select="local:uri-to-curie(@rdf:about)"/>
```

### RDF-XSimple Examples

```xml
<!-- Use clean, readable structure -->
<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
  <rdf:context>
    <rdf:prefix name="schema" uri="http://schema.org/"/>
    <rdf:prefix name="ex" uri="http://example.org/"/>
  </rdf:context>
  
  <schema:Person rdf:about="ex:alice">
    <schema:name>Alice Smith</schema:name>
    <schema:age type="integer">30</schema:age>
  </schema:Person>
</rdf:RDF>

<!-- Add comments for complex patterns -->
<!-- Nested address (single reference - inlined) -->
<schema:address>
  <schema:PostalAddress rdf:about="ex:addr1">
    <schema:streetAddress>123 Main St</schema:streetAddress>
  </schema:PostalAddress>
</schema:address>
```

### Documentation Style

- Use clear, concise language
- Include examples for complex concepts
- Use tables for comparisons
- Add code blocks with syntax highlighting
- Link to related documentation

## Testing

### Running Tests

```bash
# Run all tests
./run-tests.sh

# Run specific test
saxon -s:tests/input/simple.rdf \
      -xsl:xslt/rdfxml1-to-rdfxml2.xsl \
      -o:tests/output/simple.rdf

# Compare with expected
diff tests/output/simple.rdf tests/expected/simple.rdf
```

### Writing Tests

Each test should include:
1. **Input file**: `tests/input/test-name.rdf` (RDF/XML 1.0)
2. **Expected output**: `tests/expected/test-name.rdf` (RDF-XSimple)
3. **Description**: Comment at top of file

**Test template:**
```xml
<!--
Test: Simple person with datatype properties
Input: RDF/XML 1.0 with verbose datatypes
Expected: RDF-XSimple with simplified types
-->
<rdf:RDF>
  <!-- test content -->
</rdf:RDF>
```

### Test Coverage

Ensure tests cover:
- ✅ Simple resources
- ✅ Nested resources (1-3 levels)
- ✅ Multiple references
- ✅ All XSD datatypes
- ✅ Language tags
- ✅ Blank nodes
- ✅ RDF-star quoted triples
- ✅ Edge cases (empty values, special characters)

## Areas for Contribution

We especially welcome contributions in:

### 📝 Documentation
- Improve existing docs
- Add more examples
- Create tutorials
- Translate documentation

### 🔧 Tools
- Parser implementations
- Validators
- IDE plugins
- Library integrations

### 🧪 Testing
- Add test cases
- Improve test coverage
- Create benchmarks
- Test edge cases

### 💡 Features
- XSLT improvements
- New optimizations
- Additional examples
- Tool integrations

### 🐛 Bug Fixes
- Fix reported issues
- Improve error handling
- Edge case handling

## Recognition

Contributors are recognized in:
- CHANGELOG.md
- README.md (Contributors section)
- Release notes

## Questions?

- 💬 **Discussions**: https://github.com/yourusername/rdfxsimple-spec/discussions
- 📧 **Email**: contribute@example.org
- 🐛 **Issues**: https://github.com/yourusername/rdfxsimple-spec/issues

Thank you for contributing to RDF-XSimple! 🎉
