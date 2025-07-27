"""
File handling utilities for the PDF-to-TeX resume system.
"""

import os
import shutil
import tempfile
from pathlib import Path
from typing import Optional, List


def ensure_directory_exists(directory_path: str) -> bool:
    """
    Ensure that a directory exists, creating it if necessary.

    Args:
        directory_path: Path to the directory

    Returns:
        True if directory exists or was created successfully
    """
    try:
        Path(directory_path).mkdir(parents=True, exist_ok=True)
        return True
    except Exception as e:
        print(f"Error creating directory {directory_path}: {e}")
        return False


def validate_file_exists(file_path: str) -> bool:
    """
    Check if a file exists and is readable.

    Args:
        file_path: Path to the file

    Returns:
        True if file exists and is readable
    """
    return os.path.isfile(file_path) and os.access(file_path, os.R_OK)


def validate_pdf_file(file_path: str) -> bool:
    """
    Validate that a file is a PDF.

    Args:
        file_path: Path to the PDF file

    Returns:
        True if file is a valid PDF
    """
    if not validate_file_exists(file_path):
        return False

    # Check file extension
    if not file_path.lower().endswith('.pdf'):
        return False

    # Check PDF magic bytes
    try:
        with open(file_path, 'rb') as f:
            header = f.read(4)
            return header == b'%PDF'
    except Exception:
        return False


def create_temp_directory() -> Optional[str]:
    """
    Create a temporary directory for processing.

    Returns:
        Path to temporary directory or None if creation failed
    """
    try:
        return tempfile.mkdtemp(prefix='pdf_to_tex_')
    except Exception as e:
        print(f"Error creating temporary directory: {e}")
        return None


def cleanup_temp_directory(temp_dir: str) -> bool:
    """
    Clean up a temporary directory and its contents.

    Args:
        temp_dir: Path to temporary directory

    Returns:
        True if cleanup was successful
    """
    try:
        if os.path.exists(temp_dir):
            shutil.rmtree(temp_dir)
        return True
    except Exception as e:
        print(f"Error cleaning up temporary directory {temp_dir}: {e}")
        return False


def get_file_size(file_path: str) -> Optional[int]:
    """
    Get the size of a file in bytes.

    Args:
        file_path: Path to the file

    Returns:
        File size in bytes or None if file doesn't exist
    """
    try:
        return os.path.getsize(file_path)
    except Exception:
        return None


def clean_filename(filename: str) -> str:
    """
    Clean a filename by removing or replacing invalid characters.

    Args:
        filename: Original filename

    Returns:
        Cleaned filename safe for filesystem use
    """
    # Remove or replace invalid characters
    invalid_chars = '<>:"/\\|?*'
    cleaned = filename
    for char in invalid_chars:
        cleaned = cleaned.replace(char, '_')

    # Remove leading/trailing whitespace and dots
    cleaned = cleaned.strip(' .')

    # Ensure filename is not empty
    if not cleaned:
        cleaned = 'untitled'

    return cleaned


def find_files_with_extension(directory: str, extension: str) -> List[str]:
    """
    Find all files with a specific extension in a directory.

    Args:
        directory: Directory to search
        extension: File extension (with or without dot)

    Returns:
        List of file paths with the specified extension
    """
    if not extension.startswith('.'):
        extension = '.' + extension

    files = []
    try:
        for root, _, filenames in os.walk(directory):
            for filename in filenames:
                if filename.lower().endswith(extension.lower()):
                    files.append(os.path.join(root, filename))
    except Exception as e:
        print(f"Error searching for files in {directory}: {e}")

    return files
