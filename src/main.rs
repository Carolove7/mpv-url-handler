#![windows_subsystem = "windows"]

use std::collections::HashMap;
use std::env;
use std::path::{Path, PathBuf};
use std::process::Command;

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        return;
    }

    let raw_input = &args[1];
    let (media_url, additional_args) = parse_protocol(raw_input);
    if media_url.is_empty() {
        return;
    }

    let exe_dir = match env::current_exe() {
        Ok(path) => path.parent().unwrap_or_else(|| Path::new(".")).to_path_buf(),
        Err(_) => PathBuf::from("."),
    };

    let parent_mpv = exe_dir.join("..").join("mpv.exe");
    let current_mpv = exe_dir.join("mpv.exe");

    let mpv_path = if parent_mpv.exists() {
        parent_mpv
    } else if current_mpv.exists() {
        current_mpv
    } else {
        return;
    };

    let mut cmd = Command::new(&mpv_path);

    // 性能优化：立即展示窗口，避免等待首帧时的迟滞感
    cmd.arg("--force-window=immediate");

    // 性能优化：直链媒体跳过 yt-dlp 冷启动探测（节省 1.5 ~ 3 秒）
    if is_direct_media(&media_url) {
        cmd.arg("--ytdl=no");
    }

    // 透传附加参数
    for arg in additional_args {
        cmd.arg(arg);
    }

    // 目标媒体 URL
    cmd.arg(&media_url);

    // 静默启动子进程
    let _ = cmd.spawn();
}

fn is_direct_media(url: &str) -> bool {
    let clean = url.split('?').next().unwrap_or(url).to_ascii_lowercase();
    clean.ends_with(".mp4")
        || clean.ends_with(".m3u8")
        || clean.ends_with(".flv")
        || clean.ends_with(".mkv")
        || clean.ends_with(".ts")
        || clean.ends_with(".webm")
        || clean.ends_with(".avi")
        || clean.ends_with(".mov")
        || clean.ends_with(".mp3")
        || clean.ends_with(".m4a")
}

fn parse_protocol(raw: &str) -> (String, Vec<String>) {
    let mut text = raw.trim();
    if text.ends_with('/') {
        text = &text[..text.len() - 1];
    }

    let schemes = [
        "mpv-handler-debug://",
        "mpv-handler://",
        "mpvplay://",
        "mpv://",
    ];

    for scheme in schemes {
        if text.to_ascii_lowercase().starts_with(scheme) {
            text = &text[scheme.len()..];
            break;
        }
    }

    if text.to_ascii_lowercase().starts_with("play/") {
        text = &text[5..];
    } else if text.to_ascii_lowercase().starts_with("play?") {
        text = &text[5..];
    }

    let (data_part, query_part) = if let Some(idx) = text.find('?') {
        let (d, q) = text.split_at(idx);
        (d.trim_end_matches('/'), &q[1..])
    } else {
        (text, "")
    };

    let mut media_url = try_decode_url(data_part);
    let query_map = parse_query(query_part);

    if media_url.is_empty() {
        if let Some(val) = query_map.get("url") {
            media_url = try_decode_url(val);
        }
    }

    let mut additional_args = Vec::new();
    for (key, val) in query_map {
        let k = key.to_ascii_lowercase();
        if val.is_empty() || k == "url" {
            continue;
        }

        match k.as_str() {
            "referrer" => {
                additional_args.push(format!("--referrer={}", try_decode_url(&val)));
            }
            "v_title" | "title" => {
                additional_args.push(format!("--force-media-title={}", try_decode_url(&val)));
            }
            "subfile" | "sub" => {
                additional_args.push(format!("--sub-file={}", try_decode_url(&val)));
            }
            "startat" | "start" => {
                additional_args.push(format!("--start={}", val));
            }
            "profile" => {
                additional_args.push(format!("--profile={}", val));
            }
            "cookies" => {
                additional_args.push(format!("--cookies-file={}", val));
            }
            _ => {}
        }
    }

    (media_url, additional_args)
}

