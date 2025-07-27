
.SUFFIXES:

.SUFFIXES: .tex .pdf

.PHONY: default pdf modern resume open-resume open-modern clean clobber clean-pdfs help

# Output directory for PDFs
PDF_DIR = cv-pdf

# Source files
RESUME_SRC = CV/resume
MODERN_SRC = CV/resume_modern

# Output PDF files
RESUME_PDF = $(PDF_DIR)/resume.pdf
MODERN_PDF = $(PDF_DIR)/resume_modern.pdf

# Default build target
default: resume

# Create output directory
$(PDF_DIR):
	@mkdir -p $(PDF_DIR)

# Build original resume
resume: $(RESUME_PDF)
	@echo "Resume built successfully! Check $(RESUME_PDF)"

# Build modern resume
modern: $(MODERN_PDF)
	@echo "Modern resume built successfully! Check $(MODERN_PDF)"

# Build both resumes
pdf: resume modern

# Dependencies
$(RESUME_PDF): $(RESUME_SRC).tex CV/resume.cls | $(PDF_DIR)
	@echo "Building resume..."
	cd CV && pdflatex -output-directory=../$(PDF_DIR) resume.tex
	cd CV && rm -f ../$(PDF_DIR)/*.aux ../$(PDF_DIR)/*.log ../$(PDF_DIR)/*.out
	@if grep -q 'There were undefined references' $(PDF_DIR)/resume.log 2>/dev/null; then \
		cd CV && bibtex ../$(PDF_DIR)/resume && pdflatex -output-directory=../$(PDF_DIR) resume.tex; \
	fi
	@if grep -q 'Rerun' $(PDF_DIR)/resume.log 2>/dev/null; then \
		cd CV && pdflatex -output-directory=../$(PDF_DIR) resume.tex; \
	fi
	@if grep -q 'Rerun' $(PDF_DIR)/resume.log 2>/dev/null; then \
		cd CV && pdflatex -output-directory=../$(PDF_DIR) resume.tex; \
	fi

$(MODERN_PDF): $(MODERN_SRC).tex CV/resume.cls | $(PDF_DIR)
	@echo "Building modern resume..."
	cd CV && pdflatex -output-directory=../$(PDF_DIR) resume_modern.tex
	cd CV && rm -f ../$(PDF_DIR)/*.aux ../$(PDF_DIR)/*.log ../$(PDF_DIR)/*.out
	@if grep -q 'There were undefined references' $(PDF_DIR)/resume_modern.log 2>/dev/null; then \
		cd CV && bibtex ../$(PDF_DIR)/resume_modern && pdflatex -output-directory=../$(PDF_DIR) resume_modern.tex; \
	fi
	@if grep -q 'Rerun' $(PDF_DIR)/resume_modern.log 2>/dev/null; then \
		cd CV && pdflatex -output-directory=../$(PDF_DIR) resume_modern.tex; \
	fi
	@if grep -q 'Rerun' $(PDF_DIR)/resume_modern.log 2>/dev/null; then \
		cd CV && pdflatex -output-directory=../$(PDF_DIR) resume_modern.tex; \
	fi

# Note: .tex.pdf rule removed - using explicit rules above for better control

# Open PDFs with default viewer (macOS)
open-resume: $(RESUME_PDF)
	@echo "Opening $(RESUME_PDF)..."
	@command -v open >/dev/null 2>&1 && open $(RESUME_PDF) || echo "open command not available"

open-modern: $(MODERN_PDF)
	@echo "Opening $(MODERN_PDF)..."
	@command -v open >/dev/null 2>&1 && open $(MODERN_PDF) || echo "open command not available"

# Legacy xpdf support
xpdf: resume
	@command -v xpdf >/dev/null 2>&1 && xpdf -z page $(RESUME_PDF) & || echo "xpdf not available, use 'make open-resume' instead"

# Watch and rebuild (requires ruby)
watch-resume:
	@echo "Watching $(RESUME_SRC).tex for changes..."
	@ruby -e "file = '$(RESUME_SRC).tex'" \
	      -e "command = '$(MAKE) resume'" \
	      -e "lm = File.mtime file" \
	      -e "while true do" \
	      -e " m = File.mtime file" \
	      -e " system command unless m==lm" \
	      -e " lm = m" \
	      -e " sleep 0.25" \
	      -e "end"

watch-modern:
	@echo "Watching $(MODERN_SRC).tex for changes..."
	@ruby -e "file = '$(MODERN_SRC).tex'" \
	      -e "command = '$(MAKE) modern'" \
	      -e "lm = File.mtime file" \
	      -e "while true do" \
	      -e " m = File.mtime file" \
	      -e " system command unless m==lm" \
	      -e " lm = m" \
	      -e " sleep 0.25" \
	      -e "end"

# Clean auxiliary files
clean:
	@echo "Cleaning auxiliary files..."
	cd CV && rm -f *.aux *.bbl *.blg *.log *.toc *.dvi *.ind *.ilg *.nls *.nlo *.out

# Remove auxiliary files from PDF directory (preserves PDFs)
clobber: clean
	@echo "Cleaning auxiliary files from $(PDF_DIR)/..."
	@if [ -d "$(PDF_DIR)" ]; then \
		rm -f $(PDF_DIR)/*.aux $(PDF_DIR)/*.log $(PDF_DIR)/*.out $(PDF_DIR)/*.bbl $(PDF_DIR)/*.blg; \
		echo "Cleaned auxiliary files from $(PDF_DIR)/ (PDFs preserved)"; \
	else \
		echo "$(PDF_DIR)/ directory does not exist"; \
	fi

# Remove PDFs (use with caution)
clean-pdfs:
	@echo "Removing PDF files from $(PDF_DIR)/..."
	@if [ -d "$(PDF_DIR)" ]; then \
		rm -f $(PDF_DIR)/*.pdf; \
		echo "Removed PDF files from $(PDF_DIR)/"; \
	else \
		echo "$(PDF_DIR)/ directory does not exist"; \
	fi

# Help target
help:
	@echo "Available targets:"
	@echo "  resume      - Build original resume (default)"
	@echo "  modern      - Build modern resume"
	@echo "  pdf         - Build both resumes"
	@echo "  open-resume - Open original resume PDF"
	@echo "  open-modern - Open modern resume PDF"
	@echo "  watch-resume- Watch and rebuild original resume"
	@echo "  watch-modern- Watch and rebuild modern resume"
	@echo "  clean       - Remove auxiliary files"
	@echo "  clobber     - Remove auxiliary files from $(PDF_DIR)/ (preserves PDFs)"
	@echo "  clean-pdfs  - Remove PDF files from $(PDF_DIR)/ (use with caution)"
	@echo "  help        - Show this help message"
	@echo ""
	@echo "PDFs are generated in: $(PDF_DIR)/"
