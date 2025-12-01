const translations = {
	en: {
		lang: "English",
		title: "CYKSM",
		brief: "A super resolution tool for anime style pictures",
		start: "START",
		processing: "processing",
		reset: "reset",
		keepres: "keep the resolution",
		drophint: "Drop an image here or",
		drophintbtn: "browse",
	},
	zh: {
		lang: "中文",
		title: "次元克赛马",
		brief: "动漫风格图片超分辨率工具",
		start: "开始",
		processing: "处理中",
		reset: "重置",
		keepres: "保持分辨率",
		drophint: "拖拽图片至此或",
		drophintbtn: "浏览文件",
	},
	ja: {
		lang: "日本語",
		title: "次元ケイザーマ",
		brief: "アニメ風画像用超解像ツール",
		start: "開始",
		processing: "処理中",
		reset: "リセット",
		keepres: "解像度を維持",
		drophint: "ここに画像をドロップするか",
		drophintbtn: "ファイルを選択",
	},
}

class I18n {
	constructor() {
		this.translations = translations
		this.currentLang = this.detectLanguage()
		this.init()
	}

	// 检测语言优先级：本地存储 > 浏览器语言 > 默认英语
	detectLanguage() {
		// 1. 检查本地存储
		const savedLang = localStorage.getItem("preferred-language")
		if (savedLang && this.translations[savedLang]) {
			console.log(`Saved language: ${savedLang}`)
			return savedLang
		}

		// 2. 检测浏览器语言
		const browserLang = this.getBrowserLanguage()
		if (browserLang) {
			return browserLang
		}

		// 3. 默认英语
		return "en"
	}

	// 获取浏览器语言并映射到支持的语言
	getBrowserLanguage() {
		const browserLanguages = []

		// 获取所有浏览器语言设置
		if (navigator.languages) {
			browserLanguages.push(...navigator.languages)
		}
		if (navigator.language) {
			browserLanguages.push(navigator.language)
		}
		if (navigator.userLanguage) {
			browserLanguages.push(navigator.userLanguage)
		}

		// 去重
		const uniqueLanguages = [...new Set(browserLanguages)]

		// 按优先级匹配支持的语言
		for (const lang of uniqueLanguages) {
			const matchedLang = this.matchLanguage(lang)
			if (matchedLang) {
				console.log(
					`Detected browser language: ${lang}, using: ${matchedLang}`
				)
				return matchedLang
			}
		}

		return null
	}

	// 匹配浏览器语言到支持的语言
	matchLanguage(browserLang) {
		const lang = browserLang.toLowerCase()

		// 中文匹配（简体、繁体都映射到 zh）
		if (lang.startsWith("zh")) {
			return "zh"
		}

		// 日语匹配
		if (lang.startsWith("ja")) {
			return "ja"
		}

		// 英语匹配
		if (lang.startsWith("en")) {
			return "en"
		}

		return null
	}

	// 初始化
	init() {
		// 保存检测到的语言到本地存储
		this.saveLanguage(this.currentLang)
		console.log(`Auto-detected language: ${this.currentLang}`)
	}

	// 保存语言设置
	saveLanguage(lang) {
		localStorage.setItem("preferred-language", lang)
	}

	// 获取当前语言
	getCurrentLanguage() {
		return this.currentLang
	}

	// 获取语言显示名称
	getLanguageName(lang) {
		const names = {
			en: "English",
			zh: "中文",
			ja: "日本語",
		}
		return names[lang] || lang
	}

	// 翻译文本
	t(key, variables = {}) {
		let text =
			this.translations[this.currentLang]?.[key] ||
			this.translations["en"][key] ||
			key

		// 替换变量 {{name}} -> value
		Object.keys(variables).forEach((variable) => {
			text = text.replace(`{{${variable}}}`, variables[variable])
		})

		return text
	}

	updateElement(elem) {
		const key = elem.getAttribute("data-i18n")
		const variables = JSON.parse(
			elem.getAttribute("data-i18n-vars") || "{}"
		)

		// 处理不同类型的元素
		if (elem.placeholder !== undefined) {
			elem.placeholder = this.t(key, variables)
		} else if (elem.value !== undefined && elem.type !== "submit") {
			elem.value = this.t(key, variables)
		} else {
			elem.textContent = this.t(key, variables)
		}
	}
	// 更新页面所有文本
	updatePage() {
		document.documentElement.lang = this.currentLang
		// 找到所有带有 data-i18n 属性的元素
		const elements = document.querySelectorAll("[data-i18n]")

		elements.forEach((element) => this.updateElement(element))

		// 更新语言显示
		this.updateLanguageDisplay()

		// 触发语言切换事件
		document.dispatchEvent(
			new CustomEvent("languageChanged", {
				detail: {
					language: this.currentLang,
					languageName: this.getLanguageName(this.currentLang),
				},
			})
		)
	}

	// 更新语言显示
	updateLanguageDisplay() {
		const displayElements = document.querySelectorAll("[data-i18n-current]")
		displayElements.forEach((element) => {
			element.textContent = this.t("currentLanguage")
		})
	}

	// 手动切换语言（可选，用于调试或用户覆盖）
	setLanguage(lang) {
		if (this.translations[lang]) {
			this.currentLang = lang
			this.saveLanguage(lang)
			this.updatePage()
			console.log(`Language manually changed to: ${lang}`)
		}
	}
}

// 创建全局实例
export const i18n = new I18n()
