FROM debian:testing-slim

# Install build tools
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yy \
        automake curl file git libtool pkg-config \
        python3 texinfo vim  wget cmake clang zlib1g-dev build-essential

COPY osxcross/ /opt/osxcross

# Install osxcross
RUN cd /opt/osxcross && \
    ./tools/get_dependencies.sh && \
    wget -O tarballs/MacOSX10.11.sdk.tar.bz2 https://github.com/tritao/XcodeSDKPackager/releases/download/untagged-1fc44ce590ee92f97178/MacOSX10.11.sdk-Xcode7.3.tar.bz2 && \
    UNATTENDED=1 PORTABLE=true ./build.sh

ENV PATH=$PATH:/opt/osxcross/target/bin \
    MACOSX_DEPLOYMENT_TARGET=10.11 \
    OSXCROSS_MP_INC=1 \
    OSXCROSS_HOST=x86_64-apple-darwin15 \
    OSXCROSS_VERSION=1.0 \
    OSXCROSS_OSX_VERSION_MIN=10.5 \
    OSXCROSS_TARGET=darwin15 \
    OSXCROSS_SDK_VERSION=10.11 \
    OSXCROSS_SDK=/opt/osxcross/target/bin/../SDK/MacOSX10.11.sdk \
    OSXCROSS_TARBALL_DIR=/opt/osxcross/target/bin/../../tarballs \
    OSXCROSS_PATCH_DIR=/opt/osxcross/target/bin/../../patches \
    OSXCROSS_TARGET_DIR=/opt/osxcross/target/bin/.. \
    OSXCROSS_BUILD_DIR=/opt/osxcross/build \
    OSXCROSS_CCTOOLS_PATH=/opt/osxcross/target/bin \
    OSXCROSS_LIBLTO_PATH=/usr/lib/llvm-7/lib \
    OSXCROSS_LINKER_VERSION=409.12

RUN apt-get install -y make ccache p7zip-full python3-requests

COPY osxcross-extras/ /opt/osxcross-extras

# Install osxcross-extras
RUN git clone https://github.com/liushuyu/osxcross-extras && cd /opt/osxcross-extras && \
    ./install_extras.sh

RUN cd /opt/osxcross && \
    ./package.sh 