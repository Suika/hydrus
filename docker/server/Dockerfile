FROM suika/opencv-video-minimal:4.2-py3.7.5 as swfbuild
RUN apk add build-base git libjpeg-turbo-dev freetype-dev zlib-dev && \
    wget http://swftools.org/swftools-2013-04-09-1007.tar.gz && \
    tar xzf swftools-2013-04-09-1007.tar.gz && cd swftools* && \
    wget "http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub;hb=HEAD" -O config.guess && \
    sed -i 's/config.guess"/config.guess" $(uname -m)/' configure && \
    sed -e 's/-o -L/#-o -L/' -i swfs/Makefile.in && \
    LDFLAGS="-static" ./configure && LDFLAGS="-all-static" make && \
    mv src /src

FROM suika/opencv-video-minimal:4.2-py3.7.5

ARG UID
ARG GID

HEALTHCHECK --interval=1m --timeout=10s --retries=3 --start-period=10s \
  CMD wget --quiet --tries=1 --no-check-certificate --spider \
    https://localhost:45870 || exit 1

ENTRYPOINT ["/bin/sh", "/opt/hydrus/docker/server/entrypoint.sh"]
LABEL git="https://github.com/hydrusnetwork/hydrus"

RUN apk --no-cache add py3-beautifulsoup4 py3-psutil py3-pysocks py3-requests py3-twisted py3-yaml py3-lz4 ffmpeg py3-pillow py3-numpy py3-openssl py3-service_identity openssl su-exec
RUN pip install Send2Trash html5lib twisted cloudscrape

RUN set -xe \
    && mkdir -p /opt/hydrus \
    && addgroup -g 1000 hydrus \
    && adduser -h /opt/hydrus -u 1000 -H -S -G hydrus hydrus

COPY --chown=hydrus . /opt/hydrus
COPY --chown=hydrus --from=suika/swftools:2013-04-09-1007 /swftools/swfrender /opt/hydrus/bin/swfrender_linux

VOLUME /opt/hydrus/db

ENV UID=${UID:-1000} \
    GID=${GID:-1000}
EXPOSE 45870
