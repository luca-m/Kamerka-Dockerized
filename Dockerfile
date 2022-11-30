FROM ubuntu:22.04

LABEL maintainer="" \
    org.label-schema.license="" \
    org.label-schema.vendor=""\
    org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.name="Kamerca" \
    org.label-schema.description="" \
    org.label-schema.url="" \
    org.label-schema.vcs-url="" \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.usage="" \
    org.label-schema.docker.cmd="docker run -d --rm --name kamerka kamerka:1.0" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.version=$VERSION

# Environment configuration
# ENV KAMERKA_KEYS = "{json here}"
ENV K_USER=kamerka
ENV K_USER_UID=1000
ENV K_USER_GID=1000

RUN sed -i -e 's/^APT/# APT/' -e 's/^DPkg/# DPkg/' /etc/apt/apt.conf.d/docker-clean

RUN echo "[+] Updating the system repositories"
RUN apt update

RUN echo "[+] Installing software packages"
RUN apt install -qy --no-install-recommends curl python3 libgtk-3-0 python3-pip libdbus-glib-1-2 nmap redis net-tools vim htop jq 

#RUN echo "[+] Setting up redis server service"
#RUN systemctl enable --now redis-server

RUN echo "[+] Preparing kamerka folder"

RUN groupadd -g $K_USER_GID -o $K_USER
RUN useradd -m -u $K_USER_UID -g $K_USER_GID -o -s /bin/bash $K_USER

RUN mkdir -p /home/kamerka/
COPY ./ /home/kamerka/
WORKDIR /home/kamerka/
RUN chown root -R /home/kamerka/

RUN echo "[+] Installing python3 requirements"
RUN cd /home/kamerka; pip3 install -r requirements.txt 


HEALTHCHECK --interval=30s --timeout=3s CMD curl --fail http://127.0.0.1:8000 || exit 1   
HEALTHCHECK --interval=30s --timeout=3s CMD redis-cli ping || exit 1 


# wait for tor circuit completion 
EXPOSE 8000
CMD ["/home/kamerka/start.sh"]
