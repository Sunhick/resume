
.SUFFIXES:

.SUFFIXES: .tex .pdf

.PHONY: default pdf modern resume cover-letter open-resume open-modern open-cover clean clobber clean-pdfs help

# Output directory for PDFs
PDF_DIR = cv-pdf

# Source files
RESUME_SRC = cv/resume
MODERN_SRC = cv/resume_modern
COVER_SRC = cover-letter/coverletter

# Output PDF files
RESUME_PDF = $(PDF_DIR)/resume.pdf
MODERN_PDF = $(PDF_DIR)/resume_modern.pdf
COVER_PDF = $(PDF_DIR)/coverletter.pdf

# Page color configuration (can be overridden)
PAGE_COLOR ?= white!95!black

# Section filtering configuration
ALL_SECTIONS := summary experience education technical_skills projects research_interests honors_awards
INCLUDE_SECTIONS ?=
EXCLUDE_SECTIONS ?=

# Function to normalize section names (lowercase, convert commas to spaces, normalize whitespace)
normalize_sections = $(shell echo "$(1)" | tr '[:upper:]' '[:lower:]' | tr ',' ' ' | tr -s ' ')

# Function to validate section names against available sections
validate_sections = $(filter $(ALL_SECTIONS),$(call normalize_sections,$(1)))

# Function to get invalid section names
invalid_sections = $(filter-out $(ALL_SECTIONS),$(call normalize_sections,$(1)))

# Determine which sections to include based on parameters
ifdef INCLUDE_SECTIONS
    FILTERED_SECTIONS := $(call validate_sections,$(INCLUDE_SECTIONS))
    INVALID_INCLUDE := $(call invalid_sections,$(INCLUDE_SECTIONS))
else ifdef EXCLUDE_SECTIONS
    EXCLUDED_SECTIONS := $(call validate_sections,$(EXCLUDE_SECTIONS))
    INVALID_EXCLUDE := $(call invalid_sections,$(EXCLUDE_SECTIONS))
    FILTERED_SECTIONS := $(filter-out $(EXCLUDED_SECTIONS),$(ALL_SECTIONS))
else
    FILTERED_SECTIONS := $(ALL_SECTIONS)
endif

# Generate sections to exclude for sed processing
SECTIONS_TO_EXCLUDE := $(filter-out $(FILTERED_SECTIONS),$(ALL_SECTIONS))

# Function to display section filtering information
define show_section_info
	@echo "Section filtering information:"
	@echo "  Available sections: $(ALL_SECTIONS)"
	@echo "  Including sections: $(FILTERED_SECTIONS)"
	@if [ -n "$(SECTIONS_TO_EXCLUDE)" ]; then echo "  Excluding sections: $(SECTIONS_TO_EXCLUDE)"; fi
	@if [ -n "$(INVALID_INCLUDE)" ]; then echo "  Warning: Invalid sections in INCLUDE_SECTIONS ignored: $(INVALID_INCLUDE)"; fi
	@if [ -n "$(INVALID_EXCLUDE)" ]; then echo "  Warning: Invalid sections in EXCLUDE_SECTIONS ignored: $(INVALID_EXCLUDE)"; fi
	@if [ -n "$(INCLUDE_SECTIONS)" ] && [ -n "$(EXCLUDE_SECTIONS)" ]; then echo "  Info: Using INCLUDE_SECTIONS, ignoring EXCLUDE_SECTIONS"; fi
	@echo ""
endef

# Function to generate sed command for commenting out excluded sections
# Usage: $(call generate_section_filter_sed,variant)
# where variant is either "regular" or "modern"
define generate_section_filter_sed
$(foreach section,$(SECTIONS_TO_EXCLUDE),-e 's|^\\input{sections/$(1)/$(section)}|%\\input{sections/$(1)/$(section)}|g')
endef

# Function to create temporary LaTeX file with section filtering applied
# Usage: $(call create_filtered_tex,source_file,temp_file,variant)
define create_filtered_tex
	@echo "Creating filtered LaTeX file: $(2)"
	@if [ -n "$(SECTIONS_TO_EXCLUDE)" ]; then \
		sed $(call generate_section_filter_sed,$(3)) $(1) > $(2); \
	else \
		cp $(1) $(2); \
	fi
endef

