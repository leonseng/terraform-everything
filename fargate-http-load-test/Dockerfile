FROM alpine

ARG test_site=http://localhost:8080/
RUN apk --no-cache add apache2-utils

RUN mkdir /app
COPY dos.sh /app/dos.sh
RUN chmod +x /app/dos.sh

ENTRYPOINT [ "/app/dos.sh" ]