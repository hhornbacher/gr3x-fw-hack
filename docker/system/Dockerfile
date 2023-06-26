FROM multiarch/qemu-user-static:x86_64-arm as qemu

FROM scratch

COPY --from=qemu /usr/bin/qemu-arm-static /usr/bin

ADD rootfs /

COPY start.sh /

CMD [ "/start.sh" ]
