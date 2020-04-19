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
    OSXCROSS_OSX_VERSION_MIN=10.5 \
    OSXCROSS_TARGET=darwin15 \
    OSXCROSS_SDK_VERSION=10.11 \
    OSXCROSS_SDK=/opt/osxcross/target/bin/../SDK/MacOSX10.11.sdk

RUN apt-get install -y make ccache p7zip-full python3-requests

COPY osxcross-extras/ /opt/osxcross-extras

# Install osxcross-extras
RUN git clone https://github.com/liushuyu/osxcross-extras && cd /opt/osxcross-extras && \
    ./install_extras.sh

ENV BINARYPACKAGE=1

RUN cd /opt/osxcross && \
    rm -rf /opt/osxcross/target/SDK/MacOSX*/* && \
   ./package.sh && \
   OSXCROSS_VERSION=`cat /opt/osxcross/build.sh | grep "VERSION" | head -n1 | tr '=' ' ' | awk '{print $2}'` && \
   mv osxcross-v_.tar.xz osxcross-v${OSXCROSS_VERSION}_SDK_${OSXCROSS_SDK_VERSION}.tar.xz
