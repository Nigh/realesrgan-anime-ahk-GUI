
<div>
	<div align="center">
		<img height="180px" src="https://github.com/user-attachments/assets/530e2f35-849f-4481-83cf-07e5a021ed41"/>
	</div>
	<div align="center">
		<img src="https://capsule-render.vercel.app/api?type=transparent&fontColor=dbdbdb&text=次元克赛马&height=80&fontSize=48"/>
	</div>
</div>

---

A GUI for `realesrgan-x4plus-anime`  
一个`realesrgan-x4plus-anime`模型的简单图形界面。因为有着消除部分马赛克的能力，既然可以反马赛克，不如就叫做克赛马好了。

![](https://raw.githubusercontent.com/Nigh/realesrgan-anime-ahk-GUI/refs/heads/main/showcase.png)

## Usage
将需要超分辨率的图片拖入左侧，点击按钮即可进行超分。处理完成后，结果会显示在右侧预览区域。将鼠标移动到输出预览图上时，会显示 `复制` 和 `另存为` 按钮。  
此模型适合处理小尺寸的二次元图片，对其他类型与大尺寸的图片可能效果不佳。并且尺寸过大可能会爆显存。

Drag the image that needs super-resolution into the left panel and click the button to process it. After processing, the result is shown in the preview area on the right. When hovering over the output preview image, `Copy` and `Save As` buttons will appear.  
This model is suitable for small-sized anime-style images and may not perform well on other types of images or large-sized pictures. Additionally, excessively large dimensions may cause VRAM overload.

## Info
This project is a AutoHotkey GUI for the `realesrgan-x4plus-anime` model in project [Real-ESRGAN](https://github.com/xinntao/Real-ESRGAN/)
