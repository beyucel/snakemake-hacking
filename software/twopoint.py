import sys
import warnings
warnings.filterwarnings('ignore')
import numpy as np
import matplotlib.pyplot as plt
from sklearn.decomposition import PCA
from mpl_toolkits.mplot3d import Axes3D
from PIL import Image

from pymks import (
    generate_multiphase,
    plot_microstructures,
    PrimitiveTransformer,
    TwoPointCorrelation,
    FlattenTransformer
)

input_file = sys.argv[1]
output_file = sys.argv[2]

im = Image.open(input_file)
imarray = np.expand_dims(np.array(im), axis=0)
print("Berkay2")
data = PrimitiveTransformer(n_state=2, min_=0.0, max_=1.0).transform(imarray)
auto_correlation = TwoPointCorrelation(periodic_boundary=True,cutoff=25,correlations=[(0,0)]).transform(data)
np.save(output_file,auto_correlation)
