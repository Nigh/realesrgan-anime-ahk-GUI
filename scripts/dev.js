import { spawn } from "child_process"
import chokidar from "chokidar"

let ahkProc = null
let viteProc = null

// 启动 AHK 脚本
function startAhk() {
	if (ahkProc) {
		console.log("🚫 Kill AHK process " + ahkProc.pid)
		ahkProc.kill()
	}
	// 启动新的 AHK 进程
	let localProc = spawn("npm", ["run", "dev:ahk"], {
		stdio: "inherit",
		shell: true,
	})
	console.log("🚀 Started AHK process " + localProc.pid)
	// 监控 AHK 进程退出
	localProc.on("exit", (code, signal) => {
		console.log(`AHK process ${localProc.pid} exited ${code} ${signal}`)
		// 如果进程因为 ExitApp 退出，自动重启
		// 如果进程因为 脚本 退出，不做处理
		if(localProc.pid === ahkProc.pid) {
			if (signal !== "SIGTERM") {
				console.log("🔄 restarting...")
				startAhk() // 重启 AHK 脚本
			}
		}
	})
	ahkProc = localProc
}

// 启动 Vite
function startVite() {
	if (!viteProc) {
		viteProc = spawn("npm", ["run", "dev:front"], {
			stdio: "inherit",
			shell: true,
		})
	}
	console.log("🚀 Started Vite dev server")
}

// 启动时的处理
startVite()
startAhk()

// 如果环境变量开启了 watch，则监听 AHK 文件的更改，触发 reload
if (process.env.AHK_WATCH) {
	chokidar.watch("./app.ahk").on("change", () => {
		console.log("🔄 AHK script changed")
		startAhk()
	})
}

// 退出时清理子进程
process.on("SIGINT", () => {
	if (viteProc) viteProc.kill()
	if (ahkProc) ahkProc.kill()
	process.exit()
})
