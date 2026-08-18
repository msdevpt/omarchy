# Porting Omarchy Shell from Hyprland to Niri

This document outlines the changes needed to port the Omarchy shell from Hyprland to Niri.

## Overview

The Omarchy shell currently uses Hyprland-specific APIs for:
- Workspace management (`Hyprland.workspaces`)
- Focused workspace tracking (`Hyprland.focusedWorkspace`)
- Keyboard layout management (`hyprctl switchxkblayout`)
- Window management (`ToplevelManager`)

Niri provides similar but different APIs for these features.

## Required Changes

### 1. Core Shell Configuration

**File: `shell.qml`**
- Remove `import Quickshell.Hyprland`
- Add `import Quickshell.Niri` (if available) or use generic Quickshell APIs

### 2. Workspaces Widget (`plugins/bar/widgets/Workspaces.qml`)

**Current Hyprland dependencies:**
- `Hyprland.workspaces.values` - Get all workspaces
- `Hyprland.focusedWorkspace` - Get focused workspace
- `hyprctl dispatch hl.dsp.focus(...)` - Focus workspace

**Niri equivalents:**
- Use `Niri.workspaces` or similar Niri workspace API
- Use `Niri.focusedWorkspace` or similar
- Use `niri msg action focus-workspace <id>` or Niri's workspace switching API

### 3. Keyboard Layout Widget (`plugins/bar/widgets/KeyboardLayout.qml`)

**Current Hyprland dependencies:**
- `Hyprland` events for keyboard layout changes
- `hyprctl switchxkblayout <keyboard> next` - Switch keyboard layout
- `hyprctl -j devices` - Get keyboard devices

**Niri equivalents:**
- Use systemd-localed for keyboard layout (Niri reads from systemd-localed)
- Use `niri msg action set-keyboard-layout` or similar
- Use `niri msg --json keyboards` or similar IPC commands

### 4. Active Window Widget (`plugins/bar/widgets/ActiveWindow.qml`)

**Current Hyprland dependencies:**
- `ToplevelManager.activeToplevel` - Get active window

**Niri equivalents:**
- Use `Niri.focusedWindow` or similar Niri window API
- Use `niri msg --json focused-window` or similar IPC commands

### 5. Hyprland-Specific Services

**Files to check:**
- `plugins/services/nightlight/Service.qml` - Uses `hyprctl hyprsunset`
- `plugins/panels/monitor/Panel.qml` - Uses `hyprctl keyword monitor`
- `plugins/services/idle/Service.qml` - Uses `Hyprland` events

## Implementation Strategy

### Phase 1: Basic Porting
1. Replace Hyprland imports with Niri equivalents
2. Update workspace management to use Niri APIs
3. Test basic functionality

### Phase 2: Advanced Features
1. Port keyboard layout management
2. Port window management
3. Update any remaining Hyprland-specific services

### Phase 3: Integration Testing
1. Test all ported features
2. Ensure backward compatibility
3. Optimize performance

## Testing

After porting, test:
- Workspace switching
- Keyboard layout switching
- Active window display
- Bar widget functionality
- Plugin loading and management

## Resources

- [Niri Documentation](https://github.com/YaLTeR/niri/wiki)
- [Quickshell Niri Integration](https://github.com/YaLTeR/niri/wiki/Integrating-niri)
- [Niri IPC Commands](https://github.com/YaLTeR/niri/wiki/IPC)

## Notes

- Niri may have different API naming conventions
- Some Hyprland-specific features may not have direct Niri equivalents
- Consider using Niri's IPC commands for programmatic control
- Test on actual Niri system to verify compatibility