
.SUFFIXES:

.SUFFIXES: .tex .pdf

.PHONY: default pdf modern resume cover-letter open-resume open-modern open-cover clean clobber clean-pdfs help

# Output directory for PDFs
PDF_DIR = cv-pdf
REGULAR_DIR = $(PDF_DIR)/regular
CREAM_DIR = $(PDF_DIR)/cream
DARK_DIR = $(PDF_DIR)/dark

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
TEXT_COLOR ?= black

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
echo "Applying filters to LaTeX file: $(2)"; \
if [ -n "$(SECTIONS_TO_EXCLUDE)" ]; then \
	sed 's/PAGECOLOR_PLACEHOLDER/$(PAGE_COLOR)/g' $(1) | \
	sed 's/TEXTCOLOR_PLACEHOLDER/$(TEXT_COLOR)/g' | \
	sed $(call generate_section_filter_sed,$(3)) > $(2); \
else \
	sed 's/PAGECOLOR_PLACEHOLDER/$(PAGE_COLOR)/g' $(1) | \
	sed 's/TEXTCOLOR_PLACEHOLDER/$(TEXT_COLOR)/g' > $(2); \
fi
endef

# Default build target - build all themes
default: all-themes

# Create output directories
$(PDF_DIR):
	@mkdir -p $(PDF_DIR)

$(REGULAR_DIR): | $(PDF_DIR)
	@mkdir -p $(REGULAR_DIR)

$(CREAM_DIR): | $(PDF_DIR)
	@mkdir -p $(CREAM_DIR)

$(DARK_DIR): | $(PDF_DIR)
	@mkdir -p $(DARK_DIR)

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

# Dark theme recipes
dark-resume:
	@echo "Building resume with dark theme (black background, white text)..."
	$(MAKE) resume PAGE_COLOR=black TEXT_COLOR=white

dark-modern:
	@echo "Building modern resume with dark theme (black background, white text)..."
	$(MAKE) modern PAGE_COLOR=black TEXT_COLOR=white

dark-all:
	@echo "Building all documents with dark theme (black background, white text)..."
	$(MAKE) resume PAGE_COLOR=black TEXT_COLOR=white
	$(MAKE) modern PAGE_COLOR=black TEXT_COLOR=white
	$(MAKE) cover-letter PAGE_COLOR=black TEXT_COLOR=white

# Cream theme recipes
cream-resume:
	@echo "Building resume with cream theme (warm off-white background, dark text)..."
	$(MAKE) resume PAGE_COLOR='white!97!yellow' TEXT_COLOR='black!80'

cream-modern:
	@echo "Building modern resume with cream theme (warm off-white background, dark text)..."
	$(MAKE) modern PAGE_COLOR='white!97!yellow' TEXT_COLOR='black!80'

cream-all:
	@echo "Building all documents with cream theme (warm off-white background, dark text)..."
	$(MAKE) resume PAGE_COLOR='white!97!yellow' TEXT_COLOR='black!80'
	$(MAKE) modern PAGE_COLOR='white!97!yellow' TEXT_COLOR='black!80'
	$(MAKE) cover-letter PAGE_COLOR='white!97!yellow' TEXT_COLOR='black!80'

# Build all themes in organized folders
all-themes: | $(REGULAR_DIR) $(CREAM_DIR) $(DARK_DIR)
	@echo "Building all documents in all themes..."
	@echo "=== Building Regular Theme ==="
	$(MAKE) build-theme-set THEME_DIR=$(REGULAR_DIR) THEME_PAGE_COLOR='white!95!black' THEME_TEXT_COLOR=black THEME_NAME=regular
	@echo "=== Building Cream Theme ==="
	$(MAKE) build-theme-set THEME_DIR=$(CREAM_DIR) THEME_PAGE_COLOR='white!97!yellow' THEME_TEXT_COLOR='black!80' THEME_NAME=cream
	@echo "=== Building Dark Theme ==="
	$(MAKE) build-theme-set THEME_DIR=$(DARK_DIR) THEME_PAGE_COLOR=black THEME_TEXT_COLOR=white THEME_NAME=dark
	@echo ""
	@echo "All themes built successfully!"
	@echo "Regular theme: $(REGULAR_DIR)/"
	@echo "Cream theme:   $(CREAM_DIR)/"
	@echo "Dark theme:    $(DARK_DIR)/"

