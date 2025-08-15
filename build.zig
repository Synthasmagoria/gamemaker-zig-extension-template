const std = @import("std");
const builtin = @import("builtin");
const semantic_version = std.SemanticVersion{.major = 0, .minor = 1, .patch = 0};
const library_name = "library";
const linux_extension_directory: ?[]const u8 = null;
const windows_extension_directory: ?[]const u8 = null;
const linux_move_command = "cp";
const windows_move_command = "move";

fn getLibraryPath(alloc: std.mem.Allocator, os_tag: std.Target.Os.Tag, ver: std.SemanticVersion) ![]const u8 {
    return switch (os_tag) {
        .windows => {
            return try std.fmt.allocPrint(alloc, "zig-out/lib/{s}.dll", .{library_name});
        },
        .linux => {
            const version_string = try std.fmt.allocPrint(alloc, "{d}.{d}.{d}", .{ver.major, ver.minor, ver.patch});
            return try std.fmt.allocPrint(alloc, "zig-out/lib/lib{s}.so.{s}", .{library_name, version_string});
        },
        else => {
            return error.OsNotAccountedFor;
        }
    };
}

fn moveFile(alloc: std.mem.Allocator, move_command: []const u8, from: []const u8, to: []const u8) !void {
    const command = &[_][]const u8{move_command, from, to};
    var proc = std.process.Child.init(command, alloc);
    try proc.spawn();
}

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const lib = b.addSharedLibrary(.{
        .name = library_name,
        .root_source_file = b.path("src/lib.zig"),
        .target = target,
        .optimize = optimize,
        .version = semantic_version,
    });
    b.installArtifact(lib);

    // Pass -Dcopy to copy the built shared library to relative path set in 'extension_directory'
    if (b.option(bool, "copy", "Copies the built libarary to os target extension directory: ") orelse false) {
        const errOut = std.io.getStdErr().writer();
        const libpath = getLibraryPath(b.allocator, target.result.os.tag, semantic_version) catch {
            try errOut.print("Copy Error: Couldn't find OS library path", .{});
            @panic("Copy Error: Couldn't find OS library path");
        };
        switch (builtin.os.tag) {
            .windows => {
                if (windows_extension_directory) |dest_dir| {
                    try moveFile(b.allocator, windows_move_command, libpath, dest_dir);
                } else {
                    try errOut.print("Copy Error: Set windows extension directory\n", .{});
                }
            },
            .linux => {
                if (linux_extension_directory) |dest_dir| {
                    try moveFile(b.allocator, linux_move_command, libpath, dest_dir);
                } else {
                    try errOut.print("Copy Error: Set linux extension directory\n", .{});
                }
            },
            else => {
                try errOut.print("Copy Error: OS not accounted for", .{});
                @panic("Copy Error: os not accounted for");
            }
        }
    }
}
