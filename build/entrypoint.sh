#!/bin/bash


MODEL_FILES=(
 'SDv1.4.ckpt https://www.googleapis.com/storage/v1/b/aai-blog-files/o/sd-v1-4.ckpt?alt=media fe4efff1e174c627256e44ec2991ba279b3816e364b49f9be2abc0b3ff3f8556'
 'GFPGANv1.3.pth https://github.com/TencentARC/GFPGAN/releases/download/v1.3.0/GFPGANv1.3.pth c953a88f2727c85c3d9ae72e2bd4846bbaf59fe6972ad94130e23e7017524a70'
 'RealESRGAN_x4plus.pth https://github.com/xinntao/Real-ESRGAN/releases/download/v0.1.0/RealESRGAN_x4plus.pth 4fa0d38905f75ac06eb49a7951b426670021be3018265fd191d2125df9d682f1'
 'RealESRGAN_x4plus_anime_6B.pth https://github.com/xinntao/Real-ESRGAN/releases/download/v0.2.2.4/RealESRGAN_x4plus_anime_6B.pth f872d837d3c90ed2e05227bed711af5671a6fd1c9f7d7e91c911a61f155e99da'
)

FACEXLIB_FILES=(
 'detection_Resnet50_Final.pth https://github.com/xinntao/facexlib/releases/download/v0.1.0/detection_Resnet50_Final.pth 6d1de9c2944f2ccddca5f5e010ea5ae64a39845a86311af6fdf30841b0a5a16d'  
 'parsing_parsenet.pth https://github.com/xinntao/facexlib/releases/download/v0.2.2/parsing_parsenet.pth 3d558d8d0e42c20224f13cf5a29c79eba2d59913419f945545d8cf7b72920de2'
)

checksum () {
	local hash="$1"
	local outfile="$2"
	sha256sum --strict --check --status <<< "${hash} $outfile" 
	return $?
}

validateDownload () {
    local file=$1
    local url=$2
    local hash=$3
    local downloaddir="$4"

    echo "checking if ${file} has hash ${hash}..."
    checksum "${hash}" "$downloaddir/${file}"
    if [[ $? -ne 0 ]]; then
        echo "Downloading: ${url} please wait..."
        mkdir -p "$downloaddir" || { echo "ERROR: Cannot create download directory."; exit 1; }
        wget --output-document=$downloaddir/${file} --no-verbose --show-progress --progress=dot:giga ${url}
        echo "saved ${file}"
        if ! checksum "${hash}" "$downloaddir/${file}"; then
        	echo "ERROR: downloaded file has not the right checksum."
        	exit 1
        fi
    else
        echo -e "${file} is valid!\n"
    fi
}

# Validate model files
echo "Validating model files..."
for model in "${MODEL_FILES[@]}"; do
  	model=($model)
    validateDownload ${model[0]} ${model[1]} ${model[2]} /models
done

# Validate facexlib files
echo "Validating facexlib files..."
for model in "${FACEXLIB_FILES[@]}"; do
  	model=($model)
    validateDownload ${model[0]} ${model[1]} ${model[2]} /app/src/facexlib/facexlib/weights
done

#socat TCP4-LISTEN:8080,fork TCP4:172.17.0.1:7860 &

if [ "${RUN_MODE}" = "OPTIMIZED" ] ; then
  echo "Running OPTIMIZED mode"
  conda run --no-capture-output -n ldm python scripts/webui.py --gfpgan-cpu --esrgan-cpu --optimized
elif [ "${RUN_MODE}" = "OPTIMIZED-TURBO" ] ; then
  echo "Running OPTIMIZED-TURBO mode"
  conda run --no-capture-output -n ldm python scripts/webui.py --gfpgan-cpu --esrgan-cpu --optimized-turbo
elif [ "${RUN_MODE}" = "GTX16" ] ; then
  echo "Running GTX16 mode"
  conda run --no-capture-output -n ldm python scripts/webui.py --precision full --no-half --gfpgan-cpu --esrgan-cpu --optimized
elif [ "${RUN_MODE}" = "GTX16-TURBO" ] ; then
  echo "Running GTX16-TURBO mode"
  conda run --no-capture-output -n ldm python scripts/webui.py --precision full --no-half --gfpgan-cpu --esrgan-cpu --optimized-turbo
elif [ "${RUN_MODE}" = "FULL-PRECISION" ] ; then
  echo "Running FULL-PRECISION mode"
  conda run --no-capture-output -n ldm python scripts/webui.py --precision=full --no-half
else
  echo "Running default mode"
  conda run --no-capture-output -n ldm python scripts/webui.py
fi