# Helper target to build a complete theme set
build-theme-set:
	@echo "Building $(THEME_NAME) theme in $(THEME_DIR)/"
	@$(MAKE) build-resume-to-dir PDF_TARGET_DIR=$(THEME_DIR) PAGE_COLOR=$(THEME_PAGE_COLOR) TEXT_COLOR=$(THEME_TEXT_COLOR)
	@$(MAKE) build-modern-to-dir PDF_TARGET_DIR=$(THEME_DIR) PAGE_COLOR=$(THEME_PAGE_COLOR) TEXT_COLOR=$(THEME_TEXT_COLOR)
	@$(MAKE) build-cover-to-dir PDF_TARGET_DIR=$(THEME_DIR) PAGE_COLOR=$(THEME_PAGE_COLOR) TEXT_COLOR=$(THEME_TEXT_COLOR)

# Build individual documents to specific directories
build-resume-to-dir:
	@echo "Building resume to $(PDF_TARGET_DIR)/"
	$(call show_section_info)
	$(call apply_tex_filters,cv/resume.tex,cv/resume_temp.tex,regular)
	cd cv && pdflatex -output-directory=../$(PDF_TARGET_DIR) resume_temp.tex
	cd cv && mv ../$(PDF_TARGET_DIR)/resume_temp.pdf ../$(PDF_TARGET_DIR)/resume.pdf
	cd cv && rm -f resume_temp.tex ../$(PDF_TARGET_DIR)/*.aux ../$(PDF_TARGET_DIR)/*.log ../$(PDF_TARGET_DIR)/*.out

build-modern-to-dir:
	@echo "Building modern resume to $(PDF_TARGET_DIR)/"
	$(call show_section_info)
	$(call apply_tex_filters,cv/resume_modern.tex,cv/resume_modern_temp.tex,modern)
	cd cv && pdflatex -output-directory=../$(PDF_TARGET_DIR) resume_modern_temp.tex
	cd cv && mv ../$(PDF_TARGET_DIR)/resume_modern_temp.pdf ../$(PDF_TARGET_DIR)/resume_modern.pdf
	cd cv && rm -f resume_modern_temp.tex ../$(PDF_TARGET_DIR)/*.aux ../$(PDF_TARGET_DIR)/*.log ../$(PDF_TARGET_DIR)/*.out

build-cover-to-dir:
	@echo "Building cover letter to $(PDF_TARGET_DIR)/"
	@sed 's/PAGECOLOR_PLACEHOLDER/$(PAGE_COLOR)/g' cover-letter/coverletter.tex | \
	sed 's/TEXTCOLOR_PLACEHOLDER/$(TEXT_COLOR)/g' > cover-letter/coverletter_temp.tex
	cd cover-letter && pdflatex -output-directory=../$(PDF_TARGET_DIR) coverletter_temp.tex
	cd cover-letter && mv ../$(PDF_TARGET_DIR)/coverletter_temp.pdf ../$(PDF_TARGET_DIR)/coverletter.pdf
	cd cover-letter && rm -f coverletter_temp.tex ../$(PDF_TARGET_DIR)/*.aux ../$(PDF_TARGET_DIR)/*.log ../$(PDF_TARGET_DIR)/*.out

# Dependencies
$(RESUME_PDF): $(RESUME_SRC).tex cv/resume.cls | $(PDF_DIR)
	@echo "Building resume with page color: $(PAGE_COLOR)..."
	$(call show_section_info)
	$(call apply_tex_filters,cv/resume.tex,cv/resume_temp.tex,regular)
	cd cv && pdflatex -output-directory=../$(PDF_DIR) resume_temp.tex
	cd cv && mv ../$(PDF_DIR)/resume_temp.pdf ../$(PDF_DIR)/resume.pdf
	cd cv && rm -f resume_temp.tex ../$(PDF_DIR)/*.aux ../$(PDF_DIR)/*.log ../$(PDF_DIR)/*.out
	@if grep -q 'There were undefined references' $(PDF_DIR)/resume_temp.log 2>/dev/null; then \
		$(call apply_tex_filters,cv/resume.tex,cv/resume_temp.tex,regular); \
		cd cv && bibtex ../$(PDF_DIR)/resume_temp && pdflatex -output-directory=../$(PDF_DIR) resume_temp.tex; \
		cd cv && mv ../$(PDF_DIR)/resume_temp.pdf ../$(PDF_DIR)/resume.pdf; \
		cd cv && rm -f resume_temp.tex; \
	fi
	@if grep -q 'Rerun' $(PDF_DIR)/resume_temp.log 2>/dev/null; then \
		$(call apply_tex_filters,cv/resume.tex,cv/resume_temp.tex,regular); \
		cd cv && pdflatex -output-directory=../$(PDF_DIR) resume_temp.tex; \
		cd cv && mv ../$(PDF_DIR)/resume_temp.pdf ../$(PDF_DIR)/resume.pdf; \
		cd cv && rm -f resume_temp.tex; \
	fi
	@if grep -q 'Rerun' $(PDF_DIR)/resume_temp.log 2>/dev/null; then \
		$(call apply_tex_filters,cv/resume.tex,cv/resume_temp.tex,regular); \
		cd cv && pdflatex -output-directory=../$(PDF_DIR) resume_temp.tex; \
		cd cv && mv ../$(PDF_DIR)/resume_temp.pdf ../$(PDF_DIR)/resume.pdf; \
		cd cv && rm -f resume_temp.tex; \
	fi

$(MODERN_PDF): $(MODERN_SRC).tex cv/resume.cls | $(PDF_DIR)
	@echo "Building modern resume with page color: $(PAGE_COLOR)..."
	$(call show_section_info)
	$(call apply_tex_filters,cv/resume_modern.tex,cv/resume_modern_temp.tex,modern)
	cd cv && pdflatex -output-directory=../$(PDF_DIR) resume_modern_temp.tex
	cd cv && mv ../$(PDF_DIR)/resume_modern_temp.pdf ../$(PDF_DIR)/resume_modern.pdf
	cd cv && rm -f resume_modern_temp.tex ../$(PDF_DIR)/*.aux ../$(PDF_DIR)/*.log ../$(PDF_DIR)/*.out
	@if grep -q 'There were undefined references' $(PDF_DIR)/resume_modern_temp.log 2>/dev/null; then \
		$(call apply_tex_filters,cv/resume_modern.tex,cv/resume_modern_temp.tex,modern); \
		cd cv && bibtex ../$(PDF_DIR)/resume_modern_temp && pdflatex -output-directory=../$(PDF_DIR) resume_modern_temp.tex; \
		cd cv && mv ../$(PDF_DIR)/resume_modern_temp.pdf ../$(PDF_DIR)/resume_modern.pdf; \
		cd cv && rm -f resume_modern_temp.tex; \
	fi
	@if grep -q 'Rerun' $(PDF_DIR)/resume_modern_temp.log 2>/dev/null; then \
		$(call apply_tex_filters,cv/resume_modern.tex,cv/resume_modern_temp.tex,modern); \
		cd cv && pdflatex -output-directory=../$(PDF_DIR) resume_modern_temp.tex; \
		cd cv && mv ../$(PDF_DIR)/resume_modern_temp.pdf ../$(PDF_DIR)/resume_modern.pdf; \
		cd cv && rm -f resume_modern_temp.tex; \
	fi
	@if grep -q 'Rerun' $(PDF_DIR)/resume_modern_temp.log 2>/dev/null; then \
		$(call apply_tex_filters,cv/resume_modern.tex,cv/resume_modern_temp.tex,modern); \
		cd cv && pdflatex -output-directory=../$(PDF_DIR) resume_modern_temp.tex; \
		cd cv && mv ../$(PDF_DIR)/resume_modern_temp.pdf ../$(PDF_DIR)/resume_modern.pdf; \
		cd cv && rm -f resume_modern_temp.tex; \
	fi

$(COVER_PDF): $(COVER_SRC).tex cover-letter/coverletter.cls | $(PDF_DIR)
	@echo "Building cover letter with page color: $(PAGE_COLOR)..."
	@echo "Applying filters to LaTeX file: cover-letter/coverletter_temp.tex"
	@sed 's/PAGECOLOR_PLACEHOLDER/$(PAGE_COLOR)/g' cover-letter/coverletter.tex | \
	sed 's/TEXTCOLOR_PLACEHOLDER/$(TEXT_COLOR)/g' > cover-letter/coverletter_temp.tex
	cd cover-letter && pdflatex -output-directory=../$(PDF_DIR) coverletter_temp.tex
	cd cover-letter && mv ../$(PDF_DIR)/coverletter_temp.pdf ../$(PDF_DIR)/coverletter.pdf
	cd cover-letter && rm -f coverletter_temp.tex ../$(PDF_DIR)/*.aux ../$(PDF_DIR)/*.log ../$(PDF_DIR)/*.out

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

# Clean auxiliary files and PDFs
clean:
	@echo "Cleaning auxiliary files and PDFs..."
	cd cv && rm -f *.aux *.bbl *.blg *.log *.toc *.dvi *.ind *.ilg *.nls *.nlo *.out
	@if [ -d "$(PDF_DIR)" ]; then \
		rm -f $(PDF_DIR)/*.pdf $(PDF_DIR)/*.aux $(PDF_DIR)/*.log $(PDF_DIR)/*.out $(PDF_DIR)/*.bbl $(PDF_DIR)/*.blg; \
		rm -rf $(REGULAR_DIR) $(CREAM_DIR) $(DARK_DIR); \
		echo "Cleaned PDFs and auxiliary files from $(PDF_DIR)/ and all theme directories"; \
	fi

# Remove auxiliary files from PDF directory (preserves PDFs)
clobber:
	@echo "Cleaning auxiliary files..."
	cd cv && rm -f *.aux *.bbl *.blg *.log *.toc *.dvi *.ind *.ilg *.nls *.nlo *.out
	@echo "Cleaning auxiliary files from $(PDF_DIR)/..."
	@if [ -d "$(PDF_DIR)" ]; then \
		rm -f $(PDF_DIR)/*.aux $(PDF_DIR)/*.log $(PDF_DIR)/*.out $(PDF_DIR)/*.bbl $(PDF_DIR)/*.blg; \
		if [ -d "$(REGULAR_DIR)" ]; then rm -f $(REGULAR_DIR)/*.aux $(REGULAR_DIR)/*.log $(REGULAR_DIR)/*.out $(REGULAR_DIR)/*.bbl $(REGULAR_DIR)/*.blg; fi; \
		if [ -d "$(CREAM_DIR)" ]; then rm -f $(CREAM_DIR)/*.aux $(CREAM_DIR)/*.log $(CREAM_DIR)/*.out $(CREAM_DIR)/*.bbl $(CREAM_DIR)/*.blg; fi; \
		if [ -d "$(DARK_DIR)" ]; then rm -f $(DARK_DIR)/*.aux $(DARK_DIR)/*.log $(DARK_DIR)/*.out $(DARK_DIR)/*.bbl $(DARK_DIR)/*.blg; fi; \
		echo "Cleaned auxiliary files from $(PDF_DIR)/ and theme directories (PDFs preserved)"; \
	else \
		echo "$(PDF_DIR)/ directory does not exist"; \
	fi

# Remove PDFs (use with caution)
clean-pdfs:
	@echo "Removing PDF files from $(PDF_DIR)/..."
	@if [ -d "$(PDF_DIR)" ]; then \
		rm -f $(PDF_DIR)/*.pdf; \
		if [ -d "$(REGULAR_DIR)" ]; then rm -f $(REGULAR_DIR)/*.pdf; fi; \
		if [ -d "$(CREAM_DIR)" ]; then rm -f $(CREAM_DIR)/*.pdf; fi; \
		if [ -d "$(DARK_DIR)" ]; then rm -f $(DARK_DIR)/*.pdf; fi; \
		echo "Removed PDF files from $(PDF_DIR)/ and all theme directories"; \
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
	@echo "  dark-resume - Build original resume with dark theme"
	@echo "  dark-modern - Build modern resume with dark theme"
	@echo "  dark-all    - Build all documents with dark theme"
	@echo "  cream-resume- Build original resume with cream theme"
	@echo "  cream-modern- Build modern resume with cream theme"
	@echo "  cream-all   - Build all documents with cream theme"
	@echo "  all-themes  - Build all documents in all themes (organized in folders)"
	@echo "  open-resume - Open original resume PDF"
	@echo "  open-modern - Open modern resume PDF"
	@echo "  open-cover  - Open cover letter PDF"
	@echo "  watch-resume- Watch and rebuild original resume"
	@echo "  watch-modern- Watch and rebuild modern resume"
	@echo "  clean       - Remove auxiliary files and PDFs"
	@echo "  clobber     - Remove auxiliary files from $(PDF_DIR)/ (preserves PDFs)"
	@echo "  clean-pdfs  - Remove PDF files from $(PDF_DIR)/ (use with caution)"
	@echo "  help        - Show this help message"
	@echo ""
	@echo "Configuration:"
	@echo "  PAGE_COLOR  - Set page background color (default: $(PAGE_COLOR))"
	@echo "  TEXT_COLOR  - Set text color (default: $(TEXT_COLOR))"
	@echo ""
	@echo "Examples:"
	@echo "  make resume PAGE_COLOR=white                    # Pure white background"
	@echo "  make pdf PAGE_COLOR='white!98!black'           # Very light off-white (quoted)"
	@echo "  make modern PAGE_COLOR='white!90!yellow'       # Cream background (quoted)"
	@echo "  make resume PAGE_COLOR=gray!10                 # Light gray background"
	@echo "  make resume PAGE_COLOR=black TEXT_COLOR=white  # Black background, white text"
	@echo ""
	@echo "PDFs are generated in: $(PDF_DIR)/"

