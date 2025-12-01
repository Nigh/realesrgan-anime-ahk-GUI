;(function () {
	const pInput = document.getElementById("p-input")
	const inputPreview = document.getElementById("input-preview")
	const dropHint = document.getElementById("drop-hint")
	const outputHint = document.getElementById("output-hint")
	const filePicker = document.getElementById("file-picker")
	const browseBtn = document.getElementById("browse-btn")
	const inputResolution = document.getElementById("input-resolution")
	const outputResolution = document.getElementById("output-resolution")
	const pOutput = document.getElementById("p-output")
	const outputPreview = document.getElementById("output-preview")
	const outputProcess = document.getElementById("output-process")
	const startBtn = document.getElementById("start-btn")
	let state = "idle"
	window.getState = () => state

	function updateResolutionText(img, resolutionElement) {
		if (img && img.naturalWidth && img.naturalHeight) {
			resolutionElement.textContent = `${img.naturalWidth} × ${img.naturalHeight}`
		} else {
			resolutionElement.textContent = ""
		}
	}

	inputPreview.addEventListener("load", () => {
		updateResolutionText(inputPreview, inputResolution)
	})

	outputPreview.addEventListener("load", () => {
		updateResolutionText(outputPreview, outputResolution)
	})

	function prevent(e) {
		e.preventDefault()
		e.stopPropagation()
	}

	;["dragenter", "dragover", "dragleave", "drop"].forEach((evt) => {
		pInput.addEventListener(evt, prevent, false)
	})

	pInput.addEventListener(
		"dragover",
		() => {
			pInput.classList.add("bg-accent/50", "border-accent")
		},
		false
	)

	pInput.addEventListener(
		"dragleave",
		() => {
			pInput.classList.remove("bg-accent/50", "border-accent")
		},
		false
	)

	pInput.addEventListener(
		"drop",
		(e) => {
			pInput.classList.remove("bg-accent/50", "border-accent")
			const dt = e.dataTransfer
			if (!dt || !dt.files || dt.files.length === 0) return
			handleFiles(dt.files)
		},
		false
	)

	browseBtn.addEventListener("click", (e) => {
		e.preventDefault()
		filePicker.click()
	})

	filePicker.addEventListener("change", (e) => {
		if (!e.target.files) return
		console.log("change", e.target.files)
		handleFiles(e.target.files)
	})

	function handleFiles(files) {
		const ALLOWED_MIMES = ["image/jpeg", "image/png", "image/webp"]

		const file = Array.from(files).find((f) =>
			ALLOWED_MIMES.includes(f.type)
		)
		if (!file) {
			// showMessage(
			// 	"File rejected: Please select a JPEG, PNG, or WebP image.",
			// 	"error"
			// )
			return
		}
		const reader = new FileReader()
		reader.onload = function (ev) {
			inputPreview.src = ev.target.result
			window.setMainState("ready")
		}
		console.log("file", file)
		reader.readAsDataURL(file)
	}

	// Sets an image on a target div's preview <img> by id.
	// Accepts a File/Blob or a string (data URL or normal URL).
	window.setPictureOnDiv = function (imgElementId, source) {
		const imgEl = document.getElementById(imgElementId)
		if (!imgEl) return
		function applySrc(src) {
			imgEl.src = src
		}
		if (source === null) {
			applySrc("")
			return
		}
		if (source instanceof Blob || source instanceof File) {
			const r = new FileReader()
			r.onload = (ev) => applySrc(ev.target.result)
			r.readAsDataURL(source)
		} else if (typeof source === "string") {
			applySrc(source)
		}
	}

	// Convenience: set image into the p-output area
	window.setOutputImage = function (source) {
		// uses the output-preview img inside #p-output
		window.setPictureOnDiv("output-preview", source)
		window.setMainState("done")
	}
	window.setMainState = function (next) {
		// idle -> ready -> processing -> done
		// error -> idle
		if (next == state) return
		console.log("Main state changed:", state, "->", next)
		state = next
		switch (state) {
			default:
			case "idle":
				outputHint.style.display = "flex"
				dropHint.style.display = "flex"

				inputPreview.style.display = "none"
				outputPreview.style.display = "none"
				outputProcess.style.display = "none"

				filePicker.value = null
				inputResolution.textContent = ""
				outputResolution.textContent = ""
				
				startBtn.classList.add("btn-disabled")
				startBtn.setAttribute("data-i18n", "start")
				window.i18n.updateElement(startBtn)
				break
			case "ready":
				inputPreview.style.display = "block"
				dropHint.style.display = "none"
				startBtn.classList.remove("btn-disabled")
				break
			case "processing":
				outputHint.style.display = "none"
				outputProcess.style.display = "flex"
				startBtn.classList.add("btn-disabled")
				startBtn.setAttribute("data-i18n", "processing")
				window.i18n.updateElement(startBtn)
				break
			case "done":
				outputPreview.style.display = "block"
				outputProcess.style.display = "none"
				startBtn.classList.remove("btn-disabled")
				startBtn.setAttribute("data-i18n", "reset")
				window.i18n.updateElement(startBtn)
				break
		}
	}
})()

function onMsg(Msg) {
	if (Msg.data && typeof Msg.data == "object" && Msg.data.type.length > 0) {
		switch (Msg.data.type) {
			case "result":
				if (Msg.data.code == 0) {
					window.setOutputImage(Msg.data.content)
					window.setMainState("done")
				}
				break
		}
	}
}
window.chrome.webview.addEventListener("message", onMsg)
