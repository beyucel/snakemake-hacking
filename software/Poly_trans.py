import sys
import warnings
warnings.filterwarnings('ignore')
import numpy as np
import matplotlib.pyplot as plt
from sklearn.decomposition import PCA

import click


from pymks import (
    generate_multiphase,
    solve_fe,
    plot_microstructures,
    PrimitiveTransformer,
    TwoPointCorrelation,
    GenericTransformer
)

@click.command()
@click.option('--degree', default=2, help='boundary condition')
@click.option('--input_filename', default='input.npy', help='CSV output file name')
@click.option('--output_filename', default='output.npy', help='CSV output file name')
def Poly_trans(degree,input_filename,output_filename):
    array = np.load(input_filename)
    Poly_array = PolynomialFeatures(degree =2).fit_transform(array)
    np.save(output_filename,Poly_array)



if __name__ == '__main__':
    Poly_trans()
