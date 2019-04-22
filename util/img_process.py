#!/usr/bin/env python3
import imageio
import matplotlib.pyplot as plt
import numpy as np

image_path = "2019-04-22-124016_2560x1440_scrot.png"
color_blue_cone = (13, 71, 161)
color_yellow_cone = (255, 214, 0)

def main():
    image_path = "2019-04-22-124016_2560x1440_scrot.png"
    image = np.array(imageio.imread(image_path))
    image_blue_cones = np.zeros((np.shape(image)[0], np.shape(image)[1]))
    image_yellow_cones = np.zeros((np.shape(image)[0], np.shape(image)[1]))
    for i in range(len(image)):
        for j in range(len(image[i])):
            if np.equal(image[i, j], color_blue_cone).all():
                image_blue_cones[i, j] = 1
            if np.equal(image[i, j], color_yellow_cone).all():
                image_yellow_cones[i, j] = 1
    
    plt.figure()
    plt.imshow(image_blue_cones, cmap='Blues', interpolation='nearest')
    plt.figure()
    plt.imshow(image_yellow_cones, cmap='Oranges', interpolation='nearest')
    plt.show()


if __name__ == "__main__":
    main()
