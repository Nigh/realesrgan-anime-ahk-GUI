import { i18n } from "./i18n.js"

// 页面加载完成后初始化
document.addEventListener("DOMContentLoaded", () => {
	window.i18n = i18n || {}
	// 首次加载时更新页面（自动使用检测到的语言）
	i18n.updatePage()

	document.getElementById("version").textContent = `${
		import.meta.env.VITE_APP_VERSION
	}`

	// 监听语言切换事件
	document.addEventListener("languageChanged", (e) => {
		console.log(
			`Language changed to: ${e.detail.language} (${e.detail.languageName})`
		)
	})
})
