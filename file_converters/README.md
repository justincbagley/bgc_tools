# README

## `vcf2bgc.py`: a VCF to `bgc` file format converter utility script

### Overview

This subfolder bundles the `vcf2bgc.py` Python script from Bradley Martin along with `bgc_tools`, to serve as an additional utility script that may prove useful in preparing input files for `bgc`. This script was taken from Bradley Martin's file_converters GitHub repository, which Martin released in 2018 under the [MIT License](https://github.com/btmartin721/file_converters/blob/master/LICENSE), and edited by Justin Bagley to remove minor issues identified by checking the scripts with pyflakes, McCabe, and PEP 257 docstring style checker via Codacy. Most issues were [resolved](https://app.codacy.com/gh/justincbagley/bgc_tools/issues/index).

Info from original author ([here](https://github.com/btmartin721/file_converters/blob/master/README.md)):

```txt
vcf2bgc - converts ipyrad VCF file to BGC (Bayesian Genomic Cline) genotype uncertainty format. Currently only works with 3 populations. Also writes locinames to $prefix_loci.txt
```
### Installation

1.   Set execution privileges

```bash
chmod u+x ./vcf2bgc.py
```

2.   Install dependencies

The main dependency is PyVCF, available via [pip install](https://pypi.org/project/PyVCF/) or [Anaconda install](https://anaconda.org/bioconda/pyvcf). Code for each install is provided below:

```bash
## PyVCF dependency

# pip install:
pip install PyVCF

# conda install:
conda install -c bioconda pyvcf                 # Option #1
conda install -c bioconda/label/cf201901 pyvcf  # Option #2
```

### Header text (with full license, per stipulations of usage)

```txt

# MIT License

Copyright (c) 2018 Bradley Martin

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

# vcf2bgc.py

Script to convert VCF files to BGC (Bayesian Genomic Cline) format, using the genotype uncertainties.
Uses the read depth for each allele and each individual
which is output in the ipyrad VCF file.

BGC format looks like this:

Parental population files:
locus_1
22 4
1 21
4 55
33 0
locus_2
33 5
22 3
0 1
0 0

Admixed population files:
locus_1
pop_0
0 0
0 43
33 5
0 33
locus_2
pop_0
22 3
33 5
33 0
0 0

So: the loci contain 4 individuals, and each column represents the read depth
for each allele. Must be bi-allelic data. The admixed file requires a population ID line.
The ipyrad VCF output file contains a column that includes:
GT (Genotype):DP (total reads):CATG (# reads per allele) delimited by a colon.

Dependencies:
	PyVCF (I used version 0.6.8)
