"""
Configuration management for the PDF-to-TeX resume system.
"""

import json
import os
from dataclasses import dataclass, asdict
from pathlib import Path
from typing import Dict, Optional, Any


@dataclass
class BuildConfig:
    """Configuration for the build system."""
    output_directory: str = "output"
    temp_directory: str = "temp"
    latex_engine: str = "pdflatex"
    clean_after_build: bool = True
    max_build_attempts: int = 3
    build_timeout: int = 60  # seconds


@dataclass
class TemplateConfig:
    """Configuration for template and styling."""
    template_name: str = "default"
    font_family: str = "Computer Modern"
    font_size: str = "11pt"
    margin_top: str = "1in"
    margin_bottom: str = "1in"
    margin_left: str = "1in"
    margin_right: str = "1in"
    line_spacing: str = "1.0"
    section_spacing: str = "0.5em"


@dataclass
class ParsingConfig:
    """Configuration for content parsing."""
    date_formats: list = None
    section_headers: list = None
    skill_categories: list = None

    def __post_init__(self):
        if self.date_formats is None:
            self.date_formats = [
                "%B %Y",  # January 2023
                "%b %Y",  # Jan 2023
                "%m/%Y",  # 01/2023
                "%Y-%m",  # 2023-01
                "%Y"      # 2023
            ]

        if self.section_headers is None:
            self.section_headers = [
                "experience", "work experience", "employment",
                "education", "academic background",
                "skills", "technical skills", "core competencies",
                "projects", "selected projects",
                "awards", "honors", "achievements"
            ]

        if self.skill_categories is None:
            self.skill_categories = [
                "programming languages", "frameworks", "databases",
                "tools", "technologies", "methodologies"
            ]


@dataclass
class SystemConfig:
    """Main system configuration."""
    build: BuildConfig
    template: TemplateConfig
    parsing: ParsingConfig

    def __init__(self):
        self.build = BuildConfig()
        self.template = TemplateConfig()
        self.parsing = ParsingConfig()


class ConfigManager:
    """Manages configuration loading, saving, and validation."""

    def __init__(self, config_file: str = "config.json"):
        self.config_file = config_file
        self.config = SystemConfig()
        self.load_config()

    def load_config(self) -> None:
        """Load configuration from file if it exists."""
        if os.path.exists(self.config_file):
            try:
                with open(self.config_file, 'r') as f:
                    data = json.load(f)

                # Update build config
                if 'build' in data:
                    for key, value in data['build'].items():
                        if hasattr(self.config.build, key):
                            setattr(self.config.build, key, value)

                # Update template config
                if 'template' in data:
                    for key, value in data['template'].items():
                        if hasattr(self.config.template, key):
                            setattr(self.config.template, key, value)

                # Update parsing config
                if 'parsing' in data:
                    for key, value in data['parsing'].items():
                        if hasattr(self.config.parsing, key):
                            setattr(self.config.parsing, key, value)

            except Exception as e:
                print(f"Error loading config file: {e}")
                print("Using default configuration")

    def save_config(self) -> bool:
        """Save current configuration to file."""
        try:
            config_data = {
                'build': asdict(self.config.build),
                'template': asdict(self.config.template),
                'parsing': asdict(self.config.parsing)
            }

            with open(self.config_file, 'w') as f:
                json.dump(config_data, f, indent=2)

            return True
        except Exception as e:
            print(f"Error saving config file: {e}")
            return False

    def get_build_config(self) -> BuildConfig:
        """Get build configuration."""
        return self.config.build

    def get_template_config(self) -> TemplateConfig:
        """Get template configuration."""
        return self.config.template

    def get_parsing_config(self) -> ParsingConfig:
        """Get parsing configuration."""
        return self.config.parsing

    def update_build_config(self, **kwargs) -> None:
        """Update build configuration parameters."""
        for key, value in kwargs.items():
            if hasattr(self.config.build, key):
                setattr(self.config.build, key, value)

    def update_template_config(self, **kwargs) -> None:
        """Update template configuration parameters."""
        for key, value in kwargs.items():
            if hasattr(self.config.template, key):
                setattr(self.config.template, key, value)

    def update_parsing_config(self, **kwargs) -> None:
        """Update parsing configuration parameters."""
        for key, value in kwargs.items():
            if hasattr(self.config.parsing, key):
                setattr(self.config.parsing, key, value)

    def validate_config(self) -> list:
        """Validate configuration and return list of errors."""
        errors = []

        # Validate build config
        build = self.config.build
        if not os.path.isdir(os.path.dirname(build.output_directory) or '.'):
            errors.append(f"Output directory parent does not exist: {build.output_directory}")

        if build.max_build_attempts < 1:
            errors.append("max_build_attempts must be at least 1")

        if build.build_timeout < 10:
            errors.append("build_timeout must be at least 10 seconds")

        # Validate template config
        template = self.config.template
        valid_engines = ['pdflatex', 'xelatex', 'lualatex']
        if build.latex_engine not in valid_engines:
            errors.append(f"Invalid LaTeX engine: {build.latex_engine}")

        # Validate font sizes
        valid_font_sizes = ['10pt', '11pt', '12pt']
        if template.font_size not in valid_font_sizes:
            errors.append(f"Invalid font size: {template.font_size}")

        return errors

    def create_default_config_file(self) -> bool:
        """Create a default configuration file."""
        return self.save_config()

    def reset_to_defaults(self) -> None:
        """Reset configuration to default values."""
        self.config = SystemConfig()


def get_default_config_manager() -> ConfigManager:
    """Get a default configuration manager instance."""
    return ConfigManager()


def create_sample_config_file(filename: str = "config.json") -> bool:
    """Create a sample configuration file with comments."""
    sample_config = {
        "_comment": "PDF-to-TeX Resume System Configuration",
        "build": {
            "output_directory": "output",
            "temp_directory": "temp",
            "latex_engine": "pdflatex",
            "clean_after_build": True,
            "max_build_attempts": 3,
            "build_timeout": 60
        },
        "template": {
            "template_name": "default",
            "font_family": "Computer Modern",
            "font_size": "11pt",
            "margin_top": "1in",
            "margin_bottom": "1in",
            "margin_left": "1in",
            "margin_right": "1in",
            "line_spacing": "1.0",
            "section_spacing": "0.5em"
        },
        "parsing": {
            "date_formats": [
                "%B %Y",
                "%b %Y",
                "%m/%Y",
                "%Y-%m",
                "%Y"
            ],
            "section_headers": [
                "experience", "work experience", "employment",
                "education", "academic background",
                "skills", "technical skills", "core competencies",
                "projects", "selected projects",
                "awards", "honors", "achievements"
            ],
            "skill_categories": [
                "programming languages", "frameworks", "databases",
                "tools", "technologies", "methodologies"
            ]
        }
    }

    try:
        with open(filename, 'w') as f:
            json.dump(sample_config, f, indent=2)
        return True
    except Exception as e:
        print(f"Error creating sample config file: {e}")
        return False
