import sys
import warnings
warnings.filterwarnings('ignore')
import numpy as np
import matplotlib.pyplot as plt
from sklearn.metrics import r2_score
from sklearn.linear_model import LinearRegression
from dask_ml.model_selection import train_test_split

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
@click.option('--input_filename1', default='input.npy', help='CSV output file name')
@click.option('--input_filename2', default='inpu2.npy', help='CSV output file name')
@click.option('--output_filename', default='output.npy', help='CSV output file name')
def LinearReg(input_filename1,input_filename2,output_filename):
    array = np.load(input_filename1)
    y_stress = np.load(input_filename2)
    x_train, x_test, y_train, y_test = train_test_split(array,y_stress,test_size=0.2,random_state=3)
    Model = LinearRegression().fit(x_train,y_train)
    y_pred = Model.predict(x_test)
    r2=r2_score(y_test, y_pred)
    np.save(output_filename,r2)


if __name__ == '__main__':
    LinearReg()
