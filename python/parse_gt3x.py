from pygt3x.reader import FileReader
from pygt3x.calibration import CalibratedReader
from math import sqrt

# Read raw data and calibrate
# Dump to pandas data frame
with FileReader("test.gt3x") as reader:
    dfdf = reader.to_pandas()
    calibrated_reader = CalibratedReader(reader)
    df = calibrated_reader.to_pandas()

    window = 1
    sample_frequency = 100

    df['ENMO'] = df['X']**2 + df['Y']**2 + df['Z']**2

    df['ENMO'] = df['ENMO'].apply(lambda x: sqrt(x) - 1)
    df.loc[df['ENMO'] < 0] = 0
    df['ENMO2'] = df['ENMO'].cumsum()
    
    df['ENMO2'].to_csv('test.csv')
    
    sample_rate = window * sample_frequency

    df = df.iloc[1::sample_rate, :].reset_index()

    df = df['ENMO2'].diff() / 100

    df.to_csv('test.csv')