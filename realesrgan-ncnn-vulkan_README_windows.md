# RealESRGAN

We have provided five models:

1. realesrgan-x4plus  (default)
2. realesrnet-x4plus
3. realesrgan-x4plus-anime (optimized for anime images, small size)
4. RealESRGANv2-animevideo-xsx2 (anime video, X2)
5. RealESRGANv2-animevideo-xsx4 (anime video, X4)

Command:

1. ./realesrgan-ncnn-vulkan.exe -i input.jpg -o output.png
2. ./realesrgan-ncnn-vulkan.exe -i input.jpg -o output.png -n realesrnet-x4plus
3. ./realesrgan-ncnn-vulkan.exe -i input.jpg -o output.png -n realesrgan-x4plus-anime
4. ./realesrgan-ncnn-vulkan.exe -i input_folder -o outputfolder -n RealESRGANv2-animevideo-xsx2 -s 2 -f jpg
5. ./realesrgan-ncnn-vulkan.exe -i input_folder -o outputfolder -n RealESRGANv2-animevideo-xsx4 -s 4 -f jpg


Commands for enhancing anime videos:

1. Use ffmpeg to extract frames from a video (Remember to create the folder `tmp_frames` ahead)

    ffmpeg -i onepiece_demo.mp4 -qscale:v 1 -qmin 1 -qmax 1 -vsync 0 tmp_frames/frame%08d.png

2. Inference with Real-ESRGAN executable file (Remember to create the folder `out_frames` ahead)

    ./realesrgan-ncnn-vulkan.exe -i tmp_frames -o out_frames -n RealESRGANv2-animevideo-xsx2 -s 2 -f jpg

3. Merge the enhanced frames back into a video

    ffmpeg -i out_frames/frame%08d.jpg -i onepiece_demo.mp4 -map 0:v:0 -map 1:a:0 -c:a copy -c:v libx264 -r 23.98 -pix_fmt yuv420p output_w_audio.mp4

------------------------

GitHub: https://github.com/xinntao/Real-ESRGAN/
Paper: https://arxiv.org/abs/2107.10833

------------------------

This executable file is **portable** and includes all the binaries and models required. No CUDA or PyTorch environment is needed.

Note that it may introduce block inconsistency (and also generate slightly different results from the PyTorch implementation), because this executable file first crops the input image into several tiles, and then processes them separately, finally stitches together.

This executable file is based on the wonderful [Tencent/ncnn](https://github.com/Tencent/ncnn) and [realsr-ncnn-vulkan](https://github.com/nihui/realsr-ncnn-vulkan) by [nihui](https://github.com/nihui).
