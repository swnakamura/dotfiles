#!/usr/bin/perl
$latex                   = 'platex -interaction=nonstopmode -synctex=1 -halt-on-error';
$latex_silent            =                             'platex -interaction=batchmode';
$dvips                   =                                                     'dvips';
$bibtex                  =                                                   'pbibtex';
$makeindex               =                                  'mendex -r -c -s jind.ist';
$dvipdf                  =                                      'dvipdfmx %O -o %D %S';
$pdf_previewer           =                                           'open -a Skim %S';
$preview_continuous_mode =                                                           1;
$pdf_mode                =                                                           3;
$pdf_update_method       =                                                           4;
$aux_dir                 =                   "$ENV{HOME}/.tmp/tex/" . basename(getcwd);
$out_dir                 =                                                    $aux_dir;
