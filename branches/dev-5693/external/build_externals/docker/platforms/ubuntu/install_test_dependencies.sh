#!/bin/sh

set -e
apt-get update
apt-get install -y libgomp1 python-matplotlib
pip install --upgrade setuptools
pip install scipy
sed -i "/^backend/c\\backend:Agg" $(python -c "import matplotlib;print(matplotlib.matplotlib_fname())")'  