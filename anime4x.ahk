Class anime4x
{
	static inputfile := ""
	static outputfile := ""
	static input_bitmap := ""
	static output_bitmap := ""
	static output_base64 := ""

	static inputpath(inputfile) {
		this.inputfile := inputfile
		this.input_bitmap := Gdip_CreateBitmapFromFile(this.inputfile)
		Return this.input_bitmap
	}
	static outputpath(outputfile) {
		this.outputfile := outputfile
	}

	static go(scale := 1) {
		if not FileExist(this.inputfile) {
			return
		}
		if FileExist(this.outputfile) {
			FileDelete this.outputfile
		}
		result := RunWait(A_Temp '\CYKSM\rn-vulkan.exe -i "' this.inputfile '" -o "' this.outputfile '" -n realesrgan-x4plus-anime -m models_realesrgan', , "Hide")
		if result != 0 {
			return result
		}

		if (scale < 1) {
			pBitmap := Gdip_CreateBitmapFromFile(this.outputfile)
			Width := Gdip_GetImageWidth(pBitmap)
			Height := Gdip_GetImageHeight(pBitmap)

			NewWidth := Round(Width * scale)
			NewHeight := Round(Height * scale)

			pBitmapNew := Gdip_CreateBitmap(NewWidth, NewHeight)
			G := Gdip_GraphicsFromImage(pBitmapNew)
			Gdip_SetInterpolationMode(G, 7)
			Gdip_DrawImage(G, pBitmap, 0, 0, NewWidth, NewHeight, 0, 0, Width, Height)
			Gdip_DisposeImage(pBitmap)
			Gdip_DeleteGraphics(G)

			FileDelete this.outputfile
			Gdip_SaveBitmapToFile(pBitmapNew, this.outputfile)
			Gdip_DisposeImage(pBitmapNew)
		}

		; this.output_bitmap := Gdip_CreateBitmapFromFile(this.outputfile)
		Gdip_DisposeImage(this.input_bitmap)
		EncodedString := FileToBase64(anime4x.outputfile)
		MimeType := "image/png"
		DataUriPrefix := "data:" MimeType ";base64,"
		EncodedString := DataUriPrefix . EncodedString
		this.output_base64 := EncodedString
		return result
	}
}

; =================================================================
; FUNCTION: FileToBase64
; Converts any binary file (image, executable, etc.) into a Base64 string.
;
; Parameters:
;   FilePath - The full path to the file to be encoded.
;
; Returns:
;   The Base64 encoded string, or an empty string on failure.
;   Sets ErrorLevel to 1 on failure, 0 on success.
; =================================================================
FileToBase64(FilePath)
{
	local Stream, XML, Node, BinaryData, Base64Str

	; 1. Read the binary file data using ADODB.Stream
	Stream := ComObject("ADODB.Stream")
	if !IsObject(Stream)
	{
		ErrorLevel := 1 ; COM object creation failed
		return ""
	}

	Stream.Type := 1 ; 1 = adTypeBinary
	Stream.Open

	; Try to load the file into the stream
	try
	{
		Stream.LoadFromFile(FilePath)
		Stream.Position := 0 ; Rewind to the beginning
	}
	catch
	{
		ErrorLevel := 2 ; Failed to load file
		Stream.Close()
		return ""
	}

	; Get the binary data from the stream
	BinaryData := Stream.Read(-1) ; -1 = adReadAll
	Stream.Close()

	; 2. Use MSXML2.DOMDocument for Base64 Encoding
	XML := ComObject("MSXML2.DOMDocument")
	if !IsObject(XML)
	{
		ErrorLevel := 3 ; COM object creation failed
		return ""
	}

	; Create a temporary XML node to hold the binary data
	Node := XML.createElement("Base64Data")

	; Append the binary data directly to the node (this is where the encoding happens)
	try
	{
		Node.dataType := "bin.base64"
		Node.nodeTypedValue := BinaryData
	}
	catch
	{
		ErrorLevel := 4 ; Encoding failed
		return ""
	}

	; Extract the text content, which is the Base64 string
	Base64Str := Node.text

	ErrorLevel := 0
	return Base64Str
}
