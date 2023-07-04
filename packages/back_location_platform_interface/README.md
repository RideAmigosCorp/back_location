# back_location_platform_interface

A common platform interface for the `back_location` plugin.

This interface allows platform-specific implementations of the `back_location` plugin, as well as the plugin itself, to ensure they are supporting the same interface.

# Usage

To implement a new platform-specific implementation of `back_location`, extend `LocationPlatform` with an implementation that performs the platform-specific behavior.
