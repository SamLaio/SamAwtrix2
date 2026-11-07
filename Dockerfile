FROM eclipse-temurin:8-jre-jammy
ENV TZ=Asia/Taipei
WORKDIR /data
COPY awtrix.jar /opt/awtrix/awtrix.jar
COPY --chmod=755 entrypoint.sh /entrypoint.sh
EXPOSE 7000 7001 5568/udp
CMD ["/entrypoint.sh"]
