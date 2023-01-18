#!/usr/bin/env python
# coding: utf-8

import numpy as np
import requests
import ast
import logging
import os
from PIL import Image
import gradio as gr

def make_prediction(img:np.array, img_size:int, host:str)-> requests:
  """
  Make a binary prediction from a single fingerprint image.
  Args:
   img - The request image array.
   img_size - The image height and width.
   host - The hostname[:port] of the model service.
  Returns: The model output prediction.
  """
  #
  # Build the request payload. The "name" must match the
  # input layer name of the model.
  #
  req2 = {
      "inputs": [
        {
          "name": "conv2d_12_input",
          "shape": [1, img_size, img_size, 1],
          "datatype": "FP32",
          "data": img.tolist()
        }
      ]
    }

  url = f'https://{host}/v2/models/fingerprint/infer'
  r = requests.post(url, json=req2)
  return r

def predict(image):
    logging.debug(f"predict(): type = {type(image)}")
    logging.debug(f"predict(): image = {image}")

    resized = image.resize((96, 96)).convert('L')
    logging.debug(f"predict(): resized = {resized}")
    np_image = np.asarray(resized)
    host = os.getenv("INFERENCE_HOST")
    logging.info(f"predict(): INFERENCE_HOST = {host}")
    r = make_prediction(np_image, 96, host)
    p = ast.literal_eval(r.content.decode())
    logging.debug(f"predict(): outputs = {p}")

    if p['outputs'][0]['data'][0] > 0.95:
      return_string = "Right Hand"
    else:
        return_string = "Left Hand"

    return f"Prediction = {return_string}"

if __name__ == "__main__":

  logging.basicConfig(level=logging.INFO)

  demo = gr.Interface(predict, gr.Image(type="pil"), "text",
      flagging_options=["blurry", "incorrect", "other"], examples=[
          os.path.join(os.path.abspath(''), "images/103__F_Left_index_finger.png"),
          os.path.join(os.path.abspath(''), "images/275__F_Left_index_finger.png"),
          os.path.join(os.path.abspath(''), "images/232__M_Right_index_finger.png"),
          os.path.join(os.path.abspath(''), "images/504__M_Right_index_finger.png")
          ], title="Fingerprint Classifier")

  # - Set server name and port for Gradio
  GRADIO_SERVER_PORT=int(os.getenv("GRADIO_SERVER_PORT"))   # Automatically set by the Dockerfile
  GRADIO_SERVER_NAME=os.getenv("GRADIO_SERVER_NAME")        # Automatically set by the Dockerfile

  demo.launch(server_name=GRADIO_SERVER_NAME, server_port=GRADIO_SERVER_PORT)

  demo.close()
