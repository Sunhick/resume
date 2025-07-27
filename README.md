# LaTeX Resume Build System

This repository contains LaTeX resume templates with an automated build system using Make.

## Files

- `CV/resume.tex` - Original resume format
- `CV/resume_modern.tex` - Modern resume format with cleaner styling
- `CV/resume.cls` - Shared LaTeX class file for both formats
- `Makefile` - Build automation
- `cv-pdf/` - Generated PDF output directory (auto-created, git-ignored)

## Usage

### Building Resumes

```bash
# Build original resume (default)
make
# or
make resume

# Build modern resume
make modern

# Build both resumes
make pdf
```

### Opening PDFs

```bash
# Open original resume
make open-resume

# Open modern resume
make open-modern
```

### Development

```bash
# Watch and auto-rebuild original resume on changes
make watch-resume

# Watch and auto-rebuild modern resume on changes
make watch-modern
```

### Cleanup

```bash
# Remove auxiliary files (.aux, .log, etc.)
make clean

# Remove auxiliary files from cv-pdf/ (preserves PDFs and directory)
make clobber

# Remove PDF files from cv-pdf/ (use with caution)
make clean-pdfs
```

### Help

```bash
# Show all available targets
make help
```

## Requirements

- macOS with MacTeX installed
- `pdflatex` command available in PATH
- Optional: Ruby for watch functionality

## Git Integration

The project includes a comprehensive `.gitignore` file that excludes:
- LaTeX auxiliary files (`.aux`, `.log`, `.out`, etc.)
- macOS system files (`.DS_Store`)
- Editor temporary files
- Build artifacts

Generated PDFs are currently tracked in git, but you can exclude them by uncommenting the `*.pdf` line in `.gitignore` if you prefer to only track source files.

## Output

Generated PDFs are saved in the `cv-pdf/` directory:
- `cv-pdf/resume.pdf` - Original format
- `cv-pdf/resume_modern.pdf` - Modern format

The `cv-pdf/` directory is automatically created during build and the generated PDFs are tracked in git.

Both resumes use reduced left margins for better space utilization.
