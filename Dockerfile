FROM ubuntu:16.04

RUN apt update
RUN apt install -y wget rsync net-tools

RUN useradd -m admin

RUN mkdir /opt/smrtanalysis
RUN chown admin:admin /opt/smrtanalysis

USER admin
WORKDIR /home/admin

RUN wget http://files.pacb.com/software/smrtanalysis/2.3.0/smrtanalysis_2.3.0.140936.run
RUN wget https://s3.amazonaws.com/files.pacb.com/software/smrtanalysis/2.3.0/smrtanalysis-patch_2.3.0.140936.p5.run

RUN bash smrtanalysis_2.3.0.140936.run -p smrtanalysis-patch_2.3.0.140936.p5.run --rootdir /opt/smrtanalysis --ignore-syscheck --jmstype NONE --batch

RUN rm -rf *

RUN wget http://github.com/cyverseuk/renseq/raw/runRenSeq.sh

ENTRYPOINT ["/home/admin/runRenSeq.sh"]
