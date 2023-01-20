FROM registry.access.redhat.com/ubi7/python-38

# /opt/app-root/src/ is where s2i dumps git src
COPY . /opt/app-root/src/

RUN pip --no-cache-dir install -U pip && \
    pip --no-cache-dir install -r requirements.txt

ENV PYTHONUNBUFFERED=1
ENV PYTHONIOENCODING=UTF-8

EXPOSE 8080

ENTRYPOINT ["python"]
CMD ["gradio.py"]