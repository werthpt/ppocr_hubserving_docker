FROM paddlepaddle/paddle:2.6.2

ENV DET=ch_PP-OCRv4_det_server_infer.tar
ENV REC=ch_PP-OCRv4_rec_server_infer.tar
ENV CLS=ch_ppocr_mobile_v2.0_cls_slim_infer.tar

# RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN mkdir -p /paddle/PaddleOCR/inference/
# 包含解压缩的源码文件夹 PaddleOCR/  、 
# ch_PP-OCRv4_det_server_infer.tar 、 ch_PP-OCRv4_rec_server_infer.tar 、 ch_ppocr_mobile_v2.0_cls_slim_infer.tar 、
# startup.sh
COPY ["paddle/", "/paddle/"]


RUN cd /paddle/PaddleOCR \
        && pip3 install paddlehub==2.4.0 --upgrade -i https://pypi.tuna.tsinghua.edu.cn/simple \
        && pip3 install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple \
        && pip3 uninstall -y paddle2onnx \
        && pip3 install paddle2onnx==1.3.1 -i https://pypi.tuna.tsinghua.edu.cn/simple \
        && pip3 uninstall -y protobuf \
        && pip3 install protobuf==3.20.2 -i https://pypi.tuna.tsinghua.edu.cn/simple \
        && tar xf /paddle/$DET -C /paddle/PaddleOCR/inference/ && rm -rf /paddle/$DET \
        && tar xf /paddle/$CLS -C /paddle/PaddleOCR/inference/ && rm -rf /paddle/$CLS \
        && tar xf /paddle/$REC -C /paddle/PaddleOCR/inference/ && rm -rf /paddle/$REC \
        && mv /paddle/startup.sh  /paddle/PaddleOCR/startup.sh \
        && apt-get clean && rm -rf /var/cache/apt && rm -rf /paddle/PaddleOCR/.git \
        && sed -i 's|ch_PP-OCRv3_det_infer|ch_PP-OCRv4_det_server_infer|g' /paddle/PaddleOCR/deploy/hubserving/ocr_det/params.py \
        && sed -i 's|ch_PP-OCRv3_rec_infer|ch_PP-OCRv4_rec_server_infer|g' /paddle/PaddleOCR/deploy/hubserving/ocr_rec/params.py \
        && sed -i 's|ch_ppocr_mobile_v2.0_cls_infer|ch_ppocr_mobile_v2.0_cls_slim_infer|g' /paddle/PaddleOCR/deploy/hubserving/ocr_cls/params.py \
        && sed -i 's|ch_PP-OCRv3_det_infer|ch_PP-OCRv4_det_server_infer|g' /paddle/PaddleOCR/deploy/hubserving/ocr_system/params.py \
        && sed -i 's|ch_PP-OCRv3_rec_infer|ch_PP-OCRv4_rec_server_infer|g' /paddle/PaddleOCR/deploy/hubserving/ocr_system/params.py \
        && sed -i 's|ch_ppocr_mobile_v2.0_cls_infer|ch_ppocr_mobile_v2.0_cls_slim_infer|g' /paddle/PaddleOCR/deploy/hubserving/ocr_system/params.py

WORKDIR /paddle/PaddleOCR
EXPOSE 9996

ENTRYPOINT ["/bin/bash","-c","/paddle/PaddleOCR/startup.sh"]
