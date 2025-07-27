# LaTeX Resume Build System

![Build Status](https://github.com/sunhick/resume/workflows/Build%20Resume%20PDFs/badge.svg)

This repository contains LaTeX resume templates with an automated build system using Make and GitHub Actions CI/CD.

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

## Automated Builds

This repository uses GitHub Actions to automatically build resume PDFs on every push and pull request. The CI/CD pipeline:

- **Builds multiple configurations**: Tests default off-white, pure white, and cream page backgrounds
- **Generates artifacts**: Downloadable PDF files available from the Actions tab
- **Validates compilation**: Ensures LaTeX code compiles correctly across different configurations
- **Provides quick feedback**: Build status visible in pull requests and commits

### Downloading Built PDFs

1. Go to the [Actions tab](../../actions) in this repository
2. Click on the latest successful workflow run
3. Download artifacts:
   - `resume-pdfs-default` - Default off-white background
   - `resume-pdfs-white` - Pure white background
   - `resume-pdfs-cream` - Cream background

### Manual Builds

You can trigger manual builds with custom page colors:

1. Go to the [Actions tab](../../actions)
2. Click "Build Resume PDFs" workflow
3. Click "Run workflow"
4. Enter a custom page color (e.g., `white!98!black`, `gray!5`)
5. Click "Run workflow" to start the build
