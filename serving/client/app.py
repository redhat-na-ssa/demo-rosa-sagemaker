#!/usr/bin/env python
# coding: utf-8

import numpy as np
import requests
import ast
import logging
import os
from PIL import Image
import gradio as gr


loglevel= os.getenv("LOGLEVEL", "INFO")

def make_prediction(img: np.array, img_size: int, endpoint: str) -> requests:
    """
    Make a binary prediction from a single fingerprint image.
    Args:
     img - The request image array.
     img_size - The image height and width.
     endpoint - The [http(s)]://hostname[:port] of the model api
    Returns: The model output prediction.

    export INFERENCE_ENDPOINT='https://model-server-s3-example-triton.apps.cluster-rr8ch.rr8ch.sandbox2223.opentlc.com/v2/models/fingerprint/infer'
    """
    #
    # Build the request payload. The "name" must match the
    # input layer name of the model.
    #

    fingerprint = {
        "inputs": [
            {
                "name": "conv2d_13_input",
                "shape": [1, img_size, img_size, 1],
                "datatype": "FP32",
                "data": img.tolist(),
            }
        ]
    }

    req2 = fingerprint

    url = endpoint
    r = requests.post(url, json=req2)
    return r


def predict(image):
    logging.debug(f"predict(): type = {type(image)}")
    logging.debug(f"predict(): image = {image}")

    resized = image.resize((96, 96)).convert("L")
    logging.debug(f"predict(): resized = {resized}")
    np_image = np.asarray(resized)

    endpoint = os.getenv("INFERENCE_ENDPOINT", "http://localhost:8000")
    logging.info(f"predict(): INFERENCE_ENDPOINT = {endpoint}")

    r = make_prediction(np_image, 96, endpoint)
    p = ast.literal_eval(r.content.decode())
    logging.debug(f"predict(): outputs = {p}")

    if p["outputs"][0]["data"][0] > 0.95:
        return_string = "Right Hand"
    else:
        return_string = "Left Hand"

    return f"Prediction = {return_string}"


if __name__ == "__main__":

    logging.basicConfig(level=logging.loglevel)

    demo = gr.Interface(
        predict,
        gr.Image(type="pil"),
        "text",
        flagging_options=["blurry", "incorrect", "other"],
        examples=sorted(
            [os.path.join("images/", file) for file in os.listdir("images")],
            key=os.path.getctime,
        ),
        # examples=[
        #     os.path.join(os.path.abspath(""), "images/103__F_Left_index_finger.png"),
        #     os.path.join(os.path.abspath(""), "images/275__F_Left_index_finger.png"),
        #     os.path.join(os.path.abspath(""), "images/232__M_Right_index_finger.png"),
        #     os.path.join(os.path.abspath(""), "images/504__M_Right_index_finger.png"),
        # ],
        title="Fingerprint Classifier",
    )

    # - Set server name and port for Gradio
    GRADIO_SERVER_PORT = int(os.getenv("GRADIO_SERVER_PORT", "8080"))
    GRADIO_SERVER_NAME = os.getenv("GRADIO_SERVER_NAME", "0.0.0.0")

    demo.launch(server_name=GRADIO_SERVER_NAME, server_port=GRADIO_SERVER_PORT)

    demo.close()
