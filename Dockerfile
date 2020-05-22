FROM alpine:3.9 

RUN apk add --no-cache py2-pip && \
    pip install b2 && \
    mkdir -p /scratch

COPY entry.sh /

WORKDIR /scratch

ENTRYPOINT ["/entry.sh"]