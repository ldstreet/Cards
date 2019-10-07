# You can set the Swift version to what you need for your app. Versions can be found here: https://hub.docker.com/_/swift
FROM swift:5.1 as builder

# For local build, add `--build-arg env=docker`
# In your application, you can use `Environment.custom(name: "docker")` to check if you're in this env
ARG env

RUN apt-get -qq update && apt-get -q -y install \
  tzdata \
  && rm -r /var/lib/apt/lists/*
WORKDIR /app
COPY . .
RUN mkdir -p /build/lib && cp -R /usr/lib/swift/linux/*.so /build/lib
RUN swift build --package-path CardsServer -c release && mv `swift build --package-path CardsServer -c release --show-bin-path` /build/bin

# Production image
FROM ubuntu:16.04
ARG env
RUN apt-get -qq update && apt-get install -y \
  libicu55 libxml2 libbsd0 libcurl3 libatomic1 \
  tzdata \
  && rm -r /var/lib/apt/lists/*
WORKDIR /app
COPY --from=builder /build/bin/Run .
COPY --from=builder /build/lib/* /usr/lib/

COPY --from=builder /app/CardsServer/PassCerts ./PassCerts
COPY --from=builder /app/CardsServer/PassTemplate ./PassTemplate

ENV ENVIRONMENT=$env

ENTRYPOINT ./Run serve --env $ENVIRONMENT --hostname 0.0.0.0 --port 80
