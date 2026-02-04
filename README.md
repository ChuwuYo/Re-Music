# Re:Music

<p align="center">
  <img src="assets/images/Logos/1024.png" width="128" alt="Re:Music Logo">
</p>

<p align="center">
  <b>一款现代化的音频标签管理与批量重命名工具</b>
</p>

---

## 项目简介

**Re:Music**是基于Flutter的原生桌面端音频文件管理工具。它支持读取metadata对音频文件进行批量重命名，以及编辑音频元数据（音乐标签 - 开发中）。

## 主要功能

*   **批量重命名**: 支持读取音频元数据（标题、艺术家、专辑等），提供灵活的重命名规则配置。
*   **音乐标签编辑**: 支持编辑音频元数据（如标题、艺术家、专辑、年份等），支持批量修改与保存。
*   **文件管理**: 支持拖拽导入文件夹或文件，支持文件列表筛选与排序。
*   **个性化**: 内置亮色与暗色模式，支持中英文多语言。
*   **原生体验**: 定制化 Windows 标题栏与窗口控制。

## 技术栈

本项目基于 **Flutter** 构建，主要使用了以下技术与库：

*   **Framework**: [Flutter](https://flutter.dev/) (Windows Desktop)
*   **Language**: Dart
*   **State Management**: `provider`
*   **Core Dependencies**:
    *   `audio_metadata_reader`: 音频元数据读写。
    *   `window_manager`: 桌面窗口管理。
    *   `file_picker`: 文件选择器。
    *   `intl`: 国际化。
    *   `provider`: 状态管理。
    *   `path`: 路径处理。

## 快速开始 (Getting Started)

### 环境准备

确保你的开发环境已安装：
*   Flutter SDK (3.10.0+)
*   Visual Studio C++ Tools

### 运行与开发

1.  **克隆项目**
    ```bash
    git clone https://github.com/your-repo/audiorename.git
    cd audiorename
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
构建产物位于 `build/windows/runner/Release/` 目录下，直接压缩该文件夹即可分发。

#### 2. 安装版 (Installer)
如需生成 `.exe` 等安装包，需使用第三方工具（如 NSIS / Inno Setup）对上述便携版文件进行打包。
*注：本项目暂未集成自动打包脚本，请手动配置打包工具。*

## 许可证

MIT LICENSE

Copyright © 2026 ChuwuYo. All rights reserved.
