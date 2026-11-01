FROM alpine:latest

# Install curl and bash
RUN apk update && apk add --no-cache curl bash

WORKDIR /app

# Copy script and make it executable
COPY app_checker.sh /app/app_checker.sh
RUN chmod +x /app/app_checker.sh

# Run script
CMD ["/bin/sh", "/app/app_checker.sh"]