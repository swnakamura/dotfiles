#!/usr/bin/perl
$latex                   = 'uplatex -interaction=nonstopmode -synctex=1 -halt-on-error';
$latex_silent            = 'uplatex -interaction=batchmode';
$dvips                   = 'dvips';
$bibtex                  = 'pbibtex';
$dvipdf                  = 'dvipdfmx %O -o %D %S';
$pdf_previewer           = 'xdg-open';
$preview_continuous_mode = 1;
$pdf_mode                = 3;
$pdf_update_method       = 4;
# $aux_dir                 = "$ENV{HOME}/.tmp/tex/" . basename(getcwd);
# $out_dir                 = $aux_dir;
$makeindex               = 'mendex %O -o %D %S -s /home/woody/Documents/macros/myindex.ist';
