# README

## `vcf2bgc.py`: a VCF to `bgc` file format converter utility script

This subfolder bundles the `vcf2bgc.py` Python script from Bradley Martin along with `bgc_tools`, to serve as an additional utility script that may prove useful in preparing input files for `bgc`. This script was taken from Bradley Martin's file_converters GitHub repository, which Martin released in 2018 under the [MIT License](https://github.com/btmartin721/file_converters/blob/master/LICENSE), and edited by Justin Bagley to remove minor issues identified by checking the scripts with pyflakes, McCabe, and PEP 257 docstring style checker via Codacy. Most issues were [resolved](https://app.codacy.com/gh/justincbagley/bgc_tools/issues/index).

Info from original author ([here](https://github.com/btmartin721/file_converters/blob/master/README.md)):

```txt
vcf2bgc - converts ipyrad VCF file to BGC (Bayesian Genomic Cline) genotype uncertainty format. Currently only works with 3 populations. Also writes locinames to $prefix_loci.txt
```
