# GitHub CI/CD Setup Documentation

## Overview

This repository now includes a comprehensive GitHub Actions CI/CD pipeline that automatically builds LaTeX resume PDFs on every push, pull request, and manual trigger.

## Workflow Files

### `.github/workflows/build.yml`
Main production workflow that:
- Triggers on push to main/master/develop branches
- Triggers on pull requests to main/master
- Supports manual dispatch with custom page colors
- Builds resume PDFs with multiple page color configurations
- Uploads artifacts for download

### `.github/workflows/test-build.yml`
Test workflow for manual validation:
- Manual trigger only
- Tests basic build functionality
- Validates LaTeX environment setup

## Features

### 🚀 Automated Building
- **Multi-configuration builds**: Tests 3 different page colors automatically
- **Pull request validation**: Ensures changes don't break LaTeX compilation
- **Artifact generation**: Downloadable PDFs from every successful build

### 🎨 Page Color Matrix
The workflow automatically tests these configurations:
- **Default**: `white!95!black` (subtle off-white)
- **White**: `white` (pure white background)
- **Cream**: `white!90!yellow` (warm cream background)

### 📦 Artifact Management
Generated artifacts:
- `resume-pdfs-default` - Default off-white background
- `resume-pdfs-white` - Pure white background
- `resume-pdfs-cream` - Cream background
- `resume-pdfs-custom` - Manual builds with custom colors

### ⚡ Performance Optimizations
- **Caching**: LaTeX packages cached between runs
- **Parallel execution**: Matrix builds run simultaneously
- **Fast feedback**: Typical build time under 3 minutes

## Usage

### Automatic Builds
- Push to main/master/develop → Automatic build
- Create pull request → Automatic validation
- Merge pull request → Updated artifacts

### Manual Builds
1. Go to Actions tab → "Build Resume PDFs"
2. Click "Run workflow"
3. Enter custom page color (optional)
4. Click "Run workflow"

### Downloading PDFs
1. Go to Actions tab
2. Click on latest successful run
3. Download desired artifact
4. Extract ZIP to get PDF files

## Technical Details

### LaTeX Environment
- **OS**: Ubuntu latest
- **Packages**: texlive-latex-extra, texlive-fonts-recommended, texlive-fonts-extra, texlive-xetex
- **Caching**: LaTeX packages cached based on file changes

### Build Process
1. Checkout repository
2. Setup and cache LaTeX environment
3. Clean previous builds
4. Build PDFs with specified page color
5. Validate PDF generation
6. Upload artifacts

### Error Handling
- Build failures prevent PR merging
- Clear error messages for LaTeX compilation issues
- Validation checks ensure PDFs are generated correctly

## Security

- **Pinned actions**: All actions use specific versions (@v4)
- **Minimal permissions**: Workflow uses only required permissions
- **No sensitive data**: Placeholder information in PDFs
- **Trusted sources**: Only official GitHub and community actions

## Monitoring

- **Status badges**: Build status visible in README
- **PR checks**: Build status shown in pull requests
- **Artifact retention**: 90 days (GitHub default)
- **Build history**: Full history available in Actions tab

## Troubleshooting

### Common Issues

**LaTeX compilation errors:**
- Check workflow logs for detailed error messages
- Verify LaTeX syntax in changed files
- Test locally with `make pdf` before pushing

**Missing artifacts:**
- Ensure build completed successfully (green checkmark)
- Check that PDFs were generated in build logs
- Verify artifact upload step succeeded

**Slow builds:**
- First build may be slower (no cache)
- Subsequent builds should be faster with cached packages
- Matrix builds run in parallel for efficiency

### Getting Help

1. Check workflow logs in Actions tab
2. Review error messages in failed builds
3. Test builds locally with same commands
4. Check LaTeX installation and package availability

## Future Enhancements

Potential improvements:
- **Release automation**: Auto-create releases on tags
- **PR previews**: Comment with PDF links on pull requests
- **Build notifications**: Slack/email notifications
- **Performance metrics**: Build time and size tracking
- **Multi-format support**: Additional output formats (PNG, SVG)

## Maintenance

### Updating Dependencies
- Monitor for action updates (Dependabot recommended)
- Test LaTeX package updates periodically
- Review and update cached package versions

### Monitoring Performance
- Check build times in Actions tab
- Monitor cache hit rates
- Optimize matrix configurations as needed
