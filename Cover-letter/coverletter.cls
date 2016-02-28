\ProvidesClass{coverletter}
\LoadClass[11pt]{article}

\RequirePackage{hyperref}
\RequirePackage{tabularx}

\RequirePackage[utf8]{inputenc}
\RequirePackage[T1]{fontenc}
\RequirePackage{lmodern}

\RequirePackage[left=3cm,right=2cm,top=1.5cm,bottom=1.25cm]{geometry}

\pagestyle{empty}
\setlength\parindent{0pt}
\setlength\parskip{\baselineskip}

\newenvironment{letterheader}
	{\tabularx{\textwidth}{Xr}}
	{\endtabularx}
\newcommand{\name}[1]{
	{\hspace{-2em} \large \sc #1} &
}
\newcommand{\homeaddress}[1]{
	#1
	& \\
}
\newcommand{\companyaddress}[1]{
	#1 & \\
}

\newenvironment{letter}
	{\vspace{-1em} \hfill \today \vspace{2em} \\ }
	{\par}
\newcommand{\subject}[1]{
	{\bf #1} 
}
\newcommand{\greet}[1]{
	\vspace{1em} \par #1,
}
\newenvironment{content}
    {\justify}
	{\vspace{1em} \par}
	{}
\newcommand{\sign}[1]{
	\vspace{0.5em} \par Yours sincerely, 
	\par \vspace{1em} #1 \vspace{1em}
}

\newcommand{\note}[1]{
	{\small #1} \\
}

\newenvironment{contactdetails}
	{\vspace{\fill} \par \small \tabularx{\textwidth}{rl}}
	{\endtabularx}
\newcommand{\email}[1]{
	{Email:} & \href{mailto:#1}{#1} \\
}
\newcommand{\mobilephone}[1]{
	{Phone:} & #1 \\
}
\newcommand{\github}[1]{
	{Github:} & \href{https://www.#1}{#1} \\
}
