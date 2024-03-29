#!/usr/bin/env python
# coding: utf-8

import numpy as np
import requests
import ast
import logging
import os, json
from PIL import Image
import gradio as gr


loglevel = os.getenv("LOGLEVEL", "INFO")


def make_prediction(img: np.array, img_size: int, endpoint: str) -> requests:
    """
    Make a binary prediction from a single fingerprint image.
    Args:
     img - The request image array.
     img_size - The image height and width.
     endpoint - The [http(s)]://hostname[:port] of the model api
    Returns: The model output prediction.
    """
    #
    # Build the request payload. The "name" must match the
    # input layer name of the model.
    #

    info = requests.get(endpoint).json()
    logging.debug(f"predict(): info {info}")

    submit = {
        "inputs": [
            {
                "name": info["inputs"][0]["name"],
                "shape": [1, img_size, img_size, 1],
                "datatype": info["inputs"][0]["datatype"],
                "data": img.tolist(),
            }
        ]
    }

    url = endpoint + "/infer"
    r = requests.post(url, json=submit)
    return r


def predict(image):
    logging.debug(f"predict(): type = {type(image)}")
    logging.debug(f"predict(): image = {image}")

    resized = image.resize((96, 96)).convert("L")
    logging.debug(f"predict(): resized = {resized}")
    np_image = np.asarray(resized)

    endpoint = os.getenv("INFERENCE_ENDPOINT", "http://localhost:8000/v2/models/hand")
    logging.debug(f"predict(): INFERENCE_ENDPOINT = {endpoint}")

    r = make_prediction(np_image, 96, endpoint)
    logging.debug(f"predict(): r = {r}")
    p = ast.literal_eval(r.content.decode())
    logging.info(f"predict(): outputs = {p}")

    percent = p["outputs"][0]["data"][0]

    if percent > 0.95:
        return_string = f"Left Hand"
    else:
        return_string = f"Right Hand"

    return f"Prediction = {return_string}\n\nResult =\n{json.dumps(p, indent=4)}"


if __name__ == "__main__":
    logging.basicConfig(level=loglevel.upper())

    local_dev = """
    For local testing try:

    export INFERENCE_ENDPOINT="http://localhost:8000/v2/models/hand"
    curl ${INFERENCE_ENDPOINT} | python -m json.tool
    """

    print(local_dev)

    demo = gr.Interface(
        predict,
        gr.Image(type="pil"),
        "text",
        analytics_enabled=False,
        flagging_options=["blurry", "incorrect", "offensive"],
        flagging_dir="flagged",
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
        description="In the examples provided, the first two images are Left prints and the second two are Right prints.",
    )

    # - Set server name and port for Gradio
    GRADIO_SERVER_PORT = int(os.getenv("GRADIO_SERVER_PORT", "8080"))
    GRADIO_SERVER_NAME = os.getenv("GRADIO_SERVER_NAME", "0.0.0.0")

    demo.launch(server_name=GRADIO_SERVER_NAME, server_port=GRADIO_SERVER_PORT)

    demo.close()
