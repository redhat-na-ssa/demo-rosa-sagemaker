FROM registry.access.redhat.com/ubi8/python-38

USER root

# /opt/app-root/src/ is where s2i dumps git src
COPY . /opt/app-root/src/

RUN pip --no-cache-dir install -U pip && \
    pip --no-cache-dir install -r requirements.txt && \
    chmod -R g+rw .

ENV PYTHONUNBUFFERED=1
ENV PYTHONIOENCODING=UTF-8

EXPOSE 8080

USER 1001

ENTRYPOINT ["python"]
CMD ["app.py"]