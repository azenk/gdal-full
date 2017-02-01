FROM centos:latest

RUN yum install -y wget bzip2 unzip gcc bison flex readline-devel zlib-devel make gcc-c++ && yum clean all

ENV PGC_GDAL_INSTALL_ROOT /usr/local/gdal

WORKDIR /tmp/gdal_build

ENV PATH=$PGC_GDAL_INSTALL_ROOT/anaconda/bin:$PATH
RUN wget --no-check-certificate -q \
    http://repo.continuum.io/miniconda/Miniconda-3.7.0-Linux-x86_64.sh && \
    bash Miniconda-3.7.0-Linux-x86_64.sh -b -p $PGC_GDAL_INSTALL_ROOT/anaconda && \
    rm -f Miniconda* && \
    conda install --yes scipy jinja2 conda-build dateutil shapely scikit-image pip && \
    conda clean --all --yes

RUN wget --no-check-certificate -q \
    https://github.com/bw2/ConfigArgParse/archive/master.zip && \
    unzip master.zip && \
    cd ConfigArgParse-master && \
    python setup.py build && \
    python setup.py install && \
    cd .. && \
    rm -f master.zip && \
    rm -rf ConfigArgParse-master

ENV vers 0.1
RUN wget --no-check-certificate -q \
    https://github.com/minadyn/conda-postgresql-client/archive/$vers.zip && \
    unzip $vers && \
    conda build conda-postgresql-client-$vers && \
    conda install --yes $(conda build conda-postgresql-client-$vers --output) && \
    rm -rf conda-postgresql-client-$vers

RUN wget --no-check-certificate -q \
    https://github.com/PolarGeospatialCenter/asp/raw/master/originals/cfitsio/cfitsio3360.tar.gz && \
    tar xvfz cfitsio3360.tar.gz && \
    cd cfitsio && \
    ./configure --prefix=$PGC_GDAL_INSTALL_ROOT/cfitsio --enable-sse2 --enable-ssse3 --enable-reentrant && \
    make -j && make install && \
    cd .. && rm -rf cfitsio*

ENV SWIG_FEATURES -I/usr/share/swig/1.3.40/python -I/usr/share/swig/1.3.40
RUN wget --no-check-certificate -q \
    https://github.com/PolarGeospatialCenter/asp/raw/master/originals/geos/geos-3.4.2.tar.bz2 && \
    tar xvfj geos-3.4.2.tar.bz2 && \
    cd geos-3.4.2 && \
    ./configure --prefix=$PGC_GDAL_INSTALL_ROOT/geos && \
    make -j && make install && \
    cd .. && rm -rf geos*

RUN wget --no-check-certificate -q\
    https://github.com/PolarGeospatialCenter/asp/raw/master/originals/proj/proj-4.8.0.tar.gz && \
    tar xvfz proj-4.8.0.tar.gz && \
    cd proj-4.8.0 && \
    ./configure --prefix=$PGC_GDAL_INSTALL_ROOT/proj --with-jni=no && \
    make -j && make install && \
    cd .. && rm -rf proj*

RUN wget --no-check-certificate -q \
    https://cmake.org/files/v3.4/cmake-3.4.1.tar.gz && \
    tar xvfz cmake-3.4.1.tar.gz && \
    cd cmake-3.4.1 && \
    ./configure --prefix=$PGC_GDAL_INSTALL_ROOT/cmake && \
    gmake && gmake install && \
    cd .. && rm -rf cmake*

RUN wget --no-check-certificate -q \
    https://github.com/PolarGeospatialCenter/asp/raw/master/originals/openjpeg/openjpeg-2.0.0.tar.gz && \
    tar xvfz openjpeg-2.0.0.tar.gz && \
    cd openjpeg-2.0.0 && \
    $PGC_GDAL_INSTALL_ROOT/cmake/bin/cmake -DCMAKE_INSTALL_PREFIX=$PGC_GDAL_INSTALL_ROOT/openjpeg-2 && \
    make install && \
    cd .. && rm -rf openjpeg*

ENV gdal_version 2.1.3
RUN wget --no-check-certificate -q \
    http://download.osgeo.org/gdal/$gdal_version/gdal-$gdal_version.tar.gz && \
    tar xvfz gdal-$gdal_version.tar.gz && \
    cd gdal-$gdal_version && \
    ./configure --prefix=$PGC_GDAL_INSTALL_ROOT/gdal \
    --with-geos=$PGC_GDAL_INSTALL_ROOT/geos/bin/geos-config \
    --with-cfitsio=$PGC_GDAL_INSTALL_ROOT/cfitsio \
    --with-python --with-openjpeg=$PGC_GDAL_INSTALL_ROOT/openjpeg-2 --with-sqlite3=no && \
    make && make install && \
    cd swig/python && python setup.py install && \
    cd ../../.. && rm -rf gdal*

WORKDIR /tmp

RUN rm -rf /tmp/gdal_build

ADD init-gdal.sh /etc/profile.d/init-gdal.sh

CMD /bin/bash
