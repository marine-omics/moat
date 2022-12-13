FROM ubuntu:20.04 as final

#FROM rocker/tidyverse:4.2.2 as final

ENV DEBIAN_FRONTEND noninteractive

FROM ubuntu:20.04 as build
#FROM rocker/tidyverse:4.2.2 as build

RUN apt-get update && apt-get install -y --no-install-recommends \
  build-essential unzip wget zlib1g-dev bison

WORKDIR /usr/local/

RUN wget --no-check-certificate 'https://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/LATEST/ncbi-blast-2.13.0+-x64-linux.tar.gz' 
RUN tar -zxvf ncbi-blast-2.13.0+-x64-linux.tar.gz

RUN wget --no-check-certificate 'https://github.com/lh3/bioawk/archive/refs/tags/v1.0.tar.gz' && \
  tar -zxvf v1.0.tar.gz && \
  cd bioawk-1.0 && \
  make

# Interproscan
ARG IPR=5
ENV IPR $IPR
ARG IPRSCAN=5.59-91.0
ENV IPRSCAN $IPRSCAN

RUN mkdir -p /opt


RUN wget -O /opt/interproscan-core-$IPRSCAN.tar.gz ftp://ftp.ebi.ac.uk/pub/software/unix/iprscan/$IPR/$IPRSCAN/alt/interproscan-core-$IPRSCAN.tar.gz
RUN wget -O /opt/interproscan-core-$IPRSCAN.tar.gz.md5 ftp://ftp.ebi.ac.uk/pub/software/unix/iprscan/$IPR/$IPRSCAN/alt/interproscan-core-$IPRSCAN.tar.gz.md5
RUN wget -O /opt/interproscan-bin-$IPRSCAN.tar.gz ftp://ftp.ebi.ac.uk/pub/software/unix/iprscan/$IPR/$IPRSCAN/alt/interproscan-bin-$IPRSCAN.tar.gz
RUN wget -O /opt/interproscan-bin-$IPRSCAN.tar.gz.md5 ftp://ftp.ebi.ac.uk/pub/software/unix/iprscan/$IPR/$IPRSCAN/alt/interproscan-bin-$IPRSCAN.tar.gz.md5

WORKDIR /opt

RUN md5sum -c interproscan-core-$IPRSCAN.tar.gz.md5
RUN md5sum -c interproscan-bin-$IPRSCAN.tar.gz.md5

RUN mkdir -p /opt/interproscan

RUN  tar -pxvzf interproscan-core-$IPRSCAN.tar.gz \
    -C /opt/interproscan --strip-components=1 \
    && rm -f interproscan-core-$IPRSCAN.tar.gz interproscan-core-$IPRSCAN.tar.gz.md5

RUN tar -pxvzf interproscan-bin-$IPRSCAN.tar.gz \
    -C /opt/interproscan --strip-components=1 \
    && rm -f interproscan-bin-$IPRSCAN.tar.gz interproscan-bin-$IPRSCAN.tar.gz.md5

## HMMER 

RUN wget --no-check-certificate http://eddylab.org/software/hmmer/hmmer.tar.gz &&\
  tar -zxvf hmmer.tar.gz && cd hmmer-3.3.2/ && ./configure && make install


FROM final

RUN apt-get update && apt-get install -y --no-install-recommends \
  libgomp1 \
  python3 openjdk-11-jre libpcre3-dev libdata-dumper-simple-perl \
  zlib1g

# Interproscan
COPY --from=build /opt/interproscan /opt/interproscan
COPY --from=build /opt/interproscan/bin /opt/interproscan/bin
ENV PATH="${PATH}:/opt/interproscan/bin:/opt/interproscan/"


COPY --from=build /usr/local/ncbi-blast-2.13.0+/bin/blast[px] /usr/local/bin/

COPY --from=build /usr/local/bioawk-1.0/bioawk /usr/local/bin/

COPY --from=build /usr/local/bin/*hmm* /usr/local/bin
COPY --from=build /usr/local/bin/alimask /usr/local/bin

ADD awk/* /usr/local/bin/

WORKDIR /usr/local

ADD sw/signalp-4.1c.Linux.tar.gz .
ADD sw/tmhmm-2.0c.Linux.tar.gz .

RUN sed -i.bak 's:/usr/cbs/bio/src/:/usr/local/:' signalp-4.1/signalp
RUN sed -i.bak 's:MAX_ALLOWED_ENTRIES=10000:MAX_ALLOWED_ENTRIES=1000000:' signalp-4.1/signalp

ENV PATH="${PATH}:/usr/local/signalp-4.1/"

RUN sed -i.bak 's:/usr/local/bin/perl:/usr/bin/perl:' tmhmm-2.0c/bin/tmhmm
RUN sed -i.bak 's:/usr/local/bin/perl:/usr/bin/perl:' tmhmm-2.0c/bin/tmhmmformat.pl

ENV PATH="${PATH}:/usr/local/tmhmm-2.0c/bin/"

# Cleanup apt package lists to save space
RUN rm -rf /var/lib/apt/lists/*

