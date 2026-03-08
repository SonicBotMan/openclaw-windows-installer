// Prevents additional console window on Windows in release
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

use serde_json::Value;
use std::fs;
use std::path::PathBuf;
use std::process::Command;
use tauri::Manager;

fn get_config_path(app_handle: &tauri::AppHandle) -> PathBuf {
    // 尝试多个可能的配置路径
    let possible_paths = vec![
        // 安装目录
        app_handle.path_resolver().resource_dir()
            .map(|p| p.join("openclaw").join("openclaw.json")),
        // 当前目录
        std::env::current_exe().ok()
            .map(|p| p.parent().unwrap().join("openclaw").join("openclaw.json")),
        // 用户目录
        dirs::home_dir().map(|p| p.join(".openclaw").join("openclaw.json")),
    ];
    
    for path_opt in possible_paths {
        if let Some(path) = path_opt {
            if path.exists() {
                return path;
            }
        }
    }
    
    // 默认返回安装目录路径
    app_handle.path_resolver().resource_dir()
        .map(|p| p.join("openclaw").join("openclaw.json"))
        .unwrap_or_else(|| PathBuf::from("openclaw.json"))
}

fn get_app_dir(app_handle: &tauri::AppHandle) -> PathBuf {
    app_handle.path_resolver().resource_dir()
        .map(|p| p.join("openclaw"))
        .unwrap_or_else(|| PathBuf::from("."))
}

#[tauri::command]
fn get_config(app_handle: tauri::AppHandle) -> Result<Value, String> {
    let config_path = get_config_path(&app_handle);
    
    if !config_path.exists() {
        return Err("配置文件不存在".to_string());
    }
    
    let content = fs::read_to_string(&config_path)
        .map_err(|e| format!("读取配置失败: {}", e))?;
    
    let json: Value = serde_json::from_str(&content)
        .map_err(|e| format!("解析配置失败: {}", e))?;
    
    Ok(json)
}

#[tauri::command]
fn save_config(app_handle: tauri::AppHandle, config: Value) -> Result<(), String> {
    let config_path = get_config_path(&app_handle);
    
    // 确保目录存在
    if let Some(parent) = config_path.parent() {
        fs::create_dir_all(parent)
            .map_err(|e| format!("创建目录失败: {}", e))?;
    }
    
    let content = serde_json::to_string_pretty(&config)
        .map_err(|e| format!("序列化配置失败: {}", e))?;
    
    fs::write(&config_path, content)
        .map_err(|e| format!("写入配置失败: {}", e))?;
    
    Ok(())
}

#[tauri::command]
fn is_running(app_handle: tauri::AppHandle) -> Result<bool, String> {
    // 检查 OpenClaw 进程是否在运行
    #[cfg(target_os = "windows")]
    {
        let output = Command::new("tasklist")
            .args(["/FI", "IMAGENAME eq node.exe", "/FO", "CSV", "/NH"])
            .output()
            .map_err(|e| format!("执行命令失败: {}", e))?;
        
        let stdout = String::from_utf8_lossy(&output.stdout);
        Ok(stdout.contains("node.exe"))
    }
    
    #[cfg(not(target_os = "windows"))]
    {
        let output = Command::new("pgrep")
            .arg("node")
            .output()
            .ok();
        
        Ok(output.map(|o| !o.stdout.is_empty()).unwrap_or(false))
    }
}

#[tauri::command]
fn start_service(app_handle: tauri::AppHandle) -> Result<(), String> {
    let app_dir = get_app_dir(&app_handle);
    let start_script = app_dir.parent()
        .map(|p| p.join("start-openclaw.bat"))
        .unwrap_or_else(|| PathBuf::from("start-openclaw.bat"));
    
    #[cfg(target_os = "windows")]
    {
        Command::new("cmd")
            .args(["/C", "start", "", &start_script.to_string_lossy()])
            .spawn()
            .map_err(|e| format!("启动失败: {}", e))?;
    }
    
    #[cfg(not(target_os = "windows"))]
    {
        Command::new("sh")
            .arg(&start_script)
            .spawn()
            .map_err(|e| format!("启动失败: {}", e))?;
    }
    
    Ok(())
}

#[tauri::command]
fn stop_service(app_handle: tauri::AppHandle) -> Result<(), String> {
    let app_dir = get_app_dir(&app_handle);
    let stop_script = app_dir.parent()
        .map(|p| p.join("stop-openclaw.bat"))
        .unwrap_or_else(|| PathBuf::from("stop-openclaw.bat"));
    
    #[cfg(target_os = "windows")]
    {
        Command::new("cmd")
            .args(["/C", &stop_script.to_string_lossy()])
            .output()
            .map_err(|e| format!("停止失败: {}", e))?;
    }
    
    #[cfg(not(target_os = "windows"))]
    {
        Command::new("sh")
            .arg(&stop_script)
            .output()
            .map_err(|e| format!("停止失败: {}", e))?;
    }
    
    Ok(())
}

fn main() {
    tauri::Builder::default()
        .invoke_handler(tauri::generate_handler![
            get_config,
            save_config,
            is_running,
            start_service,
            stop_service
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
