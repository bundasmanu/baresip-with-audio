## run
FROM bitnami/minideb:bookworm AS base

WORKDIR /root/

RUN install_packages linux-headers-generic git ca-certificates build-essential openssl wget clang-15 make cmake pkg-config apt-utils python3

## libre install
FROM base AS libre

ARG RE_VERSION

RUN install_packages libssl-dev libz-dev && \
    git clone https://github.com/baresip/re.git && \
    cd re && git checkout ${RE_VERSION} && \
    cmake -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_FLAGS="-g" -DCMAKE_C_COMPILER=clang-15 && \
    cmake --build build -j4 && \
    cmake --install build --prefix dist && cp -a dist/* /usr/

## baresip logic
FROM libre AS baresip-modules

ARG BARESIP_VERSION
ARG MODULES_LIST

RUN install_packages libopus0 libasound2-dev libasound2 libasound2-data libsndfile-dev libspandsp-dev libpulse-dev libjack-jackd2-0 jackd2 libsndio7.0 \
    libmpg123-dev libsrtp2-dev libcodec2-dev libtwolame-dev libmp3lame-dev libspeexdsp-dev portaudio19-dev syslog-ng alsa-utils alsa-oss

RUN git clone -b ${BARESIP_VERSION} --single-branch https://github.com/baresip/baresip.git && \
    cd baresip && \
    cmake -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_FLAGS="-g" -DCMAKE_CXX_FLAGS="-g" -DCMAKE_C_COMPILER=clang-15 -DSTATIC=ON \
        -DCMAKE_CXX_COMPILER=clang++-15 -DCMAKE_INSTALL_PREFIX=/usr -DAPP_MODULES="" -DMODULES=${MODULES_LIST} && \
    cmake --build build -j && \
    cmake --install build --prefix dist && cp -a dist/* /usr/

FROM baresip-modules AS baresip-with-audio

COPY entrypoint.sh ./

CMD ["baresip"]
ENTRYPOINT ["./entrypoint.sh"]
