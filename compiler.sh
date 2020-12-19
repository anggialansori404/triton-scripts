ZIPNAME=New-Perf-Riva-$(date +"%S-%F")
git clone https://github.com/anggialansori404/AnyKernel3 -b ts-proton-rova --depth 1 /tmp/AnyKernel3

mkdir -p out

export KBUILD_BUILD_USER=Hikarinochikara
export KBUILD_BUILD_HOST=Drone
make O=out ARCH=arm64 riva_defconfig

curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
        -d chat_id="$CID" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=html" \
        -d text="build started"

PATH="/tmp/proton/bin:$PATH" \
make -j$(nproc --all) O=out \
                      ARCH=arm64 \
                      CC=clang \
                      CROSS_COMPILE=aarch64-linux-gnu- \
                      CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
                      AR=llvm-ar \
                      NM=llvm-nm

if ! [ -a "out/arch/arm64/boot/Image.gz-dtb" ]; then
	curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
        -d chat_id="$CID" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=html" \
        -d text="Build stopped Compilation Error"
           exit 1
fi
cp out/arch/arm64/boot/Image.gz-dtb /tmp/AnyKernel3
cd /tmp/AnyKernel3
zip -r ${ZIPNAME}.zip *

curl -F document=@$ZIPNAME.zip "https://api.telegram.org/bot$TOKEN/sendDocument" \
        -F chat_id=$CID\
        -F "disable_web_page_preview=true" \
        -F "parse_mode=html"  \
	-F caption="#Perf #New #4.9 #Riva
Compiler- Proton-Clang-v12 follow @Elementooo for more updates"
