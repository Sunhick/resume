#!/bin/bash

# Build script for LaTeX resume on macOS with MacTeX

echo "Building resume..."

# Change to CV directory
cd CV

# Build the resume
pdflatex resume.tex

# Clean up auxiliary files
rm -f *.aux *.log *.out

echo "Resume built successfully! Check CV/resume.pdf"

# Optional: Open the PDF with default viewer
if command -v open &> /dev/null; then
    echo "Opening PDF..."
    open resume.pdf
fi
