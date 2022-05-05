FROM alpine:latest
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories && \
	ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
	echo "Asia/Shanghai" > /etc/timezone
RUN apk add --no-cache tzdata moreutils git nodejs npm curl bash
RUN git clone https://github.com/awamwang/jd-scripts-docker-wm.git /jd-scripts-docker_tmp
RUN git clone --branch=main https://github.com/JDHelloWorld/jd_scripts.git /scripts_tmp
RUN git clone --branch=main https://github.com/chinnkarahoi/Loon.git /loon_tmp
RUN git clone --branch=main https://github.com/zero205/JD_tencent_scf.git /JD_tmp
RUN echo "140.82.114.4 github.com" > /etc/hosts

RUN date

WORKDIR /
COPY sync.sh /sync.sh
COPY custom.list /custom.list
RUN bash /sync.sh
COPY ./cron_wrapper /jd-scripts-docker/cron_wrapper
CMD crontab -l && crond -f
