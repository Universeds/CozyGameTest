# Introduction

Version 0.5.0

Orthogonal Games Framework is a game framework based on the ECS system Stew and makes heavy use of the Buffet Bundle Toolchain provided and maintained by Data Oriented House.

This project serves an example project meant to showcase the usage and guide for different patterns required to use the system for effective game development.

# Overview

Modules

Loaders

- Provides basic boot for both server & client scripts. Each script implements a descendants module require and the functionality for each schedules start calls.

Server

- Group Folder: A folder for a group of related components folders, this folder can also house subgroups.
  - Classes: Module scripts that are meant to build prebuilt objects by creating new entities and adding on default components.
  - Components: A folder for holding component modules related to the group.
  - Jobs: A folder for holding modules that return sandwich jobs for global jobs.
  - Modules: Modules that contain libraries of functions related to the group.
  - Functions: Modules that return functions.
  - Enums: Modules that hold lists of predefined lists of categories.
  - Types.lua: A module that hold exported types used by the group.

Client

- Group Folder: A folder for a group of related components folders, this folder can also house subgroups.
  - Classes: Module scripts that are meant to build prebuilt objects by creating new entities and adding on default components.
  - Components: A folder for holding component modules related to the group.
  - Jobs: A folder for holding modules that return sandwich jobs for global jobs.
  - Modules: Modules that contain libraries of functions related to the group.
  - Functions: Modules that return functions.
  - Enums: Modules that hold lists of predefined lists of categories.
  - Types.lua: A module that hold exported types used by the group.

Shared

- Config: Folder for housing module files that provide configuration for various modules.
- Modules

  

- Global: A script required by most scripts to give quick access to other scripts. Global contains the following items in it's table.
  - Local: a reference to the Server or Client folder depending on where Global is required from.
  - Shared: a reference to the Shared Folder
  - Packages: a reference to the Package module created by Wally
  - Vendor: a reference to the Vendor folder in Replicated Storage
  - Assets: a reference to the Assets folder in Replicated Storage
  - Config: a reference to the Config folder in Replicated Storage
  - Schedules: a reference to all Sandwich schedule objects

# VS Code Snippets

- global: creates a variable for ReplicatedStorage and the required Global module for easy access to all globals.
- package: creates a quick fill variable for requiring a module in the Packages folder. (requires a Global variable set)