# Function to apply both page color and section filtering to LaTeX file
# Usage: $(call apply_tex_filters,source_file,temp_file,variant)
define apply_tex_filters
	@echo "Applying filters to LaTeX file: $(2)"
	@if [ -n "$(SECTIONS_TO_EXCLUDE)" ]; then \
		sed 's/PAGECOLOR_PLACEHOLDER/$(PAGE_COLOR)/g' $(1) | \
		sed $(call generate_section_filter_sed,$(3)) > $(2); \
	else \
		sed 's/PAGECOLOR_PLACEHOLDER/$(PAGE_COLOR)/g' $(1) > $(2); \
	fi
endef

# Default build target - build all documents
default: resume modern cover-letter

# Create output directory
$(PDF_DIR):
	@mkdir -p $(PDF_DIR)

# Build original resume
resume: $(RESUME_PDF)
	@echo "Resume built successfully! Check $(RESUME_PDF)"

# Build modern resume
modern: $(MODERN_PDF)
	@echo "Modern resume built successfully! Check $(MODERN_PDF)"

# Build cover letter
cover-letter: $(COVER_PDF)
	@echo "Cover letter built successfully! Check $(COVER_PDF)"

# Build all documents
pdf: resume modern cover-letter

# Dependencies
$(RESUME_PDF): $(RESUME_SRC).tex cv/resume.cls | $(PDF_DIR)
	@echo "Building resume with page color: $(PAGE_COLOR)..."
	@sed 's/PAGECOLOR_PLACEHOLDER/$(PAGE_COLOR)/g' cv/resume.tex > cv/resume_temp.tex
	cd cv && pdflatex -output-directory=../$(PDF_DIR) resume_temp.tex
	cd cv && mv ../$(PDF_DIR)/resume_temp.pdf ../$(PDF_DIR)/resume.pdf
	cd cv && rm -f resume_temp.tex ../$(PDF_DIR)/*.aux ../$(PDF_DIR)/*.log ../$(PDF_DIR)/*.out
	@if grep -q 'There were undefined references' $(PDF_DIR)/resume_temp.log 2>/dev/null; then \
		@sed 's/PAGECOLOR_PLACEHOLDER/$(PAGE_COLOR)/g' cv/resume.tex > cv/resume_temp.tex; \
		cd cv && bibtex ../$(PDF_DIR)/resume_temp && pdflatex -output-directory=../$(PDF_DIR) resume_temp.tex; \
		cd cv && mv ../$(PDF_DIR)/resume_temp.pdf ../$(PDF_DIR)/resume.pdf; \
		cd cv && rm -f resume_temp.tex; \
	fi
	@if grep -q 'Rerun' $(PDF_DIR)/resume_temp.log 2>/dev/null; then \
		@sed 's/PAGECOLOR_PLACEHOLDER/$(PAGE_COLOR)/g' cv/resume.tex > cv/resume_temp.tex; \
		cd cv && pdflatex -output-directory=../$(PDF_DIR) resume_temp.tex; \
		cd cv && mv ../$(PDF_DIR)/resume_temp.pdf ../$(PDF_DIR)/resume.pdf; \
		cd cv && rm -f resume_temp.tex; \
	fi
	@if grep -q 'Rerun' $(PDF_DIR)/resume_temp.log 2>/dev/null; then \
		@sed 's/PAGECOLOR_PLACEHOLDER/$(PAGE_COLOR)/g' cv/resume.tex > cv/resume_temp.tex; \
		cd cv && pdflatex -output-directory=../$(PDF_DIR) resume_temp.tex; \
		cd cv && mv ../$(PDF_DIR)/resume_temp.pdf ../$(PDF_DIR)/resume.pdf; \
		cd cv && rm -f resume_temp.tex; \
	fi

$(MODERN_PDF): $(MODERN_SRC).tex cv/resume.cls | $(PDF_DIR)
	@echo "Building modern resume with page color: $(PAGE_COLOR)..."
	@sed 's/PAGECOLOR_PLACEHOLDER/$(PAGE_COLOR)/g' cv/resume_modern.tex > cv/resume_modern_temp.tex
	cd cv && pdflatex -output-directory=../$(PDF_DIR) resume_modern_temp.tex
	cd cv && mv ../$(PDF_DIR)/resume_modern_temp.pdf ../$(PDF_DIR)/resume_modern.pdf
	cd cv && rm -f resume_modern_temp.tex ../$(PDF_DIR)/*.aux ../$(PDF_DIR)/*.log ../$(PDF_DIR)/*.out
	@if grep -q 'There were undefined references' $(PDF_DIR)/resume_modern_temp.log 2>/dev/null; then \
		@sed 's/PAGECOLOR_PLACEHOLDER/$(PAGE_COLOR)/g' cv/resume_modern.tex > cv/resume_modern_temp.tex; \
		cd cv && bibtex ../$(PDF_DIR)/resume_modern_temp && pdflatex -output-directory=../$(PDF_DIR) resume_modern_temp.tex; \
		cd cv && mv ../$(PDF_DIR)/resume_modern_temp.pdf ../$(PDF_DIR)/resume_modern.pdf; \
		cd cv && rm -f resume_modern_temp.tex; \
	fi
	@if grep -q 'Rerun' $(PDF_DIR)/resume_modern_temp.log 2>/dev/null; then \
		@sed 's/PAGECOLOR_PLACEHOLDER/$(PAGE_COLOR)/g' cv/resume_modern.tex > cv/resume_modern_temp.tex; \
		cd cv && pdflatex -output-directory=../$(PDF_DIR) resume_modern_temp.tex; \
		cd cv && mv ../$(PDF_DIR)/resume_modern_temp.pdf ../$(PDF_DIR)/resume_modern.pdf; \
		cd cv && rm -f resume_modern_temp.tex; \
	fi
	@if grep -q 'Rerun' $(PDF_DIR)/resume_modern_temp.log 2>/dev/null; then \
		@sed 's/PAGECOLOR_PLACEHOLDER/$(PAGE_COLOR)/g' cv/resume_modern.tex > cv/resume_modern_temp.tex; \
		cd cv && pdflatex -output-directory=../$(PDF_DIR) resume_modern_temp.tex; \
		cd cv && mv ../$(PDF_DIR)/resume_modern_temp.pdf ../$(PDF_DIR)/resume_modern.pdf; \
		cd cv && rm -f resume_modern_temp.tex; \
	fi

$(COVER_PDF): $(COVER_SRC).tex cover-letter/coverletter.cls | $(PDF_DIR)
	@echo "Building cover letter..."
	cd cover-letter && pdflatex -output-directory=../$(PDF_DIR) coverletter.tex
	cd cover-letter && rm -f ../$(PDF_DIR)/*.aux ../$(PDF_DIR)/*.log ../$(PDF_DIR)/*.out

# Note: .tex.pdf rule removed - using explicit rules above for better control

# Open PDFs with default viewer (macOS)
open-resume: $(RESUME_PDF)
	@echo "Opening $(RESUME_PDF)..."
	@command -v open >/dev/null 2>&1 && open $(RESUME_PDF) || echo "open command not available"

open-modern: $(MODERN_PDF)
	@echo "Opening $(MODERN_PDF)..."
	@command -v open >/dev/null 2>&1 && open $(MODERN_PDF) || echo "open command not available"

open-cover: $(COVER_PDF)
	@echo "Opening $(COVER_PDF)..."
	@command -v open >/dev/null 2>&1 && open $(COVER_PDF) || echo "open command not available"

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
	cd cv && rm -f *.aux *.bbl *.blg *.log *.toc *.dvi *.ind *.ilg *.nls *.nlo *.out

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
	@echo "  default     - Build all documents (resume, modern, cover letter)"
	@echo "  resume      - Build original resume"
	@echo "  modern      - Build modern resume"
	@echo "  cover-letter- Build cover letter"
	@echo "  pdf         - Build all documents"
	@echo "  open-resume - Open original resume PDF"
	@echo "  open-modern - Open modern resume PDF"
	@echo "  open-cover  - Open cover letter PDF"
	@echo "  watch-resume- Watch and rebuild original resume"
	@echo "  watch-modern- Watch and rebuild modern resume"
	@echo "  clean       - Remove auxiliary files"
	@echo "  clobber     - Remove auxiliary files from $(PDF_DIR)/ (preserves PDFs)"
	@echo "  clean-pdfs  - Remove PDF files from $(PDF_DIR)/ (use with caution)"
	@echo "  help        - Show this help message"
	@echo ""
	@echo "Configuration:"
	@echo "  PAGE_COLOR  - Set page background color (default: $(PAGE_COLOR))"
	@echo ""
	@echo "Examples:"
	@echo "  make resume PAGE_COLOR=white                    # Pure white background"
	@echo "  make pdf PAGE_COLOR='white!98!black'           # Very light off-white (quoted)"
	@echo "  make modern PAGE_COLOR='white!90!yellow'       # Cream background (quoted)"
	@echo "  make resume PAGE_COLOR=gray!10                 # Light gray background"
	@echo ""
	@echo "PDFs are generated in: $(PDF_DIR)/"

