# LaTeX Resume Build System

This repository contains LaTeX resume templates with an automated build system using Make.

## Files

- `cv/resume.tex` - Original resume format
- `cv/resume_modern.tex` - Modern resume format with cleaner styling
- `cv/resume.cls` - Shared LaTeX class file for both formats
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

### Customization

```bash
# Configure page background color
make resume PAGE_COLOR=white                    # Pure white background
make pdf PAGE_COLOR='white!98!black'           # Very light off-white (quoted)
make modern PAGE_COLOR='white!90!yellow'       # Cream background (quoted)
make resume PAGE_COLOR=gray!10                 # Light gray background

# Default page color is white!95!black (subtle off-white)
# Note: Use quotes around colors containing ! to avoid bash history expansion
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
