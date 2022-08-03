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
@click.option('--n_components', default=4, help='boundary condition')
@click.option('--svd_solver', default="full", help='cut-off for two point stats')
@click.option('--input_filename', default='input.npy', help='CSV output file name')
@click.option('--output_filename', default='output.npy', help='CSV output file name')
@click.option('--random_state', default=99, help='Correlations of interest')
def PCA_f(n_components,svd_solver,random_state,input_filename,output_filename):
    array = np.load(input_filename)
    flat_corr = GenericTransformer(lambda x: x.reshape(x.shape[0], -1)).transform(array)
    pc_scores = PCA(svd_solver='full',n_components=3,random_state=10).fit_transform(flat_corr)
    np.save(output_filename,pc_scores)



if __name__ == '__main__':
    PCA_f()
