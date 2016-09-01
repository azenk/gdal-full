FROM centos:latest

COPY install-scripts/gdal-install.sh /root/gdal-install.sh

RUN yum groupinstall -y Development Tools
RUN yum install -y wget

RUN echo -e "/usr/local/gdal\n2.1.1\n\n" | /root/gdal-install.sh
RUN ln -s /usr/local/gdal/init-gdal.sh /etc/profile.d/init-gdal.sh

CMD /bin/bash
