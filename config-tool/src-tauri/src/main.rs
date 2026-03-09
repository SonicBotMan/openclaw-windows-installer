// Prevents additional console window on Windows in release
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

use serde_json::Value;
use std::fs;
use std::path::PathBuf;
use std::process::Command;

/// 获取配置文件路径
fn get_config_path() -> PathBuf {
    // 用户目录（最常用）
    if let Some(home) = dirs::home_dir() {
        let user_path = home.join(".openclaw").join("openclaw.json");
        if user_path.exists() {
            log::info!("使用用户配置: {:?}", user_path);
            return user_path;
        }
    }
    
    // 默认返回用户目录（即使不存在）
    let default_path = dirs::home_dir()
        .map(|p| p.join(".openclaw").join("openclaw.json"))
        .unwrap_or_else(|| PathBuf::from("openclaw.json"));
    
    log::info!("使用默认配置路径: {:?}", default_path);
    default_path
}

/// 获取配置
#[tauri::command]
fn get_config() -> Result<Value, String> {
    let config_path = get_config_path();
    
    if !config_path.exists() {
        log::warn!("配置文件不存在: {:?}", config_path);
        // 返回默认配置
        return Ok(serde_json::json!({
            "providers": {
                "zai": {
                    "type": "zai",
                    "apiKey": "",
                    "baseUrl": "https://open.bigmodel.cn/api/paas/v4"
                },
                "minimax": {
                    "type": "minimax",
                    "apiKey": "",
                    "baseUrl": "https://api.minimax.chat/v1"
                }
            },
            "agents": {
                "defaults": {
                    "model": "zai/glm-4-flash",
                    "fallbacks": []
                }
            },
            "gateway": {
                "port": 18789,
                "bind": "127.0.0.1"
            }
        }));
    }
    
    let content = fs::read_to_string(&config_path)
        .map_err(|e| {
            log::error!("读取配置失败: {}", e);
            format!("读取配置失败: {}", e)
        })?;
    
    let json: Value = serde_json::from_str(&content)
        .map_err(|e| {
            log::error!("解析配置失败: {}", e);
            format!("解析配置失败: {}", e)
        })?;
    
    log::info!("配置加载成功");
    Ok(json)
}

/// 保存配置
#[tauri::command]
fn save_config(config: Value) -> Result<(), String> {
    let config_path = get_config_path();
    
    // 确保目录存在
    if let Some(parent) = config_path.parent() {
        fs::create_dir_all(parent)
            .map_err(|e| {
                log::error!("创建目录失败: {}", e);
                format!("创建目录失败: {}", e)
            })?;
    }
    
    let content = serde_json::to_string_pretty(&config)
        .map_err(|e| {
            log::error!("序列化配置失败: {}", e);
            format!("序列化配置失败: {}", e)
        })?;
    
    fs::write(&config_path, content)
        .map_err(|e| {
            log::error!("写入配置失败: {}", e);
            format!("写入配置失败: {}", e)
        })?;
    
    log::info!("配置保存成功: {:?}", config_path);
    Ok(())
}

/// 检查服务是否运行
#[tauri::command]
fn is_running() -> Result<bool, String> {
    #[cfg(target_os = "windows")]
    {
        let output = Command::new("tasklist")
            .args(["/FI", "IMAGENAME eq node.exe", "/FO", "CSV", "/NH"])
            .output()
            .map_err(|e| {
                log::error!("执行命令失败: {}", e);
                format!("执行命令失败: {}", e)
            })?;
        
        let stdout = String::from_utf8_lossy(&output.stdout);
        let running = stdout.contains("node.exe");
        log::info!("服务状态: {}", if running { "运行中" } else { "已停止" });
        Ok(running)
    }
    
    #[cfg(not(target_os = "windows"))]
    {
        let output = Command::new("pgrep")
            .arg("node")
            .output()
            .ok();
        
        let running = output.map(|o| !o.stdout.is_empty()).unwrap_or(false);
        log::info!("服务状态: {}", if running { "运行中" } else { "已停止" });
        Ok(running)
    }
}

/// 启动服务
#[tauri::command]
fn start_service() -> Result<(), String> {
    // 可能的启动脚本位置
    let possible_scripts: Vec<PathBuf> = vec![
        PathBuf::from("start-openclaw.bat"),
        PathBuf::from("start-openclaw.sh"),
    ];
    
    let start_script = possible_scripts
        .iter()
        .find(|p| p.exists())
        .ok_or("找不到启动脚本")?;
    
    log::info!("启动脚本: {:?}", start_script);
    
    #[cfg(target_os = "windows")]
    {
        Command::new("cmd")
            .args(["/C", "start", "", &start_script.to_string_lossy()])
            .spawn()
            .map_err(|e| {
                log::error!("启动失败: {}", e);
                format!("启动失败: {}", e)
            })?;
    }
    
    #[cfg(not(target_os = "windows"))]
    {
        Command::new("sh")
            .arg(start_script)
            .spawn()
            .map_err(|e| {
                log::error!("启动失败: {}", e);
                format!("启动失败: {}", e)
            })?;
    }
    
    log::info!("服务启动命令已执行");
    Ok(())
}

/// 停止服务
#[tauri::command]
fn stop_service() -> Result<(), String> {
    // 可能的停止脚本位置
    let possible_scripts: Vec<PathBuf> = vec![
        PathBuf::from("stop-openclaw.bat"),
        PathBuf::from("stop-openclaw.sh"),
    ];
    
    if let Some(stop_script) = possible_scripts.iter().find(|p| p.exists()) {
        log::info!("停止脚本: {:?}", stop_script);
        
        #[cfg(target_os = "windows")]
        {
            Command::new("cmd")
                .args(["/C", &stop_script.to_string_lossy()])
                .output()
                .map_err(|e| {
                    log::error!("停止失败: {}", e);
                    format!("停止失败: {}", e)
                })?;
        }
        
        #[cfg(not(target_os = "windows"))]
        {
            Command::new("sh")
                .arg(stop_script)
                .output()
                .map_err(|e| {
                    log::error!("停止失败: {}", e);
                    format!("停止失败: {}", e)
                })?;
        }
    } else {
        // 没有停止脚本，直接终止进程
        log::info!("未找到停止脚本，尝试终止 node 进程");
        
        #[cfg(target_os = "windows")]
        {
            Command::new("taskkill")
                .args(["/F", "/IM", "node.exe"])
                .output()
                .map_err(|e| format!("终止进程失败: {}", e))?;
        }
        
        #[cfg(not(target_os = "windows"))]
        {
            Command::new("pkill")
                .arg("node")
                .output()
                .map_err(|e| format!("终止进程失败: {}", e))?;
        }
    }
    
    log::info!("服务停止命令已执行");
    Ok(())
}

fn main() {
    // 初始化日志
    env_logger::Builder::from_env(env_logger::Env::default().default_filter_or("info"))
        .init();
    
    log::info!("OpenClaw Config 工具启动");
    
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
