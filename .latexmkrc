#!/usr/bin/perl
$latex                   = 'pdflatex -interaction=nonstopmode -synctex=1 -halt-on-error';
$latex_silent            = 'pdflatex -interaction=batchmode';
$bibtex                  = 'bibtex %O %S';
$biber                   = 'biber --bblencoding=utf8 -u -U';
$dvipdf                  = 'dvipdfmx %O -o %D %S';
$preview_continuous_mode = 1;
$pdf_mode                = 3;
$pdf_update_method       = 4;
$out_dir                 = 'livepreview';
