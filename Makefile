
.SUFFIXES:

.SUFFIXES: .tex .pdf

.PHONY: default pdf modern resume open-resume open-modern clean clobber help

# Default targets
RESUME = CV/resume
MODERN = CV/resume_modern

# Default build target
default: resume

# Build original resume
resume: $(RESUME).pdf
	@echo "Resume built successfully! Check $(RESUME).pdf"

# Build modern resume
modern: $(MODERN).pdf
	@echo "Modern resume built successfully! Check $(MODERN).pdf"

# Build both resumes
pdf: resume modern

# Dependencies
$(RESUME).pdf: $(RESUME).tex CV/resume.cls
$(MODERN).pdf: $(MODERN).tex CV/resume.cls

# Build rule for LaTeX files
.tex.pdf:
	@echo "Building $*..."
	cd $(dir $*) && pdflatex $(notdir $*)
	cd $(dir $*) && rm -f *.aux *.log *.out
	grep 'There were undefined references' $*.log > /dev/null 2>&1 && \
	   (cd $(dir $*) && bibtex $(notdir $*) && pdflatex $(notdir $*)) || true
	grep Rerun $*.log > /dev/null 2>&1 && \
	   (cd $(dir $*) && pdflatex $(notdir $*)) || true
	grep Rerun $*.log > /dev/null 2>&1 && \
	   (cd $(dir $*) && pdflatex $(notdir $*)) || true

# Open PDFs with default viewer (macOS)
open-resume: $(RESUME).pdf
	@echo "Opening $(RESUME).pdf..."
	@command -v open >/dev/null 2>&1 && open $(RESUME).pdf || echo "open command not available"

open-modern: $(MODERN).pdf
	@echo "Opening $(MODERN).pdf..."
	@command -v open >/dev/null 2>&1 && open $(MODERN).pdf || echo "open command not available"

# Legacy xpdf support
xpdf: resume
	@command -v xpdf >/dev/null 2>&1 && xpdf -z page $(RESUME).pdf & || echo "xpdf not available, use 'make open-resume' instead"

# Watch and rebuild (requires ruby)
watch-resume:
	@echo "Watching $(RESUME).tex for changes..."
	@ruby -e "file = '$(RESUME).tex'" \
	      -e "command = '$(MAKE) resume'" \
	      -e "lm = File.mtime file" \
	      -e "while true do" \
	      -e " m = File.mtime file" \
	      -e " system command unless m==lm" \
	      -e " lm = m" \
	      -e " sleep 0.25" \
	      -e "end"

watch-modern:
	@echo "Watching $(MODERN).tex for changes..."
	@ruby -e "file = '$(MODERN).tex'" \
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

# Remove all generated files including PDFs
clobber: clean
	@echo "Removing all generated files..."
	rm -f $(RESUME).pdf $(MODERN).pdf

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
	@echo "  clobber     - Remove all generated files"
	@echo "  help        - Show this help message"
