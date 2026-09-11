using System;
using System.IO;
using System.Diagnostics;
using System.Collections.Generic;

namespace MpvHandler
{
    static class Program
    {
        [STAThread]
        static void Main(string[] args)
        {
            if (args == null || args.Length == 0) return;

            string rawUrl = args[0];
            string mediaUrl;
            string additionalArgs;
            ParseProtocol(rawUrl, out mediaUrl, out additionalArgs);

            if (string.IsNullOrEmpty(mediaUrl)) return;

            string exeDir = AppDomain.CurrentDomain.BaseDirectory;
            string mpvPath = Path.GetFullPath(Path.Combine(exeDir, @"..\mpv.exe"));
            if (!File.Exists(mpvPath))
            {
                mpvPath = Path.GetFullPath(Path.Combine(exeDir, "mpv.exe"));
            }

            if (!File.Exists(mpvPath))
            {
                System.Windows.Forms.MessageBox.Show(
                    "未找到 mpv.exe！请确认 mpv.exe 位于上级目录或当前目录。\n路径: " + exeDir,
                    "MPV Handler",
                    System.Windows.Forms.MessageBoxButtons.OK,
                    System.Windows.Forms.MessageBoxIcon.Error
                );
                return;
            }

            // 极速唤起参数优化:
            // 1. --force-window=immediate: 立即创建并展示播放器窗口
            // 2. 直链媒体增加 --ytdl=no: 避开 yt-dlp 每次冷启动探测耗费的 1~3 秒
            bool isDirectStream = IsDirectMedia(mediaUrl);
            string finalArgs = "--force-window=immediate";
            if (isDirectStream)
            {
                finalArgs += " --ytdl=no";
            }

            if (!string.IsNullOrEmpty(additionalArgs))
            {
                finalArgs += " " + additionalArgs.Trim();
            }

            finalArgs += " \"" + mediaUrl + "\"";

            ProcessStartInfo psi = new ProcessStartInfo
            {
                FileName = mpvPath,
                Arguments = finalArgs,
                UseShellExecute = false,
                CreateNoWindow = false
            };

            Process.Start(psi);
        }

        static bool IsDirectMedia(string url)
        {
            if (string.IsNullOrEmpty(url)) return false;
            string clean = url.Split('?')[0].ToLowerInvariant();
            return clean.EndsWith(".mp4")  || clean.EndsWith(".m3u8") || 
                   clean.EndsWith(".flv")  || clean.EndsWith(".mkv")  || 
                   clean.EndsWith(".ts")   || clean.EndsWith(".webm") ||
                   clean.EndsWith(".avi")  || clean.EndsWith(".mov")  ||
                   clean.EndsWith(".mp3")  || clean.EndsWith(".m4a");
        }

