#include "flutter_window.h"

#include <optional>

#include "flutter/generated_plugin_registrant.h"

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());
  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  window_channel_ =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          flutter_controller_->engine()->messenger(), "remusic/window",
          &flutter::StandardMethodCodec::GetInstance());

  window_channel_->SetMethodCallHandler(
      [this](const flutter::MethodCall<flutter::EncodableValue>& call,
             std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>>
                 result) {
        HWND hwnd = GetHandle();
        if (!hwnd) {
          result->Error("no_window", "Window handle is null");
          return;
        }

        const std::string& method = call.method_name();
        if (method == "minimize") {
          ShowWindow(hwnd, SW_MINIMIZE);
          result->Success();
          return;
        }

        if (method == "toggleMaximize") {
          ShowWindow(hwnd, IsZoomed(hwnd) ? SW_RESTORE : SW_MAXIMIZE);
          result->Success();
          return;
        }

        if (method == "close") {
          PostMessage(hwnd, WM_CLOSE, 0, 0);
          result->Success();
          return;
        }

        if (method == "startDrag") {
          ReleaseCapture();
          SendMessage(hwnd, WM_NCLBUTTONDOWN, HTCAPTION, 0);
          result->Success();
          return;
        }

        if (method == "isMaximized") {
          result->Success(flutter::EncodableValue(IsZoomed(hwnd) ? true : false));
          return;
        }

        if (method == "getHandle") {
          const int64_t handle_value = reinterpret_cast<int64_t>(hwnd);
          result->Success(flutter::EncodableValue(handle_value));
          return;
        }

        result->NotImplemented();
      });

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  switch (message) {
    case WM_GETMINMAXINFO:
      return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
    case WM_ERASEBKGND:
      return 1;
    case WM_ENTERSIZEMOVE:
      in_size_move_ = true;
      break;
    case WM_EXITSIZEMOVE:
      in_size_move_ = false;
      break;
  }

  std::optional<LRESULT> pre_base_result;
  if (message == WM_SIZE) {
    pre_base_result = Win32Window::MessageHandler(hwnd, message, wparam, lparam);
  }

  const bool should_force_redraw =
      flutter_controller_ &&
      (message == WM_SIZE || message == WM_SIZING || message == WM_MOVING ||
       message == WM_EXITSIZEMOVE || in_size_move_);

  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      if (should_force_redraw) {
        flutter_controller_->ForceRedraw();
      }
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  const LRESULT base_result =
      pre_base_result.value_or(
          Win32Window::MessageHandler(hwnd, message, wparam, lparam));

  if (should_force_redraw) {
    flutter_controller_->ForceRedraw();
  }

  return base_result;
}
