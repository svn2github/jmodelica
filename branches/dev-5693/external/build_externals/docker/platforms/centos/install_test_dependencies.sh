#!/bin/sh

set -e


pip install --upgrade setuptools
pip install scipy
yum install -y python-matplotlib
yum install -y libgomp
sed -i "/^backend/c\\backend:Agg" $(python -c "import matplotlib;print(matplotlib.matplotlib_fname())")

yum install -y make

# Debug packages
yum install -y tmux vim