import numpy as np
import matplotlib.pyplot as plt

def plot_analysis(analysis):

    plt.style.use('seaborn-deep')

    x = np.random.normal(1, 2, 5000)
    y = np.random.normal(-1, 3, 2000)
    bins = np.linspace(-10, 10, 30)

    plt.hist([x, y], bins, label=['x', 'y'])
    plt.legend(loc='upper right')
    plt.show()

if __name__ == "__main__":
    with open("./experiments/reports/analysis-phas3.txt","r") as f:
        print(f)