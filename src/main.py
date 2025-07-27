"""
Main entry point for the PDF-to-TeX resume system.
"""

import sys
import argparse
from pathlib import Path

from utils.system_utils import run_system_diagnostics, validate_system_requirements
from utils.config import ConfigManager, create_sample_config_file
from utils.file_utils import ensure_directory_exists, validate_pdf_file


def setup_project_structure():
    """Set up the basic project directory structure."""
    directories = [
        "output",
        "temp",
        "templates",
        "examples"
    ]

    for directory in directories:
        if ensure_directory_exists(directory):
            print(f"✓ Created directory: {directory}")
        else:
            print(f"✗ Failed to create directory: {directory}")
            return False

    return True


def run_diagnostics():
    """Run system diagnostics and display results."""
    print("Running system diagnostics...")
    print("=" * 50)

    diagnostics = run_system_diagnostics()

    # System information
    print("System Information:")
    system_info = diagnostics['system_info']
    print(f"  Platform: {system_info['platform']}")
    print(f"  System: {system_info['system']}")
    print(f"  Python: {system_info['python_version']}")
    print(f"  macOS: {'Yes' if diagnostics['is_macos'] else 'No'}")

    if diagnostics['disk_space_mb']:
        print(f"  Disk Space: {diagnostics['disk_space_mb']} MB available")

    print()

    # MacTeX components
    print("MacTeX Components:")
    mactex = diagnostics['mactex_components']
    for component, available in mactex.items():
        status = "✓" if available else "✗"
        print(f"  {status} {component}")

    print()

    # pdfly
    pdfly_status = "✓" if diagnostics['pdfly_available'] else "✗"
    print(f"pdfly: {pdfly_status}")
    if diagnostics['pdfly_version']:
        print(f"  Version: {diagnostics['pdfly_version']}")

    print()

    # Validation
    print("System Requirements:")
    errors = validate_system_requirements()
    if not errors:
        print("  ✓ All requirements met")
    else:
        for error in errors:
            print(f"  ✗ {error}")

    return len(errors) == 0


def initialize_config():
    """Initialize configuration management."""
    config_manager = ConfigManager()

    if not Path("config.json").exists():
        print("Creating default configuration file...")
        if create_sample_config_file():
            print("✓ Created config.json")
        else:
            print("✗ Failed to create config.json")
            return None

    # Validate configuration
    errors = config_manager.validate_config()
    if errors:
        print("Configuration validation errors:")
        for error in errors:
            print(f"  ✗ {error}")
        return None

    print("✓ Configuration loaded and validated")
    return config_manager


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description="PDF-to-TeX Resume System",
        formatter_class=argparse.RawDescriptionHelpFormatter
    )

    parser.add_argument(
        '--setup',
        action='store_true',
        help='Set up project structure and configuration'
    )

    parser.add_argument(
        '--diagnostics',
        action='store_true',
        help='Run system diagnostics'
    )

    parser.add_argument(
        '--pdf',
        type=str,
        help='PDF file to process'
    )

    args = parser.parse_args()

    if args.setup:
        print("Setting up PDF-to-TeX Resume System...")
        print("=" * 40)

        # Set up directory structure
        if not setup_project_structure():
            print("Failed to set up project structure")
            sys.exit(1)

        # Initialize configuration
        config_manager = initialize_config()
        if not config_manager:
            print("Failed to initialize configuration")
            sys.exit(1)

        print("\n✓ Setup completed successfully!")
        print("\nNext steps:")
        print("1. Run --diagnostics to check system requirements")
        print("2. Place your PDF resume in the current directory")
        print("3. Run with --pdf <filename> to process your resume")

    elif args.diagnostics:
        if not run_diagnostics():
            print("\n⚠️  Some system requirements are not met.")
            print("Please install missing components before proceeding.")
            sys.exit(1)
        else:
            print("\n✓ System is ready for PDF-to-TeX processing!")

    elif args.pdf:
        pdf_file = args.pdf

        # Validate PDF file
        if not validate_pdf_file(pdf_file):
            print(f"✗ Invalid or missing PDF file: {pdf_file}")
            sys.exit(1)

        print(f"✓ PDF file validated: {pdf_file}")
        print("PDF processing functionality will be implemented in subsequent tasks.")

    else:
        parser.print_help()


if __name__ == "__main__":
    main()
