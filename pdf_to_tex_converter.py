#!/usr/bin/env python3
"""
PDF to TeX Resume Converter
Converts PDF resume to structured LaTeX format
"""

import re
import subprocess
import sys
from pathlib import Path
from typing import Dict, List, Optional, Tuple
from dataclasses import dataclass


@dataclass
class ContactInfo:
    """Contact information structure"""
    name: str = ""
    email: str = ""
    phone: str = ""
    address: str = ""
    linkedin: str = ""
    github: str = ""


@dataclass
class WorkExperience:
    """Work experience entry"""
    title: str
    company: str
    location: str = ""
    start_date: str = ""
    end_date: str = ""
    description: List[str] = None

    def __post_init__(self):
        if self.description is None:
            self.description = []


@dataclass
class Education:
    """Education entry"""
    degree: str
    institution: str
    location: str = ""
    graduation_date: str = ""
    gpa: str = ""
    details: List[str] = None

    def __post_init__(self):
        if self.details is None:
            self.details = []


@dataclass
class ResumeData:
    """Complete resume data structure"""
    contact: ContactInfo
    summary: str = ""
    experience: List[WorkExperience] = None
    education: List[Education] = None
    skills: List[str] = None
    projects: List[Dict[str, str]] = None

    def __post_init__(self):
        if self.experience is None:
            self.experience = []
        if self.education is None:
            self.education = []
        if self.skills is None:
            self.skills = []
        if self.projects is None:
            self.projects = []


class PDFTextExtractor:
    """Extract text from PDF using pdfly"""

    @staticmethod
    def extract_text(pdf_path: str) -> str:
        """Extract text from PDF file using pdfly"""
        try:
            result = subprocess.run(
                ['pdfly', 'extract-text', pdf_path],
                capture_output=True,
                text=True,
                check=True
            )
            return result.stdout
        except subprocess.CalledProcessError as e:
            raise Exception(f"Failed to extract text from PDF: {e}")
        except FileNotFoundError:
            raise Exception("pdfly not found. Please install pdfly: pip install pdfly")


class ResumeContentParser:
    """Parse extracted resume text into structured data"""

    def __init__(self):
        # Common section headers (case insensitive)
        self.section_patterns = {
            'experience': r'(?i)(?:work\s+)?experience|employment|professional\s+experience',
            'education': r'(?i)education|academic\s+background',
            'skills': r'(?i)skills|technical\s+skills|competencies',
            'projects': r'(?i)projects|selected\s+projects',
            'summary': r'(?i)summary|profile|objective|about'
        }

        # Contact information patterns
        self.contact_patterns = {
            'email': r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b',
            'phone': r'(?:\+?1[-.\s]?)?\(?([0-9]{3})\)?[-.\s]?([0-9]{3})[-.\s]?([0-9]{4})',
            'linkedin': r'(?:linkedin\.com/in/|linkedin\.com/profile/view\?id=)([A-Za-z0-9-]+)',
            'github': r'(?:github\.com/)([A-Za-z0-9-]+)'
        }

        # Date patterns
        self.date_patterns = [
            r'(?i)(?:jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)[a-z]*\.?\s+\d{4}',
            r'\d{1,2}/\d{4}',
            r'\d{4}',
            r'(?i)present|current'
        ]

    def parse_resume(self, text: str) -> ResumeData:
        """Parse resume text into structured data"""
        # Clean and normalize text
        text = self._clean_text(text)

        # Extract contact information
        contact = self._extract_contact_info(text)

        # Split text into sections
        sections = self._split_into_sections(text)

        # Parse each section
        experience = self._parse_experience_section(sections.get('experience', ''))
        education = self._parse_education_section(sections.get('education', ''))
        skills = self._parse_skills_section(sections.get('skills', ''))
        projects = self._parse_projects_section(sections.get('projects', ''))
        summary = sections.get('summary', '').strip()

        return ResumeData(
            contact=contact,
            summary=summary,
            experience=experience,
            education=education,
            skills=skills,
            projects=projects
        )

    def _clean_text(self, text: str) -> str:
        """Clean and normalize extracted text"""
        # Remove excessive whitespace
        text = re.sub(r'\n\s*\n', '\n\n', text)
        text = re.sub(r' +', ' ', text)

        # Fix common OCR issues
        text = text.replace('•', '•')  # Normalize bullet points
        text = text.replace('–', '-')  # Normalize dashes

        return text.strip()

    def _extract_contact_info(self, text: str) -> ContactInfo:
        """Extract contact information from text"""
        contact = ContactInfo()

        # Extract email
        email_match = re.search(self.contact_patterns['email'], text)
        if email_match:
            contact.email = email_match.group(0)

        # Extract phone
        phone_match = re.search(self.contact_patterns['phone'], text)
        if phone_match:
            contact.phone = phone_match.group(0)

        # Extract LinkedIn
        linkedin_match = re.search(self.contact_patterns['linkedin'], text)
        if linkedin_match:
            contact.linkedin = f"linkedin.com/in/{linkedin_match.group(1)}"

        # Extract GitHub
        github_match = re.search(self.contact_patterns['github'], text)
        if github_match:
            contact.github = f"github.com/{github_match.group(1)}"

        # Extract name (assume first line or line before email)
        lines = text.split('\n')
        for i, line in enumerate(lines[:5]):  # Check first 5 lines
            line = line.strip()
            if line and not any(pattern in line.lower() for pattern in ['email', 'phone', 'linkedin', 'github']):
                if len(line.split()) >= 2 and len(line) < 50:  # Likely a name
                    contact.name = line
                    break

        return contact
