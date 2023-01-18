import os
import numpy as np
import requests
# import cv2
import ast
import logging
from PIL import Image

model_endpoint = os.environ.get('MODEL_ENDPOINT', 'http://localhost:8000')

def make_prediction(img:np.array, img_size:int, model_endpoint:str)-> requests:
  """
  Make a binary prediction from a single fingerprint image.
  Args:
   img - The request image array.
   img_size - The image height and width.
   model_endpoint - The hostname[:port] of the model service.
  Returns: The model output prediction.
  """
  req2 = {
      "inputs": [
        {
          "name": "conv2d_3_input",
          "shape": [1, img_size, img_size, 1],
          "datatype": "FP32",
          "data": img.tolist()
        }
      ]
    }

  url = f'{model_endpoint}/v2/models/fingerprint/infer'
  r = requests.post(url, json=req2)
  return r

if __name__ == "__main__":

  logging.basicConfig(level=logging.INFO)

  #
  # Get the model server info.
  #
  url = f'{model_endpoint}/v2'
  r = ""
  try:
    r = requests.get(url)
    logging.info("")
    logging.info(f'Triton Server Status:')
    logging.info("")
    logging.info(f'{r.content.decode()}')
    logging.info("")
  except:
    logging.error(f"Requests Error! {r}")

  #
  # Make 4 single image predictions.
  #
  img_size = int(96)
  file_path = "scratch/fingerprint_real"
  # file_path = input(r"Enter path to test data (ex: scratch/fingerprint_real): ")
  file_list = os.listdir(file_path)
  
  print(file_list)

  import skimage
  for filename in file_list:
    #
    # OpenCV option
    #
    # img_data = cv2.imread(f'{file_path}/{filename}', cv2.IMREAD_GRAYSCALE)
    # img_resized = img_data.resize((img_size, img_size))
    # img_resized = cv2.resize(img_data, (img_size, img_size))
    # img_resized.resize(1, img_size, img_size, 1)

    #
    # skimage option
    #
    f = f'{file_path}/{filename}'
    img_data = skimage.io.imread(f, as_gray=True)
    img_resized = skimage.transform.resize(img_data, (img_size,img_size))
    logging.debug(f'img_resized.shape = {img_resized.shape}')
    
    try:
      r = make_prediction(img_resized, img_size, model_endpoint)
      logging.debug(f'REST inference response = {r}')
      logging.debug(f'REST inference content = {r.content}')
      p = ast.literal_eval(r.content.decode())
      logging.info(f"Fingerprint Image = {filename}, Prediction = {p['outputs'][0]['data']}")
    except:
      logging.error(f"Requests POST Error {r.content}")
