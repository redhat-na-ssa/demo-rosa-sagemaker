FROM registry.access.redhat.com/ubi7/python-38

COPY . /opt/app-root/src/

RUN pip --no-cache-dir install -U pip && \
    pip --no-cache-dir install -r requirements.txt

ENV PYTHONUNBUFFERED=1
ENV PYTHONIOENCODING=UTF-8

ENV GRADIO_SERVER_PORT=8080
ENV GRADIO_SERVER_NAME=0.0.0.0

EXPOSE 8080

ENTRYPOINT ["python"]
CMD ["client-gradio.py"]