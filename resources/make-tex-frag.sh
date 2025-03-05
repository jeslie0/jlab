#!/usr/bin/env bash
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
latex_template_file="$SCRIPT_DIR/latex-template.tex"

tmp_dir="/tmp/texfrag"

PLACEHOLDER="%s"
REPLACEMENT="$1"

# latex_contents=$(sed "s/$PLACEHOLDER/$REPLACEMENT/g" "$latex_template_file")
latex_contents="
\documentclass{article}
\usepackage[pdftex,active,tightpage]{preview}
\usepackage{amsmath}
\usepackage{amsthm}
\usepackage{amsfonts}
\usepackage{amssymb}
\usepackage{bbm}
\usepackage{mathrsfs}
\usepackage{mathtools}
\usepackage{physics}
\usepackage{tikz-cd}
\usepackage{tikz}
\begin{document}
\begin{preview}
$1
\end{preview}
\end{document}
"

hash=$(echo "$latex_contents" | md5sum | cut -d ' ' -f 1)

tex_file="$tmp_dir/$hash.tex"
dvi_file="$tmp_dir/$hash.dvi"
svg_file="$tmp_dir/$hash.svg"

if [[ -f "$svg_file" ]]; then
	cat "$svg_file"
	exit
fi

mkdir -p "$tmp_dir"

echo $latex_contents >$tex_file

lualatex --interaction=nonstopmode \
	--shell-escape \
	--output-format=dvi \
	--output-directory="$tmp_dir" \
	"$tex_file" &>/dev/null

dvisvgm "$dvi_file" \
	-n \
	-b \
	min \
	-c 1.5 \
	-o "$svg_file" &>/dev/null

cat $svg_file
