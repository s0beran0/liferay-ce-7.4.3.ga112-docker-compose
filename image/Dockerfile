FROM liferay/portal:7.4.3.67-ga67
USER root
COPY tzdata_2023d-1_all.deb /tmp/
RUN dpkg -i /tmp/tzdata_2023d-1_all.deb
RUN unlink /etc/localtime
RUN ln -s /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
RUN rm -rf /tmp/tzdata_2023d-1_all.deb
RUN rm -f /opt/liferay/tomcat/conf/server.xml
COPY portal-ext.properties /opt/liferay/
COPY keystore.jks /opt/liferay
COPY server.xml /opt/liferay/tomcat/conf/
COPY com.liferay.portal.search.elasticsearch7.configuration.ElasticsearchConfiguration.config /opt/liferay/osgi/configs/com.liferay.portal.search.elasticsearch7.configuration.ElasticsearchConfiguration.config
RUN chown -R liferay. /opt/liferay


USER liferay

