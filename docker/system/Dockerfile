FROM multiarch/qemu-user-static:x86_64-arm as qemu

FROM scratch

ADD rootfs /

COPY --from=qemu /usr/bin/qemu-arm-static /usr/bin

COPY start.sh /

CMD [ "/start.sh" ]
