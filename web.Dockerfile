# You can set the Swift version to what you need for your app. Versions can be found here: https://hub.docker.com/_/swift
FROM swift:5.1 as builder

# For local build, add `--build-arg environment=local`
ARG env=""
ENV ENVIRONMENT=$env

RUN apt-get -qq update && apt-get install -y \
  libssl-dev.1.1.0 zlib1g-dev \
  && rm -r /var/lib/apt/lists/*
WORKDIR /app
COPY . .
RUN mkdir -p /build/lib && cp -R /usr/lib/swift/linux/*.so* /build/lib
RUN swift build --package-path Server -c release && mv `swift build --package-path Server -c release --show-bin-path` /build/bin

# Production image
FROM ubuntu:16.04
RUN apt-get -qq update && apt-get install -y \
  libicu55 libxml2 libbsd0 libcurl3 libatomic1 \
  tzdata \
  && rm -r /var/lib/apt/lists/*d
WORKDIR /app
COPY --from=builder /build/bin/Run .
COPY --from=builder /build/lib/* /usr/lib/
COPY --from=builder /app/Server/Public ./Public
COPY --from=builder /app/Server/Resources/PassCerts ./PassCerts
COPY --from=builder /app/Server/Resources/PassTemplate ./PassTemplate
# Uncommand the next line if you are using Leaf
#COPY --from=builder /app/Resources ./Resources

ENTRYPOINT ./Run serve --env $ENVIRONMENT --hostname 0.0.0.0 --port 80
