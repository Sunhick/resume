#!/bin/bash

# Build script for modern LaTeX resume on macOS with MacTeX

echo "Building modern resume..."

# Change to CV directory
cd CV

# Build the modern resume
pdflatex resume_modern.tex

# Clean up auxiliary files
rm -f *.aux *.log *.out

echo "Modern resume built successfully! Check CV/resume_modern.pdf"

# Optional: Open the PDF with default viewer
if command -v open &> /dev/null; then
    echo "Opening PDF..."
    open resume_modern.pdf
fi
