import json
import numpy as np
from tensorflow.keras.models import load_model
import sys
import os

# access preprocess file
sys.path.append(os.path.abspath("../utils"))
from preprocess import prepare_image

# load model
model = load_model("skin_disease_model.h5")

# load class labels
with open("class_indices.json", "r") as f:
    class_indices = json.load(f)

# reverse dictionary
labels = {v: k for k, v in class_indices.items()}

def predict(image_path):
    img = prepare_image(image_path)

    prediction = model.predict(img)
    class_id = np.argmax(prediction)
    confidence = float(np.max(prediction)) * 100

    disease_name = labels[class_id]

    print("\nPrediction Result")
    print("Disease:", disease_name)
    print("Confidence: {:.2f}%".format(confidence))

# run prediction
if __name__ == "__main__":
    image_path = input("Enter image path: ")
    predict(image_path)