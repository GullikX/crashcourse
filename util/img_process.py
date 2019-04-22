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
    image_blue_cones_reduced = []
    image_yellow_cones = np.zeros((np.shape(image)[0], np.shape(image)[1]))
    image_yellow_cones_reduced = []
    for i in range(len(image)):
        for j in range(len(image[i])):
            if np.equal(image[i, j], color_blue_cone).all():
                image_blue_cones[i, j] = 1
                image_blue_cones_reduced.append((i,j))
            if np.equal(image[i, j], color_yellow_cone).all():
                image_yellow_cones[i, j] = 1
                image_yellow_cones_reduced.append((i, j))

    x = np.linspace(0, np.shape(image)[1])

    plt.figure()
    plt.imshow(image_blue_cones, cmap='Blues', interpolation='nearest')
    image_blue_cones_reduced = np.array(image_blue_cones_reduced).transpose()
    fit_blue = np.polyfit(image_blue_cones_reduced[1], image_blue_cones_reduced[0], 1)
    plt.plot(x, fit_blue[0] * x + fit_blue[1])
    plt.ylim(np.shape(image)[0], 0)

    plt.figure()
    plt.imshow(image_yellow_cones, cmap='Oranges', interpolation='nearest')
    image_yellow_cones_reduced = np.array(image_yellow_cones_reduced).transpose()
    fit_yellow = np.polyfit(image_yellow_cones_reduced[1], image_yellow_cones_reduced[0], 1)
    plt.plot(x, fit_yellow[0] * x + fit_yellow[1], 'r')
    plt.ylim(np.shape(image)[0], 0)
    plt.show()


if __name__ == "__main__":
    main()
