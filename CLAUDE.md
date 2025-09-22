# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a comprehensive FiveM PvP (Player vs Player) gamemode resource built in Lua, featuring multiple competitive game modes, extensive customization systems, and player management tools. The project is designed as a complete PvP server experience with various zones, weapons systems, inventory management, and social features.

## Project Structure

### Core Architecture
```
gamemode/
├── fxmanifest.lua          # Resource manifest and dependencies
├── sh_init.lua             # Shared initialization with security layer
├── base/                   # Core foundation files
│   ├── cl_base.lua         # Client-side base functionality
│   ├── sv_base.lua         # Server-side base functionality
│   └── cl_safezone.lua     # Safezone client logic
├── config/                 # Configuration files
├── core/                   # Main feature modules (60+ modules)
├── modules/                # Additional systems
├── ui/                     # Web-based user interface
├── data/                   # Game data and metadata
└── stream/                 # Asset streaming files
```

### Key Components

#### Game Modes
- **FFA (Free For All)**: Multi-map deathmatch with configurable limits
- **Gunrace**: Progressive weapon-based racing gameplay
- **Capture Mode**: Territory-based competitive gameplay
- **Military Zone**: Restricted high-intensity combat areas
- **Dark Zone**: High-risk PvP areas with special rules
- **Red Zone**: Active combat zones with specific mechanics

#### Core Systems
- **Inventory System**: Advanced item management with UI
- **Weapon System**: Custom weapons with modifications
- **Vehicle System**: Vehicle spawning and customization
- **Crew System**: Team/guild functionality
- **Leaderboard**: Player statistics and rankings
- **Shop System**: In-game economy and purchases
- **Badge System**: Achievement and recognition system
- **Effect System**: Visual and gameplay effects
- **Farm System**: AFK detection and resource farming
- **Admin Tools**: Comprehensive administration interface

#### Security Features
- **Anti-cheat**: Built-in protection systems
- **Event Protection**: Encrypted event system with blacklisting
- **Whitelist System**: Player access control
- **Detection Systems**: Various exploit detection modules

## File Organization

### Naming Conventions
- `sh_*.lua` - Shared files (client + server)
- `cl_*.lua` - Client-side only files
- `sv_*.lua` - Server-side only files
- `config/*.lua` - Configuration files

### Loading Order
1. Dependencies (`@library`, `@kaykl_core`, `@oxmysql`)
2. Shared scripts (`sh_init.lua`)
3. Config files
4. Base system files
5. Items definitions
6. Modules (playersManagement, etc.)
7. Core features (alphabetically loaded)

## Development Guidelines

### Code Patterns
- **Event-Driven Architecture**: Heavy use of FiveM events for communication
- **Modular Design**: Each feature isolated in its own core module
- **Security-First**: All custom events are encrypted and validated
- **Configuration-Based**: Extensive use of config files for customization

### Key Dependencies
- `oxmysql` / `mysql-async` - Database operations
- `library` - Custom library dependency
- `kaykl_core` - Core framework dependency
- `spawnmanager` - Player spawning management

### Security Implementation
The `sh_init.lua` file implements a comprehensive security layer:
- Event encryption using time-based keys
- Blacklisted event protection
- Anti-exploitation measures for event handlers
- Server-side validation for all player actions

### UI System
- Web-based interface using HTML/CSS/JavaScript
- Bootstrap 5 framework for responsive design
- jQuery for DOM manipulation
- Multiple specialized interfaces (inventory, shop, leaderboard, etc.)
- FontAwesome icons and Google Fonts integration

## Development Environment

### File Structure
- **226 Lua files** - Core game logic
- **48 JavaScript files** - UI functionality
- **Multiple CSS files** - Interface styling
- **Asset files** - Images, sounds, and 3D models

### Key Configuration Files
- `config/safezone_config.lua` - Safe zone definitions
- `config/shop.lua` - Shop items and pricing
- `core/inventory/sh_config.lua` - Item definitions and properties

### Database Integration
- MySQL/MariaDB backend for persistent data
- Player statistics and inventory storage
- Leaderboard and achievement tracking
- Economic transaction logging

## Important Notes

### Security Considerations
- The codebase includes sophisticated anti-cheat and event protection
- All custom events use encryption to prevent exploitation
- Server-side validation is enforced for critical operations
- Player actions are logged and monitored

### Performance
- Modular loading system for efficient resource usage
- Optimized client-side loops and threading
- Database queries use prepared statements
- Asset streaming for reduced memory footprint

### Customization
- Extensive configuration options for all game modes
- Modular architecture allows easy feature addition/removal
- Separate UI components for interface customization
- Map-based configurations for different scenarios

## Getting Started

1. Ensure all dependencies are installed and configured
2. Configure database connection in MySQL resource
3. Adjust configuration files in `config/` directory
4. Customize game modes in respective `core/` modules
5. Modify UI elements in `ui/` directory as needed
6. Test security systems and event handlers
7. Configure admin permissions and whitelist

## Architecture Highlights

- **Event Security**: Advanced encryption system for network events
- **Modular Core**: 60+ independent feature modules
- **Database Integration**: Persistent player data and statistics
- **Multi-Mode Support**: Various competitive game modes
- **Admin Tools**: Comprehensive server management
- **UI Framework**: Modern web-based interface system
- **Asset Management**: Efficient streaming and loading

This gamemode represents a full-featured PvP server solution with enterprise-level security, extensive customization options, and professional-grade architecture suitable for large-scale FiveM communities.