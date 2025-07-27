"""
System utilities for checking dependencies and environment.
"""

import subprocess
import shutil
import platform
from typing import Optional, Dict, List


def check_command_available(command: str) -> bool:
    """
    Check if a command is available in the system PATH.

    Args:
        command: Command name to check

    Returns:
        True if command is available
    """
    return shutil.which(command) is not None


def get_command_version(command: str) -> Optional[str]:
    """
    Get the version of a command if available.

    Args:
        command: Command name

    Returns:
        Version string or None if command not available
    """
    if not check_command_available(command):
        return None

    try:
        # Try common version flags
        version_flags = ['--version', '-v', '-V']
        for flag in version_flags:
            try:
                result = subprocess.run(
                    [command, flag],
                    capture_output=True,
                    text=True,
                    timeout=10
                )
                if result.returncode == 0:
                    return result.stdout.strip().split('\n')[0]
            except (subprocess.TimeoutExpired, subprocess.SubprocessError):
                continue
    except Exception:
        pass

    return None


def check_macos_system() -> bool:
    """
    Check if the system is macOS.

    Returns:
        True if running on macOS
    """
    return platform.system() == 'Darwin'


def check_mactex_installation() -> Dict[str, bool]:
    """
    Check MacTeX installation and required components.

    Returns:
        Dictionary with status of MacTeX components
    """
    components = {
        'pdflatex': check_command_available('pdflatex'),
        'bibtex': check_command_available('bibtex'),
        'makeindex': check_command_available('makeindex'),
        'texdoc': check_command_available('texdoc'),
    }

    return components


def check_pdfly_installation() -> bool:
    """
    Check if pdfly is installed and available.

    Returns:
        True if pdfly is available
    """
    return check_command_available('pdfly')


def check_python_version() -> Optional[str]:
    """
    Get the current Python version.

    Returns:
        Python version string
    """
    return platform.python_version()


def get_system_info() -> Dict[str, str]:
    """
    Get comprehensive system information.

    Returns:
        Dictionary with system information
    """
    return {
        'platform': platform.platform(),
        'system': platform.system(),
        'release': platform.release(),
        'version': platform.version(),
        'machine': platform.machine(),
        'processor': platform.processor(),
        'python_version': platform.python_version(),
    }


def check_disk_space(path: str = '.') -> Optional[int]:
    """
    Check available disk space in bytes.

    Args:
        path: Path to check (defaults to current directory)

    Returns:
        Available space in bytes or None if check failed
    """
    try:
        statvfs = shutil.disk_usage(path)
        return statvfs.free
    except Exception:
        return None


def run_system_diagnostics() -> Dict[str, any]:
    """
    Run comprehensive system diagnostics for the PDF-to-TeX system.

    Returns:
        Dictionary with diagnostic results
    """
    diagnostics = {
        'system_info': get_system_info(),
        'is_macos': check_macos_system(),
        'python_version': check_python_version(),
        'disk_space_mb': check_disk_space() // (1024 * 1024) if check_disk_space() else None,
        'mactex_components': check_mactex_installation(),
        'pdfly_available': check_pdfly_installation(),
        'pdfly_version': get_command_version('pdfly'),
        'pdflatex_version': get_command_version('pdflatex'),
    }

    return diagnostics


def validate_system_requirements() -> List[str]:
    """
    Validate that all system requirements are met.

    Returns:
        List of error messages for missing requirements
    """
    errors = []

    # Check macOS
    if not check_macos_system():
        errors.append("This system is designed for macOS")

    # Check Python version
    python_version = check_python_version()
    if python_version:
        major, minor = python_version.split('.')[:2]
        if int(major) < 3 or (int(major) == 3 and int(minor) < 8):
            errors.append(f"Python 3.8+ required, found {python_version}")

    # Check MacTeX components
    mactex_components = check_mactex_installation()
    if not mactex_components['pdflatex']:
        errors.append("pdflatex not found - MacTeX installation required")

    # Check pdfly
    if not check_pdfly_installation():
        errors.append("pdfly not found - install with 'pip install pdfly'")

    # Check disk space (require at least 100MB)
    disk_space = check_disk_space()
    if disk_space and disk_space < 100 * 1024 * 1024:
        errors.append("Insufficient disk space (at least 100MB required)")

    return errors