fn parse_query(query: &str) -> HashMap<String, String> {
    let mut map = HashMap::new();
    if query.is_empty() {
        return map;
    }

    for pair in query.split('&') {
        if pair.is_empty() {
            continue;
        }
        if let Some(idx) = pair.find('=') {
            let key = pair[..idx].trim().to_string();
            let val = pair[idx + 1..].trim().to_string();
            map.insert(key, val);
        } else {
            map.insert(pair.trim().to_string(), String::new());
        }
    }
    map
}

fn try_decode_url(input: &str) -> String {
    let mut s = input.trim().to_string();
    if s.is_empty() {
        return String::new();
    }

    // 修复浏览器可能解析出的 http// 或 https//
    if s.to_ascii_lowercase().starts_with("https//") {
        s = format!("https://{}", &s[7..]);
    } else if s.to_ascii_lowercase().starts_with("http//") {
        s = format!("http://{}", &s[6..]);
    }

    // 若已是直接 URL 或 本地路径
    let lower = s.to_ascii_lowercase();
    if lower.starts_with("http://")
        || lower.starts_with("https://")
        || lower.starts_with("file://")
        || (s.len() > 2 && s.as_bytes()[1] == b':')
    {
        return url_decode(&s);
    }

    // 尝试 Base64 / URL-Safe Base64 解码
    if let Some(decoded) = base64_url_safe_decode(&s) {
        let dec_lower = decoded.to_ascii_lowercase();
        if dec_lower.starts_with("http://")
            || dec_lower.starts_with("https://")
            || dec_lower.starts_with("file://")
            || dec_lower.contains("://")
        {
            return decoded;
        }
    }

    url_decode(&s)
}

fn url_decode(s: &str) -> String {
    let mut result = Vec::new();
    let bytes = s.as_bytes();
    let mut i = 0;
    while i < bytes.len() {
        if bytes[i] == b'%' && i + 2 < bytes.len() {
            if let Ok(val) = u8::from_str_radix(&s[i + 1..i + 3], 16) {
                result.push(val);
                i += 3;
                continue;
            }
        } else if bytes[i] == b'+' {
            result.push(b' ');
            i += 1;
            continue;
        }
        result.push(bytes[i]);
        i += 1;
    }
    String::from_utf8(result).unwrap_or_else(|_| s.to_string())
}

fn base64_url_safe_decode(input: &str) -> Option<String> {
    let mut clean = input.replace('_', "/").replace('-', "+");
    let mod_len = clean.len() % 4;
    if mod_len == 2 {
        clean.push_str("==");
    } else if mod_len == 3 {
        clean.push('=');
    } else if mod_len != 0 {
        return None;
    }

    let table = b"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    let mut lookup = [255u8; 256];
    for (i, &b) in table.iter().enumerate() {
        lookup[b as usize] = i as u8;
    }

    let bytes = clean.as_bytes();
    let mut out = Vec::with_capacity(bytes.len() * 3 / 4);

    for chunk in bytes.chunks(4) {
        if chunk.len() < 4 {
            return None;
        }

        let b0 = lookup[chunk[0] as usize];
        let b1 = lookup[chunk[1] as usize];
        if b0 == 255 || b1 == 255 {
            return None;
        }

        let b2 = if chunk[2] == b'=' { 0 } else { lookup[chunk[2] as usize] };
        let b3 = if chunk[3] == b'=' { 0 } else { lookup[chunk[3] as usize] };

        if chunk[2] != b'=' && b2 == 255 {
            return None;
        }
        if chunk[3] != b'=' && b3 == 255 {
            return None;
        }

        let triple = ((b0 as u32) << 18) | ((b1 as u32) << 12) | ((b2 as u32) << 6) | (b3 as u32);

        out.push(((triple >> 16) & 0xFF) as u8);
        if chunk[2] != b'=' {
            out.push(((triple >> 8) & 0xFF) as u8);
        }
        if chunk[3] != b'=' {
            out.push((triple & 0xFF) as u8);
        }
    }

    String::from_utf8(out).ok()
}