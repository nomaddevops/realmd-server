ARG MANGOS_VERSION
FROM --platform=linux/amd64 mangos-base:$MANGOS_VERSION as build-realmd
WORKDIR /home/build
RUN cmake .. -DCMAKE_INSTALL_PREFIX=/mangos -DBUILD_MANGOSD=0 -DBUILD_REALMD=1 -DBUILD_TOOLS=0
RUN make -j4
RUN make install

FROM --platform=linux/amd64 ubuntu:18.04 as realmd
COPY --from=build-realmd /etc/realmd.conf.dist /etc/realmd/realmd.conf.dist
COPY --from=build-realmd /mangos/bin/realmd /usr/local/bin/
RUN chmod +x /usr/local/bin/realmd
RUN apt-get -y update && apt-get -y upgrade
RUN apt-get -y install libmysqlclient20 openssl
VOLUME ["/etc/realmd"]
EXPOSE 3724
CMD ["/usr/local/bin/realmd","-c","/etc/realmd/realmd.conf.dist"]
