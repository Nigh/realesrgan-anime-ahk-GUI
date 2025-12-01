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
	const resetHoverClasses = [
		"cursor-pointer",
		"hover:border-error",
		"hover:bg-error/20",
	]
	let state = "idle"
	window.getState = () => state

	function updateResolutionText(img, resolutionElement) {
		if (img && img.naturalWidth && img.naturalHeight) {
			resolutionElement.removeAttribute("data-i18n")
			resolutionElement.textContent = `${img.naturalWidth} × ${img.naturalHeight}`
		} else {
			resolutionElement.setAttribute("data-i18n", "res_placeholder")
			resolutionElement.textContent = ""
			if (window.i18n && window.i18n.updateElement) {
				window.i18n.updateElement(resolutionElement)
			}
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

	document.addEventListener("dragover", (e) => e.preventDefault())
	document.addEventListener("drop", (e) => e.preventDefault())
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

	pInput.addEventListener("click", () => {
		if (state === "ready" || state === "done") {
			if (window.fullReset) window.fullReset()
		}
	})

	browseBtn.addEventListener("click", (e) => {
		e.preventDefault()
		e.stopPropagation() // Prevent pInput click
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
			window.showMessage(
				"File rejected: Please select a JPEG, PNG, or WebP image.",
				"error"
			)
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
	window.showMessage = function (message, type = "info") {
		let container = document.getElementById("toast-container")
		if (!container) {
			container = document.createElement("div")
			container.id = "toast-container"
			container.className = "toast toast-top toast-end z-50"
			document.body.appendChild(container)
		}

		const alertDiv = document.createElement("div")
		const alertClass =
			type === "error"
				? "alert-error"
				: type === "success"
				? "alert-success"
				: type === "warning"
				? "alert-warning"
				: "alert-info"
		alertDiv.className = `alert ${alertClass}`

		const span = document.createElement("span")
		span.textContent = message
		alertDiv.appendChild(span)

		container.appendChild(alertDiv)

		setTimeout(() => {
			alertDiv.remove()
			if (container.children.length === 0) {
				container.remove()
			}
		}, 3000)
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
				pInput.classList.remove(...resetHoverClasses)
				outputHint.style.display = "flex"
				dropHint.style.display = "flex"

				inputPreview.style.display = "none"
				outputPreview.style.display = "none"
				outputProcess.style.display = "none"

				filePicker.value = null

				inputResolution.setAttribute("data-i18n", "res_placeholder")
				if (window.i18n) window.i18n.updateElement(inputResolution)
				else inputResolution.textContent = ""

				outputResolution.setAttribute("data-i18n", "res_placeholder")
				if (window.i18n) window.i18n.updateElement(outputResolution)
				else outputResolution.textContent = ""

				startBtn.classList.add("btn-disabled")
				startBtn.setAttribute("data-i18n", "start")
				if (window.i18n) window.i18n.updateElement(startBtn)
				break
			case "ready":
				pInput.classList.add(...resetHoverClasses)
				inputPreview.style.display = "block"
				dropHint.style.display = "none"

				// Clear output (partial reset logic)
				outputHint.style.display = "flex"
				outputPreview.style.display = "none"
				outputProcess.style.display = "none"
				outputResolution.setAttribute("data-i18n", "res_placeholder")
				if (window.i18n) window.i18n.updateElement(outputResolution)

				startBtn.classList.remove("btn-disabled")
				startBtn.setAttribute("data-i18n", "start")
				if (window.i18n) window.i18n.updateElement(startBtn)
				break
			case "processing":
				pInput.classList.remove(...resetHoverClasses)
				outputHint.style.display = "none"
				outputProcess.style.display = "flex"
				startBtn.classList.add("btn-disabled")
				startBtn.setAttribute("data-i18n", "processing")
				if (window.i18n) window.i18n.updateElement(startBtn)
				break
			case "done":
				pInput.classList.add(...resetHoverClasses)
				outputPreview.style.display = "block"
				outputProcess.style.display = "none"
				startBtn.classList.remove("btn-disabled")
				startBtn.setAttribute("data-i18n", "reset")
				if (window.i18n) window.i18n.updateElement(startBtn)
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
			case "error":
				window.showMessage(
					`Error ${Msg.data.code}: ${Msg.data.content}`,
					"error"
				)
				window.setMainState("idle")
				break
		}
	}
}
window.chrome.webview.addEventListener("message", onMsg)
