import { execSync } from "child_process"
import fs from "fs/promises"
import path from "path"
import { existsSync } from "fs"
import AdmZip from 'adm-zip';

const clearFiles = ["compile_prop.ahk", "CYKSM.zip", "CYKSM.exe", "version.txt"]
const distFiles = ["CYKSM.zip", "version.txt"]
const distDir = "release"
const exec = execSync

async function dist() {
	try {
		console.log("Starting file operations...")

		// 1. Delete
		try {
			for (const file of clearFiles) {
				await fs.rm(file, { force: true })
				console.log(`File ${file} processed (deleted if existed)`)
			}
		} catch (error) {
			console.error(`Error deleting files: ${error.message}`)
			process.exit(1)
		}

		// 2. Clear or create distDir
		await fs.rm(distDir, { recursive: true, force: true })
		await fs.mkdir(distDir, { recursive: true })
		console.log(`Directory ${distDir} cleared and recreated`)

		// 3. Generate version.txt
		exec("npx ahk64 run app.ahk --out=version", (error, stdout, stderr) => {
			if (error) {
				console.error(`Error generating version.txt: ${error.message}`)
				process.exit(1)
			}
		})
		console.log(`version.txt generated`)

		// 4. Compile CYKSM.exe
		exec("npx ahk64 run gen_compile_prop.ahk", (error, stdout, stderr) => {
			if (error) {
				console.error(`Error generating compile prop: ${error.message}`)
				process.exit(1)
			}
		})
		exec("npm run build:ahk", (error, stdout, stderr) => {
			if (error) {
				console.error(`Error compiling CYKSM.exe: ${error.message}`)
				process.exit(1)
			}
		})
		console.log(`CYKSM.exe compiled`)

		// 5. Zip CYKSM.exe
		try {
			const zip = new AdmZip()
			zip.addLocalFile("CYKSM.exe")
			zip.writeZip("CYKSM.zip")
		} catch (error) {
			console.error(`Error zipping CYKSM.exe: ${error.message}`)
			process.exit(1)
		}
		console.log(`CYKSM.zip created`)

		// 6. Move file to distDir
		try {
			for (const file of distFiles) {
				if (existsSync(file)) {
					await fs.rename(file, path.join(distDir, file))
					console.log(`File ${file} moved to ${distDir}`)
				} else {
					console.log(
						`File ${file} not found, skipping move operation`
					)
				}
			}
		} catch (error) {
			console.error(`Error moving files: ${error.message}`)
			process.exit(1)
		}

		console.log("All operations completed successfully")
	} catch (error) {
		console.error("Error during execution:", error.message)
		process.exit(1)
	}
}

dist()
