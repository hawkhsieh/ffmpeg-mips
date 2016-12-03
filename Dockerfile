FROM ubuntu:14.04

RUN dpkg --add-architecture i386 \
    && apt-get update 

RUN apt-get install -y libc6:i386 libncurses5:i386 libstdc++6:i386 
RUN apt-get install -y lib32z1 lib32ncurses5 lib32bz2-1.0 
RUN apt-get install -y curl wget htop git 
RUN apt-get install -y build-essential libncurses-dev autoconf automake libtool

COPY ./ipcam.tar.bz2 /root
RUN cd /root && tar -jxf ./ipcam.tar.bz2
ENV PATH $PATH:"/root/rsdk-1.5.5-5281-EB-2.6.30-0.9.30.3-110714/bin"

#
# librtmp
#
ENV TOOLCHAIN_PATH=/root/rsdk-1.5.5-5281-EB-2.6.30-0.9.30.3-110714/
RUN cd /root && git clone git://git.ffmpeg.org/rtmpdump
RUN cd /root/rtmpdump &&  \
    CROSS_COMPILE=mips-linux- make CRYPTO= && \
    cp ./librtmp/librtmp.a ${TOOLCHAIN_PATH}/lib &&  \
    mkdir -p ${TOOLCHAIN_PATH}/include/librtmp &&  \
    cp ./librtmp/amf.h ${TOOLCHAIN_PATH}/include/librtmp &&  \
    cp ./librtmp/rtmp.h ${TOOLCHAIN_PATH}/include/librtmp &&  \
    cp ./librtmp/log.h ${TOOLCHAIN_PATH}/include/librtmp  

#
# x264
#
COPY ./x264-snapshot-20161126-2245-stable /root/x264-snapshot-20161126-2245-stable
#RUN cd /root/x264-snapshot-20161126-2245-stable && ./configure --host=mips-linux --prefix=/root/rsdk-1.5.5-5281-EB-2.6.30-0.9.30.3-110714/  --enable-static --disable-shared --disable-opencl --disable-asm
RUN cd /root/x264-snapshot-20161126-2245-stable && \  
    make && make install  


#
# ffmpeg
#
#RUN curl -Ls "https://github.com/FFmpeg/FFmpeg/archive/n3.2.tar.gz" | tar -zx -C /root
RUN mkdir /root/FFmpeg
ADD ./FFmpeg/ /root/FFmpeg
RUN cd /root/FFmpeg/ && ./configure --enable-cross-compile --arch=mips --target-os=linux --cross-prefix=mips-linux- --extra-ldflags=-static --extra-ldflags=-lrtmp \
--disable-asm --disable-yasm --disable-optimizations --disable-inline-asm --disable-mipsfpu --disable-mips32r5 --disable-mips64r6 --disable-mipsdspr2 \
--disable-encoders --enable-gpl --enable-libx264 --enable-encoder=libx264 \
--disable-decoders --enable-decoder=h264 \
--disable-muxers --enable-muxer=flv \
--disable-demuxers --enable-demuxer=rtsp --enable-demuxer=flv \
--disable-filters \
--disable-protocols --enable-protocol=file --enable-protocol=tcp --enable-protocol=rtmp \
--disable-avdevice --disable-parsers --disable-hwaccels --disable-bsfs --disable-indevs --disable-outdevs --disable-ffprobe --disable-ffserver \
--enable-network \
--enable-parser=aac --enable-parser=mpegvideo --enable-parser=h264 --enable-librtmp \
--enable-ffprobe --enable-ffserver \
--enable-debug

RUN cd /root/FFmpeg/ && make



