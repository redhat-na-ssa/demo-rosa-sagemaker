FROM nvcr.io/nvidia/tritonserver:22.11-py3

ENV STI_SCRIPTS_PATH=/usr/libexec/s2i/
COPY s2i/bin/ $STI_SCRIPTS_PATH
COPY usr/ /usr/

### Setup user for build execution and application runtime
ENV APP_ROOT=/opt/app-root

RUN mkdir -p ${APP_ROOT}/{bin,src} && \
    chmod -R u+x ${APP_ROOT}/bin && \
    chgrp -R 0 ${APP_ROOT} && \
    chmod -R g=u ${APP_ROOT}

ENV PATH=${APP_ROOT}/bin:${PATH} \
    HOME=${APP_ROOT}

WORKDIR ${APP_ROOT}/src

USER 1001

EXPOSE 8000 8001 8002

# ENTRYPOINT /opt/nvidia/nvidia_entrypoint.sh
CMD $STI_SCRIPTS_PATH/run
