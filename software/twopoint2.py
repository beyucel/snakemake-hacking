import sys
import warnings
warnings.filterwarnings('ignore')
import numpy as np
import matplotlib.pyplot as plt
from sklearn.decomposition import PCA
from mpl_toolkits.mplot3d import Axes3D
from PIL import Image

import click


from pymks import (
    generate_multiphase,
    plot_microstructures,
    PrimitiveTransformer,
    TwoPointCorrelation,
    FlattenTransformer
)

@click.command()
@click.option('--periodic_boundary', default=True, help='boundary condition')
@click.option('--cutoff', default=15, help='cut-off for two point stats')
@click.option('--input_filename', default='input.npy', help='CSV output file name')
@click.option('--output_filename', default='output.npy', help='CSV output file name')
@click.option('--correlations', default=1, help='Correlations of interest')
def twopoint(periodic_boundary,cutoff,correlations,input_filename,output_filename):
    print("Berkay")
    array = np.load(input_filename)

    print(input_filename)
    data = PrimitiveTransformer(n_state=2, min_=0.0, max_=1.0).transform(array)
    auto_correlation = TwoPointCorrelation(periodic_boundary=periodic_boundary,cutoff=25,correlations=[(0,0)]).transform(data)
    np.save(output_filename,auto_correlation)

if __name__ == '__main__':
    twopoint()
