#### Copyright (C) 2023 -- 2026, Christopher Mark Gore,
#### Soli Deo Gloria,
#### All rights reserved.
####
#### 22 Forest Glade Court, Saint Charles, Missouri 63304 USA.
#### Web: http://cgore.com
#### Email: cgore@cgore.com
####
#### Redistribution and use in source and binary forms, with or without
#### modification, are permitted provided that the following conditions are met:
####
####     * Redistributions of source code must retain the above copyright
####       notice, this list of conditions and the following disclaimer.
####
####     * Redistributions in binary form must reproduce the above copyright
####       notice, this list of conditions and the following disclaimer in the
####       documentation and/or other materials provided with the distribution.
####
####     * Neither the name of Christopher Mark Gore nor the names of other
####       contributors may be used to endorse or promote products derived from
####       this software without specific prior written permission.
####
#### THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
#### AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
#### IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
#### ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
#### LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
#### CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
#### SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
#### INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
#### CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
#### ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
#### POSSIBILITY OF SUCH DAMAGE.

LATEX_FILES=coingecko.latex copyright.latex introduction.latex	\
	  rest-api-package.latex coingecko-package.latex

all: coingecko.dvi coingecko.ps coingecko.pdf

coingecko.dvi: ${LATEX_FILES} coingecko.bib
	latex coingecko.latex
	bibtex coingecko
	latex coingecko.latex
	latex coingecko.latex

coingecko.ps: coingecko.dvi
	dvips -o coingecko.ps coingecko.dvi

coingecko.pdf: ${LATEX_FILES} coingecko.bib
	pdflatex coingecko.latex
	bibtex coingecko
	pdflatex coingecko.latex
	pdflatex coingecko.latex

clean:
	rm -f coingecko.pdf coingecko.ps coingecko.dvi
