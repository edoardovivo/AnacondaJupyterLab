FROM continuumio/anaconda3:latest


SHELL [ "/bin/bash", "--login", "-c" ]

RUN apt-get update && apt-get install g++ -y && apt-get install graphviz -y && apt-get update && apt-get install twine -y && apt-get install -y nodejs npm  -y && apt-get update

# Create a non-root user
ARG username=edo
ARG uid=1000
ARG gid=100
ENV USER $username
ENV UID $uid
ENV GID $gid
ENV HOME /home/$USER
RUN adduser --disabled-password \
    --gecos "Non-root user" \
    --uid $UID \
    --gid $GID \
    --home $HOME \
    $USER

COPY start_jupyterlab.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/start_jupyterlab.sh




COPY environment.yml requirements.txt /tmp/
RUN chown $UID:$GID /tmp/environment.yml /tmp/requirements.txt
COPY postBuild /usr/local/bin/postBuild.sh
RUN chown $UID:$GID /usr/local/bin/postBuild.sh
RUN chmod u+x /usr/local/bin/postBuild.sh

COPY entrypoint.sh /usr/local/bin/
RUN chown $UID:$GID /usr/local/bin/entrypoint.sh
RUN chmod u+x /usr/local/bin/entrypoint.sh

ENV ENV_PREFIX /env
RUN mkdir $ENV_PREFIX
RUN chown -R $UID:$GID /env

#RUN chown -R $UID:$GID /opt/conda

ENV PATH $PATH:$HOME/.local/bin

#RUN /opt/conda/bin/pip install jupyter_contrib_nbextensions
#RUN /opt/conda/bin/jupyter contrib nbextension install --sys-prefix
#RUN /opt/conda/bin/jupyter nbextension enable collapsible_headings/main --sys-prefix

RUN conda install nodejs
#RUN conda install -c conda-forge jupyterlab-plotly-extension


RUN conda update --all
RUN /opt/conda/bin/jupyter labextension install jupyterlab-plotly
RUN /opt/conda/bin/jupyter labextension install jupyterlab-chart-editor




USER $USER

# create a project directory inside user home
ENV PROJECT_DIR $HOME/Notebooks
RUN mkdir $PROJECT_DIR
WORKDIR $PROJECT_DIR

RUN whereis pip3

#RUN /opt/conda/bin/conda install m2w64-toolchain
#RUN /opt/conda/bin/conda install -c anaconda libpython
RUN /opt/conda/bin/conda init bash

RUN /opt/conda/bin/python3 -m pip install -r /tmp/requirements.txt




ENTRYPOINT [ "/bin/bash" ]

# default command will launch JupyterLab server for development
#CMD ["start_jupyter.sh", "/home/edo/Notebooks"]
#CMD [ "jupyter", "lab", "--no-browser", "--ip", "0.0.0.0", "--no-browser", "--allow-root", "--NotebookApp.token=" ]
CMD ["start_jupyterlab.sh", "/home/edo/Notebooks"]



















