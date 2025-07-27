%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Resume Class File
% Compatible with original resume.tex format
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{resume}[2024/01/01 Resume class]

\LoadClass[11pt,letterpaper]{article}

% Required packages
\RequirePackage{array}
\RequirePackage{ifthen}

\pagestyle{empty} % Suppress page numbers

%----------------------------------------------------------------------------------------
%	VARIABLES AND COMMANDS
%----------------------------------------------------------------------------------------

% Define categoryfont
\newcommand{\categoryfont}{\sc}

% Name and author commands
\def \name#1{\def\@name{#1}}
\def \@name {}
\def \author#1{\def\@name{#1}}

% Address handling - support both single and double argument versions
\let \@addressone \relax
\let \@addresstwo \relax

% Two-argument address command (original format)
\def \address #1#2{
  \def \@addressone {#1}
  \def \@addresstwo {#2}
}

% Print address function
\def \printaddress #1{
  \begingroup
    \def \\ {\\}
    \centerline{\parbox{3in}{\centering #1}}
  \endgroup
  \par
  \smallskip
}

% Print name function
\def \printname {
  \begingroup
    \hfil{\Large\bf \@name}\hfil
    \bigskip\break
  \endgroup
}

% Maketitle command
\renewcommand{\maketitle}{
  \printname
  \@ifundefined{@addressone}{}{
    \begin{center}
    \begin{tabular}{c@{\hskip 2in}c}
    \@addressone & \@addresstwo
    \end{tabular}
    \end{center}
    \bigskip
  }
}

%----------------------------------------------------------------------------------------
%	CATEGORY ENVIRONMENT
%----------------------------------------------------------------------------------------

\newenvironment{category}[1]{
  \medskip
  \noindent{\categoryfont #1}\par
  \smallskip
  \hrule
  \smallskip
  \begin{list}{}{\leftmargin=0.75em \rightmargin=0em \itemsep=0.5em}
}{
  \end{list}
  \medskip
}

%----------------------------------------------------------------------------------------
%	ITEM COMMANDS
%----------------------------------------------------------------------------------------

% Category item with bullet
\newcommand{\citem}[1]{\item {\bf #1}}

% Category item without bullet
\newcommand{\citemnobullet}[1]{\item[] #1}

%----------------------------------------------------------------------------------------
%	LABEL CUSTOMIZATION
%----------------------------------------------------------------------------------------

% Custom bullet points
\renewcommand{\labelitemi}{$\cdot$}

% Allow redefinition of label commands
\newcommand{\labelcitem}{$\diamond$}

%----------------------------------------------------------------------------------------
%	MODERN RESUME ENVIRONMENTS (rSection and rSubsection)
%----------------------------------------------------------------------------------------

% rSection environment for modern resume format
\newenvironment{rSection}[1]{
  \medskip
  \MakeUppercase{\bf #1}
  \medskip
  \hrule
  \begin{list}{}{\leftmargin=0.75em}
  \item[]
}{
  \end{list}
}

% rSubsection environment for work experience
\newenvironment{rSubsection}[4]{
 {\bf #1} \hfill {#2}
 \ifthenelse{\equal{#3}{}}{}{
  \\
  {\em #3} \hfill {\em #4}
  }\smallskip
  \begin{list}{$\cdot$}{\leftmargin=0em}
   \itemsep -0.5em \vspace{-0.5em}
  }{
  \end{list}
  \vspace{0.5em}
}

%----------------------------------------------------------------------------------------
%	ORDINAL COMMANDS (defined in resume.tex)
%----------------------------------------------------------------------------------------
% These are defined in the main document to avoid conflicts
