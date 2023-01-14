#!/usr/bin/perl
$latex                   = 'lualatex -interaction=nonstopmode -synctex=1 -halt-on-error';
$latex_silent            = 'lualatex -interaction=batchmode';
$bibtex                  = 'pbibtex';
$dvipdf                  = 'dvipdfmx %O -o %D %S';
$pdf_previewer           = 'xdg-open';
$preview_continuous_mode = 1;
$pdf_mode                = 3;
$pdf_update_method       = 4;
$out_dir                 = 'livepreview';
$makeindex               = 'mendex %O -o %D %S -s /home/woody/Documents/macros/myindex.ist';
