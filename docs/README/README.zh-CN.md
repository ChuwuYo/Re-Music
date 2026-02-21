# Re:Music

<p align="center">
  <img src="../../assets/images/Logos/1024.png" width="128" alt="Re:Music Logo">
</p>

<p align="center">
  <b>一款现代化的音频文件管理工具，支持批量重命名、标签编辑与音频降采样</b>
</p>

<p align="center">
  <a href="../../README.md">English</a> | <b>简体中文</b>
</p>

---

## 项目简介

**Re:Music**是基于Flutter的原生桌面端音频文件管理工具。它支持读取metadata对音频文件进行批量重命名、编辑音频元数据（音乐标签）、在线获取元数据（开发中），以及音频降采样与格式转换（开发中）

## 界面预览

<p align="center">
  <img src="../../assets/images/previews/preview01.png" width="100%" alt="Preview 01">
</p>
<p align="center">
  <img src="../../assets/images/previews/preview02.png" width="100%" alt="Preview 02">
</p>

## 主要功能

*   **批量重命名**: 支持读取音频元数据，提供灵活的重命名规则配置
*   **音乐标签编辑**: 支持编辑音频元数据，支持批量修改与保存
*   **在线获取元数据（开发中）**: 从在线数据源获取歌曲标签与封面图片
*   **音频降采样（开发中）**: 无损音频降采样。
*   **文件管理**: 支持拖拽导入文件夹或文件，文件列表筛选与排序
*   **个性化**: 内置亮色与暗色模式，多种MD3色彩模式，支持中英文多语言
*   **响应式布局**: 左侧边栏，窗口较窄时自动收起

## 常量管理

应用程序中使用的所有常量都集中在 `lib/constants.dart` 中管理，便于维护和保持一致性

## 支持格式

**Re:Music** 支持多种常见的音频文件格式：

*   **MP3** (`.mp3`)
*   **FLAC** (`.flac`)
*   **M4A / AAC** (`.m4a`, `.aac`)
*   **OGG / Opus** (`.ogg`, `.opus`)
*   **WMA** (`.wma`)
*   **WavPack** (`.wv`)
*   **DSD** (`.dsf`, `.dff`)

## 技术栈

本项目基于 **Flutter** 构建，主要使用了以下技术与库：

*   **Framework**: [Flutter](https://flutter.dev/) (Windows Desktop)
*   **Language**: Dart
*   **State Management**: `provider`
*   **Core Dependencies**:
    *   `audio_metadata_reader`: 音频元数据读取。
    *   `audiotags`: 音频元数据写入。
    *   `window_manager`: 桌面窗口管理。
    *   `file_picker`: 文件选择器。
    *   `intl`: 国际化。
    *   `provider`: 状态管理。
    *   `path`: 路径处理。

## 快速开始 (Getting Started)

### 环境准备

确保你的开发环境已安装：
*   Flutter SDK (3.38.6+)
*   Visual Studio C++ Tools

### 运行与开发

1.  **克隆项目**
    
    ```bash
    git clone https://github.com/ChuwuYo/Re-Music.git
    cd Re-Music
    ```

2.  **管理依赖**
    *   安装依赖：`flutter pub get`
    *   更新依赖：`flutter pub upgrade`

3.  **运行**
    
    ```bash
    flutter run -d windows
    ```

### 构建发布 (Build)

#### 1. 使用自动化脚本构建 (推荐)
本项目提供了一个 PowerShell 脚本，可自动递增构建号并完成 Release 编译：

```powershell
.\build.ps1 -Version "0.0.1"
```

#### 2. 手动构建便携版 (Portable)

```bash
flutter build windows --release
```

构建产物位于 `build/windows/runner/Release/` 目录下
直接压缩该文件夹即可分发

#### 3. 安装版 (Installer)
如需生成 `.exe` 等安装包，需使用第三方工具（如 NSIS / Inno Setup）对上述便携版文件进行打包
*注：本项目暂未集成自动打包脚本，请手动配置打包工具*

## 许可证

MIT LICENSE

Copyright © 2026 ChuwuYo. All rights reserved.
