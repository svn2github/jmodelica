#!/bin/sh

set -e


pip install --upgrade setuptools
pip install scipy lxml
yum install -y python-matplotlib
yum install -y libgomp
sed -i "/^backend/c\\backend:Agg" $(python -c "import matplotlib;print(matplotlib.matplotlib_fname())")

yum install -y make

pip install colorama decorator jinja2 jpype1
pip install --upgrade lxml
yum install -y java-1.8.0-openjdk

# Debug packages
yum install -y tmux vim