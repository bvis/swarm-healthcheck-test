FROM alpine:3.4

COPY health-check.sh /health-check.sh
COPY start.sh /start.sh

ENTRYPOINT /start.sh

HEALTHCHECK --interval=5s --timeout=1s \
  CMD /health-check.sh