        static void ParseProtocol(string raw, out string mediaUrl, out string additionalArgs)
        {
            mediaUrl = "";
            additionalArgs = "";

            if (string.IsNullOrEmpty(raw)) return;

            string text = raw.Trim();
            if (text.EndsWith("/")) text = text.Substring(0, text.Length - 1);

            // 匹配协议前缀
            string[] schemes = new[] {
                "mpv-handler-debug://",
                "mpv-handler://",
                "mpvplay://",
                "mpv://"
            };

            foreach (var s in schemes)
            {
                if (text.StartsWith(s, StringComparison.OrdinalIgnoreCase))
                {
                    text = text.Substring(s.Length);
                    break;
                }
            }

            // 处理 mpv-handler 官方格式: play/...
            if (text.StartsWith("play/", StringComparison.OrdinalIgnoreCase))
            {
                text = text.Substring(5);
            }
            else if (text.StartsWith("play?", StringComparison.OrdinalIgnoreCase))
            {
                text = text.Substring(5);
            }

            // 处理 query string
            string dataPart = text;
            string queryPart = "";
            int qIdx = text.IndexOf('?');
            if (qIdx >= 0)
            {
                dataPart = text.Substring(0, qIdx).TrimEnd('/');
                queryPart = text.Substring(qIdx + 1);
            }

            mediaUrl = TryDecodeUrl(dataPart);

            // 如果从 path 没解析出，尝试从 query (如 ?url=...) 解析
            Dictionary<string, string> queryMap = ParseQueryString(queryPart);
            if (string.IsNullOrEmpty(mediaUrl) && queryMap.ContainsKey("url"))
            {
                mediaUrl = TryDecodeUrl(queryMap["url"]);
            }

            // 解析 mpv-handler 标准附加参数
            List<string> extra = new List<string>();
            foreach (var kvp in queryMap)
            {
                string key = kvp.Key.ToLowerInvariant();
                string val = kvp.Value;
                if (string.IsNullOrEmpty(val) || key == "url") continue;

                if (key == "referrer")
                {
                    extra.Add("\"--referrer=" + TryDecodeUrl(val) + "\"");
                }
                else if (key == "v_title" || key == "title")
                {
                    extra.Add("\"--force-media-title=" + TryDecodeUrl(val) + "\"");
                }
                else if (key == "subfile" || key == "sub")
                {
                    extra.Add("\"--sub-file=" + TryDecodeUrl(val) + "\"");
                }
                else if (key == "startat" || key == "start")
                {
                    extra.Add("\"--start=" + val + "\"");
                }
                else if (key == "profile")
                {
                    extra.Add("\"--profile=" + val + "\"");
                }
                else if (key == "cookies")
                {
                    extra.Add("\"--cookies-file=" + val + "\"");
                }
            }

            additionalArgs = string.Join(" ", extra.ToArray());
        }

        static Dictionary<string, string> ParseQueryString(string qs)
        {
            var dict = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
            if (string.IsNullOrEmpty(qs)) return dict;

            string[] pairs = qs.Split('&');
            foreach (var p in pairs)
            {
                if (string.IsNullOrEmpty(p)) continue;
                int eq = p.IndexOf('=');
                if (eq >= 0)
                {
                    string k = p.Substring(0, eq).Trim();
                    string v = p.Substring(eq + 1).Trim();
                    dict[k] = v;
                }
                else
                {
                    dict[p.Trim()] = "";
                }
            }
            return dict;
        }

        static string TryDecodeUrl(string input)
        {
            if (string.IsNullOrEmpty(input)) return "";
            string temp = input.Trim();

            // 修正部分浏览器解析产生的 http// 或 https//
            if (temp.StartsWith("https//", StringComparison.OrdinalIgnoreCase))
                temp = "https://" + temp.Substring(7);
            else if (temp.StartsWith("http//", StringComparison.OrdinalIgnoreCase))
                temp = "http://" + temp.Substring(6);

            // 如果已经是 URL 或文件路径
            if (temp.StartsWith("http://", StringComparison.OrdinalIgnoreCase) ||
                temp.StartsWith("https://", StringComparison.OrdinalIgnoreCase) ||
                temp.StartsWith("file://", StringComparison.OrdinalIgnoreCase) ||
                (temp.Length > 2 && temp[1] == ':'))
            {
                try { return Uri.UnescapeDataString(temp); } catch { return temp; }
            }

            // 尝试 Base64 / URL-Safe Base64 解码
            try
            {
                string b64 = temp.Replace('_', '/').Replace('-', '+');
                int mod = b64.Length % 4;
                if (mod == 2) b64 += "==";
                else if (mod == 3) b64 += "=";

                byte[] bytes = Convert.FromBase64String(b64);
                string decoded = System.Text.Encoding.UTF8.GetString(bytes);

                if (decoded.StartsWith("http://", StringComparison.OrdinalIgnoreCase) ||
                    decoded.StartsWith("https://", StringComparison.OrdinalIgnoreCase) ||
                    decoded.StartsWith("file://", StringComparison.OrdinalIgnoreCase) ||
                    decoded.Contains("://"))
                {
                    return decoded;
                }
            }
            catch { }

            try
            {
                return Uri.UnescapeDataString(temp);
            }
            catch
            {
                return temp;
            }
        }
    }
}