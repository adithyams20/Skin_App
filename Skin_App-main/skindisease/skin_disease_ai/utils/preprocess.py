import numpy as np
import cv2
from tensorflow.keras.applications.mobilenet_v2 import preprocess_input

IMG_SIZE = 224

def prepare_image(image_path):
    # read image
    img = cv2.imread(image_path)

    # check image
    if img is None:
        raise ValueError("Image not found or unable to read")

    # BGR → RGB (VERY IMPORTANT)
    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)

    # resize
    img = cv2.resize(img, (IMG_SIZE, IMG_SIZE))

    # convert to array
    img = np.array(img, dtype=np.float32)

    # mobilenet preprocessing
    img = preprocess_input(img)

    # model expects batch dimension
    img = np.expand_dims(img, axis=0)

    return img