FROM registry.hub.docker.com/library/ubuntu:xenial

ENV DEBIAN_FRONTEND noninteractive 
ENV MONO_VERSION 5.18

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF && \
    echo "deb http://download.mono-project.com/repo/debian stable-xenial/snapshots/$MONO_VERSION main" > /etc/apt/sources.list.d/mono-official-stable.list && \
    apt-get update && apt-get install -y \ 
        devscripts build-essential tofrodos \
        dh-make dh-systemd \
        cli-common-dev \
        mono-complete \
        sqlite3 libcurl3 mediainfo

RUN apt-cache policy mono-complete
RUN apt-cache policy cli-common-dev

RUN curl -sL https://deb.nodesource.com/setup_15.x | bash - && apt-get install -y nodejs && npm install --global yarn

WORKDIR /data
COPY . /data

RUN mono tools/nuget/nuget.exe update -self && mono tools/nuget/nuget.exe install PInvoke.Crypt32 && mono tools/nuget/nuget.exe restore src/Sonarr.sln

RUN bash ./build.sh



FROM registry.hub.docker.com/library/ubuntu:xenial

ENV DEBIAN_FRONTEND noninteractive
ENV MONO_VERSION 5.18

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF && \
    echo "deb http://download.mono-project.com/repo/debian stable-xenial/snapshots/$MONO_VERSION main" > /etc/apt/sources.list.d/mono-official-stable.list && \
    apt-get update && \
    apt-get install -y mono-complete sqlite3 libcurl3 mediainfo

COPY --from=0 /data/_output_linux /app
WORDIR /app
CMD mono --debug Sonarr.exe -nobrowser -data=/config
