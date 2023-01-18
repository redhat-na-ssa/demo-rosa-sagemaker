# Need to change to UBI
FROM python:3.10.4

WORKDIR /tmp

COPY . /tmp

RUN pip install -r requirements.txt

ENV PYTHONUNBUFFERED=1
ENV PYTHONIOENCODING=UTF-8

ENV GRADIO_SERVER_PORT=8080
ENV GRADIO_SERVER_NAME=0.0.0.0

EXPOSE 8080

ENTRYPOINT ["python"]
CMD ["client-gradio.py"]