REQUIREMENTS TO BUILD PYFMI WITH DOCKER

1. svn checkout JModelica

2. cd to JModelica/external/build_externals/build/pyfmi/

3. cp example_user_config user_config_ubuntu (or user_config_centos)

4. edit user_config_ubuntu and follow directions

5. when configs are set follow the next steps

HOW TO BUILD PYFMI BASE IMAGE WITH DOCKER

1. You build a base pyfmi image with config named my_config by running:
    
    make python_fmil USER_CONFIG=my_config
    
2. To build pyfmi (full image) with config named my_config you run:

    make pyfmi_full_image USER_CONFIG=my_config
