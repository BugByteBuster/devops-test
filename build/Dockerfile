FROM nginx:1.25.3
RUN mkdir /home/demo
RUN chmod 755 /home/demo
COPY default.conf /etc/nginx/conf.d/
COPY index.html /home/demo/
COPY page1.html /home/demo/
COPY page2.html /home/demo/